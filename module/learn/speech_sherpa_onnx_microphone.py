import json
import queue
import sys
import difflib
import os
import re
import sounddevice as sd
import tty
import time
import argparse
import pyaudio
import sherpa_onnx
import numpy as np
import speech_utils
import threading


# ========== 配置 ==========
MODEL_PATH_SHERPA_ONNX = os.environ.get("dirPathPythonSherpaOnnxkModel")
SAMPLE_RATE = 16000
# ========== 参数解析 ==========

parser = argparse.ArgumentParser(description="实时语音识别：SherpaOnnx")
parser.add_argument("--model_path", type=str, default=f"{MODEL_PATH_SHERPA_ONNX}", help="模型路径")
parser.add_argument("--peference_audio", type=str, help="音频文件路径")
parser.add_argument("--peference_text", type=str, help="参考对比文本")
args = parser.parse_args()
# ========== ANSI颜色 ==========

RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"

# ====================

q = queue.Queue()
def audio_callback(indata, frames, time, status):
    if status:
        print(status, file=sys.stderr)
    q.put(bytes(indata))

def main():
    speech_utils.play_audio(args.peference_audio)
    speech_utils.print_overwrite("Loading model ...");

    #构建 Denoiser
    gtcrn_config = sherpa_onnx.OfflineSpeechDenoiserGtcrnModelConfig(
        model=f"{args.model_path}/gtcrn_simple.onnx"
    )
    model_config = sherpa_onnx.OfflineSpeechDenoiserModelConfig(
        gtcrn=gtcrn_config,
        num_threads=2,
        provider="cpu",
    )
    denoiser_config = sherpa_onnx.OfflineSpeechDenoiserConfig(
        model=model_config
    )
    denoiser = sherpa_onnx.OfflineSpeechDenoiser(denoiser_config)

    #构建 OnlineRecognizer
    recognizer = sherpa_onnx.OnlineRecognizer.from_transducer(
        encoder=f"{args.model_path}/encoder.int8.onnx",
        decoder=f"{args.model_path}/decoder.int8.onnx",
        joiner=f"{args.model_path}/joiner.int8.onnx",
        tokens=f"{args.model_path}/tokens.txt",
        num_threads=2,
        sample_rate=SAMPLE_RATE,
        feature_dim=80,
        decoding_method="modified_beam_search",
        max_active_paths=4,
        rule1_min_trailing_silence=2.4, # 强制断句时间
        rule2_min_trailing_silence=0.8, # 有字后的停顿时间
        rule3_min_utterance_length=20,  # 单句最长时间
        provider="cpu",  # 780M 环境下尝试 "cuda" 或 "rocm"，若报错改用 "cpu"
        debug=False
    )

    # 初始化 AGC 实例
    agc = speech_utils.SimpleAGC(target_rms=0.18, max_gain=8.0)

    # vad = speech_utils.AdvancedVAD(sample_rate=16000,
    #               frame_ms=20,
    #               enter_threshold=0.03,
    #               exit_threshold=0.015,
    #               min_speech_ms=100,
    #               window_ms=100)

    # 4. 创建识别流
    stream = recognizer.create_stream()

    # 5. 初始化 PyAudio
    pa = pyaudio.PyAudio()

    # 定义麦克风回调函数 (高效处理数据)
    audio_queue = queue.Queue()
    def callback(in_data, frame_count, time_info, status):
        # 将二进制 PCM16 转换为 float32 归一化数据
        samples = np.frombuffer(in_data, dtype=np.int16).astype(np.float32) / 32768.0

        audio_queue.put(samples.copy())
   
        return (None, pyaudio.paContinue)

    # 3. 独立的识别线程
    def recognition_worker(stream,vad,denoiser):
        while True:
            samples = audio_queue.get() # 阻塞等待新音频

            #降噪
            result = denoiser(samples, SAMPLE_RATE)
            samples = np.asarray(result.samples, dtype=np.float32)

            # #讲话
            # if vad.is_speech(samples):
            
            # AGC 优化识别效果,无论你离麦克风近还是远，识别效果都会变得稳定
            samples = agc.process(samples)

            # 喂入识别器
            stream.accept_waveform(16000, samples)

    def on_recognition_equal(ref):
        print("\nRecognition successful. Exiting.")
        sys.exit(0)

    while True:
        speech_utils.print_overwrite(f"{RED}→{RESET} play audio , {RED}↓{RESET} start to practice, {RED}←{RESET} cancel practice")
        keyStart = speech_utils.get_key()
        #if key == '\x1b[A': #Up
        #if key == '\x1b[B': #Down
        #if key == '\x1b[D': #Left
        #if key == '\x1b[C': #Right
        #if key == 'ctrl+c':   #Ctrl+C
        if keyStart == '\x1b[B':
            speech_utils.print_overwrite(f"{YELLOW}{args.peference_text}{RESET}\nPlease start to read aloud ...");
            break
        elif keyStart == '\x1b[C':
            speech_utils.play_audio_blocked(args.peference_audio)
        elif keyStart == '\x1b[D' or keyStart == "ctrl+c":
            print("\nRecognition cancel")
            sys.exit(1)

    # 打开录音流 (16kHz, 单声道, 16bit)
    mic_stream = pa.open(
        format=pyaudio.paInt16,
        channels=1,
        rate=SAMPLE_RATE,
        input=True,
        frames_per_buffer=8000, # 每次处理 1600=0.1 秒音频
        stream_callback=callback
    )

    # 打开识别线程
    threading.Thread(target=recognition_worker, args=(stream,vad,denoiser), daemon=True).start()

    last_text = ""
    last_active_time = time.time()
    try:
        while True:
            # 6. 在主线程不断解码并获取结果
            while recognizer.is_ready(stream):
                recognizer.decode_stream(stream)
            
            result = recognizer.get_result(stream)
            
            # 2025 API 适配：检查 result 是否为字符串或对象
            text = result if isinstance(result, str) else result.text

            if text and text != last_text:
                if speech_utils.is_exact_match(args.peference_text, text):
                    print("\nRecognition successful. Exiting.")
                    sys.exit(0)
                if speech_utils.is_recognition_over(text):
                    print("\nRecognition cancel. Exiting.")
                    sys.exit(0)
                if speech_utils.last_two_words_match(args.peference_text,text):
                    recognizer.reset(stream)
                    last_text = ""
                    continue

                new_part = text[len(last_text):]
                if new_part:
                    if speech_utils.is_exact_match(args.peference_text, new_part):
                        print("\nRecognition successful. Exiting.")
                        sys.exit(0)
                    if speech_utils.is_recognition_over(new_part):
                        print("\nRecognition cancel. Exiting.")
                        sys.exit(0)
                    if speech_utils.last_two_words_match(args.peference_text,new_part):
                        recognizer.reset(stream)
                        last_text = ""
                        continue

                speech_utils.print_multi_overwrite([
                    speech_utils.highlight_diff(args.peference_text, text, on_recognition_equal),
                    text.lower()
                ])
                last_text = text
                last_active_time = time.time()


            #断句
            if recognizer.is_endpoint(stream):
                recognizer.reset(stream)
                last_text = ""
                continue

            #句子累积过长
            if speech_utils.is_too_long(text):
                recognizer.reset(stream)
                last_text = ""
                continue

            # 如果超过 1.5 秒没有新字产出，手动断句
            if time.time() - last_active_time > 2.2 and last_text != "":
                recognizer.reset(stream)
                last_text = ""
                continue

                
    except KeyboardInterrupt:
        speech_utils.print_overwrite("Recognition force cancel\n") 
    finally:
        mic_stream.stop_stream()
        mic_stream.close()
        pa.terminate()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        speech_utils.print_overwrite("Recognition force cancel\n") 
        sys.exit(1)

