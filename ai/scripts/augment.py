from pathlib import Path
from PIL import Image, ImageEnhance
import shutil

# Point this to your actual train folder
train_dir = Path("../dataset/train")

# This will create a new folder next to it so we don't ruin the original data
aug_dir = train_dir.parent / "train_augmented"
aug_dir.mkdir(exist_ok=True)

print(train_dir)

count = 0
for img_path in train_dir.glob("*.jpg"): # change to .png if needed
    md_path = img_path.with_suffix('.md')
    if not md_path.exists():
        continue

    base_name = img_path.stem
    img = Image.open(img_path)

    # --- VARIATION 0: The Original ---
    img.save(aug_dir / f"{base_name}_orig.jpg")
    shutil.copy(md_path, aug_dir / f"{base_name}_orig.md")

    # --- VARIATION 1: Darker & slightly rotated left ---
    # Simulates bad room lighting and a crooked camera
    img_dark = ImageEnhance.Brightness(img).enhance(0.7)
    img_dark = img_dark.rotate(1.5, expand=True, fillcolor=(255,255,255)) # Fill white borders
    img_dark.save(aug_dir / f"{base_name}_v1.jpg")
    shutil.copy(md_path, aug_dir / f"{base_name}_v1.md")

    # --- VARIATION 2: Brighter, high contrast, rotated right ---
    # Simulates washed-out flash photography
    img_bright = ImageEnhance.Brightness(img).enhance(1.2)
    img_bright = ImageEnhance.Contrast(img_bright).enhance(1.3)
    img_bright = img_bright.rotate(-1.5, expand=True, fillcolor=(255,255,255))
    img_bright.save(aug_dir / f"{base_name}_v2.jpg")
    shutil.copy(md_path, aug_dir / f"{base_name}_v2.md")

    count += 3

print(f"✅ Done! Generated {count} training pairs in {aug_dir.name}")