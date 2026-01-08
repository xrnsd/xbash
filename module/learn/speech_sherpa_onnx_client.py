import json
import sys
import os
import re
import time
import argparse
import speech_utils
import socket

# ========== 参数解析 ==========

parser = argparse.ArgumentParser(description="实时语音识别：SherpaOnnx")
parser.add_argument("--peference_audio", type=str, help="音频文件路径")
parser.add_argument("--peference_text", type=str, help="参考对比文本")
parser.add_argument("--port", type=str, help="服务器端口")
args = parser.parse_args()
# ========== ANSI颜色 ==========

RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"

# ====================

def main():
    speech_utils.play_audio(args.peference_audio)

    while True:
        speech_utils.print_overwrite(f"{RED}→{RESET} play audio , {RED}↓{RESET} start to practice, {RED}←{RESET} cancel practice")
        keyStart = speech_utils.get_key()
        #if key == '\x1b[A': #Up
        #if key == '\x1b[B': #Down
        #if key == '\x1b[D': #Left
        #if key == '\x1b[C': #Right
        #if key == 'ctrl+c':   #Ctrl+C
        if keyStart == '\x1b[B':
            speech_utils.print_multi_overwrite([
                        f"{YELLOW}{args.peference_text}{RESET}",
                        "start to connect server ..."
                    ])
            break
        elif keyStart == '\x1b[C':
            speech_utils.play_audio_blocked(args.peference_audio)
        elif keyStart == '\x1b[D' or keyStart == "ctrl+c":
            print("\nRecognition cancel")
            sys.exit(1)
    
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(('127.0.0.1', int(args.port)))
    
    time.sleep(0.5)
    request_strat_recognize="CLIENT:strat_recognize"+args.peference_text+"\n"
    client.sendall(request_strat_recognize.encode('utf-8'))

    def on_recognition_equal(ref):
        print("\nRecognition successful. Exiting.")
        sys.exit(0)
    
    speech_utils.print_multi_overwrite([
                f"{YELLOW}{args.peference_text}{RESET}",
                "Please start to read aloud ..."
            ])

    try:
        while True:
            # 接收数据
            data = client.recv(1024)
            if not data: # 服务器关闭了连接
                print("\nRecognition server disconnect.")
                break
            text = data.decode('utf-8')
            #print(f"服务器: {text}")

            if speech_utils.is_exact_match(args.peference_text, text):
                print("\nRecognition successful. Exiting.")
                break
            if speech_utils.is_recognition_over(text):
                print("\nRecognition cancel. Exiting.")
                break

            result_lines = speech_utils.highlight_diff_multi(args.peference_text, text, on_recognition_equal)
            result_lines.append(text.lower())
            speech_utils.print_multi_overwrite(result_lines)

    except KeyboardInterrupt:
        speech_utils.print_overwrite("Recognition force cancel\n") 
    finally:
        client.close()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        speech_utils.print_overwrite("Recognition force cancel\n") 
        sys.exit(1)

