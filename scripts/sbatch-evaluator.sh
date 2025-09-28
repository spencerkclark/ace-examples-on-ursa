#!/bin/bash -l

#SBATCH --job-name=ace-evaluator
#SBATCH --partition=u1-h100
#SBATCH --qos=gpuwf
#SBATCH --account=gfdlhires
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=192
#SBATCH --gres=gpu:h100:1
#SBATCH --time=3:00:00
#SBATCH --output=stdout/%x.%j.out
#SBATCH --signal=USR1@60
#SBATCH --open-mode=append

# SLURM parameters based in part on those used by Linjiong Zhou:
# /home/Linjiong.Zhou/scratch/ace/train_scripts/run.sh

set -xe

FME_VENV="$1"
EVALUATOR_CONFIG="$2"
SCRIPT_DIR="$3"
SCRATCH="$4"
WANDB_NAME="$5"
WANDB_USERNAME="$6"
OVERRIDE="${@:7}"

# directory for saving output from training/inference job
FME_OUTPUT_DIR=${SCRATCH}/fme-output/${SLURM_JOB_ID}

mkdir -p $FME_OUTPUT_DIR

OVERRIDE="${OVERRIDE} experiment_dir=${FME_OUTPUT_DIR}"

# During the first segment, archive scripts and config needed to run the
# job. This ensures that they stay consistent throughout job requeues,
# and do not get lost, e.g. if we switch branches in the full-model
# repo where we launch experiments from.
JOB_CONFIG_DIR=$FME_OUTPUT_DIR/job_config
ARCHIVED_CONFIG=$JOB_CONFIG_DIR/archived_config.yaml
if [ ! -d $JOB_CONFIG_DIR ]; then
    mkdir $JOB_CONFIG_DIR
    cp $EVALUATOR_CONFIG $ARCHIVED_CONFIG
    cp $SCRIPT_DIR/scripts/run-evaluator-ursa.sh $JOB_CONFIG_DIR
    cp $SCRIPT_DIR/scripts/sbatch-inference.sh $JOB_CONFIG_DIR
    cp $SCRIPT_DIR/scripts/sbatch-wandb-sync.sh $JOB_CONFIG_DIR
fi

if [[ -z "${WANDB_NAME}" || -z "${WANDB_USERNAME}" ]]; then
    echo "Either WANDB_NAME or WANDB_USERNAME is empty; disabling WandB logging."
    WANDB_MODE=disabled
else
    WANDB_MODE=offline
fi

WANDB_NOTES="Results on Ursa: $FME_OUTPUT_DIR" \
    WANDB_JOB_TYPE=inference \
    WANDB_MODE=$WANDB_MODE \
    WANDB_NAME=$WANDB_NAME \
    WANDB_USERNAME=$WANDB_USERNAME \
    srun -u conda run --name $FME_VENV \
      torchrun \
      -m fme.ace.evaluator $EVALUATOR_CONFIG \
      --override $OVERRIDE
     
if [ -d $WANDB_DATA_DIR ]; then
    # Submit non-blocking wandb sync job after training is complete to sync artifacts.
    sbatch $JOB_CONFIG_DIR/sbatch-wandb-sync.sh \
           $FME_VENV $FME_OUTPUT_DIR
fi

sleep 120
