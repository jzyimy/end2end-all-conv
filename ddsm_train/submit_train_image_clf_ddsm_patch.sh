#!/bin/bash
#SBATCH --job-name          ddsm_patch
#SBATCH --output            ddsm_patch.log
#SBATCH --error             ddsm_patch.log
#SBATCH --nodes             1
#SBATCH --ntasks-per-node   1
#SBATCH --cpus-per-task     4
#SBATCH --mem               8G
#SBATCH --partition         skylake-gpu
#SBATCH --gres              gpu:1
#SBATCH --time              4:00:00


module load openmpi/4.0.0
module load cudnn/7.0.5-cuda-9.0.176

source activate py2

cd "/fred/oz121/binyan/repos/end2end-all-conv/"

export PYTHONPATH=$PYTHONPATH:"/fred/oz121/binyan/repos/end2end-all-conv/"


TRAIN_DIR="data/curated_breast_imaging_ddsm/train_dat_mod/train"
VAL_DIR="data/curated_breast_imaging_ddsm/train_dat_mod/val"
TEST_DIR="data/curated_breast_imaging_ddsm/train_dat_mod/test"
#RESUME_FROM="saved_model/ddsm_patch/5cls_best_model.h5"
BEST_MODEL="saved_model/ddsm_patch/5cls_best_model.h5"
# FINAL_MODEL="saved_model/ddsm_patch/5cls_final_model.h5"
FINAL_MODEL="NOSAVE"

export NUM_CPU_CORES=4

srun "/fred/oz121/anaconda/envs/py2/bin/python" "ddsm_train/patch_clf_train.py" \
    --img-size 256 256 \
    --img-scale 255.0 \
    --featurewise-center \
    --featurewise-mean 59.6 \
    --equalize-hist \
    --batch-size 64 \
    --train-bs-multiplier 0.5 \
    --augmentation \
    --class-list background  calc_ben  calc_mal  mass_ben  mass_mal \
    --nb-epoch 2 \
    --top-layer-epochs 5 \
    --all-layer-epochs 30 \
    --net resnet50 \
    --optimizer adam \
    --use-pretrained \
    --no-top-layer-nb \
    --nb-init-filter 64 \
    --init-filter-size 7 \
    --init-conv-stride 2 \
    --max-pooling-size 3 \
    --max-pooling-stride 2 \
    --weight-decay 0.0001 \
    --weight-decay2 0.0001 \
    --alpha 0.0001 \
    --l1-ratio 0.0 \
    --inp-dropout 0.0 \
    --hidden-dropout 0.5 \
    --hidden-dropout2 0.0 \
    --init-learningrate 0.0001 \
    --top-layer-multiplier 0.1 \
    --all-layer-multiplier 0.1 \
    --lr-patience 2 \
    --es-patience 5 \
    --no-resume-from \
    --auto-batch-balance \
    --pos-cls-weight 1.0 \
    --neg-cls-weight 1.0 \
    --best-model $BEST_MODEL \
    --final-model $FINAL_MODEL \
    $TRAIN_DIR $VAL_DIR $TEST_DIR
