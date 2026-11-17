#!/usr/bin/env python3
"""Turn Kenney's Casino Audio pack into the app's four UI sounds.

Usage:
    python3 trim_ui_sounds.py <unzipped kenney_casino-audio folder> <assets/sounds>

Needs ffmpeg on PATH (to decode the pack's .ogg files); nothing else
beyond the Python standard library.

For each sound it:
  1. decodes to 44.1 kHz mono, the audio engine's default rate;
  2. cuts the silence before the first real sound, so it starts on time;
  3. cuts the quiet tail, then caps the length to the flight's;
  4. fades the start in briefly and the end out, so neither clicks;
  5. normalises loudness so the four sit together, quiet, under music.

Swap the source files in SOUNDS to audition other sounds from the pack.
"""

import array
import subprocess
import sys
import wave
from pathlib import Path

SAMPLE_RATE = 44_100
MAX_SAMPLE = 32_767

# Sound below this counts as silence when trimming the ends.
SILENCE_DBFS = -45.0

# Kept before the detected start, so the very first transient survives.
ONSET_PADDING_MS = 3

# A route transition is about 300 ms; the sound should not outlast it.
MAX_LENGTH_MS = 280

FADE_IN_MS = 2
FADE_OUT_MS = 25

# Every sound peaks here before its own gain. Well below 0 dBFS: these
# decorate the UI and should sit under whatever else is playing.
TARGET_PEAK_DBFS = -6.0

# Output file -> (source file in the pack, extra gain in dB).
# Page sounds are one sheet, so a little lighter than the stack's.
SOUNDS = {
    "stack_spread.wav": ("cardFan1.ogg", 0.0),
    "stack_gather.wav": ("cardPlace1.ogg", 0.0),
    "page_open.wav": ("cardSlide1.ogg", -3.0),
    "page_close.wav": ("cardPlace2.ogg", -4.0),
}


def db_to_gain(db: float) -> float:
    return 10 ** (db / 20)


def decode(path: Path) -> array.array:
    raw = subprocess.run(
        [
            "ffmpeg", "-v", "error", "-i", str(path),
            "-ac", "1", "-ar", str(SAMPLE_RATE), "-f", "s16le", "-",
        ],
        check=True,
        capture_output=True,
    ).stdout
    samples = array.array("h")
    samples.frombytes(raw)
    return samples


def trim(samples: array.array) -> list[float]:
    threshold = MAX_SAMPLE * db_to_gain(SILENCE_DBFS)
    loud = [i for i, s in enumerate(samples) if abs(s) > threshold]

    if not loud:
        raise ValueError("source is silent")

    padding = SAMPLE_RATE * ONSET_PADDING_MS // 1000
    start = max(0, loud[0] - padding)
    end = min(loud[-1] + 1, start + SAMPLE_RATE * MAX_LENGTH_MS // 1000)

    return [float(s) for s in samples[start:end]]


def fade(samples: list[float]) -> None:
    fade_in = min(len(samples), SAMPLE_RATE * FADE_IN_MS // 1000)
    fade_out = min(len(samples) // 4, SAMPLE_RATE * FADE_OUT_MS // 1000)

    for i in range(fade_in):
        samples[i] *= i / fade_in

    for i in range(fade_out):
        samples[len(samples) - 1 - i] *= i / fade_out


def normalise(samples: list[float], extra_db: float) -> array.array:
    peak = max(abs(s) for s in samples) or 1.0
    gain = MAX_SAMPLE * db_to_gain(TARGET_PEAK_DBFS + extra_db) / peak

    return array.array(
        "h",
        (max(-MAX_SAMPLE, min(MAX_SAMPLE, round(s * gain))) for s in samples),
    )


def write(path: Path, samples: array.array) -> None:
    with wave.open(str(path), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(SAMPLE_RATE)
        out.writeframes(samples.tobytes())


AUDIO_EXTENSIONS = {".ogg", ".wav", ".mp3", ".flac"}


def _key(name: str) -> str:
    """cardFan1.ogg, card-fan-1.ogg and card_fan_1.wav all become cardfan1:
    the pack's file names have changed style between releases."""
    stem = Path(name).stem
    return "".join(ch for ch in stem.lower() if ch.isalnum())


def audio_files(pack: Path) -> list[Path]:
    return sorted(
        p for p in pack.rglob("*")
        if p.is_file() and p.suffix.lower() in AUDIO_EXTENSIONS
    )


def find(files: list[Path], name: str) -> Path:
    matches = [p for p in files if _key(p.name) == _key(name)]

    if not matches:
        raise FileNotFoundError(name)

    return matches[0]


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(__doc__)

    pack, out_dir = Path(sys.argv[1]).expanduser(), Path(sys.argv[2])

    if not pack.is_dir():
        sys.exit(f"No folder at {pack}. Unzip the pack and pass its folder.")

    files = audio_files(pack)

    if not files:
        sys.exit(f"No audio files under {pack}. Is it the unzipped pack?")

    missing = []
    for source, _ in SOUNDS.values():
        try:
            find(files, source)
        except FileNotFoundError:
            missing.append(source)

    if missing:
        print(f"Not in the pack: {', '.join(missing)}. It has:")
        for path in files:
            print(f"  {path.relative_to(pack)}")
        sys.exit("Edit SOUNDS at the top of this script to use names above.")

    out_dir.mkdir(parents=True, exist_ok=True)

    for output, (source, extra_db) in SOUNDS.items():
        samples = trim(decode(find(files, source)))
        fade(samples)
        result = normalise(samples, extra_db)
        write(out_dir / output, result)

        length_ms = len(result) * 1000 // SAMPLE_RATE
        print(f"{output:<18} <- {source:<16} {length_ms:>4} ms")


if __name__ == "__main__":
    main()