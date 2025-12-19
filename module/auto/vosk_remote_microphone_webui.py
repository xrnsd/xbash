import json
import queue
import sys
import difflib
import html
import os
import socket
import json
import re
import threading
import eventlet
eventlet.monkey_patch()
from flask import Flask, render_template
from flask_socketio import SocketIO

import sounddevice as sd
from vosk import Model, KaldiRecognizer, SetLogLevel

# You can set log level to 0 to enable debug messages
SetLogLevel(-1)

# ========== WEB UI 配置 ==========
HOST_WEB_GUI = "0.0.0.0"
PORT_WEB_GUI = 5000
app = Flask(__name__)
# eventlet.monkey_patch()
socketio = SocketIO(app, cors_allowed_origins="*", async_mode="eventlet")

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
#REFERENCE_AUDIO = sys.argv[2].strip().lower()
# =======================

# ANSI 颜色
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"


# ---------------------------
# Web 路由
# ---------------------------
@app.route("/")
def index():
    return render_template("index.html")

# ---------------------------
# Web UI 线程
# ---------------------------
def run_webui():
    socketio.run(app, host="0.0.0.0", port=5000)

# ---------------------------
# Vosk 推送接口（示意）
# ---------------------------

# def push_reference_text(text):
#     with app.app_context():
#         socketio.emit("reference", {"text": text})

def push_final(text):
    if isinstance(text, bytes):
        text = text.decode("utf-8")
    diff_html=highlight_diff_html(REFERENCE_TEXT, text)
    if isinstance(diff_html, bytes):
        diff_html = diff_html.decode("utf-8")
    with app.app_context():
        socketio.emit("reference", {"text": REFERENCE_TEXT})
        socketio.emit("final", {
            "text": text,
            "diff": diff_html,
            "match": is_exact_match(REFERENCE_TEXT, text)
        })

def push_partial(text):
    if isinstance(text, bytes):
        text = text.decode("utf-8")
    diff_html=highlight_diff_html(REFERENCE_TEXT, text)
    if isinstance(diff_html, bytes):
        diff_html = diff_html.decode("utf-8")
    with app.app_context():
        socketio.emit("partial", {
            "text": text,
            "diff": diff_html,
            "match": is_exact_match(REFERENCE_TEXT, text)
        })


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
            output.extend([f"{GREEN}{w}{RESET}" for w in ref_words[i1:i2]])

    return " ".join(output)

def highlight_diff_html(reference: str, recognized: str) -> str:
    """
    返回 HTML 字符串，ok 部分绿色，错误部分红色
    """
    # 忽略标点
    import re
    def normalize(s):
        return re.sub(r'[^\w\s]', '', s.lower())

    ref_words = normalize(reference).split()
    rec_words = normalize(recognized).split()

    matcher = difflib.SequenceMatcher(None, ref_words, rec_words)
    html_result = []

    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == 'equal':
            html_result.extend(f'<span class="ok">{html.escape(w)}</span> ' for w in rec_words[j1:j2])
        elif tag in ('replace', 'delete', 'insert'):
            html_result.extend(f'<span class="bad">{html.escape(w)}</span> ' for w in rec_words[j1:j2])

    return ''.join(html_result)

def main():
    #print("Loading model...")
    model = Model(MODEL_PATH)

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((HOST, PORT))
    server.listen(1)

    t = threading.Thread(target=lambda: socketio.run(app, host="0.0.0.0", port=5000), daemon=True)
    t.start()

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
                        push_final(text)
                         # ========= 完全一致 → 成功退出 =========
                        if is_exact_match(REFERENCE_TEXT, text):
                            print("\nRaw Result Recognition successful. Exiting.")
                            conn.close()
                            server.close()
                            sys.exit(0)
                        print_overwrite("raw :",highlight_diff(REFERENCE_TEXT, text))
                else:
                    result = json.loads(recognizer.PartialResult())
                    text = result.get("partial")
                    if text and text != last_partial:
                        push_partial(text)
                         # ========= 完全一致 → 成功退出 =========
                        if is_exact_match(REFERENCE_TEXT, text):
                            print("\nPartial Result Recognition successful. Exiting.")
                            conn.close()
                            server.close()
                            sys.exit(0)
                        print_overwrite("partial :",highlight_diff(REFERENCE_TEXT, text))
                        last_partial = text

        except KeyboardInterrupt:
            pass
            print("\nRecognition fail. Exiting.")
            conn.close()
            server.close()
            sys.exit(1)
        finally:
            conn.close()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nRecognition fail. Exiting.")
        sys.exit(1)
