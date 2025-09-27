#!/bin/bash

#SBATCH --job-name=wandb-sync
#SBATCH --partition=u1-service
#SBATCH --account=gfdlhires
#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --output=stdout/%x.%j.out

FME_VENV="$1"
FME_OUTPUT_DIR="$2"

# Note that it is apparently very important to pass the wandb directory
# as a relative path, so we change to the FME_OUTPUT_DIR first. If we
# do not do this WandB does not detect any data to sync.
cd $FME_OUTPUT_DIR
conda run --name $FME_VENV wandb sync --sync-all --append wandb
