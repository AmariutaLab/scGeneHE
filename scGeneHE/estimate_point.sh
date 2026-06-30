#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 13 || $# -gt 14 ]]; then
    echo "Usage: $0 <grm_dir> <plink_prefix_or_dir> <pheno_dir> <pheno_suffix> <out_dir> <n_marker> <gene_list> <tau_init> <covars> <sample_covars> <sample_id_col> <trait_type> <out_suffix> [pheno_col]" >&2
    exit 1
fi

grm_path=$1 # directory or per-gene directory containing sparse GRM files
plink_file_path=$2 # PLINK prefix or directory containing per-gene PLINK prefixes
pheno_path=$3 # directory or per-gene directory containing phenotype files
pheno_str=$(txt_suffix "$4") # phenotype suffix, with or without .txt
out_path=$5 # output directory
n_marker=$6 # number of genetic markers used when generating GRM
gene_path=$7 # path to the gene list, one gene per row, without header
tau_init=$8 # default: 1,0.1,0.1
covar=$9 # all covariates including sample-level and cell-level covariates
sample_covar=${10} # sample/donor-level covariates, duplicated for cells
sample_id=${11} # sample/donor ID column in phenotype file
trait_type=${12} # default: count
out_str=${13} # output suffix, e.g. _h2_estimate
pheno_col=${14:-} # phenotype column; defaults to the current gene name

activate_conda_env "${SCGENEHE_SAIGEQTL_ENV:-saigeqtl}"
echo "Start"

while read -r gene; do
    [[ -z "${gene}" ]] && continue
    printf '%s\n' "Processing $gene" 
    current_pheno_col=${pheno_col:-$gene}
    grm_prefix=$(resolve_existing_prefix "${grm_path}" "${gene}" "_standard_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx")
    pheno_prefix=$(resolve_existing_prefix "${pheno_path}" "${gene}" "${pheno_str}")
    plink_prefix=$(resolve_plink_prefix "${plink_file_path}" "${gene}")
    out_prefix=$(gene_prefix_for_output "${out_path}" "${gene}")

    echo "SAIGEQTL run ==================="
    step1_fitNULLGLMM_qtl.R \
        --useSparseGRMtoFitNULL=true \
        --useGRMtoFitNULL=true \
        --sparseGRMFile="${grm_prefix}_standard_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx" \
        --sparseGRMSampleIDFile="${grm_prefix}_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt" \
        --phenoFile="${pheno_prefix}${pheno_str}" \
        --phenoCol="${current_pheno_col}" \
        --covarColList="${covar}" \
        --sampleCovarColList="${sample_covar}" \
        --sampleIDColinphenoFile="${sample_id}" \
        --traitType="${trait_type}" \
        --outputPrefix="${out_prefix}${out_str}" \
        --skipVarianceRatioEstimation=false  \
        --isRemoveZerosinPheno=false \
        --isCovariateOffset=true \
        --isCovariateTransform=true  \
        --skipModelFitting=false  \
        --tol=0.01 \
        --IsOverwriteVarianceRatioFile=true \
        --plinkFile="${plink_prefix}" \
        --tauInit="${tau_init}"

done < "$gene_path"

echo "Done!"
