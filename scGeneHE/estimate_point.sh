#!/bin/bash

grm_path=$1 # the directory to grm files for all genes, assuming each gene has its own directory, e.g. grm_path/gene/gene
plink_file_path=$2 # the directory to the plink files for all genes, assuming each gene has its own directory, e.g. plink_file_path/gene/gene.bed
pheno_path=$3 # the directory to file of gene expression and covariates for all genes, e.g. the file names are hardcode as pheno_path/gene/gene_all.txt, separated by comma, contains all covariates columns
pheno_str=$4 # the phenotype file name, e.g. _all.txt, with gene name as prefix
out_path=$5 # the directory to the output files for all genes, e.g. out_path/gene/gene_h2_estimate
n_marker=$6 # number of genetic markers used when generating grm
gene_path=$7 # the path to the gene list, where each gene is a row, without header
tau_init=$8 # default to 1,0.1,0.1
covar=$9 # all covariates including sample level and cell level
sample_covar=${10} # sample/donor level covariates, duplicated for cells, e.g. sex, age
sample_id=${11} # sample/donor id
trait_type=${12} # default: count
out_str=${13} # the output file name, e.g. _h2_estimate, with gene name as prefix

conda activate saigeqtl
echo "Start"

while read -r gene; do
    printf '%s\n' "Processing $gene" 

    echo "SAIGEQTL run ==================="
    step1_fitNULLGLMM_qtl.R \
        --useSparseGRMtoFitNULL=true \
        --useGRMtoFitNULL=true \
        --sparseGRMFile=${grm_path}/${gene}/${gene}_standard_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx \
        --sparseGRMSampleIDFile=${grm_path}/${gene}/${gene}_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt \
        --phenoFile=${pheno_path}/${gene}/${gene}${pheno_str}.txt \
        --phenoCol=${gene} \
        --covarColList=${covar} \
        --sampleCovarColList=${sample_covar} \
        --sampleIDColinphenoFile=${sample_id} \
        --traitType=${trait_type} \
        --outputPrefix=${out_path}/${gene}/${gene}${out_str} \
        --skipVarianceRatioEstimation=false  \
        --isRemoveZerosinPheno=false \
        --isCovariateOffset=true \
        --isCovariateTransform=true  \
        --skipModelFitting=false  \
        --tol=0.01 \
        --IsOverwriteVarianceRatioFile=true \
        --plinkFile=${plink_file_path} \
        --tauInit=${tau_init}

done < "$gene_path"

echo "Done!"


