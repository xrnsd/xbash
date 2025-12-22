import json
import time
import re
from difflib import SequenceMatcher
from vosk import Model, KaldiRecognizer

SIMILARITY_THRESHOLD = 0.7  # ↓ 放松 / ↑ 收紧
MIN_GRAMMAR_WORDS = 5
GRAMMAR_TIMEOUT_SEC = 5

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


def build_weak_grammar(reference: str):
    """
    关键词袋 Grammar（弱约束）
    """
    words = normalize_text(reference).split()
    uniq = list(dict.fromkeys(words))  # 保序去重
    if len(uniq) < MIN_GRAMMAR_WORDS:
        return None
    return json.dumps([" ".join(uniq)])


class AdaptiveGrammarRecognizer:
    def __init__(self, model_path, sample_rate, reference_text):
        self.model = Model(model_path)
        self.sample_rate = sample_rate
        self.reference = normalize_text(reference_text)

        self.rec_free = KaldiRecognizer(self.model, self.sample_rate)
        self.rec_grammar = None

        self.grammar_enabled = False
        self.grammar_start_time = 0

    def enable_grammar(self):
        grammar = build_weak_grammar(self.reference)
        if not grammar:
            return False

        self.rec_grammar = KaldiRecognizer(self.model, self.sample_rate)
        self.rec_grammar.SetGrammar(grammar)

        self.grammar_enabled = True
        self.grammar_start_time = time.time()
        print_overwrite("[INFO] Grammar enabled:", grammar)
        return True

    def disable_grammar(self):
        self.rec_grammar = None
        self.grammar_enabled = False
        print_overwrite("[INFO] Grammar disabled")

    def accept_audio(self, pcm_bytes: bytes):
        """
        主入口：喂音频
        """
        rec = self.rec_grammar if self.grammar_enabled else self.rec_free

        if rec.AcceptWaveform(pcm_bytes):
            result = json.loads(rec.Result()).get("text", "")
            return self._handle_final(result)
        else:
            partial = json.loads(rec.PartialResult()).get("partial", "")
            return self._handle_partial(partial)

    def _handle_partial(self, text):
        text = normalize_text(text)
        if not text:
            return None

        score = similarity(text, self.reference)

        # 达到阈值 → 启用 Grammar
        if (not self.grammar_enabled) and score >= SIMILARITY_THRESHOLD:
            self.enable_grammar()

        # Grammar 超时保护
        if self.grammar_enabled and (time.time() - self.grammar_start_time > GRAMMAR_TIMEOUT_SEC):
            self.disable_grammar()

        return {
            "type": "partial",
            "text": text,
            "similarity": round(score, 3),
            "grammar": self.grammar_enabled
        }

    def _handle_final(self, text):
        text = normalize_text(text)
        score = similarity(text, self.reference)

        # 完全一致或包含 → 成功
        if text == self.reference or self.reference in text:
            print_overwrite("[SUCCESS] Matched reference")
            return {
                "type": "final",
                "text": text,
                "similarity": 1.0,
                "success": True
            }

        # Grammar 结束后自动关闭
        if self.grammar_enabled:
            self.disable_grammar()

        return {
            "type": "final",
            "text": text,
            "similarity": round(score, 3),
            "success": False
        }

