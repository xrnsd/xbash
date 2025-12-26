import numpy as np

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
