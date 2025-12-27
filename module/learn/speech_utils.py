import difflib
import numpy as np
import json
import sys
import os
import re
import string
# 禁止 SDL 日志输出
os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"
import warnings
warnings.filterwarnings(
    "ignore",
    message="pkg_resources is deprecated"
)
import pygame
import tty
import termios
import time

# ========== ANSI 颜色 ==========
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"
UNDERLINE = "\033[32;4m"  # 下划线
STRIKETHROUGH = "\033[32;9m"  # 删除线（某些旧终端可能不支持）


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
            output.extend([f"{UNDERLINE}{w}{RESET}" for w in ref_words[i1:i2]])

    return " ".join(output)

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


def print_overwrite(*args, sep=' ', end='', flush=True):
    text = sep.join(str(a) for a in args)
    
    # 获取当前终端的实际宽度
    try:
        columns = os.get_terminal_size().columns
    except OSError:
        columns = 137  # 如果获取失败（如在某些 IDE 中），使用 137 兜底

    # 留出一点余量（比如 -1）防止极少数终端的边界换行 Bug
    limit = min(columns - 1, 137) 
    
    if len(text) > limit:
        # text = text[:limit]
        #自动切割：如果超过 137 字符，截断并添加省略标记（可选）
        #截断到 134 位并加 "..." 凑够 137，或者直接 text[:limit]
        text = text[:limit-2] + "..." if limit > 2 else text[:limit]
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
    reference = normalize_text(reference)
    if reference.endswith("recognition over"):
        return True
    if reference.endswith("text over"):
        return True
    if reference.endswith("test over"):
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

def last_two_words_match(a: str, b: str) -> bool:
    def norm(s):
        s = re.sub(r"[^\w\s]", "", s)
        return s.lower().strip().split()

    wa = norm(a)
    wb = norm(b)

    return len(wa) >= 2 and len(wb) >= 2 and wa[-2:] == wb[-2:]

# ========== 麦克风增益自动调整 ==========
from pydub import AudioSegment
import io

class PydubAGC:
    def __init__(self, sample_rate=16000, target_dbfs=-3.0, max_gain=12.0):
        self.sample_rate = sample_rate
        self.target_dbfs = target_dbfs
        self.max_gain = max_gain

    def _apply_agc(self, raw_bytes):
        # 将原始字节转为 AudioSegment 对象 (int16, 单声道)
        segment = AudioSegment(
            data=raw_bytes,
            sample_width=2,
            frame_rate=self.sample_rate,
            channels=1
        )

        # 核心：归一化处理。headroom 是距离 0dBFS 的余量
        # normalize 内部会自动计算增益，如果声音太小会放大，太大则缩小
        processed_segment = segment.normalize(headroom=abs(self.target_dbfs))
        
        # 限制最大增益，防止静音时底噪过载
        gain_added = processed_segment.dBFS - segment.dBFS
        if gain_added > self.max_gain:
            processed_segment = segment.apply_gain(self.max_gain)
            
        return processed_segment

    def process_for_vosk(self, raw_bytes):
        """返回 Vosk 需要的 int16 格式 bytes"""
        processed = self._apply_agc(raw_bytes)
        return processed.raw_data

    def process_for_sherpa(self, raw_bytes):
        """返回 Sherpa-Onnx 需要的 float32 numpy 数组"""
        processed = self._apply_agc(raw_bytes)
        # 获取 int16 数组
        samples = np.array(processed.get_array_of_samples())
        # 转换为 Sherpa 需要的 float32 归一化格式 [-1.0, 1.0]
        return samples.astype(np.float32) / 32768.0

class SimpleAGC:
    def __init__(self, target_rms=0.15, max_gain=10.0, smoothing=0.1):
        """
        :param target_rms: 目标能量水平 (0.0 到 1.0)。通常 0.15 是 ASR 模型的舒适区。
        :param max_gain: 最大放大倍数。防止在静音时过度放大底噪。
        :param smoothing: 平滑系数。防止音量突变导致破音。
        """
        self.target_rms = target_rms
        self.max_gain = max_gain
        self.smoothing = smoothing
        self.current_gain = 1.0

    def process(self, samples):
        # 1. 计算当前块的有效值能量 (RMS)
        rms = np.sqrt(np.mean(samples**2)) + 1e-6
        
        # 2. 计算理想增益
        target_gain = self.target_rms / rms
        
        # 3. 限制增益范围（防止过度放大或过度压缩）
        target_gain = np.clip(target_gain, 0.1, self.max_gain)
        
        # 4. 平滑增益变化，让声音听起来更自然
        self.current_gain = (1 - self.smoothing) * self.current_gain + self.smoothing * target_gain
        
        # 5. 应用增益并限幅（防止数据超过 1.0 导致模型识别错乱）
        output = samples * self.current_gain
        return np.clip(output, -1.0, 1.0)
