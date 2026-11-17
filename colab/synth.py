"""Makes synthetic training pages in the style of note-054: unruled lists of
`Brand ABBR : description` rows under roman-numeral section headings, on
lined notebook paper, in handwriting fonts.

What they teach is structure, not her handwriting: keep reading row by row,
never drop a row, keep each description with its brand, and accept a page
that starts mid-list without a heading. Keep them a minority of the training
set (about a quarter) so her real pages stay the main signal.

    python synth.py --count 15                  # writes into DRIVE_DATA/train
    python synth.py --count 4 --out /content/synth_preview   # look first

Each page is a pair, synth-NNNN.jpg + synth-NNNN.md, in the same label
format as the real notes. The rows are generated combinations: they are
correct transcriptions of the image, not real product facts.
"""

import argparse
import math
import random
import urllib.request
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

import config

FONT_URLS = [
    "ofl/patrickhand/PatrickHand-Regular.ttf",
    "ofl/indieflower/IndieFlower-Regular.ttf",
    "ofl/shadowsintolight/ShadowsIntoLight.ttf",
    "ofl/kalam/Kalam-Regular.ttf",
    "ofl/architectsdaughter/ArchitectsDaughter-Regular.ttf",
    "ofl/gloriahallelujah/GloriaHallelujah.ttf",
    "apache/comingsoon/ComingSoon-Regular.ttf",
    "apache/justanotherhand/JustAnotherHand-Regular.ttf",
    "ofl/gaegu/Gaegu-Regular.ttf",
    "ofl/reeniebeanie/ReenieBeanie.ttf",
    "ofl/coveredbyyourgrace/CoveredByYourGrace.ttf",
    "ofl/nanumpenscript/NanumPenScript-Regular.ttf",
    "ofl/handlee/Handlee-Regular.ttf",
    "apache/schoolbell/Schoolbell-Regular.ttf",
    "ofl/neucha/Neucha.ttf",
]
FONT_BASE = "https://raw.githubusercontent.com/google/fonts/main/"

BRANDS = """
Biogesic Neozep Bioflu Alaxan Ponstan Solmux Kremil Tuseran Decolgen Diatabs
Ceelin Enervon Cherifer Conzace Medicol Dolfenal Flanax Skelan Robitussin
Cozaar Norvasc Lipitor Crestor Plavix Glucophage Galvus Januvia Diamicron
Amaryl Augmentin Amoxil Zithromax Klaricid Ceporex Keflex Ventolin Seretide
Singulair Zyrtec Claritin Allerta Benadryl Iterax Buscopan Imodium Plasil
Gaviscon Nexium Omepron Prevacid Losec Motilium Dulcolax Duphalac Myra
Stresstabs Centrum Pharmaton Propan Appebon Nutroplex Polynerv Neurobion
Arcoxia Celebrex Voltaren Tempra Calpol Disudrin Sinutab Rhinathiol
Mucosolvan Fluimucil Flagyl Bactrim Tegretol Depakote Keppra Dilantin
Rivotril Zoloft Risperdal Zyprexa Abilify Seroquel Plendil Tenormin Concor
Vastarel Isordil Lasix Aldactone Clexane Lanoxin Synthroid Eltroxin Medrol
Decilone Celestone Premarin Duphaston Provera Clomid Cataflam Feldene Mobic
Panfor Clanza Melanov Godex Amara Obynal Clusivol Meganerv Folicard
Pediafortan Ventar Nobiloc Prialta Asfrenon Altria Fluanxol Hemarate
Sangobion Ferlin Tiki-Tiki Growee Nutrilin Moriamin Cortal Eskinol Dequadin
""".split()

# Section heading -> rows (abbreviation, description). "{n}" makes a dose.
SECTIONS = {
    "HIGHER DOSAGE STRENGTH": [
        ("DS", "Double strength"), ("Forte", "Higher strength"),
        ("ES", "Extra strength"), ("Max", "Maximum strength"),
        ("XS", "Extra strength"), ("-{n}", "{n} mg"),
    ],
    "FASTER EFFECT": [
        ("FR", "Fast relief"), ("SF", "Super fast"),
        ("FDT", "Fast disintegrating tablet"), ("QT", "Quick tab"),
        ("ODT", "Orally disintegrating tablet"), ("Rapid", "Rapid acting"),
    ],
    "TIME-RELEASE FORMULATION": [
        ("ER", "Extended release"), ("LA", "Long acting"),
        ("MR", "Modified release"), ("XR", "Extended release"),
        ("OD", "Once daily"), ("SR", "Sustained release"),
        ("CR", "Controlled release"), ("PR", "Prolonged release"),
        ("Retard", "Slow release"),
    ],
    "INDICATION / USE": [
        ("AC", "Acute and chronic pain"), ("AH", "Antihistamine"),
        ("AS", "Appetite stimulant"), ("C", "Vitamin C"), ("E", "Vit. E"),
        ("B Plus", "Vit. B Complex"), ("GE", "Growth enhancer"),
        ("M", "Multivitamins"), ("OB", "Obstetrics"), ("EXP", "Expectorant"),
        ("CCB", "Calcium channel blocker"), ("PGM", "Pubertal Growth Maximizer"),
        ("D", "Decongestant"), ("Kids", "Pediatric"),
    ],
    "MODE OF ADMINISTRATION": [
        ("Depot", "through injection"), ("Sprinkle", "sprinkle on soft food"),
        ("Zydis", "orodispersible"), ("Quicklet", "orodispersible"),
        ("Flash", "orodispersible"), ("Discmelt", "orodispersible"),
        ("Drops", "oral drops"), ("Inhaler", "inhalation"),
        ("Patch", "transdermal"), ("Gel", "topical"),
    ],
    "ADDITIONAL COMPONENT W/ ADDED EFFECT": [
        ("S", "Simethicone"), ("MET", "Metformin"), ("GF", "Guaifenesin"),
        ("PED", "Combination pediatrics"), ("HCT", "Hydrochlorothiazide"),
        ("Plus", "with added ingredient"), ("AM", "Amlodipine"),
        ("XQ", "Extra quality"),
    ],
}
ROMAN = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]

WIDTH, HEIGHT = 1650, 2150


@dataclass
class Row:
    brand: str
    abbr: str
    description: str  # exactly as written, ditto marks included

    @property
    def name(self) -> str:
        return f"{self.brand}{self.abbr}" if self.abbr.startswith("-") else f"{self.brand} {self.abbr}"


@dataclass
class Block:
    heading: str | None  # None: carry-over rows from the previous page
    rows: list[Row]


# ── Content ──────────────────────────────────────────────────────────────

def make_rows(section: str, count: int, rng: random.Random) -> list[Row]:
    options = SECTIONS[section]
    rows, previous = [], None
    for brand in rng.sample(BRANDS, count):
        abbr, description = rng.choice(options)
        if "{n}" in abbr:
            n = rng.choice([2, 4, 5, 8, 10, 20, 40, 50])
            abbr, description = abbr.format(n=n), description.format(n=n)
        written = description
        if previous is not None and rng.random() < 0.6:
            if description == previous:
                written = '"'  # whole description repeated
            elif description.split()[-1] == previous.split()[-1] and " " in description:
                written = description.rsplit(" ", 1)[0] + ' "'  # "Modified \""
        rows.append(Row(brand, abbr, written))
        previous = description
    return rows


def make_page(rng: random.Random) -> list[Block]:
    sections = rng.sample(list(SECTIONS), k=len(SECTIONS))
    number = rng.randint(1, 6)
    blocks = []
    if rng.random() < 0.6:  # starts mid-list, like a continuation page
        blocks.append(Block(None, make_rows(sections.pop(), rng.randint(2, 5), rng)))
    for section in sections:
        heading = f"{ROMAN[number - 1]}. {section}"
        blocks.append(Block(heading, make_rows(section, rng.randint(3, 10), rng)))
        number += 1
    return blocks  # trimmed to what fits when drawn


def to_markdown(blocks: list[Block]) -> str:
    headings = [b.heading for b in blocks if b.heading]
    front = ["---", "date: null", "has_exam_section: false", "exam_sections: []"]
    front += ["sections:"] + [f'  - "{h}"' for h in headings] if headings else ["sections: []"]
    body = []
    for block in blocks:
        if block.heading:
            body += [f"## {block.heading}", ""]
        body += ["| | |", "| --- | --- |"]
        body += [f"| {row.name} | : {row.description} |" for row in block.rows]
        body.append("")
    return "\n".join(front + ["---", ""] + body).rstrip() + "\n"


# ── Drawing ──────────────────────────────────────────────────────────────

class Pen:
    """Draws words one at a time with small random size, angle and baseline
    changes, so text looks hand-written rather than typeset."""

    def __init__(self, font_path: Path, size: int, ink: tuple, rng: random.Random):
        self.font_path, self.size, self.ink, self.rng = font_path, size, ink, rng
        self.fonts: dict[int, ImageFont.FreeTypeFont] = {}

    def font(self, size: int) -> ImageFont.FreeTypeFont:
        if size not in self.fonts:
            self.fonts[size] = ImageFont.truetype(str(self.font_path), size)
        return self.fonts[size]

    def write(self, page: Image.Image, x: float, baseline: float, text: str,
              underline_word: str | None = None) -> float:
        """Writes text with its baseline at `baseline`; returns the end x."""
        for word in text.split(" "):
            if not word:
                continue
            size = max(8, int(self.size * self.rng.uniform(0.93, 1.07)))
            font = self.font(size)
            left, top, right, bottom = font.getbbox(word)
            ascent = font.getmetrics()[0]
            pad = 8
            tile = Image.new("L", (right - left + 2 * pad, bottom - top + 2 * pad), 0)
            ImageDraw.Draw(tile).text((pad - left, pad - top), word, font=font, fill=255)
            tile = tile.rotate(self.rng.uniform(-2.5, 2.5), resample=Image.BICUBIC, expand=True)
            y = baseline - ascent + top - pad + self.rng.uniform(-2.5, 2.5)
            ink = Image.new("RGB", tile.size, self.ink)
            page.paste(ink, (int(x), int(y)), tile.point(lambda v: int(v * self.rng.uniform(0.82, 1.0))))
            word_end = x + tile.width - 2 * pad
            if underline_word and word == underline_word:
                self._underline(page, x + pad - 2, word_end + pad, baseline + size * 0.12)
            x = word_end + size * self.rng.uniform(0.28, 0.42)
        return x

    def _underline(self, page, x0, x1, y):
        draw = ImageDraw.Draw(page)
        mid = (x0 + x1) / 2 + self.rng.uniform(-6, 6)
        width = max(2, self.size // 18)
        draw.line([(x0, y + self.rng.uniform(-2, 2)), (mid, y + self.rng.uniform(-2, 2)),
                   (x1, y + self.rng.uniform(-2, 2))], fill=self.ink, width=width)


def paper(rng: random.Random) -> Image.Image:
    base = np.array([rng.randint(222, 238), rng.randint(226, 240), rng.randint(230, 244)], np.float32)
    ys, xs = np.mgrid[0:HEIGHT, 0:WIDTH].astype(np.float32)
    angle = rng.uniform(0, 2 * math.pi)
    light = 1 + 0.06 * (math.cos(angle) * (xs / WIDTH - 0.5) + math.sin(angle) * (ys / HEIGHT - 0.5))
    pixels = base * light[..., None]
    return Image.fromarray(np.clip(pixels, 0, 255).astype(np.uint8))


def ruled_lines(page, top, spacing, rng):
    draw = ImageDraw.Draw(page)
    colour = (rng.randint(150, 175), rng.randint(160, 185), rng.randint(175, 200))
    y = top
    while y < HEIGHT - 40:
        draw.line([(40, y), (WIDTH - 110, y + rng.uniform(-1.5, 1.5))], fill=colour, width=2)
        y += spacing


def spiral(page, rng):
    draw = ImageDraw.Draw(page)
    x = WIDTH - 70
    for y in range(30, HEIGHT - 30, 42):
        draw.arc([x - 22, y - 12, x + 30, y + 22], start=200, end=60,
                 fill=(70, 72, 78), width=7)


def show_through(page, fonts, spacing, rng):
    """Faint mirrored writing from the back of the sheet."""
    ghost = Image.new("RGB", page.size, (255, 255, 255))
    pen = Pen(rng.choice(fonts), int(spacing * 0.6), (150, 150, 160), rng)
    y = rng.uniform(150, 250)
    while y < HEIGHT - 80:
        words = " ".join(rng.choice(BRANDS) for _ in range(rng.randint(2, 6)))
        pen.write(ghost, rng.uniform(80, WIDTH / 2), y, words)
        y += spacing
    ghost = ghost.transpose(Image.FLIP_LEFT_RIGHT).filter(ImageFilter.GaussianBlur(1.2))
    strength = rng.uniform(0.10, 0.25)
    blended = np.asarray(page, np.float32) * (1 - strength * (1 - np.asarray(ghost, np.float32) / 255))
    page.paste(Image.fromarray(blended.astype(np.uint8)))


def highlight(page, box, rng):
    """Pink highlighter behind a heading (multiplied, like real ink)."""
    x0, y0, x1, y1 = (int(v) for v in box)
    colour = np.array([rng.randint(240, 255), rng.randint(95, 135), rng.randint(160, 200)], np.float32) / 255
    pixels = np.asarray(page, np.float32).copy()
    pixels[y0:y1, x0:x1] *= colour
    page.paste(Image.fromarray(pixels.astype(np.uint8)))


def draw_page(blocks: list[Block], fonts: list[Path], rng: random.Random):
    """Draws as many blocks as fit; returns the image and the blocks drawn."""
    page = paper(rng)
    spacing = rng.randint(48, 58)
    top = rng.randint(150, 230)
    ruled_lines(page, top, spacing, rng)
    if rng.random() < 0.5:
        show_through(page, fonts, spacing, rng)
    if rng.random() < 0.8:
        spiral(page, rng)

    ink = rng.choice([(35, 35, 40), (25, 28, 45), (45, 40, 40), (20, 25, 60)])
    pen = Pen(rng.choice(fonts), int(spacing * rng.uniform(0.62, 0.78)), ink, rng)
    left = rng.randint(70, 110)
    colon_x = left + rng.randint(300, 430)
    bottom = HEIGHT - 2 * spacing
    line = top + spacing * rng.randint(1, 2)
    drawn = []

    for block in blocks:
        needed = (len(block.rows) + (2 if block.heading else 0)) * spacing
        if line + min(needed, 4 * spacing) > bottom:
            break
        if block.heading:
            start = left + rng.uniform(-10, 15)
            baseline = line - spacing * 0.15
            end = pen.write(page, start, baseline, block.heading)
            if rng.random() < 0.8:  # like her pink highlighter; section V had none
                highlight(page, (start - 8, baseline - pen.size * 0.85,
                                 end + 4, baseline + pen.size * 0.25), rng)
            line += spacing
        kept = []
        for row in block.rows:
            if line > bottom:
                break
            x = pen.write(page, left + rng.uniform(-12, 12), line - spacing * 0.15,
                          row.name, underline_word=row.abbr if rng.random() < 0.8 else None)
            colon = max(colon_x + rng.uniform(-10, 10), x + 15)
            pen.write(page, colon, line - spacing * 0.15, ":")
            pen.write(page, colon + rng.uniform(30, 60), line - spacing * 0.15, row.description)
            kept.append(row)
            line += spacing
        if len(kept) < 2:  # never end a page on a heading with no rows
            break
        drawn.append(Block(block.heading, kept))
        line += spacing * rng.randint(1, 2)

    return page, drawn


def load_fonts(directory: Path) -> list[Path]:
    directory.mkdir(parents=True, exist_ok=True)
    paths = []
    for url in FONT_URLS:
        path = directory / url.rsplit("/", 1)[1]
        if not path.exists():
            urllib.request.urlretrieve(FONT_BASE + url, path)
        paths.append(path)
    return paths


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--count", type=int, default=15)
    parser.add_argument("--out", type=Path, default=config.DRIVE_DATA / "train")
    parser.add_argument("--seed", type=int, default=config.SEED)
    args = parser.parse_args()

    rng = random.Random(args.seed)
    fonts = load_fonts(config.LOCAL_CACHE / "fonts")
    args.out.mkdir(parents=True, exist_ok=True)

    for index in range(1, args.count + 1):
        image, drawn = draw_page(make_page(rng), fonts, rng)
        name = f"synth-{index:04d}"
        image.save(args.out / f"{name}.jpg", quality=config.JPEG_QUALITY)
        (args.out / f"{name}.md").write_text(to_markdown(drawn), encoding="utf-8")
        rows = sum(len(b.rows) for b in drawn)
        print(f"{name}: {len(drawn)} blocks, {rows} rows", flush=True)
    print(f"Saved {args.count} pages to {args.out}")


if __name__ == "__main__":
    main()