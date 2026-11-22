"""Cleans the `sections:` / `exam_sections:` lists in the YAML front matter of
each note-NNN.md file:

1. Every item is wrapped in double quotes.
2. Every heading in the body (#, ##, ###, ...) appears in a list. Headings
   already in exam_sections stay there; all others go to sections.
3. `sections` follows the body's heading order, each heading once (a heading
   repeated on the page, e.g. a running title, is listed once).
4. Visual padding is removed from the body: `&nbsp;` (and `&#160;`, `&ensp;`,
   `&emsp;`, the U+00A0 character). A table cell holding only padding becomes
   an empty cell; padding around text in a cell is dropped; padding inside
   text becomes one normal space. Lines without padding are left untouched.
   Padding inside fenced code blocks is kept.

Items in `sections` that match no heading in the body are kept at the end
and reported, so you can decide whether they belong.

Apart from step 4, only the front matter is rewritten.

    python quote_sections.py <folder>            # dry run: shows changes
    python quote_sections.py <folder> --write    # applies them
"""

import difflib
import json
import re
import sys
from pathlib import Path

KEYS = ("sections", "exam_sections")
KEY_LINE = re.compile(r"^(\w+):\s*(.*?)\s*$")
ITEM_LINE = re.compile(r"^\s*-\s+(.*?)\s*$")
HEADING = re.compile(r"^#{1,6}\s+(.+?)\s*#*\s*$")
FENCE = re.compile(r"^\s*(```|~~~)")
PADDING = re.compile(r"(?:&nbsp;|&#160;|&#xa0;|&ensp;|&emsp;|\u00a0)", re.IGNORECASE)
CELL_SPLIT = re.compile(r"(?<!\\)\|")


def unquote(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] == '"':
        return json.loads(value)
    if len(value) >= 2 and value[0] == value[-1] == "'":
        return value[1:-1].replace("''", "'")
    return value


def quote(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)  # valid YAML double-quoted string


def body_headings(body: list[str]) -> list[str]:
    """Headings in page order, each once, ignoring fenced code blocks."""
    seen, ordered, in_fence = set(), [], False
    for line in body:
        if FENCE.match(line):
            in_fence = not in_fence
            continue
        match = None if in_fence else HEADING.match(line)
        if match and match.group(1) not in seen:
            seen.add(match.group(1))
            ordered.append(match.group(1))
    return ordered


def _clean_cell(cell: str) -> str:
    return re.sub(r" {2,}", " ", PADDING.sub(" ", cell)).strip()


def remove_padding(body: list[str]) -> tuple[list[str], int]:
    """Drops visual padding entities; returns new lines and how many changed."""
    out, changed, in_fence = [], 0, False
    for line in body:
        if FENCE.match(line):
            in_fence = not in_fence
        if in_fence or not PADDING.search(line):
            out.append(line)
            continue
        changed += 1
        stripped = line.strip()
        if stripped.startswith("|"):
            indent = line[: len(line) - len(line.lstrip())]
            cells = CELL_SPLIT.split(stripped)
            # A row "| a | b |" splits into ["", " a ", " b ", ""].
            inner = cells[1:-1] if stripped.endswith("|") and len(cells) > 2 else cells[1:]
            rendered = " | ".join(_clean_cell(c) for c in inner)
            out.append(f"{indent}| {rendered} |".replace("|  |", "| |"))
        else:
            indent = line[: len(line) - len(line.lstrip(" "))]
            text = PADDING.sub(" ", line[len(indent):])
            out.append(indent + re.sub(r" {2,}", " ", text).strip())
    return out, changed


def read_lists(front: list[str]) -> tuple[dict[str, list[str]], dict[str, tuple[int, int]]]:
    """Each key's items and the (start, end) line span its block occupies."""
    items, spans = {}, {}
    i = 0
    while i < len(front):
        key = KEY_LINE.match(front[i])
        if key and key.group(1) in KEYS:
            name, inline = key.group(1), key.group(2)
            start, i = i, i + 1
            if inline.startswith("[") and inline.endswith("]"):
                inner = inline[1:-1].strip()
                values = [v.strip() for v in inner.split(",")] if inner else []
            elif inline:
                raise ValueError(f"unsupported value for {name}: {inline}")
            else:
                values = []
                while i < len(front) and ITEM_LINE.match(front[i]):
                    values.append(ITEM_LINE.match(front[i]).group(1))
                    i += 1
            items[name] = [unquote(v) for v in values]
            spans[name] = (start, i)
        else:
            i += 1
    return items, spans


def render(name: str, values: list[str]) -> list[str]:
    if not values:
        return [f"{name}: []"]
    return [f"{name}:"] + [f"  - {quote(v)}" for v in values]


def fix(text: str) -> tuple[str, list[str]]:
    """Returns the fixed text and warnings for this file."""
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return text, ["no front matter"]
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        return text, ["front matter not closed"]

    front, body = lines[1:end], lines[end + 1:]
    items, spans = read_lists(front)
    headings = body_headings(body)
    exam = items.get("exam_sections", [])

    in_body = [h for h in headings if h not in exam]
    stale = [s for s in items.get("sections", []) if s not in headings]
    sections = in_body + stale
    warnings = [f"in sections but not a heading in the body: {s!r}" for s in stale]

    new_blocks = {"sections": sections, "exam_sections": exam}
    # Replace existing blocks from the bottom up so earlier spans stay valid.
    for name in sorted(spans, key=lambda n: spans[n][0], reverse=True):
        start, stop = spans[name]
        front[start:stop] = render(name, new_blocks[name])
    for name in KEYS:  # a key missing entirely is appended
        if name not in spans:
            front.extend(render(name, new_blocks[name]))

    closing, rest = lines[end], lines[end + 1:]
    rest, padded = remove_padding(rest)
    if padded:
        warnings.append(f"removed padding on {padded} line(s)")
    return "\n".join([lines[0], *front, closing, *rest]), warnings


def main() -> None:
    write = "--write" in sys.argv
    folders = [Path(a) for a in sys.argv[1:] if a != "--write"]
    changed = 0
    for path in sorted(p for folder in folders for p in folder.rglob("*.md")):
        if path.name.endswith(".draft.md"):
            continue
        original = path.read_text(encoding="utf-8")
        try:
            fixed, warnings = fix(original)
        except ValueError as error:
            print(f"!! {path}: {error} (fix by hand)")
            continue
        for warning in warnings:
            print(f"?? {path}: {warning}")
        if fixed == original:
            continue
        changed += 1
        diff = difflib.unified_diff(
            original.split("\n"), fixed.split("\n"), lineterm="", n=0
        )
        print(f"== {path}")
        print("\n".join(line for line in diff if not line.startswith(("---", "+++"))))
        print()
        if write:
            path.write_text(fixed, encoding="utf-8")
    print(f"{changed} file(s) {'updated' if write else 'would change (dry run; add --write)'}")


if __name__ == "__main__":
    main()