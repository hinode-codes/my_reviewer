"""Loads the image + Markdown pairs and caches resized images locally."""

import shutil
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageOps

import config


@dataclass(frozen=True)
class Pair:
    name: str
    image_path: Path
    markdown: str


def _find_pairs(folder: Path) -> list[tuple[Path, Path]]:
    if not folder.is_dir():
        raise FileNotFoundError(f"No folder at {folder}")

    images = sorted(
        p for p in folder.iterdir()
        if p.is_file() and p.suffix.lower() in config.IMAGE_EXTENSIONS
    )
    pairs, missing = [], []

    for image in images:
        markdown = image.with_suffix(".md")
        if markdown.exists():
            pairs.append((image, markdown))
        else:
            missing.append(image.name)

    if missing:
        raise FileNotFoundError(
            f"{folder.name}: no .md for {len(missing)} image(s), e.g. {missing[:5]}"
        )
    if not pairs:
        raise FileNotFoundError(f"{folder} has no image + .md pairs")

    return pairs


def _resize(source: Path, target: Path) -> None:
    with Image.open(source) as image:
        # Phone photos store rotation in EXIF; apply it, or pages train sideways.
        image = ImageOps.exif_transpose(image).convert("RGB")
        image.thumbnail((config.MAX_LONG_EDGE, config.MAX_LONG_EDGE))
        image.save(target, "JPEG", quality=config.JPEG_QUALITY)


def prepare_split(split: str) -> list[Pair]:
    """Copies a split from Drive to local disk, resized, once. Later runs
    reuse the cache unless the source changed."""
    source_dir = config.DRIVE_DATA / split
    cache_dir = config.LOCAL_CACHE / split
    cache_dir.mkdir(parents=True, exist_ok=True)

    pairs = []
    for image, markdown in _find_pairs(source_dir):
        cached = cache_dir / f"{image.stem}.jpg"
        if not cached.exists() or cached.stat().st_mtime < image.stat().st_mtime:
            _resize(image, cached)

        text = markdown.read_text(encoding="utf-8").strip()
        if not text:
            raise ValueError(f"{markdown} is empty")

        pairs.append(Pair(name=image.stem, image_path=cached, markdown=text))

    return pairs


def check_no_overlap(splits: dict[str, list[Pair]]) -> None:
    """The same page name in two splits usually means a page was copied twice,
    which makes the scores look better than they are."""
    seen: dict[str, str] = {}
    for split, pairs in splits.items():
        for pair in pairs:
            if pair.name in seen:
                raise ValueError(
                    f"{pair.name} is in both {seen[pair.name]} and {split}"
                )
            seen[pair.name] = split


def clear_cache() -> None:
    shutil.rmtree(config.LOCAL_CACHE, ignore_errors=True)
