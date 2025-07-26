#!/bin/bash

# ----- Default values -----
category=$1 # speech / audio
dataset=$2  # librispeech ... / esc50 ...
ref_path=/teamspace/studios/this_studio/data/samples
syn_path=/teamspace/studios/this_studio/resynth/samples
outdir=exps/logs
result_log=exps

# ----- Command-line overrides -----
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --category) category="$2"; shift ;;
        --dataset) dataset="$2"; shift ;;
        --syn_path) syn_path="$2"; shift ;;
        --ref_path) ref_path="$2"; shift ;;
        --outdir) outdir="$2"; shift ;;
        --result_log) result_log="$2"; shift ;;
    esac
    shift
done

# ----- Append dataset to paths -----
syn_path="${syn_path}/${dataset}"
ref_path="${ref_path}/${dataset}"
outdir="${outdir}/${dataset}"
result_log="${result_log}/${dataset}.log"


mkdir -p $outdir

echo "Codec SUPERB objective metric evaluation on ${dataset}" | tee ${result_log}

if [ "$category" = "speech" ]; then
    stage=1
    stop_stage=4
else
    stage=1
    stop_stage=2
fi

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then

    echo -e "\nStage 1: Run SDR evaluation." | tee -a $result_log
    model_type=SDR
    python evaluation.py \
        --syn_path ${syn_path} \
        --ref_path ${ref_path} \
        --metric_name $model_type \
        2>&1 | tee $outdir/${model_type}.log

    if [ "do" ]; then
        value=$(grep -o 'mean score is: -*[0-9]\+[.0-9]*' $outdir/${model_type}.log)
        echo $model_type: $value | tee -a $result_log
    fi

fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then

    echo -e "\nStage 2: Run Mel Spectrogram Loss." | tee -a $result_log
    model_type=mel_loss
    python evaluation.py \
        --syn_path ${syn_path} \
        --ref_path ${ref_path} \
        --metric_name $model_type \
        2>&1 | tee $outdir/${model_type}.log

    if [ "do" ]; then
        value=$(grep -o 'mean score is: [0-9.]*' $outdir/${model_type}.log)
        echo $model_type: $value | tee -a $result_log
    fi

fi

if [ ${stage} -le 3 ] && [ ${stop_stage} -ge 3 ]; then

    echo -e "\nStage 3: Run STOI." | tee -a $result_log
    model_type=stoi
    python evaluation.py \
        --syn_path ${syn_path} \
        --ref_path ${ref_path} \
        --metric_name $model_type \
        --target_sr 16000 \
        2>&1 | tee $outdir/${model_type}.log

    if [ "do" ]; then
        value=$(grep -o 'mean score is: [0-9.]*' $outdir/${model_type}.log)
        echo $model_type: $value | tee -a $result_log
    fi

fi

if [ ${stage} -le 4 ] && [ ${stop_stage} -ge 4 ]; then

    echo -e "\nStage 4: Run PESQ." | tee -a $result_log
    model_type=pesq
    python evaluation.py \
        --syn_path ${syn_path} \
        --ref_path ${ref_path} \
        --metric_name $model_type \
        --target_sr 16000 \
        2>&1 | tee $outdir/${model_type}.log

    if [ "do" ]; then
        value=$(grep -o 'mean score is: [0-9.]*' $outdir/${model_type}.log)
        echo $model_type: $value | tee -a $result_log
    fi

fi