# [Moreh] Running on HAC machine
![](https://badgen.net/badge/Moreh-HAC/fail/red) ![](https://badgen.net/badge/Nvidia-A100/passed/green)

## Prepare

### Data
Download and extract [LJSpeech dataset](https://keithito.com/LJ-Speech-Dataset/).
Assume the dataset is located at `/data/work/dataset/LJSpeech-1.1`

### Code
```bash
git clone https://github.com/loctxmoreh/deepvoice3_pytorch
cd deepvoice3_pytorch
```

### Environment
```bash
conda create -n deepvoice3 python=3.8
conda activate deepvoice3
```

#### Install `torch`
##### On HAC VM
```bash
conda install -y torchvision torchaudio numpy protobuf==3.13.0 pytorch==1.7.1 cpuonly -c pytorch
update-moreh --force --target 22.9.1
```

##### On A100 VM
With `torch=1.7.1`:
```bash
pip install torch==1.7.1+cu110 torchvision==0.8.2+cu110 torchaudio==0.7.2 -f https://download.pytorch.org/whl/torch_stable.html
```
With `torch=1.12.1`:
```bash
conda install pytorch torchvision torchaudio cudatoolkit=11.3 -c pytorch
```
Fixed `protobuf` to version `3.13.0`:
```bash
pip install protobuf==3.13.0
```

#### Install the repo as a package
```
pip install -e ".[bin]"
```

## Run

### Preprocess
```bash
# preprocess LJSpeech dataset and save to ./data/ljspeech
mkdir -p ./data/ljspeech
python preprocess.py --preset=presets/deepvoice3_ljspeech.json ljspeech /data/work/dataset/LJSpeech-1.1 ./data/ljspeech
```

### Train
First, edit the preset file (e.g. `./presets/deepvoice3_ljspeech.json`) and
change `nepochs` to 1 or 2 for testing.

Then:
```bash
# download cmdict (if have not yet)
python -c "import nltk; nltk.download('cmudict')"

# train
python train.py --data-root=./data/ljspeech/ --preset=presets/deepvoice3_ljspeech.json
```
