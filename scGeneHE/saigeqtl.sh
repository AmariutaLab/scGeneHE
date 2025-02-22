#!/bin/bash

grm_path=$1
grm_id_path=$2
plink_file=$3
pheno_path=$4
out_path=$5
n_marker=$6
gene=$7
tau_init=$8
covar=$9
sample_covar=${10}
sample_id=${11}
trait_type=${12}

conda activate saigeqtl
echo "Start"


printf '%s\n' "$gene" 

echo "SAIGEQTL run ==================="
step1_fitNULLGLMM_qtl.R \
    --useSparseGRMtoFitNULL=true \
    --useGRMtoFitNULL=true \
    --sparseGRMFile=${grm_path}.sparseGRM.mtx \
    --sparseGRMSampleIDFile=${grm_id_path}.sparseGRM.mtx.sampleIDs.txt \
    --phenoFile=${pheno_path} \
    --phenoCol=${gene} \
    --covarColList=${covar} \
    --sampleCovarColList=${sample_covar} \
    --sampleIDColinphenoFile=${sample_id} \
    --traitType=${trait_type} \
    --outputPrefix=${out} \
    --skipVarianceRatioEstimation=false  \
    --isRemoveZerosinPheno=false \
    --isCovariateOffset=true \
    --isCovariateTransform=true  \
    --skipModelFitting=false  \
    --tol=0.01 \
    --IsOverwriteVarianceRatioFile=true \
    --plinkFile=${plink_file} \
    --tauInit=${tau_init}


echo "Done!"


