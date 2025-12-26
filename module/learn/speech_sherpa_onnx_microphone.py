import json
import queue
import sys
import difflib
import os
import json
import re
import string
# 禁止 SDL 日志输出
os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"
import pygame
import sounddevice as sd
import tty
import termios
import time
import argparse
import pyaudio
import sherpa_onnx
import numpy as np
import re
from agc import SimpleAGC

# ========== 配置 ==========
MODEL_PATH_SHERPA_ONNX = os.environ.get("dirPathPythonSherpaOnnxkModel")
SAMPLE_RATE = 16000
# ========== 参数解析 ==========

parser = argparse.ArgumentParser(description="实时语音识别：SherpaOnnx")
parser.add_argument("--model_path", type=str, default=f"{MODEL_PATH_SHERPA_ONNX}", help="模型路径")
parser.add_argument("--peference_audio", type=str, help="音频文件路径")
parser.add_argument("--peference_text", type=str, help="参考对比文本")
args = parser.parse_args()

# ========== ANSI 颜色 ==========

RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"

# ====================

def last_two_words_match(a: str, b: str) -> bool:
    def norm(s):
        s = re.sub(r"[^\w\s]", "", s)
        return s.lower().strip().split()

    wa = norm(a)
    wb = norm(b)

    return len(wa) >= 2 and len(wb) >= 2 and wa[-2:] == wb[-2:]

def get_key():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch1 = sys.stdin.read(1)
        if ch1 == '\x1b':  # ESC 开头的控制序列
            ch2 = sys.stdin.read(1)
            ch3 = sys.stdin.read(1)
            return ch1 + ch2 + ch3
        return ch1
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

def play_audio(file_path):
    pygame.mixer.init()
    pygame.mixer.music.load(file_path)
    pygame.mixer.music.play()

    result = "/".join(file_path.split("/")[-4:])
    print_overwrite(f"playing : {YELLOW}{result}{RESET}")


def play_audio_blocked(file_path):
    pygame.mixer.init()
    result = "/".join(file_path.split("/")[-4:])

    try:
        pygame.mixer.music.load(file_path)
        pygame.mixer.music.play()
        print_overwrite(f"playing : {YELLOW}{result}{RESET} , to press Ctrl+C to exit play")

        while pygame.mixer.music.get_busy():
            time.sleep(0.1) 
            
        print_overwrite("play finish")

    except KeyboardInterrupt:
        print_overwrite("play is stoping...")
        pygame.mixer.music.stop()
        
    finally:
        pygame.mixer.quit()

def clear_screen():
    os.system("cls" if os.name == "nt" else "clear")

def print_overwrite(*args, sep=' ', end='', flush=True):
    text = sep.join(str(a) for a in args)
    print(f"\r\033[K{text}", end=end, flush=flush)

def is_exact_match(reference: str, recognized: str) -> bool:
    ref = normalize_text(reference)
    rec = normalize_text(recognized)

    if rec == ref:
        return True
    if (ref + " ") in rec:
        return True
    if (" " + ref) in rec:
        return True

    return False

def is_recognition_over(reference: str) -> bool:
    if reference.endswith("recognition over"):
        return True
    if reference.endswith("text over"):
        return True

    return False

def normalize_text(text: str) -> str:
    # 转小写
    text = text.lower()
    # 只保留 字母 / 数字 / 空格
    text = re.sub(r"[^a-z0-9\s]", "", text)
    # 合并多空格
    text = " ".join(text.split())
    return text

q = queue.Queue()

def audio_callback(indata, frames, time, status):
    if status:
        print(status, file=sys.stderr)
    q.put(bytes(indata))

def highlight_diff(reference, recognized):
    ref = normalize_text(reference)
    rec = normalize_text(recognized)
    ref_words = ref.split()
    rec_words = rec.split()

    matcher = difflib.SequenceMatcher(None, ref_words, rec_words)
    output = []

    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == "equal":
            output.extend(rec_words[j1:j2])
        elif tag == "insert":
            output.extend([f"{RED}{w}{RESET}" for w in rec_words[j1:j2]])
        elif tag == "replace":
            output.extend([f"{RED}{w}{RESET}" for w in rec_words[j1:j2]])
        elif tag == "delete":
            output.extend([f"{GREEN}{w}{RESET}" for w in ref_words[i1:i2]])

    return " ".join(output)

def main():
    play_audio(args.peference_audio)

    recognizer = sherpa_onnx.OnlineRecognizer.from_transducer(
        encoder=f"{args.model_path}/encoder.int8.onnx",
        decoder=f"{args.model_path}/decoder.int8.onnx",
        joiner=f"{args.model_path}/joiner.int8.onnx",
        tokens=f"{args.model_path}/tokens.txt",
        num_threads=6,
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
    agc = SimpleAGC(target_rms=0.18, max_gain=8.0)

    # 4. 创建识别流
    stream = recognizer.create_stream()

    # 5. 初始化 PyAudio
    pa = pyaudio.PyAudio()

    # 定义麦克风回调函数 (高效处理数据)
    def callback(in_data, frame_count, time_info, status):
        # 将二进制 PCM16 转换为 float32 归一化数据
        samples = np.frombuffer(in_data, dtype=np.int16).astype(np.float32) / 32768.0

        # 2. 应用手动 AGC 优化识别效果
        # 无论你离麦克风近还是远，识别效果都会变得稳定
        optimized_samples = agc.process(samples)

        # 喂入识别器
        stream.accept_waveform(16000, optimized_samples)
        return (None, pyaudio.paContinue)

    while True:
        print_overwrite(f"{RED}→{RESET} play audio , {RED}↓{RESET} start to practice, {RED}←{RESET} cancel practice")
        keyStart = get_key()
        #if key == '\x1b[A': #Up
        #if key == '\x1b[B': #Down
        #if key == '\x1b[D': #Left
        #if key == '\x1b[C': #Right
        if keyStart == '\x1b[B':
            break
        elif keyStart == '\x1b[C':
            play_audio_blocked(args.peference_audio)
        elif keyStart == '\x1b[D':
            print("\nRecognition cancel")
            sys.exit(1)

    # 打开录音流 (16kHz, 单声道, 16bit)
    mic_stream = pa.open(
        format=pyaudio.paInt16,
        channels=1,
        rate=16000,
        input=True,
        frames_per_buffer=1600, # 每次处理 0.1 秒音频
        stream_callback=callback
    )

    print(f"\n{YELLOW}{args.peference_text}{RESET}")
    
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
                if is_exact_match(args.peference_text, text):
                    print("\nRecognition successful. Exiting.")
                    sys.exit(0)
                if is_recognition_over(text):
                    print("\nRecognition cancel. Exiting.")
                    sys.exit(0)
                if last_two_words_match(args.peference_text,text):
                    recognizer.reset(stream)
                    last_text = ""
                    continue
                
                new_part = text[len(last_text):]
                if new_part:
                    if is_exact_match(args.peference_text, new_part):
                        print("\nRecognition successful. Exiting.")
                        sys.exit(0)
                    if is_recognition_over(new_part):
                        print("\nRecognition cancel. Exiting.")
                        sys.exit(0)
                    if last_two_words_match(args.peference_text,new_part):
                        recognizer.reset(stream)
                        last_text = ""
                        continue
                    # print_overwrite(highlight_diff(args.peference_text, new_part))
                
                print_overwrite(highlight_diff(args.peference_text, text))
                last_text = text
                last_active_time = time.time()
            
            #断句
            if recognizer.is_endpoint(stream):
                recognizer.reset(stream)
                last_text = ""

            # 如果超过 1.5 秒没有新字产出，手动断句
            if time.time() - last_active_time > 1.5 and last_text != "":
                recognizer.reset(stream)
                last_text = ""

                
    except KeyboardInterrupt:
        print_overwrite("Recognition force cancel\n") 
    finally:
        mic_stream.stop_stream()
        mic_stream.close()
        pa.terminate()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print_overwrite("Recognition force cancel\n") 
        sys.exit(1)

