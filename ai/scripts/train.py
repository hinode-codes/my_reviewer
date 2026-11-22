"""Fine-tunes the model on train/, watching validation/ to keep the best
checkpoint. The test split is never touched here.

    python train.py
"""

import json
import math
import shutil

import torch
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from torch.utils.data import Dataset
from transformers import EarlyStoppingCallback, Trainer, TrainingArguments, set_seed

import config
from data import check_no_overlap, prepare_split
from model import LORA_TARGETS, TrainingCollator, compute_dtype, load_model, load_processor


class PairDataset(Dataset):
    def __init__(self, pairs):
        self.pairs = pairs

    def __len__(self):
        return len(self.pairs)

    def __getitem__(self, index):
        return self.pairs[index]


def warmup_steps(train_pages: int) -> int:
    steps_per_epoch = math.ceil(train_pages / (config.BATCH_SIZE * config.GRAD_ACCUMULATION))
    return max(1, round(steps_per_epoch * config.EPOCHS * config.WARMUP_RATIO))


def main() -> None:
    set_seed(config.SEED)

    # Clear previous collapsed checkpoints so training starts clean
    if config.DRIVE_OUTPUT.exists():
        shutil.rmtree(config.DRIVE_OUTPUT)

    splits = {split: prepare_split(split) for split in config.SPLITS}
    check_no_overlap(splits)
    print({split: len(pairs) for split, pairs in splits.items()}, flush=True)

    processor = load_processor()
    model = load_model()
    model = prepare_model_for_kbit_training(
        model,
        use_gradient_checkpointing=True,
        gradient_checkpointing_kwargs={"use_reentrant": False},
    )
    model = get_peft_model(model, LoraConfig(
        r=config.LORA_R,
        lora_alpha=config.LORA_ALPHA,
        lora_dropout=config.LORA_DROPOUT,
        target_modules=LORA_TARGETS,
        bias="none",
        task_type="CAUSAL_LM",
    ))
    model.print_trainable_parameters()

    run_dir = config.DRIVE_OUTPUT / "checkpoints"
    use_bf16 = compute_dtype() == torch.bfloat16
    warmup = warmup_steps(len(splits["train_augmented"]))
    print(f"Warmup: {warmup} optimiser steps", flush=True)

    args = TrainingArguments(
        output_dir=str(run_dir),
        num_train_epochs=config.EPOCHS,
        learning_rate=config.LEARNING_RATE,
        max_grad_norm=1.0,  # prevents gradient spikes from collapsing LoRA weights
        per_device_train_batch_size=config.BATCH_SIZE,
        per_device_eval_batch_size=config.BATCH_SIZE,
        gradient_accumulation_steps=config.GRAD_ACCUMULATION,
        warmup_steps=warmup,
        lr_scheduler_type="cosine",
        optim="paged_adamw_8bit",
        bf16=use_bf16,
        fp16=not use_bf16,
        gradient_checkpointing=True,
        gradient_checkpointing_kwargs={"use_reentrant": False},
        eval_strategy="epoch",
        save_strategy="epoch",
        save_total_limit=2,
        load_best_model_at_end=True,
        metric_for_best_model="eval_loss",
        weight_decay=config.WEIGHT_DECAY,
        neftune_noise_alpha=config.NEFTUNE_NOISE_ALPHA,
        label_smoothing_factor=config.LABEL_SMOOTHING_FACTOR,
        greater_is_better=False,
        prediction_loss_only=True,
        logging_steps=5,
        remove_unused_columns=False,
        dataloader_num_workers=2,
        report_to="none",
        seed=config.SEED,
    )

    trainer = Trainer(
        model=model,
        args=args,
        train_dataset=PairDataset(splits["train_augmented"]),
        eval_dataset=PairDataset(splits["validation"]),
        data_collator=TrainingCollator(processor),
        callbacks=[EarlyStoppingCallback(config.EARLY_STOPPING_PATIENCE)],
    )

    trainer.train()

    best_dir = config.DRIVE_OUTPUT / "adapter_best"
    trainer.save_model(str(best_dir))
    processor.save_pretrained(str(best_dir))

    history = [e for e in trainer.state.log_history if "eval_loss" in e]
    (config.DRIVE_OUTPUT / "validation_history.json").write_text(json.dumps(history, indent=2))
    print("Validation loss per epoch:")
    for entry in history:
        print(f"  epoch {entry['epoch']:.0f}: {entry['eval_loss']:.4f}")
    print(f"Best adapter saved to {best_dir}")


if __name__ == "__main__":
    main()