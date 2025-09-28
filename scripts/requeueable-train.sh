#!/bin/bash

set -x

FME_VENV="$1"
FME_OUTPUT_DIR="$2"
TRAIN_CONFIG="$3"
WANDB_NAME="$4"
WANDB_USERNAME="$5"
OVERRIDE="${@:6}"

# this will manually requeue the job and is called if a timeout signal is received
# see https://docs.nersc.gov/jobs/examples/#preemptible-jobs
preempt_handler()
{
    #place here: commands to run when preempt signal (SIGTERM) arrives from slurm
    kill -TERM ${1} #forward SIGTERM signal to the user application
    #if --requeue was used, slurm will automatically do so here
}
timeout_handler()
{
    kill -TERM ${1}
    scontrol requeue ${SLURM_JOB_ID}
}

# Distributed training parameters based on those used by Linjiong Zhou:
# /home/Linjiong.Zhou/scratch/ace/train_scripts/run.sh
MAIN_NODE=$(scontrol show hostnames $SLURM_JOB_NODELIST | head -n 1)
MAIN_IP=$(getent ahostsv4 $MAIN_NODE | awk "{ print \$1; exit 1}")
MAIN_PORT=29500
GPUS_PER_NODE=2

if [[ -z "${WANDB_NAME}" || -z "${WANDB_USERNAME}" ]]; then
    echo "Either WANDB_NAME or WANDB_USERNAME is empty; disabling WandB logging."
    WANDB_MODE=disabled
else
    WANDB_MODE=offline
fi

WANDB_NOTES="Results on Ursa: $FME_OUTPUT_DIR" \
    WANDB_JOB_TYPE=training \
    WANDB_MODE=$WANDB_MODE \
    WANDB_NAME=$WANDB_NAME \
    WANDB_USERNAME=$WANDB_USERNAME \
    conda run --name $FME_VENV \
      torchrun \
      --nproc_per_node ${GPUS_PER_NODE} \
      --nnodes=${SLURM_NNODES} \
      --rdzv_id=${SLURM_JOB_ID} \
      --rdzv_backend=c10d \
      --rdzv_endpoint=${MAIN_IP}:${MAIN_PORT} \
      -m fme.ace.train ${TRAIN_CONFIG} \
      --override $OVERRIDE &

pid=$!
trap "preempt_handler '$pid'" SIGTERM #this catches preempt SIGTERM from slurm
trap "timeout_handler '$pid'" USR1 # this catches timeout USR1 from slurm
wait
sleep 120
