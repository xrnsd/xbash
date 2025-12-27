import json
import queue
import sys
import difflib
import os
import sounddevice as sd
from vosk import Model, KaldiRecognizer, SetLogLevel
from adaptive_vosk_recognizer import AdaptiveGrammarRecognizer
import speech_utils
import argparse

# You can set log level to 0 to enable debug messages
SetLogLevel(-1)

# ========== 配置 ==========
MODEL_PATH_VOSK = os.environ.get("dirPathPythonVoskModel")
SAMPLE_RATE = 16000
# ========== 读取终端参数 ==========

parser = argparse.ArgumentParser(description="实时语音识别：vosk")
parser.add_argument("--model_path", type=str, default=f"{MODEL_PATH_VOSK}", help="模型路径")
parser.add_argument("--peference_audio", type=str, help="音频文件路径")
parser.add_argument("--peference_text", type=str, help="参考对比文本")
args = parser.parse_args()

# ========== ANSI颜色 ==========

RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"
# =======================

q = queue.Queue()
def audio_callback(indata, frames, time, status):
    if status:
        print(status, file=sys.stderr)
    q.put(bytes(indata))

def main():
    # speech_utils.print_overwrite("Reference text:",f"{YELLOW}{REFERENCE_TEXT}{RESET}")
    while True:
        speech_utils.play_audio_blocked(args.peference_audio)
        speech_utils.print_overwrite(f"{RED}→{RESET} play audio , {RED}↓{RESET} start to practice, {RED}←{RESET} cancel practice")
        keyStart = speech_utils.get_key()
        #if key == '\x1b[A': #Up
        #if key == '\x1b[B': #Down
        #if key == '\x1b[D': #Left
        #if key == '\x1b[C': #Right
        if keyStart == '\x1b[B':
            speech_utils.print_overwrite("Please start reading aloud")
            break
        elif keyStart == '\x1b[D':
            print("\nRecognition cancel")
            sys.exit(1)
    
    agc = speech_utils.PydubAGC(sample_rate=SAMPLE_RATE, target_dbfs=-3.0)

    asr = AdaptiveGrammarRecognizer(
        model_path=args.model_path,
        sample_rate=SAMPLE_RATE,
        reference_text=args.peference_text
    )

    with sd.RawInputStream(
        samplerate=SAMPLE_RATE,
        blocksize=8000,
        dtype="int16",
        channels=1,
        callback=audio_callback
    ):
        while True:
            data = q.get()
            data = speech_utils.process_for_vosk_df(data);#deepfilternet降噪
            data = agc.process_for_vosk(data) # AGC 优化识别效果: 无论你离麦克风近还是远，识别效果都会变得稳定
            result = asr.accept_audio(data)
            if result:
                if result.get("success"):
                    speech_utils.print_overwrite("Partial Result Recognition successful. Exiting.\n")
                    sys.exit(0)
                speech_utils.print_overwrite(speech_utils.highlight_diff(args.peference_text, result.get("text", "")))

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        speech_utils.print_overwrite("Recognition force cancel\n") 
        sys.exit(1)
