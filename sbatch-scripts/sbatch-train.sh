#!/bin/bash -l

#SBATCH --job-name=train-ace
#SBATCH --partition=u1-h100
#SBATCH --qos=gpuwf
#SBATCH --account=gfdlhires
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=192
#SBATCH --gres=gpu:h100:2
#SBATCH --time=3:00:00
#SBATCH --output=stdout/%x.%j.out
#SBATCH --signal=USR1@60
#SBATCH --requeue
#SBATCH --open-mode=append

# SLURM parameters based in part on those used by Linjiong Zhou:
# /home/Linjiong.Zhou/scratch/ace/train_scripts/run.sh

set -xe

FME_VENV="$1"
TRAIN_CONFIG="$2"
SCRIPT_DIR="$3"
SCRATCH="$4"
WANDB_NAME="$5"
WANDB_USERNAME="$6"
OVERRIDE="${@:7}"

# directory for saving output from training/inference job
if [ -z "${RESUME_JOB_ID}" ]; then
  FME_OUTPUT_DIR=${SCRATCH}/fme-output/${SLURM_JOB_ID}
else
  FME_OUTPUT_DIR=${SCRATCH}/fme-output/${RESUME_JOB_ID}
fi
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
    cp $TRAIN_CONFIG $ARCHIVED_CONFIG
    cp $SCRIPT_DIR/run-train-ursa.sh $JOB_CONFIG_DIR
    cp $SCRIPT_DIR/sbatch-scripts/requeueable-train.sh $JOB_CONFIG_DIR
    cp $SCRIPT_DIR/sbatch-scripts/sbatch-train.sh $JOB_CONFIG_DIR
    cp $SCRIPT_DIR/sbatch-scripts/sbatch-wandb-sync.sh $JOB_CONFIG_DIR
fi

WANDB_DATA_DIR=$FME_OUTPUT_DIR/wandb
if [ -d $WANDB_DATA_DIR ]; then
    # Submit a blocking wandb sync job before resuming training. This ensures
    # that we at least see some progress logged to WandB during training each
    # time the job is requeued. One can control the cadence of the sync by
    # the job time.
    sbatch --wait $JOB_CONFIG_DIR/sbatch-wandb-sync.sh \
	   $FME_VENV $FME_OUTPUT_DIR
fi

# run the requeueable job
srun -u $JOB_CONFIG_DIR/requeueable-train.sh \
     "$FME_VENV" \
     "$FME_OUTPUT_DIR" \
     "$ARCHIVED_CONFIG" \
     "$WANDB_NAME" \
     "$WANDB_USERNAME" \
     "$OVERRIDE"

if [ -d $WANDB_DATA_DIR ]; then
    # Submit non-blocking wandb sync job after training is complete to sync
    # remaining artifacts.
    sbatch $JOB_CONFIG_DIR/sbatch-wandb-sync.sh \
           $FME_VENV $FME_OUTPUT_DIR
fi

sleep 120
