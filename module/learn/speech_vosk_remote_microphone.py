import json
import queue
import sys
import difflib
import os
import socket
import re
import string
import sounddevice as sd
from vosk import Model, KaldiRecognizer, SetLogLevel
import tty
import termios
import time
import argparse
import speech_utils
from adaptive_vosk_recognizer import AdaptiveGrammarRecognizer

# You can set log level to 0 to enable debug messages
SetLogLevel(-1)

# ========== 配置 ==========
HOST = "0.0.0.0"
PORT = 2701
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

# ====================

q = queue.Queue()

def audio_callback(indata, frames, time, status):
    if status:
        print(status, file=sys.stderr)
    q.put(bytes(indata))

def send_server_close(conn):
    try:
        msg = "SERVER:close\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception as e:
        speech_utils.print_overwrite("send close notify failed:", e,"\n")

def send_server_request_start_record(conn):
    try:
        msg = "SERVER:request client start to record\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception as e:
        speech_utils.print_overwrite("send request start record failed:", e,"\n")

def send_server_reply_receive_heartbeat(conn):
    try:
        msg = "SERVER:reply receive heartbeat\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception as e:
        speech_utils.print_overwrite("send reply receive heartbeat failed:", e,"\n")

def send_server_request_stop_record(conn):
    try:
        msg = "SERVER:request client stop to record\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception as e:
        speech_utils.print_overwrite("send request stop record failed:", e,"\n")

def recognition_end(conn, tips):
    if not tips:
        speech_utils.print_overwrite(tips)
    send_server_request_stop_record(conn)
    time.sleep(0.1)
    send_server_close(conn)
    time.sleep(0.1)
    try:
        conn.shutdown(socket.SHUT_RDWR)
        conn.close()
    except Exception as e:
        speech_utils.print_overwrite("close connect failed:", e,"\n")

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((HOST, PORT))
    server.listen(1)
    #print("Reference text:",f"{YELLOW}{args.peference_text}{RESET}")

    asr = AdaptiveGrammarRecognizer(
        model_path=args.model_path,
        sample_rate=SAMPLE_RATE,
        reference_text=args.peference_text
    )

    while True:
        is_operation_key = True
        speech_utils.print_overwrite(f"Waiting for remote microphone connect to {HOST}:{PORT}")
        conn, addr = server.accept()

        try:
            while True:
                if is_operation_key:
                    is_operation_key = False
                    while True:
                        speech_utils.play_audio_blocked(args.peference_audio)
                        speech_utils.print_overwrite(f"{RED}→{RESET} play audio , {RED}↓{RESET} start to practice, {RED}←{RESET} cancel practice")
                        keyStart = speech_utils.get_key()
                        #if key == '\x1b[A': #Up
                        #if key == '\x1b[B': #Down
                        #if key == '\x1b[D': #Left
                        #if key == '\x1b[C': #Right
                        if keyStart == '\x1b[B':
                            send_server_request_start_record(conn)
                            speech_utils.print_overwrite("Please start reading aloud")
                            break
                        elif keyStart == '\x1b[D':
                            print("\nRecognition cancel")
                            sys.exit(1)

                data = conn.recv(4096)
                # data = conn.recv(480 * 2)
                # data = conn.recv(512)
                if not data:
                    break
                if "CLIENT:Stop record" in data.decode("utf-8", errors="ignore"):
                    break
                elif "CLIENT:heartbeat" in data.decode("utf-8", errors="ignore"):
                    send_server_reply_receive_heartbeat(conn)
                    continue
                else:
                    # speech_utils.print_overwrite("data:",denoised.decode("utf-8", errors="ignore").strip())
                    result = asr.accept_audio(data)
                    if result:
                        if result.get("success"):
                            speech_utils.print_overwrite("Partial Result Recognition successful. Exiting.\n")
                            sys.exit(0)
                        speech_utils.print_overwrite(speech_utils.highlight_diff(args.peference_text, result.get("text", "")))
        finally:
            recognition_end(conn,"")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        speech_utils.print_overwrite("Recognition force cancel\n") 
        sys.exit(1)
