#!/bin/bash

boot_rate=$1
n_boot=$2
gene_path=$3
pheno_path=$4
fam_path=$5
covar=$6
bootstrap_path=$7
out_str=$8

conda activate pythn

python3 bootstrap_real.py \
    --boot_rate=${boot_rate} \
    --n_boot=${n_boot} \
    --gene_path=${gene_path} \
    --pheno_path=${pheno_path} \
    --fam_path=${fam_path} \
    --covar=${covar} \
    --bootstrap_path=${bootstrap_path} \
    --out_str=${out_str}



