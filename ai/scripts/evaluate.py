"""Scores a model on a split: it writes Markdown from each image, and that
is compared with the split's .md files.

    python evaluate.py --name baseline                    # untrained model
    python evaluate.py --name finetuned --adapter <dir>   # after training
"""

import argparse
import csv
import json
import time

import torch
from peft import PeftModel

import config
from data import prepare_split
from metrics import average, score_page
from model import generate, load_model, load_processor, require_gpu


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True, help="results folder name, e.g. baseline")
    parser.add_argument("--adapter", help="trained LoRA adapter folder; omit for the base model")
    parser.add_argument("--split", default="test", choices=config.SPLITS)
    args = parser.parse_args()

    require_gpu()  # before the slow data and model steps, not after them

    pairs = prepare_split(args.split)
    processor = load_processor()
    model = load_model()
    if args.adapter:
        model = PeftModel.from_pretrained(model, args.adapter)
    model.eval()
    model.config.use_cache = True

    out_dir = config.DRIVE_OUTPUT / "results" / args.name
    (out_dir / "predictions").mkdir(parents=True, exist_ok=True)

    rows, started = [], time.time()
    size = config.GENERATION_BATCH_SIZE
    print(f"Generating {len(pairs)} pages, {size} per batch", flush=True)

    for start in range(0, len(pairs), size):
        batch = pairs[start:start + size]
        try:
            predictions = generate(model, processor, batch)
        except torch.cuda.OutOfMemoryError:
            # One page at a time instead of failing the whole run.
            torch.cuda.empty_cache()
            predictions = [generate(model, processor, [p])[0] for p in batch]

        for pair, prediction in zip(batch, predictions):
            print(f"--- RAW OUTPUT FOR {pair.name} ---")
            print(repr(prediction)) # repr() will show hidden spaces and \n
            print("-----------------------------------")
            (out_dir / "predictions" / f"{pair.name}.md").write_text(prediction, encoding="utf-8")
            rows.append({"page": pair.name, **score_page(prediction, pair.markdown)})

        done = start + len(batch)
        elapsed = time.time() - started
        remaining = elapsed / done * (len(pairs) - done)
        print(f"{done}/{len(pairs)} pages, {elapsed / done:.1f} s/page, "
              f"~{remaining / 60:.0f} min left", flush=True)

    summary = {"split": args.split, "pages": len(rows), "adapter": args.adapter, **average(
        [{k: v for k, v in r.items() if k != "page"} for r in rows]
    )}

    with open(out_dir / "per_page.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    (out_dir / "scores.json").write_text(json.dumps(summary, indent=2))

    print(json.dumps(summary, indent=2))
    print(f"Saved to {out_dir}")


if __name__ == "__main__":
    main()
