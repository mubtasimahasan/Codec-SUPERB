#!/bin/bash
set -e

MODELS=("FuseCodec_Fusion" "FuseCodec_Distill" "FuseCodec_ContextAlign")

for MODEL in "${MODELS[@]}"; do
    echo "Processing $MODEL ..."

    #Step 1: reconstruction
    # cd speech-token-modified

    python recon.py \
        --ckpt_path ckpt/${MODEL}.pt

    cd Codec-SUPERB-test

    # #Ensure main outdir exists
    OUTDIR="exps_${MODEL}"
    mkdir -p "$OUTDIR"

    bash run.sh \
        --syn_path /teamspace/studios/this_studio/resynth/${MODEL} \
        --outdir "$OUTDIR"

    cd src/codec_metrics

    # #Ensure logs subfolder exists
    LOGDIR="${OUTDIR}/logs"
    mkdir -p "$LOGDIR"

    bash run_wrapper.sh \
        --syn_path /teamspace/studios/this_studio/resynth/${MODEL}/samples \
        --outdir "$LOGDIR" \
        --result_log "$OUTDIR"

    cd ../../../
done
