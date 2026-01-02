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
import shutil

# ========== ANSI 颜色 ==========
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = '\033[93m'
RESET = "\033[0m"
UNDERLINE = "\033[32;4m"  # 下划线
STRIKETHROUGH = "\033[32;9m"  # 删除线（某些旧终端可能不支持）
BOLD = "\033[1m"

def highlight_diff(reference, recognized, on_complete=None):
    # ---------- 初始化静态状态 ----------
    if not hasattr(highlight_diff, "_state"):
        highlight_diff._state = {
            "last_reference": None,
            "matched_indices": set(),  # reference 中已匹配词的索引
            "completed": False,  # 是否已 100%
        }

    state = highlight_diff._state

    ref = normalize_text(reference)
    rec = normalize_text(recognized)

    ref_words = ref.split()
    rec_words = rec.split()

    # ---------- reference 变化 → 重置 ----------
    if ref != state["last_reference"]:
        state["matched_indices"].clear()
        state["completed"] = False
        state["last_reference"] = ref

    matcher = difflib.SequenceMatcher(None, ref_words, rec_words)

    # ---------- 记录匹配的 reference 词 ----------
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == "equal":
            for idx in range(i1, i2):
                state["matched_indices"].add(idx)

    # ---------- 计算匹配度 ----------
    total = len(ref_words)
    matched = len(state["matched_indices"])
    accuracy = int((matched / total) * 100) if total > 0 else 0

    # ---------- 100% 回调（只触发一次） ----------
    if accuracy == 100 and not state["completed"]:
        state["completed"] = True
        if callable(on_complete):
            on_complete(reference)

    # ---------- 构造 reference 高亮输出 ----------
    output = []
    for idx, word in enumerate(ref_words):
        if idx in state["matched_indices"]:
            output.append(word)  # 已匹配，不高亮
        else:
            output.append(f"{RED}{word}{RESET}")  # 未匹配，高亮
    # ---------- 单行输出 ----------
    return f"[{accuracy}%] " + " ".join(output)

#if key == '\x1b[A': #Up
#if key == '\x1b[B': #Down
#if key == '\x1b[D': #Left
#if key == '\x1b[C': #Right
#if key == 'ctrl+c':   #Ctrl+C
def get_key():
    """获取单个按键，支持方向键并能处理 Ctrl+C"""
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
        # 手动处理 Ctrl+C (ASCII 3)
        if ch == '\x03':
            raise KeyboardInterrupt
        # 方向键通常以 \x1b[ 开头（转义序列）
        if ch == '\x1b':
            ch += sys.stdin.read(2)
        return ch
    except KeyboardInterrupt:
        return "ctrl+c"
    finally:
        # 无论发生什么，必须恢复终端设置，否则终端会乱码
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


def play_audio(file_path):
    pygame.mixer.pre_init(24000, -16, 1, 4096) 
    pygame.mixer.init()
    pygame.mixer.music.load(file_path)
    pygame.mixer.music.play()

    result = "/".join(file_path.split("/")[-4:])
    print_overwrite(f"playing : {YELLOW}{result}{RESET}")


def play_audio_blocked(file_path):
    pygame.mixer.pre_init(24000, -16, 1, 4096) 
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

def get_visual_len(text):
    """计算字符串在终端显示的实际宽度（剔除 ANSI 转义序列）"""
    # 这个正则表达式匹配所有 \033[...m 格式的 ANSI 转义序列
    ansi_escape = re.compile(r'\x1b\[[0-9;]*m')
    return len(ansi_escape.sub('', text))

def print_overwrite(*args, sep=' ', end='', flush=True):
    text = sep.join(str(a) for a in args)

    # 自动获取宽度，fallback 设为 (137, 24)
    # 这比 try-except os 模块要可靠得多
    columns, _ = shutil.get_terminal_size(fallback=(137, 24))
    # columns = 137

    # 留出 1 个字符的余量，防止某些终端自动换行
    limit = columns - 1

     # 2. 计算视觉长度
    v_len = get_visual_len(text)

    # 3. 如果视觉长度超过限制，需要截断
    if v_len > limit:
        # 注意：截断带颜色的字符串很复杂，直接截断可能会丢失结尾的 \033[0m 导致后续全变色
        # 这里演示一个简单的截断逻辑（剔除颜色后截断，再加一个重置符防止溢出）
        # 更好的做法通常是先计算好截断位置，或者使用专门的库如 'rich'
        ansi_escape = re.compile(r'\x1b\[[0-9;]*m')
        plain_text = ansi_escape.sub('', text)
        text = STRIKETHROUGH+ plain_text[:limit-7] + "..." + RESET

    # \r 回到行首，\033[K 清除从光标位置到行尾的内容
    print(f"\r\033[K{text}", end=end, flush=flush)

def print_multi_overwrite(lines, flush=True):
    """
    显示多行内容并确保不换行。
    :param lines: 字符串列表，每一项代表一行
    """
    columns, _ = shutil.get_terminal_size(fallback=(137, 24))
    limit = columns - 1
    ansi_escape = re.compile(r'\x1b\[[0-9;]*m')

    processed_lines = []
    for text in lines:
        v_len = get_visual_len(text)
        
        # 长度限制处理
        if v_len > limit:
            # 截断逻辑：为了保证颜色不丢失且不溢出，
            # 最稳妥做法是提取纯文本截断后重新追加 RESET
            plain_text = ansi_escape.sub('', text)
            text = plain_text[:limit-4] + "..." + RESET
        
        # 每行添加清除指令 \033[K 确保旧内容不残留
        processed_lines.append(f"\r\033[K{text}")

    # 1. 打印所有行，行与行之间用换行符连接
    output = "\n".join(processed_lines)
    sys.stdout.write(output)
    
    if flush:
        sys.stdout.flush()

    # 2. 关键：将光标向上移动 (行数 - 1) 行，回到第一行的开头
    # 这样下一次调用该函数时，会从第一行开始覆盖
    num_lines = len(lines)
    if num_lines > 1:
        # \033[F 回到上一行行首，重复执行
        sys.stdout.write(f"\033[{num_lines - 1}F")

def is_too_long(text) -> bool:
    columns, _ = shutil.get_terminal_size(fallback=(137, 24))
    limit = columns - 1

    if get_visual_len(text) > limit:
        return True
    return False

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


class SimpleVAD:
    def __init__(self, threshold=0.02, min_speech_ms=100, sample_rate=16000):
        self.threshold = threshold
        self.min_speech_samples = int(min_speech_ms / 1000 * sample_rate)
        self.speech_counter = 0

    def is_speech(self, samples: np.ndarray) -> bool:
        """
        samples: float32 numpy array [-1,1]
        """
        energy = np.sqrt(np.mean(samples ** 2))
        if energy > self.threshold:
            self.speech_counter += len(samples)
        else:
            self.speech_counter = max(0, self.speech_counter - len(samples))

        return self.speech_counter >= self.min_speech_samples

from collections import deque

class AdvancedVAD:
    def __init__(self,
                 sample_rate=16000,
                 frame_ms=20,
                 enter_threshold=0.03,
                 exit_threshold=0.015,
                 min_speech_ms=100,
                 window_ms=100):
        """
        sample_rate: 采样率
        frame_ms: 每帧长度
        enter_threshold: 进入语音阈值
        exit_threshold: 离开语音阈值
        min_speech_ms: 最小语音长度（ms）
        window_ms: 滑动窗口大小（ms）
        """
        self.sample_rate = sample_rate
        self.frame_size = int(frame_ms / 1000 * sample_rate)
        self.enter_threshold = enter_threshold
        self.exit_threshold = exit_threshold
        self.min_speech_samples = int(min_speech_ms / 1000 * sample_rate)
        self.window_size = int(window_ms / 1000 * sample_rate)
        self.energy_window = deque(maxlen=self.window_size)
        self.in_speech = False
        self.speech_counter = 0

    def is_speech(self, samples: np.ndarray) -> bool:
        """
        samples: float32 [-1,1]
        """
        # 1. 计算当前帧 RMS
        energy = np.sqrt(np.mean(samples ** 2))
        self.energy_window.append(energy)

        # 2. 滑动窗口平均
        avg_energy = np.mean(self.energy_window)

        # 3. 双阈值判断
        if self.in_speech:
            if avg_energy < self.exit_threshold:
                self.in_speech = False
        else:
            if avg_energy > self.enter_threshold:
                self.in_speech = True

        # 4. 最小语音长度计数
        if self.in_speech:
            self.speech_counter += len(samples)
        else:
            self.speech_counter = max(0, self.speech_counter - len(samples))

        # 5. 返回是否为语音（满足最小语音长度）
        return self.speech_counter >= self.min_speech_samples

import sounddevice as sd
import ctypes
import os
import samplerate  # 处理 48k -> 16k 的重采样

class SherpaRNNoiseEngine:
    def __init__(self, lib_path=None):
        # 1. 自动定位库文件
        if lib_path is None:
            # 优先查找当前目录，其次查找系统目录
            lib_path = "./librnnoise.so.0" if os.path.exists("./librnnoise.so.0") else "librnnoise.so.0"
        
        try:
            self.lib = ctypes.cdll.LoadLibrary(lib_path)
        except OSError as e:
            raise ImportError(f"无法加载 RNNoise 库。请确保已安装 librnnoise 或将 .so 文件放入当前目录。\n错误信息: {e}")

        self.lib.rnnoise_create.restype = ctypes.c_void_p
        self.lib.rnnoise_process_frame.argtypes = [
            ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float)
        ]
        self.lib.rnnoise_destroy.argtypes = [ctypes.c_void_p]
        self.st = self.lib.rnnoise_create(None)
        self.rnnoise_frame_size = 480  # 10ms @ 48kHz

        # --- 2. 初始化重采样器 (48k -> 16k) ---
        # 比例为 1/3 (16000 / 48000)
        self.resampler = samplerate.Resampler('sinc_fastest', channels=1)
        self.ratio = 16000 / 48000

    def process_and_resample_48k_2_16K(self, frame_48k):
        """
        输入: 48kHz 采样点 (480,)
        输出: 16kHz 降噪后的采样点 (160,)
        """
        # A. RNNoise 处理 (要求 ±32768 范围)
        in_data = (frame_48k * 32768.0).astype(np.float32)
        in_data = np.ascontiguousarray(in_data)
        out_buffer = np.zeros(self.rnnoise_frame_size, dtype=np.float32)
        
        in_ptr = in_data.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
        out_ptr = out_buffer.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
        
        self.lib.rnnoise_process_frame(self.st, out_ptr, in_ptr)
        
        # B. 缩放回归一化范围
        clean_frame_48k = out_buffer / 32768.0
        
        # C. 下采样至 16kHz (480点 -> 160点)
        clean_frame_16k = self.resampler.process(clean_frame_48k, self.ratio)
        return clean_frame_16k

    def float_to_pcm16(self, audio_float):
        """
        [独立 API] 将 float32 数组转换为 Vosk 要求的 PCM16 字节流
        :param audio_float: numpy array, 范围通常在 [-1.0, 1.0]
        :return: bytes
        """
        # 限制范围，防止溢出产生噪音
        audio_float = np.clip(audio_float, -1.0, 1.0)
        # 转换为 int16 (PCM16)
        return (audio_float * 32767).astype(np.int16).tobytes()

    def __del__(self):
        if hasattr(self, 'st'):
            self.lib.rnnoise_destroy(self.st)
