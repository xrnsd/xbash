import json
import queue
import sys
import difflib
import os
import socket
import json
import re

import sounddevice as sd
from vosk import Model, KaldiRecognizer, SetLogLevel

# You can set log level to 0 to enable debug messages
SetLogLevel(-1)

# ========== 配置 ==========
HOST = "0.0.0.0"
PORT = 2701
MODEL_PATH = os.environ.get("dirPathPythonVoskModel")
SAMPLE_RATE = 16000
# ========== 读取终端参数 ==========

if len(sys.argv) < 2:
    print("Usage:")
    print("  python speech_diff.py \"reference text here\"")
    sys.exit(1)

REFERENCE_TEXT = sys.argv[1].strip().lower()
# =======================

# ANSI 颜色
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"

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
            output.extend([f"{GREEN}({w}){RESET}" for w in ref_words[i1:i2]])

    return " ".join(output)

def main():
    #print("Loading model...")
    model = Model(MODEL_PATH)

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((HOST, PORT))
    server.listen(1)

    while True:
        #clear_screen()
        print("Reference text:",f"{YELLOW}{REFERENCE_TEXT}{RESET}")
        #print("Listening... (Ctrl+C to stop)")
        print_overwrite(f"Waiting for client connect to {HOST}:{PORT}")
        conn, addr = server.accept()
        print_overwrite("Connected from:", addr, " (Ctrl+C to stop)")
        
        last_partial = ""
        recognizer = KaldiRecognizer(model, SAMPLE_RATE)

        try:
            while True:
                data = conn.recv(4096)
                if not data:
                    break

                if recognizer.AcceptWaveform(data):
                    result = json.loads(recognizer.Result())
                    text = result.get("text", "")
                    if text:
                         # ========= 完全一致 → 成功退出 =========
                        if is_exact_match(REFERENCE_TEXT, text):
                            print("\nRecognition successful. Exiting.")
                            conn.close()
                            server.close()
                            sys.exit(0)
                        #clear_screen()
                        #print("Reference text:",f"{YELLOW}{REFERENCE_TEXT}{RESET}")
                        #print("Raw result:",text)
                        print_overwrite("Diff raw result:",highlight_diff(REFERENCE_TEXT, text))
                        #print("-" * 60)
                else:
                    partial = json.loads(recognizer.PartialResult())
                    if partial.get("partial") and partial != last_partial:
                        # print("Partial:", partial["partial"], end="\r")

                         # ========= 完全一致 → 成功退出 =========
                        if is_exact_match(REFERENCE_TEXT, partial["partial"]):
                            print("\nRecognition successful. Exiting.")
                            conn.close()
                            server.close()
                            sys.exit(0)
                        #clear_screen()
                        #print("Reference text:",f"{YELLOW}{REFERENCE_TEXT}{RESET}")
                        #print("Partial result:",partial["partial"])
                        print_overwrite("Diff partial result:",highlight_diff(REFERENCE_TEXT, partial["partial"]))
                        #print("-" * 60)
                        last_partial = partial

        except KeyboardInterrupt:
            pass
            print("\nRecognition fail. Exiting.")
            conn.close()
            server.close()
            sys.exit(1)
        finally:
            conn.close()
            # server.close()
            # print("\nServer stopped")
            # sys.exit(1)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nRecognition fail. Exiting.")
        sys.exit(1)
