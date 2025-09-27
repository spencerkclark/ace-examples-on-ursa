#!/bin/bash

set -e

CHECKPOINT=/home/Spencer.Clark/scratch/2025-09-26-fme-output/fme-output/3755651/training_checkpoints/best_inference_ckpt.tar
FME_VENV=2025-09-26-fme
EVALUATOR_CONFIG=ace-evaluator-config.yaml
SCRIPT_DIR=$(pwd)
SCRATCH=/scratch4/GFDL/gfdlscr/Spencer.Clark/2025-09-26-fme-output
WANDB_NAME=2025-09-26-test-evaluator
WANDB_USERNAME=spencerc_ai2
OVERRIDE="checkpoint_path=$CHECKPOINT"

conda run --name $FME_VENV \
    python -m fme.ace.validate_config \
    --config_type evaluator \
    $EVALUATOR_CONFIG --override $OVERRIDE
bash run-evaluator-ursa.sh \
     $FME_VENV \
     $EVALUATOR_CONFIG \
     $SCRIPT_DIR \
     $SCRATCH \
     $WANDB_NAME \
     $WANDB_USERNAME \
     $OVERRIDE
