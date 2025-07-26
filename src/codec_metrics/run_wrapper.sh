#!/bin/bash

# ----- Dataset groups -----
speech_datasets=("crema_d" "fluent_speech_commands" "libri2Mix_test" "librispeech" "quesst" "snips_test_valid_subset" "vox_lingua_top10" "voxceleb1")
audio_datasets=("esc50" "fsd50k" "gunshot_triangulation")

# ----- Defaults -----
ref_path=/teamspace/studios/this_studio/data/samples
syn_path=/teamspace/studios/this_studio/resynth/samples
outdir=exps/logs
result_log=exps

# ----- Parse args -----
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --syn_path) syn_path="$2"; shift ;;
        --ref_path) ref_path="$2"; shift ;;
        --outdir) outdir="$2"; shift ;;
        --result_log) result_log="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

for dataset in "${speech_datasets[@]}"; do
    bash run.sh \
        --category speech \
        --dataset $dataset \
        --syn_path $syn_path \
        --ref_path $ref_path \
        --outdir $outdir \
        --result_log $result_log
done

for dataset in "${audio_datasets[@]}"; do
    bash run.sh \
        --category speech \
        --dataset $dataset \
        --syn_path $syn_path \
        --ref_path $ref_path \
        --outdir $outdir \
        --result_log $result_log
done

if [ do ]; then

    result_log_path="${result_log}/results.txt"
    echo "Log results" > $result_log_path
    echo "--------------------------------------------------" >> $result_log_path

    for log_file in ${result_log}/*.log; do

        filename=$(basename "$log_file")
        echo "File Name: $filename" >> $result_log_path
        cat "$log_file" >> $result_log_path
        echo "--------------------------------------------------" >> $result_log_path

    done

    if [ do ]; then
        python utils/log_overall_score.py --log_dir ${result_log} | tee -a $result_log_path
    fi

fi