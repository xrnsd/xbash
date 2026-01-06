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


def highlight_diff_multi(reference, recognized, on_complete=None):
    # ---------- 1. 初始化静态状态 (保持原样) ----------
    if not hasattr(highlight_diff, "_state"):
        highlight_diff._state = {
            "last_reference": None,
            "matched_indices": set(),
            "completed": False,
        }

    state = highlight_diff._state

    # 假设 normalize_text 已定义
    ref = normalize_text(reference)
    rec = normalize_text(recognized)

    ref_words = ref.split()
    rec_words = rec.split()

    # ---------- 2. 逻辑处理 (保持原样) ----------
    if ref != state["last_reference"]:
        state["matched_indices"].clear()
        state["completed"] = False
        state["last_reference"] = ref

    matcher = difflib.SequenceMatcher(None, ref_words, rec_words)

    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == "equal":
            for idx in range(i1, i2):
                state["matched_indices"].add(idx)

    total = len(ref_words)
    matched = len(state["matched_indices"])
    accuracy = int((matched / total) * 100) if total > 0 else 0

    if accuracy == 100 and not state["completed"]:
        state["completed"] = True
        if callable(on_complete):
            on_complete(reference)

    # ---------- 3. 自动切分输出逻辑 (新增) ----------
    columns, _ = shutil.get_terminal_size(fallback=(137, 24))
    limit = columns - 2
    
    prefix = f"[{accuracy}%] "
    # 使用你定义的 get_visual_len
    prefix_v_len = get_visual_len(prefix)
    
    final_lines = []
    current_line = prefix
    current_v_len = prefix_v_len

    for idx, word in enumerate(ref_words):
        # 构造带颜色的单词
        styled_word = word if idx in state["matched_indices"] else f"{RED}{word}{RESET}"
        word_v_len = get_visual_len(styled_word)
        
        # 判断：当前行长度 + 空格(1) + 新单词长度 是否超限
        # 注意：第一行已包含 prefix，后续行需要考虑对齐缩进
        if current_v_len + 1 + word_v_len > limit:
            final_lines.append(current_line)
            # 新行开始：为了美观，通常在百分比标识下方留空对齐
            indent = " " * prefix_v_len
            current_line = indent + styled_word
            current_v_len = prefix_v_len + word_v_len
        else:
            # 如果是该行第一个词（除 prefix 外）不加空格，否则加空格
            spacer = "" if current_v_len == prefix_v_len or current_v_len == 0 else " "
            current_line += spacer + styled_word
            current_v_len += (len(spacer) + word_v_len)

    if current_line:
        final_lines.append(current_line)

    # 返回列表，兼容 print_multi_overwrite
    return final_lines


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

# 定义 ANSI 颜色提取正则
ANSI_ESCAPE = re.compile(r'\x1b\[[0-9;]*m')

def get_visual_len(text):
    """计算字符串在终端显示的实际宽度（剔除 ANSI 转义序列）"""
    # 这个正则表达式匹配所有 \033[...m 格式的 ANSI 转义序列
    ansi_escape = re.compile(r'\x1b\[[0-9;]*m')
    return len(ansi_escape.sub('', text))

def split_text_preserving_color(text, limit):
    """
    切分文本并尝试为每一行保留颜色。
    逻辑：提取文本中所有的颜色转义符，包裹在每一个切分后的纯文本段上。
    """
    # 1. 提取该行所有的 ANSI 颜色代码
    colors = ANSI_ESCAPE.findall(text)
    color_prefix = "".join(colors)  # 合并所有颜色指令作为前缀
    
    # 2. 获取纯文本
    plain_text = ANSI_ESCAPE.sub('', text)
    
    if not plain_text: # 处理空行或纯控制符行
        return [text]

    parts = []
    # 3. 按照视觉宽度切分纯文本
    for i in range(0, len(plain_text), limit):
        chunk = plain_text[i : i + limit]
        # 为每一段重新包裹颜色前缀和重置后缀
        parts.append(f"{color_prefix}{chunk}\033[0m")
    
    return parts

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

def print_multi_overwrite(*args, flush=True):
    """
    修正版：支持混合输入，确保首行 prefix 不丢失。
    """
    # 1. 扁平化所有输入
    raw_lines = []
    for item in args:
        if isinstance(item, list):
            raw_lines.extend(item)
        else:
            raw_lines.append(str(item))

    # 2. 获取终端宽度
    columns, _ = shutil.get_terminal_size(fallback=(137, 24))
    limit = columns - 2
    
    # 3. 再次确认每行是否需要物理切分（防止溢出导致终端自动换行破坏光标计算）
    final_lines = []
    for line in raw_lines:
        # 如果这一行视觉长度已经超了，强制按颜色保留方式切分
        if get_visual_len(line) > limit:
            final_lines.extend(split_text_preserving_color(line, limit))
        else:
            final_lines.append(line)

    if not final_lines:
        return

    # 4. 打印：关键在于 \r\033[K 必须紧贴每一行的开头
    # 这样可以清除掉旧内容，同时从最左侧开始输出
    processed_output = []
    for i, line in enumerate(final_lines):
        # 每一行都强制从行首开始并清除该行
        processed_output.append(f"\r\033[K{line}")

    # 使用 \n 连接，但最后一行不要加 \n 避免产生多余空行
    sys.stdout.write("\n".join(processed_output))
    
    if flush:
        sys.stdout.flush()

    # 5. 光标回退逻辑
    actual_num_lines = len(final_lines)
    if actual_num_lines > 1:
        # 回到本次打印的第一行行首
        sys.stdout.write(f"\033[{actual_num_lines - 1}F")
    
    # 始终确保光标在当前行（即第一行）的开头，准备下次覆盖
    sys.stdout.write("\r")
    sys.stdout.flush()

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

import numpy as np
import samplerate  # 确保已安装: pip install samplerate
from pyrnnoise import RNNoise  # 确保已安装: pip install pyrnnoise

class SherpaRNNoiseEngine:
    def __init__(self, lib_path=None):
        """
        适配 2026 年最新版 pyrnnoise 的初始化逻辑
        """
        try:
            # 关键修改：必须传入采样率 48000
            # 最新版本的 pyrnnoise 构造函数签名通常为: RNNoise(sample_rate)
            from pyrnnoise import RNNoise
            self.rnnoise = RNNoise(48000) 
            self.rnnoise_frame_size = 480 
        except Exception as e:
            # 如果依然报错，可能是因为该版本要求 positional 参数
            try:
                self.rnnoise = RNNoise(sample_rate=48000)
            except:
                raise ImportError(f"无法初始化 RNNoise 引擎。错误信息: {e}")

        # --- 2. 初始化重采样器 (48k -> 16k) ---
        import samplerate
        self.resampler = samplerate.Resampler('sinc_fastest', channels=1)
        self.ratio = 16000 / 48000

    def process_and_resample_48k_2_16K(self, frame_48k):
        """
        输入: 48kHz 采样点 (480,)，float32 范围 [-1.0, 1.0]
        输出: 16kHz 降噪后的采样点 (160,)
        """
        # A. RNNoise 处理
        # pyrnnoise 的 process 方法接收 float32 数据，
        # 但内部通常需要 16位对齐的量级，所以乘以 32768.0
        # 处理完后再除回 32768.0 得到归一化 float32
        in_data = frame_48k * 32768.0
        
        # pyrnnoise 内部封装了指针操作，直接传入 ndarray 即可
        out_data = self.rnnoise.process(in_data)
        
        clean_frame_48k = out_data / 32768.0
        
        # B. 下采样至 16kHz (480点 -> 160点)
        clean_frame_16k = self.resampler.process(clean_frame_48k, self.ratio)
        return clean_frame_16k

    def float_to_pcm16(self, audio_float):
        """
        将 float32 数组转换为 PCM16 字节流
        """
        # 限制范围，防止溢出
        audio_float = np.clip(audio_float, -1.0, 1.0)
        # 转换为 int16 (PCM16)
        return (audio_float * 32767).astype(np.int16).tobytes()

    # pyrnnoise 会在对象销毁时自动调用 rnnoise_destroy，
    # 因此这里不再需要显式的 __del__ 逻辑。

