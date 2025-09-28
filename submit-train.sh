#!/bin/bash

set -e

FME_VENV=fme  # Name of conda environment with ace installed
TRAIN_CONFIG=ace-train-config.yaml  # Path to training configuration
SCRIPT_DIR=$(pwd)  # Absolute path to ace-examples-on-ursa directory
SCRATCH=/scratch4/GFDL/gfdlscr/$USER  # Output in $SCRATCH/fme-output/$SLURM_JOB_ID (including out.log)
WANDB_NAME=ace-train  # Set to "" to disable WandB logging
WANDB_USERNAME=wandb-username  # Set to "" to disable WandB logging
OVERRIDE=  # Any parameters to override in the config via the command line

conda run --name $FME_VENV \
    python -m fme.ace.validate_config \
    --config_type train \
    $TRAIN_CONFIG --override $OVERRIDE
bash scripts/run-train-ursa.sh \
     $FME_VENV \
     $TRAIN_CONFIG \
     $SCRIPT_DIR \
     $SCRATCH \
     $WANDB_NAME \
     $WANDB_USERNAME \
     $OVERRIDE
