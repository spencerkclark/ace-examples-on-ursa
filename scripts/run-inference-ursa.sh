#!/bin/bash

set -x

FME_VENV="$1"  # Name of conda environment
INFERENCE_CONFIG="$2"  # Path to inference configuration
SCRIPT_DIR="$3"  # Absolute path to ace-ursa-example directory
SCRATCH="$4"  # Run artifacts will be stored in $SCRATCH/fme-output/$SLURM_JOB_ID
WANDB_NAME="$5"  # Set to "" to disable WandB logging
WANDB_USERNAME="$6"  # Set to "" to disable WandB logging
OVERRIDE="${@:7}"  # Any parameters to override in the config via the command line

sbatch $SCRIPT_DIR/sbatch-scripts/sbatch-inference.sh \
       "$FME_VENV" \
       "$INFERENCE_CONFIG" \
       "$SCRIPT_DIR" \
       "$SCRATCH" \
       "$WANDB_NAME" \
       "$WANDB_USERNAME" \
       "$OVERRIDE"
