import dac

import os
import dac
from audiotools import AudioSignal
from tqdm import tqdm
from pathlib import Path

# Official DAC
model_path = dac.utils.download(model_type="24khz")
model = dac.DAC.load(model_path)

DEVICE = "cuda"

TEST_DIR = f"/teamspace/studios/this_studio/test_dataset"
OUT_DIR = f"/teamspace/studios/this_studio/output_dataset"

model.to(DEVICE)

print(f"Model device {model.device}")
print(f"Model sampling rate: {model.sample_rate}")

# Find wav files in TEST_DIR and its subdirectories
wav_files = []
for root, dirs, files in os.walk(TEST_DIR):
    files = [f for f in files if f.endswith(".wav") or f.endswith(".flac")]
    for file in files:
        wav_files.append(os.path.join(root, file))

print(f"Found {len(wav_files)} audio files in {TEST_DIR}")

# Resynthesis
for wav_file in tqdm(wav_files):
      out_file = os.path.join(OUT_DIR, os.path.relpath(wav_file, TEST_DIR))
      if os.path.exists(out_file):
          continue

      # Load and resample audio signal if needed
      signal = AudioSignal(wav_file)
      sr = signal.sample_rate
      if sr != model.sample_rate:
          signal.resample(model.sample_rate)

      # Resynthesize
      signal.to(model.device)
      x = model.compress(signal, win_duration=5.0)
      y = model.decompress(x)

      # Resample to the original sampling rate
      y.resample(sr)

      # Write
      out_dir = os.path.dirname(out_file)
      Path(out_dir).mkdir(parents=True, exist_ok=True)
      y.cpu().write(out_file)
