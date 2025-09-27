#!/bin/bash

set -e

CHECKPOINT=/home/Spencer.Clark/scratch/2025-09-26-fme-output/fme-output/3755651/training_checkpoints/best_inference_ckpt.tar
FME_VENV=2025-09-26-fme
INFERENCE_CONFIG=ace-inference-config.yaml
SCRIPT_DIR=$(pwd)
SCRATCH=/scratch4/GFDL/gfdlscr/Spencer.Clark/2025-09-26-fme-output
WANDB_NAME=2025-09-26-test-inference
WANDB_USERNAME=spencerc_ai2
OVERRIDE="checkpoint_path=$CHECKPOINT"

conda run --name $FME_VENV \
    python -m fme.ace.validate_config \
    --config_type inference \
    $INFERENCE_CONFIG --override $OVERRIDE
bash run-inference-ursa.sh \
     $FME_VENV \
     $INFERENCE_CONFIG \
     $SCRIPT_DIR \
     $SCRATCH \
     $WANDB_NAME \
     $WANDB_USERNAME \
     $OVERRIDE
