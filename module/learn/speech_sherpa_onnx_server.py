import json
import queue
import sys
import difflib
import os
import socket
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
HOST = "0.0.0.0"
PORT = 2701
MODEL_PATH_SHERPA_ONNX = os.environ.get("dirPathPythonSherpaOnnxModel")
SAMPLE_RATE = 16000
# ========== 参数解析 ==========

parser = argparse.ArgumentParser(description="实时语音识别：SherpaOnnx")
parser.add_argument("--model_path", type=str, default=f"{MODEL_PATH_SHERPA_ONNX}", help="模型路径")
parser.add_argument("--port", type=str, default=f"{PORT}", help="服务器端口")
# parser.add_argument("--peference_text", type=str, help="参考对比文本")
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

def notice_client(conn,result):
    try:
        msg = result + "\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception as e:
        speech_utils.print_overwrite("notice_client failed:", e,"\n")

def send_server_close(conn):
    notice_client(conn,"SERVER:close")

def send_server_reply_receive_heartbeat(conn):
    notice_client(conn,"SERVER:reply receive heartbeat")

def send_server_request_stop_record(conn):
    notice_client(conn,"SERVER:request client stop to record")

def recognition_end(conn, tips):
    if not tips:
        speech_utils.print_overwrite(tips)
    send_server_close(conn)
    time.sleep(0.1)
    try:
        conn.shutdown(socket.SHUT_RDWR)
        conn.close()
    except Exception as e:
        speech_utils.print_overwrite("close connect failed:", e,"\n")

def main():
    # speech_utils.play_audio(args.peference_audio)
    # speech_utils.print_overwrite("Loading Sherpa Onnx model ...");

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((HOST, PORT))
    server.listen(1)

    #构建 Denoiser
    #构建降噪引擎
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
        provider="coreml",  # cpu 780M 环境下尝试 "cuda" 或 "rocm"，若报错改用 "cpu"
        debug=False
    )

    # 初始化 AGC 实例
    agc = speech_utils.SimpleAGC(target_rms=0.18, max_gain=8.0)

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
    def recognition_worker(stream,agc,denoiser):
        while True:
            samples = audio_queue.get() # 阻塞等待新音频
            
            # 收到停止信号（None），跳出循环
            if samples is None:
                print("收到停止信号，正在关闭线程...")
                audio_queue.task_done() # 可选：通知任务已完成
                break

            #降噪
            result = denoiser(samples, SAMPLE_RATE)
            samples = np.asarray(result.samples, dtype=np.float32)

            # AGC 优化识别效果,无论你离麦克风近还是远，识别效果都会变得稳定
            samples = agc.process(samples)

            # 喂入识别器
            stream.accept_waveform(16000, samples)

    def on_recognition_equal(ref):
        print("\nRecognition successful. Exiting.")
        sys.exit(0)

    while True:
        is_operation_key = True
        speech_utils.print_overwrite(f"Waiting for client connect to {HOST}:{args.port}")
        conn, addr = server.accept()
        prefix_strat_recognize="CLIENT:strat_recognize"

        while True:
            data = conn.recv(4096)
            # data = conn.recv(480 * 2)
            # data = conn.recv(512)
            if data:
                raw_text = data.decode('utf-8')
                if raw_text.startswith(prefix_strat_recognize):
                    peference_text = raw_text.removeprefix(prefix_strat_recognize)
                    break
                elif "CLIENT:heartbeat" in data.decode("utf-8", errors="ignore"):
                    send_server_reply_receive_heartbeat(conn)
                    continue

        speech_utils.print_overwrite("Opening microphone")

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
        # threading.Thread(target=recognition_worker, args=(stream,agc,denoiser), daemon=True).start()
        thread_recognizer = threading.Thread(target=recognition_worker, args=(stream, agc, denoiser), daemon=True)
        thread_recognizer.start()
        
        last_text = ""
        last_active_time = time.time()
        
        speech_utils.print_overwrite("Please start reading aloud.............................")

        try:
            while True:
                # 6. 在主线程不断解码并获取结果
                while recognizer.is_ready(stream):
                    recognizer.decode_stream(stream)
                
                result = recognizer.get_result(stream)
                
                text = result if isinstance(result, str) else result.text
                if text and text != last_text:
                    if speech_utils.is_exact_match(peference_text, text):
                        print("\nRecognition successful. Exiting.")
                        break
                    if speech_utils.is_recognition_over(text):
                        print("\nRecognition cancel. Exiting.")
                        break
                    if speech_utils.last_two_words_match(peference_text,text):
                        recognizer.reset(stream)
                        last_text = ""
                        continue
                    notice_client(conn,text)

                    new_part = text[len(last_text):]
                    if new_part:
                        if speech_utils.is_exact_match(peference_text, new_part):
                            print("\nRecognition successful. Exiting.")
                            break
                        if speech_utils.is_recognition_over(new_part):
                            print("\nRecognition cancel. Exiting.")
                            break
                        if speech_utils.last_two_words_match(peference_text,new_part):
                            recognizer.reset(stream)
                            last_text = ""
                            continue

                    result_lines = speech_utils.highlight_diff_multi(peference_text, text, on_recognition_equal)
                    result_lines.append(text.lower())
                    speech_utils.print_multi_overwrite(result_lines)

                    last_text = text
                    last_active_time = time.time()

                    #断句
                    if recognizer.is_endpoint(stream):
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
            recognition_end(conn,"")
            # 停止识别线程
            audio_queue.put(None) 
            thread_recognizer.join()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        speech_utils.print_overwrite("Recognition force cancel\n") 
        sys.exit(1)

