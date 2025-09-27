#!/bin/bash

set -e

FME_VENV=2025-09-26-fme
TRAIN_CONFIG=ace-train-config.yaml
SCRIPT_DIR=$(pwd)
SCRATCH=/scratch4/GFDL/gfdlscr/Spencer.Clark/2025-09-26-fme-output
WANDB_NAME=2025-09-26-test
WANDB_USERNAME=spencerc_ai2
OVERRIDE=

conda run --name $FME_VENV \
    python -m fme.ace.validate_config \
    --config_type train \
    $TRAIN_CONFIG --override $OVERRIDE
bash run-train-ursa.sh \
     $FME_VENV \
     $TRAIN_CONFIG \
     $SCRIPT_DIR \
     $SCRATCH \
     $WANDB_NAME \
     $WANDB_USERNAME \
     $OVERRIDE
