#!/bin/bash

set -e

CHECKPOINT=/path/to/checkpoint.tar  # Checkpoint of trained model
FME_VENV=fme  # Name of conda environment with ace installed
EVALUATOR_CONFIG=ace-evaluator-config.yaml  # Path to evaluator configuration
SCRIPT_DIR=$(pwd)  # Absolute path to ace-examples-on-ursa directory
SCRATCH=/scratch4/GFDL/gfdlscr/$USER  # Output in $SCRATCH/fme-output/$SLURM_JOB_ID
WANDB_NAME=ace-evaluator  # Set to "" to disable WandB logging
WANDB_USERNAME=wandb-username  # Set to "" to disable WandB logging
OVERRIDE="checkpoint_path=$CHECKPOINT"  # Any parameters to override in the config via the command line

conda run --name $FME_VENV \
    python -m fme.ace.validate_config \
    --config_type evaluator \
    $EVALUATOR_CONFIG --override $OVERRIDE
bash scripts/run-evaluator-ursa.sh \
     $FME_VENV \
     $EVALUATOR_CONFIG \
     $SCRIPT_DIR \
     $SCRATCH \
     $WANDB_NAME \
     $WANDB_USERNAME \
     $OVERRIDE
