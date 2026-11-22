"""Scores a predicted Markdown page against its annotation."""

import re


def edit_distance(a: str, b: str) -> int:
    """Fewest single-character edits turning a into b (Levenshtein)."""
    if len(a) < len(b):
        a, b = b, a
    previous = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        current = [i]
        for j, cb in enumerate(b, 1):
            current.append(min(
                previous[j] + 1,
                current[j - 1] + 1,
                previous[j - 1] + (ca != cb),
            ))
        previous = current
    return previous[-1]


def plain_text(markdown: str) -> str:
    """The words only: Markdown symbols and spacing removed."""
    text = re.sub(r"[#*_`>\-|]+", " ", markdown)
    return " ".join(text.split())


def score_page(prediction: str, reference: str) -> dict[str, float]:
    text_pred, text_ref = plain_text(prediction), plain_text(reference)
    ref_words = set(text_ref.lower().split())
    pred_words = text_pred.lower().split()

    return {
        # Reading: wrong characters per character, ignoring formatting.
        "text_cer": edit_distance(text_pred, text_ref) / max(1, len(text_ref)),
        # Reading + formatting: the full Markdown compared.
        "markdown_cer": edit_distance(prediction, reference) / max(1, len(reference)),
        # Made-up words: share of output words that are not in the page at all.
        "invented_words": sum(w not in ref_words for w in pred_words)
        / max(1, len(pred_words)),
    }


def average(scores: list[dict[str, float]]) -> dict[str, float]:
    return {key: sum(s[key] for s in scores) / len(scores) for key in scores[0]}
