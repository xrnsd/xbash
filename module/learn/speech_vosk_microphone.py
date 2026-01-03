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

audio_queue = queue.Queue()
def audio_callback(indata, frames, time, status):
    if status:
        print(status, file=sys.stderr)
        return
    audio_queue.put(indata[:, 0].copy())

def on_recognition_equal(ref):
    print("\nRecognition successful. Exiting.")
    sys.exit(0)

def main():
    speech_utils.print_overwrite(f"{YELLOW}{args.peference_text}{RESET}")
    while True:
        speech_utils.play_audio_blocked(args.peference_audio)
        speech_utils.print_overwrite(f"{RED}→{RESET} play audio , {RED}↓{RESET} start to practice, {RED}←{RESET} cancel practice")
        keyStart = speech_utils.get_key()
        #if key == '\x1b[A': #Up
        #if key == '\x1b[B': #Down
        #if key == '\x1b[D': #Left
        #if key == '\x1b[C': #Right
        if keyStart == '\x1b[B':
            speech_utils.print_overwrite(f"{YELLOW}{args.peference_text}{RESET}\nPlease start to read aloud ...");
            break
        elif keyStart == '\x1b[D':
            print("\nRecognition cancel")
            sys.exit(1)

    #构建降噪引擎
    engine = speech_utils.SherpaRNNoiseEngine()

    agc = speech_utils.PydubAGC(sample_rate=SAMPLE_RATE, target_dbfs=-3.0)

    vad = speech_utils.AdvancedVAD(sample_rate=16000,
                  frame_ms=20,
                  enter_threshold=0.03,
                  exit_threshold=0.015,
                  min_speech_ms=100,
                  window_ms=100)

    asr = AdaptiveGrammarRecognizer(
        model_path=args.model_path,
        sample_rate=SAMPLE_RATE,
        reference_text=args.peference_text
    )

    with sd.InputStream(samplerate=48000, 
                            blocksize=480, 
                            channels=1, 
                            dtype='float32', 
                            callback=audio_callback):
        while True:
            data = audio_queue.get()
            data = engine.process_and_resample_48k_2_16K(data) #RNNoise降噪

            #确认在讲话
            if vad.is_speech(data):
                data = engine.float_to_pcm16(data)
                # data = speech_utils.process_for_vosk_df(data);#deepfilternet降噪
                data = agc.process_for_vosk(data) # AGC 优化识别效果: 无论你离麦克风近还是远，识别效果都会变得稳定
                result = asr.accept_audio(data)
                if result:
                    if result.get("success"):
                        speech_utils.print_overwrite("Partial Result Recognition successful. Exiting.\n")
                        sys.exit(0)

                    speech_utils.print_multi_overwrite(speech_utils.highlight_diff(args.peference_text, result.get("text", ""), on_recognition_equal),result.get("text", "").lower())

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        speech_utils.print_overwrite("Recognition force cancel\n") 
        sys.exit(1)
