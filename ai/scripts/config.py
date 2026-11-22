"""Every setting in one place. Edit here, not in the other scripts."""

from pathlib import Path

# ── Where things live ────────────────────────────────────────────────────
# Your Drive folder with train/, validation/ and test/ inside. Each holds
# pairs with matching names: 0001.jpg + 0001.md.
#DRIVE_DATA = Path("/content/drive/MyDrive/personal_projects/apps/my_reviewer/llm")

# Results and checkpoints go to Drive, so a Colab disconnect loses nothing.
#DRIVE_OUTPUT = Path("/content/drive/MyDrive/personal_projects/apps/my_reviewer/llm/runs")

# Fast local disk: resized images are cached here once (Drive reads are slow).
#LOCAL_CACHE = Path("/content/cache")


DRIVE_DATA   = Path("/kaggle/input/datasets/aaronangeloragudos/gdrive")   # folder holding train/validation/test
DRIVE_OUTPUT = Path("/kaggle/working/runs")
LOCAL_CACHE  = Path("/kaggle/working/cache")

SPLITS = ("train", "train_augmented", "validation", "test")
IMAGE_EXTENSIONS = (".jpg", ".jpeg", ".png", ".webp")

# ── Model ────────────────────────────────────────────────────────────────
MODEL_ID = "Qwen/Qwen3-VL-2B-Instruct"

# The one instruction. Use exactly this text in the app too.
INSTRUCTION = "Transcribe this handwritten page to Markdown."

# ── Images ───────────────────────────────────────────────────────────────
# Longest side after resizing. Visual tokens grow with area (about one per
# 32x32 px for Qwen3-VL), so this is the biggest lever on speed and memory.
# Handwriting needs detail: lower it if you run out of memory, raise it if
# small writing is misread.
MAX_LONG_EDGE = 1560
JPEG_QUALITY = 96

# ── Training ─────────────────────────────────────────────────────────────
EPOCHS = 6
LEARNING_RATE = 1e-5
BATCH_SIZE = 1  # pages per step on the GPU
GRAD_ACCUMULATION = 8  # effective batch = BATCH_SIZE * GRAD_ACCUMULATION
WARMUP_RATIO = 0.1
LORA_R = 16
LORA_ALPHA = 32
LORA_DROPOUT = 0.05
# Stop when validation loss has not improved for this many evaluations.
EARLY_STOPPING_PATIENCE = 2
SEED = 42

WEIGHT_DECAY = 0.01
NEFTUNE_NOISE_ALPHA = 5.0
LABEL_SMOOTHING_FACTOR = 0.0

# ── Generation (baseline and final scoring) ──────────────────────────────
GENERATION_BATCH_SIZE = 4
MAX_NEW_TOKENS = 2080  # longest Markdown a page may produce
