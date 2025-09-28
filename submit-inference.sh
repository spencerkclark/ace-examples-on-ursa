#!/bin/bash

set -e

CHECKPOINT=/path/to/checkpoint.tar  # Checkpoint of trained model
FME_VENV=fme  # Name of conda environment with ace installed
INFERENCE_CONFIG=ace-inference-config.yaml  # Path to inference configuration
SCRIPT_DIR=$(pwd)  # Absolute path to ace-examples-on-ursa directory
SCRATCH=/scratch4/GFDL/gfdlscr/$USER  # Output in $SCRATCH/fme-output/$SLURM_JOB_ID
WANDB_NAME=ace-inference  # Set to "" to disable WandB logging
WANDB_USERNAME=wandb-username  # Set to "" to disable WandB logging
OVERRIDE="checkpoint_path=$CHECKPOINT"  # Any parameters to override in the config via the command line

conda run --name $FME_VENV \
    python -m fme.ace.validate_config \
    --config_type inference \
    $INFERENCE_CONFIG --override $OVERRIDE
bash scripts/run-inference-ursa.sh \
     $FME_VENV \
     $INFERENCE_CONFIG \
     $SCRIPT_DIR \
     $SCRATCH \
     $WANDB_NAME \
     $WANDB_USERNAME \
     $OVERRIDE
