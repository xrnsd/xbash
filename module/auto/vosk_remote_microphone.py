import json
import queue
import sys
import difflib
import os
import socket
import json
import re
import string
# 禁止 SDL 日志输出
os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"
import pygame
import sounddevice as sd
from vosk import Model, KaldiRecognizer, SetLogLevel
import tty
import termios
import time
from adaptive_vosk_recognizer import AdaptiveGrammarRecognizer

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
REFERENCE_AUDIO = sys.argv[2].strip()
# ================================
# ANSI 颜色
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"

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

def play_audio():
    pygame.mixer.init()
    pygame.mixer.music.load(REFERENCE_AUDIO)
    pygame.mixer.music.play()

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

def send_server_close(conn):
    try:
        msg = "SERVER:close\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception as e:
        print_overwrite("send close notify failed:", e,"\n")

def send_server_request_start_record(conn):
    try:
        msg = "SERVER:request client start to record\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception as e:
        print_overwrite("send request start record failed:", e,"\n")

def send_server_reply_receive_heartbeat(conn):
    try:
        msg = "SERVER:reply receive heartbeat\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception as e:
        print_overwrite("send reply receive heartbeat failed:", e,"\n")

def send_server_request_stop_record(conn):
    try:
        msg = "SERVER:request client stop to record\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception as e:
        print_overwrite("send request stop record failed:", e,"\n")

def recognition_end(conn, tips):
    if not tips:
        print_overwrite(tips)
    send_server_request_stop_record(conn)
    time.sleep(0.1)
    send_server_close(conn)
    time.sleep(0.1)
    try:
        conn.shutdown(socket.SHUT_RDWR)
        conn.close()
    except Exception as e:
        print_overwrite("close connect failed:", e,"\n")

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((HOST, PORT))
    server.listen(1)
    #print("Reference text:",f"{YELLOW}{REFERENCE_TEXT}{RESET}")

    asr = AdaptiveGrammarRecognizer(
        model_path=MODEL_PATH,
        sample_rate=SAMPLE_RATE,
        reference_text=REFERENCE_TEXT
    )

    while True:
        is_operation_key = True
        print_overwrite(f"Waiting for remote microphone connect to {HOST}:{PORT}")
        conn, addr = server.accept()

        try:
            while True:
                if is_operation_key:
                    is_operation_key = False
                    while True:
                        play_audio()
                        print_overwrite(f"{RED}→{RESET} play audio , {RED}↓{RESET} start to practice, {RED}←{RESET} cancel practice")
                        keyStart = get_key()
                        #if key == '\x1b[A': #Up
                        #if key == '\x1b[B': #Down
                        #if key == '\x1b[D': #Left
                        #if key == '\x1b[C': #Right
                        if keyStart == '\x1b[B':
                            send_server_request_start_record(conn)
                            print_overwrite("Please start reading aloud")
                            break
                        elif keyStart == '\x1b[D':
                            print("\nRecognition cancel")
                            sys.exit(1)

                #data = conn.recv(4096)
                data = conn.recv(480 * 2)
                if not data:
                    break
                if "Client:Stop record" in data.decode("utf-8", errors="ignore"):
                    break
                elif "Client:heartbeat" in data.decode("utf-8", errors="ignore"):
                    send_server_reply_receive_heartbeat(conn)
                    continue
                else:
                    # print_overwrite("data:",denoised.decode("utf-8", errors="ignore").strip())
                    result = asr.accept_audio(data)
                    if result:
                        if result.get("success"):
                            print_overwrite("Partial Result Recognition successful. Exiting.\n")
                            sys.exit(0)
                        print_overwrite(highlight_diff(REFERENCE_TEXT, result.get("text", "")))
        finally:
            recognition_end(conn,"")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print_overwrite("Recognition force cancel\n") 
        sys.exit(1)
