#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 9 || $# -gt 12 ]]; then
    echo "Usage: $0 <boot_rate> <n_boot> <gene_list> <pheno_dir> <pheno_suffix> <plink_prefix_or_dir> <covars> <bootstrap_dir> <boot_out_prefix> [pheno_col] [sample_id_col] [seed]" >&2
    exit 1
fi

boot_rate=$1 # percent of cells sampled with replacement for each bootstrap
n_boot=$2 # number of bootstraps
gene_path=$3 # path to the gene list, one gene per row, without header
pheno_path=$4 # directory or per-gene directory containing phenotype files
pheno_str=$(txt_suffix "$5") # phenotype suffix, with or without .txt
plink_path=$6 # PLINK prefix or directory containing per-gene PLINK prefixes
covar=$7 # comma-separated covariates to include
bootstrap_path=$8 # directory to save bootstrap files
boot_out_str=$9 # output bootstrap file prefix
pheno_col=${10:-} # phenotype column; defaults to the current gene name
sample_id_col=${11:-iid} # sample ID column in phenotype file
seed=${12:-} # optional random seed

activate_conda_env pythn
echo "Start"

while read -r gene; do
    [[ -z "${gene}" ]] && continue
    printf '%s\n' "Processing $gene" 
    current_pheno_col=${pheno_col:-$gene}
    pheno_prefix=$(resolve_existing_prefix "${pheno_path}" "${gene}" "${pheno_str}")
    plink_prefix=$(resolve_plink_prefix "${plink_path}" "${gene}")
    gene_bootstrap_path=$(gene_dir_for_output "${bootstrap_path}" "${gene}")
    seed_arg=()
    if [[ -n "${seed}" ]]; then
        seed_arg=(--seed="${seed}")
    fi

    python3 "${SCRIPT_DIR}/bootstrap_real.py" \
        --boot_rate="${boot_rate}" \
        --n_boot="${n_boot}" \
        --gene="${gene}" \
        --pheno_path="${pheno_prefix}${pheno_str}" \
        --fam_path="${plink_prefix}.fam" \
        --covar="${covar}" \
        --bootstrap_path="${gene_bootstrap_path}" \
        --out_str="${boot_out_str}" \
        --pheno_col="${current_pheno_col}" \
        --sample_id_col="${sample_id_col}" \
        "${seed_arg[@]}"

done < "$gene_path"

echo "Done!"

