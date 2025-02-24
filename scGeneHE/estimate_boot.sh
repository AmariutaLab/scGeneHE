#!/bin/bash

grm_path=$1 # the path to the grm file, could use all sample grm to save memory and computation time
grm_id_path=$2 # the path to the grm id file, could use all sample id to save memory and computation time
gene_path=$3 # path to a list of genes, each gene is a row, without header
bootstarp_path=$4 # the directory to save all the bootstrap files, assuming each gene has its own directory, e.g. bootstrap_path/gene/boot...
boot_file_str=$5 # the bootstrap file name, without adding the index of bootstrap
n_boot=$6 # number of bootstrap conducted
tau_init=$7 # default to 1,0.1,0.1
covar=$8 # all covariates including sample level and cell level
sample_covar=$9 # sample/donor level covariates, duplicated for cells, e.g. sex, age
sample_id=${10} # sample/donor id
trait_type=${11} # default: count
boot_out_path=${12} # the output directory of bootstrap estimates, assuming each gene has its own directory, e.g. boot_out_path/gene/boot...
boot_out_str=${13} # the bootstrap output file name, e.g. h2_estimate
n_marker=${14} # number of genetic marker used to generate grm
plink_file_path=${15} # path to the directory that saved all genes plink file, assuming each gene has its own directory, e.g. plink_file_path/gene/gene.bed

echo "Start"
conda activate saigeqtl

while read -r gene; do
    printf '%s\n' "Processing $gene" 

    for ((i=0;i<n_boot;i++)); do
        echo "BOOT $i"
        echo "SAIGEQTL run ==================="
        spgrm="${grm_path}/${gene}/${gene}_standard_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx"
        spgrm_id="${grm_id_path}/${gene}/${gene}_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt"
        pheno="${bootstarp_path}/${gene}/boot${i}/${boot_file_str}_${i}.txt"
        boot_out="${boot_out_path}/${gene}/boot${i}/${boot_out_str}"
        geno="${plink_file_path}"
	    step1_fitNULLGLMM_qtl.R \
            --useSparseGRMtoFitNULL=true \
            --useGRMtoFitNULL=true \
            --sparseGRMFile=${spgrm} \
            --sparseGRMSampleIDFile=${spgrm_id} \
            --phenoFile=${pheno} \
            --phenoCol=${gene} \
            --covarColList=${covar} \
            --sampleCovarColList=${sample_covar} \
            --sampleIDColinphenoFile=${sample_id} \
            --traitType=${trait_type} \
            --outputPrefix=${boot_out} \
            --skipVarianceRatioEstimation=false  \
            --isRemoveZerosinPheno=false \
            --isCovariateOffset=true \
            --isCovariateTransform=true  \
            --skipModelFitting=false  \
            --tol=0.01 \
            --IsOverwriteVarianceRatioFile=true \
            --plinkFile=${geno} \
            --tauInit=${tau_init}
    done
done < "$gene_path"

echo "Done!"

