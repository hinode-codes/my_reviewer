"""Loading the model and turning pairs into model inputs."""

import re

import torch
from PIL import Image
from transformers import (
    AutoProcessor, BitsAndBytesConfig, LogitsProcessor, LogitsProcessorList,
    Qwen3VLForConditionalGeneration, StoppingCriteria, StoppingCriteriaList,
)
import config
from data import Pair

# The 4 language-model projections LoRA trains. The vision tower names its
# layers differently (qkv, proj, linear_fc1/2), so it stays frozen: it
# already sees well, and freezing it saves memory and time.
LORA_TARGETS = ["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"]

# The base model often wraps its answer in ```markdown ... ```; the labels
# do not, so the fence is removed before scoring.
_FENCE = re.compile(r"^```(?:markdown|md)?[ \t]*\n(.*?)\n?```\s*$", re.DOTALL)


class RunawayStop(StoppingCriteria):
    """Stops a page that is padding spaces or repeating one line, instead
    of letting it run to MAX_NEW_TOKENS."""

    def __init__(self, tokenizer, prompt_length: int, window: int = 200):
        self.tokenizer = tokenizer
        self.prompt_length = prompt_length
        self.window = window

    def __call__(self, input_ids, scores, **kwargs):
        stop = []
        for row in input_ids:
            tail = self.tokenizer.decode(
                row[self.prompt_length:][-self.window:], skip_special_tokens=True
            )
            lines = [line.strip() for line in tail.splitlines() if line.strip()]
            padding = " " * 40 in tail
            repeating = len(lines) >= 4 and len(set(lines[-4:])) == 1
            stop.append(padding or repeating)
        return torch.tensor(stop, device=input_ids.device)

class NoSpaceRuns(LogitsProcessor):
    """Makes runs of more than `limit` spaces impossible to generate, so the
    model must write the next real character instead of padding a column."""

    _token_spaces: dict[int, tuple[torch.Tensor, torch.Tensor]] = {}

    def __init__(self, tokenizer, prompt_length: int, limit: int = 8):
        self.tokenizer = tokenizer
        self.prompt_length = prompt_length
        self.limit = limit
        self.leading, self.longest = self._space_counts(tokenizer)

    @classmethod
    def _space_counts(cls, tokenizer):
        """Per token: leading spaces, and the longest run inside. Computed once."""
        key = id(tokenizer)
        if key not in cls._token_spaces:
            texts = tokenizer.batch_decode([[i] for i in range(len(tokenizer))])
            leading = [len(t) - len(t.lstrip(" ")) for t in texts]
            longest = [max((len(r) for r in re.findall(r" +", t)), default=0) for t in texts]
            cls._token_spaces[key] = (torch.tensor(leading), torch.tensor(longest))
        return cls._token_spaces[key]

    def __call__(self, input_ids, scores):
        vocab = min(scores.shape[-1], self.leading.shape[0])
        leading = self.leading[:vocab].to(scores.device)
        longest = self.longest[:vocab].to(scores.device)
        scores[:, :vocab][:, longest > self.limit] = float("-inf")
        for row in range(input_ids.shape[0]):
            tail = self.tokenizer.decode(
                input_ids[row, self.prompt_length:][-16:], skip_special_tokens=True
            )
            trailing = len(tail) - len(tail.rstrip(" "))
            if trailing:
                scores[row, :vocab][leading > self.limit - trailing] = float("-inf")
        return scores

def require_gpu() -> None:
    """Fails at once instead of silently running for hours on the CPU."""
    if not torch.cuda.is_available():
        raise RuntimeError(
            "No CUDA GPU. In Colab: Runtime → Change runtime type → GPU, and "
            "check that !nvidia-smi lists one (a used-up GPU quota connects you "
            "to a CPU runtime without saying so)."
        )


def compute_dtype() -> torch.dtype:
    # torch.cuda.is_bf16_supported() is True on a T4 because it counts
    # emulation, and emulated bf16 is several times slower. Real bf16 starts
    # at Ampere (L4, A100: compute capability 8.x); T4 (7.5) gets float16.
    require_gpu()
    if torch.cuda.get_device_capability()[0] >= 8:
        return torch.bfloat16
    return torch.float16


def load_processor():
    return AutoProcessor.from_pretrained(config.MODEL_ID)


def load_model():
    """The base model in 4-bit (QLoRA), vision tower and output head kept in
    full precision so reading quality is not lost to quantisation."""
    dtype = compute_dtype()
    quantization = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_use_double_quant=True,
        bnb_4bit_compute_dtype=dtype,
        llm_int8_skip_modules=["visual", "lm_head"],
    )
    model = Qwen3VLForConditionalGeneration.from_pretrained(
        config.MODEL_ID,
        quantization_config=quantization,
        torch_dtype=dtype,
        device_map="auto",
        attn_implementation="sdpa",
    )
    print(f"Model on {next(model.parameters()).device} "
          f"({torch.cuda.get_device_name()}), compute dtype {dtype}", flush=True)
    return model


def _messages(markdown: str | None) -> list[dict]:
    messages = [{
        "role": "user",
        "content": [
            {"type": "image"},
            {"type": "text", "text": config.INSTRUCTION},
        ],
    }]
    if markdown is not None:
        messages.append({
            "role": "assistant",
            "content": [{"type": "text", "text": markdown}],
        })
    return messages


def _image(pair: Pair) -> Image.Image:
    with Image.open(pair.image_path) as image:
        return image.convert("RGB")


def _unfence(text: str) -> str:
    text = text.strip()
    match = _FENCE.match(text)
    return match.group(1).strip() if match else text


class TrainingCollator:
    """Builds a batch where the loss covers only the Markdown answer (and the
    end-of-turn token, so the model learns to stop), not the image or the
    instruction."""

    def __init__(self, processor):
        self.processor = processor
        tokenizer = processor.tokenizer
        self.pad_id = tokenizer.pad_token_id
        self.answer_start = tokenizer.encode(
            "<|im_start|>assistant\n", add_special_tokens=False
        )

    def _answer_offset(self, ids: list[int]) -> int:
        marker, n = self.answer_start, len(self.answer_start)
        for start in range(len(ids) - n, -1, -1):
            if ids[start:start + n] == marker:
                return start + n
        raise ValueError("assistant turn not found; did the chat template change?")

    def __call__(self, pairs: list[Pair]) -> dict:
        self.processor.tokenizer.padding_side = "right"
        texts = [
            self.processor.apply_chat_template(
                _messages(pair.markdown), tokenize=False, add_generation_prompt=False
            )
            for pair in pairs
        ]
        batch = self.processor(
            text=texts,
            images=[_image(pair) for pair in pairs],
            padding=True,
            return_tensors="pt",
        )
        batch.pop("token_type_ids", None)

        labels = batch["input_ids"].clone()
        for row, ids in enumerate(batch["input_ids"].tolist()):
            labels[row, : self._answer_offset(ids)] = -100
        labels[batch["attention_mask"] == 0] = -100
        batch["labels"] = labels

        return batch


@torch.inference_mode()
def generate(model, processor, pairs: list[Pair]) -> list[str]:
    """Writes Markdown for each page from its image alone; the annotation is
    never shown to the model."""
    processor.tokenizer.padding_side = "left"  # generation needs left padding
    texts = [
        processor.apply_chat_template(
            _messages(None), tokenize=False, add_generation_prompt=True
        )
        for _ in pairs
    ]
    inputs = processor(
        text=texts,
        images=[_image(pair) for pair in pairs],
        padding=True,
        return_tensors="pt",
    ).to(model.device)
    inputs.pop("token_type_ids", None)

    prompt_length = inputs["input_ids"].shape[1]
    output = model.generate(
        **inputs,
        max_new_tokens=config.MAX_NEW_TOKENS,
        do_sample=False,
        logits_processor=LogitsProcessorList(
            [NoSpaceRuns(processor.tokenizer, prompt_length)]
        ),
        stopping_criteria=StoppingCriteriaList(
            [RunawayStop(processor.tokenizer, prompt_length)]
        ),
    )
    new_tokens = output[:, inputs["input_ids"].shape[1]:]
    return [
        _unfence(text)
        for text in processor.batch_decode(new_tokens, skip_special_tokens=True)
    ]