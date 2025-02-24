#!/bin/bash

boot_rate=$1 # for each time of bootstrap, the % of samples involved
n_boot=$2 # number of bootstrap conducted
gene_path=$3 # the path to the gene list, where each gene is a row, without header
pheno_path=$4 # the directory to files of gene expression and covariates for all genes, assuming each gene has its own directoru, e.g. pheno_path/gene/gene..., separated by comma, contains all covariates columns
pheno_str=$5 # the phenotype file name, e.g. _all.txt, must contain gene name as prefix
fam_path=$6 # the directory to plink files of all genes, assuming each gene has its own directoru, e.g. fam_path/gene/gene.fam  
covar=$7 # list of all covariates to include
bootstrap_path=$8 # the directory to save all the bootstrap files, assuming each gene has its own directory, e.g. bootstrap_path/gene/boot...
boot_out_str=$9 # the output bootstrap file name, without adding the index of bootstrap. We will hard-code it for processing the results

conda activate pythn

echo "Start"

while read -r gene; do
    printf '%s\n' "Processing $gene" 

    python3 bootstrap_real.py \
        --boot_rate=${boot_rate} \
        --n_boot=${n_boot} \
        --gene=${gene} \
        --pheno_path=${pheno_path}/${gene}/${gene}${pheno_str} \
        --fam_path=${fam_path}.fam \
        --covar=${covar} \
        --bootstrap_path=${bootstrap_path}/${gene} \
        --out_str=${boot_out_str}

done < "$gene_path"

echo "Done!"



