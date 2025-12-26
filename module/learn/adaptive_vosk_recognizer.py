import json
import time
import re
from difflib import SequenceMatcher
from vosk import Model, KaldiRecognizer
from collections import deque

# ================== 可调参数 ==================

SIMILARITY_THRESHOLD = 0.5      # 触发 Grammar 的相似度，↓ 放松 / ↑ 收紧
MIN_GRAMMAR_WORDS = 5           # Grammar 启用最少词数
MIN_GRAMMAR_UPDATE_WORDS = 2    # 防止因为历史样本过少而频繁、抖动地更新 Grammar
GRAMMAR_TIMEOUT_SEC = 4         # Grammar 最长启用时间（秒）
GRAMMAR_HISTORY_SIZE = 5        # Grammar 历史动态增量，最近 N 次 final

# ==============================================


def print_overwrite(*args, sep=' ', end='', flush=True):
    text = sep.join(str(a) for a in args)
    print(f"\r\033[K{text}", end=end, flush=flush)

def normalize_text(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^\w\s]", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def similarity(a: str, b: str) -> float:
    return SequenceMatcher(None, a, b).ratio()

def build_dynamic_grammar(reference, history_words):
    ref_words = normalize_text(reference).split()

    # 增量词数量不足，不更新
    if len(history_words) < MIN_GRAMMAR_UPDATE_WORDS:
        return None

    words = ref_words + history_words
    uniq = list(dict.fromkeys(words))

    return json.dumps([" ".join(uniq)])

def build_dynamic_grammar(reference, history_words):
    """
    构建“弱 Grammar”：关键词袋（保序、去重）
    """
    words = normalize_text(reference).split()

    # 增量词数量大于等于阈值后更新
    if len(history_words) >= MIN_GRAMMAR_UPDATE_WORDS:
        words += history_words

    uniq = list(dict.fromkeys(words))
    if len(uniq) < MIN_GRAMMAR_WORDS:
        return None

    return json.dumps([" ".join(uniq)])

# ================== Grammar 动态增量（基于最近 N 次识别） ==================

class GrammarHistory:
    def __init__(self, max_size):
        self.items = deque(maxlen=max_size)

    def add(self, text):
        if text and text not in self.items:
            self.items.append(text)

    def keywords(self):
        words = []
        for t in self.items:
            words.extend(t.split())
        # 去重保序
        return list(dict.fromkeys(words))



# ================== 输出稳定器 ==================

class StableOutputFilter:
    """
    规则：
    - partial 只能单向增长（前缀 + 长度）
    - final 一旦出现，冻结输出
    """

    def __init__(self):
        self.reset()

    def reset(self):
        self.last_text = ""
        self.final_seen = False

    def accept(self, text: str, is_final: bool) -> bool:
        if is_final:
            self.last_text = text
            self.final_seen = True
            return True

        if self.final_seen:
            return False

        if not self.last_text:
            self.last_text = text
            return True

        # 只允许“向前走”
        if text.startswith(self.last_text) and len(text) >= len(self.last_text):
            self.last_text = text
            return True

        return False


# ================== 主识别器 ==================

class AdaptiveGrammarRecognizer:
    def __init__(self, model_path, sample_rate, reference_text):
        self.model = Model(model_path)
        self.sample_rate = sample_rate
        self.reference = normalize_text(reference_text)

        # recognizers
        self.rec_free = KaldiRecognizer(self.model, self.sample_rate)
        self.rec_grammar = None
        self.active_recognizer = self.rec_free

        # grammar state
        self.grammar_enabled = False
        self.grammar_start_time = 0

        # grammar history
        self.history = GrammarHistory(GRAMMAR_HISTORY_SIZE)

        # output stability
        self.output_filter = StableOutputFilter()

    # ---------- Grammar 控制 ----------

    def enable_grammar(self):
        history_words = self.history.keywords()
        grammar = build_dynamic_grammar(self.reference, history_words)
        if not grammar:
            return False

        self.rec_grammar = KaldiRecognizer(self.model, self.sample_rate)
        self.rec_grammar.SetGrammar(grammar)

        self.active_recognizer = self.rec_grammar
        self.grammar_enabled = True
        self.grammar_start_time = time.time()

        self.output_filter.reset()
        #print_overwrite("[INFO] Grammar enabled:", grammar)
        return True

    def disable_grammar(self):
        self.active_recognizer = self.rec_free
        self.rec_grammar = None
        self.grammar_enabled = False

        self.output_filter.reset()
        #print_overwrite("[INFO] Grammar disabled")

    # ---------- 主入口 ----------

    def accept_audio(self, pcm_bytes: bytes):
        rec = self.active_recognizer

        if rec.AcceptWaveform(pcm_bytes):
            text = json.loads(rec.Result()).get("text", "")
            return self._emit(text, is_final=True)
        else:
            text = json.loads(rec.PartialResult()).get("partial", "")
            return self._emit(text, is_final=False)

    # ---------- 输出调度 ----------

    def _emit(self, text: str, is_final: bool):
        text = normalize_text(text)
        if not text:
            return None

        score = similarity(text, self.reference)

        # 触发 Grammar
        if (not self.grammar_enabled) and score >= SIMILARITY_THRESHOLD:
            self.enable_grammar()
            return None  # 切换帧不输出，避免抖动

        # Grammar 超时保护
        if self.grammar_enabled and (time.time() - self.grammar_start_time > GRAMMAR_TIMEOUT_SEC):
            self.disable_grammar()
            return None

        # 稳定过滤
        if not self.output_filter.accept(text, is_final):
            return None

        # 成功条件
        success = False
        if is_final:
            if text == self.reference or self.reference in text:
                success = True

        # 只在 Grammar 关闭状态下采样，避免自反馈
        if is_final and not self.grammar_enabled:
            if similarity(text, self.reference) > 0.5:
                words = text.split()
                if len(words) >= MIN_GRAMMAR_UPDATE_WORDS:
                    self.history.add(text)

        return {
            "type": "final" if is_final else "partial",
            "text": text,
            "similarity": round(score, 3),
            "grammar": self.grammar_enabled,
            "success": success
        }
