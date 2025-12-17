import json
import queue
import sys
import difflib
import os

import sounddevice as sd
from vosk import Model, KaldiRecognizer, SetLogLevel

# You can set log level to 0 to enable debug messages
SetLogLevel(-1)

# ========== 配置 ==========
MODEL_PATH = os.environ.get("dirPathPythonVoskModel")
SAMPLE_RATE = 16000
# =======================

# -------- 读取终端参数 --------
if len(sys.argv) < 2:
    print("Usage:")
    print("  python speech_diff.py \"reference text here\"")
    sys.exit(1)

REFERENCE_TEXT = sys.argv[1].strip().lower()
# --------------------------------

# ANSI 颜色
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"

def clear_screen():
    os.system("cls" if os.name == "nt" else "clear")

def is_exact_match(reference: str, recognized: str) -> bool:
    return reference.split() == recognized.lower().split()

q = queue.Queue()

def audio_callback(indata, frames, time, status):
    if status:
        print(status, file=sys.stderr)
    q.put(bytes(indata))

def highlight_diff(reference, recognized):
    ref_words = reference.split()
    rec_words = recognized.split()

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
            output.extend([f"{GREEN}({w}){RESET}" for w in ref_words[i1:i2]])

    return " ".join(output)

def main():
    #print("Loading model...")
    model = Model(MODEL_PATH)
    recognizer = KaldiRecognizer(model, SAMPLE_RATE)

    print("Reference text:",f"{YELLOW}{REFERENCE_TEXT}{RESET}")
    print("Listening... (Ctrl+C to stop)")

    with sd.RawInputStream(
        samplerate=SAMPLE_RATE,
        blocksize=8000,
        dtype="int16",
        channels=1,
        callback=audio_callback
    ):
        while True:
            data = q.get()
            if recognizer.AcceptWaveform(data):
                result = json.loads(recognizer.Result())
                text = result.get("text", "")
                if text:
                     # ========= 完全一致 → 成功退出 =========
                    if is_exact_match(REFERENCE_TEXT, text):
                        print("\nRecognition successful. Exiting.")
                        sys.exit(0)
                    clear_screen()
                    print("Reference text:",f"{YELLOW}{REFERENCE_TEXT}{RESET}")
                    print("\nRaw result:",text)
                    print("\nDiff result:",highlight_diff(REFERENCE_TEXT, text))
                    print("-" * 60)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nRecognition fail. Exiting.")
        sys.exit(1)
