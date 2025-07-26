import numpy as np
from scipy.special import expit

# === Parameters tuned to match paper results === 
SDR_SCALE = 0.3
SDR_OFFSET = 1.0
MEL_SCALE = 1.2
MEL_OFFSET = -3.0

def normalize_bounded(value, min_val, max_val):
    """Min-max normalization for bounded metrics like STOI or PESQ."""
    return (value - min_val) / (max_val - min_val)

def normalize_unbounded_sigmoid(value, scale=1.0, offset=0.0, invert=False):
    """Sigmoid normalization for unbounded metrics like SDR or Mel Loss."""
    x = scale * (value + offset)
    sigmoid_val = expit(x)
    return 1 - sigmoid_val if invert else sigmoid_val

def harmonic_mean(values):
    values = np.array(values)
    return len(values) / np.sum(1.0 / values)

def compute_overall_score(metrics):
    """
    Compute overall signal-level score from raw metric values.
    Expected keys:
        - 'SDR': float
        - 'Mel_Loss': float
        - 'STOI': float (optional)
        - 'PESQ': float (optional)
    """
    norm_sdr = normalize_unbounded_sigmoid(metrics["SDR"], scale=SDR_SCALE, offset=SDR_OFFSET)
    norm_mel = normalize_unbounded_sigmoid(metrics["Mel_Loss"], scale=MEL_SCALE, offset=MEL_OFFSET, invert=True)

    norm_values = [norm_sdr, norm_mel]

    if "STOI" in metrics:
        norm_stoi = normalize_bounded(metrics["STOI"], 0.0, 1.0)
        norm_values.append(norm_stoi)

    if "PESQ" in metrics:
        norm_pesq = normalize_bounded(metrics["PESQ"], 0.5, 4.5)
        norm_values.append(norm_pesq)

    return harmonic_mean(norm_values)
    
    
example_speech_metrics = {
    "SDR": 5.8,
    "Mel_Loss": 0.8,
    "STOI": 0.8,
    "PESQ": 2.8
}

example_audio_metrics = {
    "SDR": 1.8,
    "Mel_Loss": 1.8
}


# Compute scores
speech_score = compute_overall_score(example_speech_metrics)
audio_score = compute_overall_score(example_audio_metrics)

# Display results
print("Speech Score:", round(speech_score, 3))
print("Audio Score:", round(audio_score, 3))
