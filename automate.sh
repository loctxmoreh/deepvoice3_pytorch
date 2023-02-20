#!/usr/bin/env bash

# On HAC machine only

set -e

DATASET_ROOT="/nas/common_data"
LJSPEECH_LINK="https://data.keithito.com/data/speech/LJSpeech-1.1.tar.bz2"
PRESET_FILE="presets/deepvoice3_ljspeech.json"
PROCESSED_DATA="data/ljspeech"

if [[ ! -d "${DATASET_ROOT}/LJSpeech-1.1" ]]; then
    curl $LJSPEECH_LINK --output $DATASET_ROOT/ljspeech.tar.bz2 --silent
    tar xf $DATASET_ROOT/ljspeech.tar.bz2 -C $DATASET_ROOT
    rm -f $DATASET_ROOT/ljspeech.tar.bz2
fi

#env_file="hacenv.yml"
env_file="hacenv2.yml"
env_name=$(grep ^name: $env_file | awk '{print $NF}')

conda env create -f $env_file
#conda run -n $env_name update-moreh --force --target 23.3.0
conda run -n $env_name update-moreh --force --target 23.3.0 --nightly

if [[ ! -d $PROCESSED_DATA ]]; then
    mkdir -p $PROCESSED_DATA
    conda run -n $env_name python3 preprocess.py \
        --preset=$PRESET_FILE \
        ljspeech \
        $DATASET_ROOT/LJSpeech-1.1 \
        $PROCESSED_DATA
fi

n_epochs=$(grep nepochs $PRESET_FILE | awk '{print $NF}' | tr -d ',')
[[ $n_epochs -gt 2 ]] && echo "Num epochs $n_epochs too large" && exit 1

[[ ! -d $HOME/nltk_data ]] \
    && conda run -n $env_name python3 -c "import nltk; nltk.download('cmudict')"

conda run -n $env_name \
    python3 train.py \
    --data-root=$PROCESSED_DATA \
    --preset=$PRESET_FILE

conda env remove -n $env_name
