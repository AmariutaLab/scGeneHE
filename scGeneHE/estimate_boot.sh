#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 15 || $# -gt 16 ]]; then
    echo "Usage: $0 <grm_dir> <grm_id_dir> <gene_list> <bootstrap_dir> <boot_file_prefix> <n_boot> <tau_init> <covars> <sample_covars> <sample_id_col> <trait_type> <boot_out_dir> <boot_out_prefix> <n_marker> <plink_prefix_or_dir> [pheno_col]" >&2
    exit 1
fi

grm_path=$1 # directory containing sparse GRM files
grm_id_path=$2 # directory containing sparse GRM sample ID files
gene_path=$3 # path to a list of genes, one per row, without header
bootstrap_path=$4 # directory containing bootstrap files
boot_file_str=$5 # bootstrap input file prefix
n_boot=$6 # number of bootstraps
tau_init=$7 # default: 1,0.1,0.1
covar=$8 # all covariates including sample-level and cell-level covariates
sample_covar=$9 # sample/donor-level covariates
sample_id=${10} # sample/donor ID column
trait_type=${11} # default: count
boot_out_path=${12} # output directory for bootstrap estimates
boot_out_str=${13} # bootstrap output file prefix
n_marker=${14} # number of genetic markers used to generate GRM
plink_file_path=${15} # PLINK prefix or directory containing per-gene PLINK prefixes
pheno_col=${16:-} # phenotype column; defaults to current gene name

echo "Start"
activate_conda_env "${SCGENEHE_SAIGEQTL_ENV:-saigeqtl}"

while read -r gene; do
    [[ -z "${gene}" ]] && continue
    printf '%s\n' "Processing $gene" 
    current_pheno_col=${pheno_col:-$gene}
    grm_prefix=$(resolve_existing_prefix "${grm_path}" "${gene}" "_standard_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx")
    grm_id_prefix=$(resolve_existing_prefix "${grm_id_path}" "${gene}" "_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt")
    plink_prefix=$(resolve_plink_prefix "${plink_file_path}" "${gene}")
    gene_bootstrap_path=$(resolve_gene_dir "${bootstrap_path}" "${gene}" "boot0/${boot_file_str}_0.txt")
    gene_boot_out_path=$(gene_dir_for_output "${boot_out_path}" "${gene}")

    for ((i=0;i<n_boot;i++)); do
        echo "BOOT $i"
        echo "SAIGEQTL run ==================="
        spgrm="${grm_prefix}_standard_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx"
        spgrm_id="${grm_id_prefix}_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt"
        pheno="${gene_bootstrap_path}/boot${i}/${boot_file_str}_${i}.txt"
        boot_out="${gene_boot_out_path}/boot${i}/${boot_out_str}"
        mkdir -p "$(dirname "${boot_out}")"
	    step1_fitNULLGLMM_qtl.R \
            --useSparseGRMtoFitNULL=true \
            --useGRMtoFitNULL=true \
            --sparseGRMFile="${spgrm}" \
            --sparseGRMSampleIDFile="${spgrm_id}" \
            --phenoFile="${pheno}" \
            --phenoCol="${current_pheno_col}" \
            --covarColList="${covar}" \
            --sampleCovarColList="${sample_covar}" \
            --sampleIDColinphenoFile="${sample_id}" \
            --traitType="${trait_type}" \
            --outputPrefix="${boot_out}" \
            --skipVarianceRatioEstimation=false  \
            --isRemoveZerosinPheno=false \
            --isCovariateOffset=true \
            --isCovariateTransform=true  \
            --skipModelFitting=false  \
            --tol=0.01 \
            --IsOverwriteVarianceRatioFile=true \
            --plinkFile="${plink_prefix}" \
            --tauInit="${tau_init}"
    done
done < "$gene_path"

echo "Done!"
