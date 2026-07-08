#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 6 || $# -gt 7 ]]; then
    echo "Usage: $0 <boot_out_dir> <boot_out_prefix> <agg_out_dir> <n_boot> <gene_list> <agg_out_suffix> [post_aggregate_cleanup]" >&2
    exit 1
fi

boot_out_path=$1 # output directory of bootstrap estimates
boot_out_str=$2 # bootstrap output file prefix
agg_out_path=$3 # output directory of aggregated bootstrap results
n_boot=$4 # number of bootstraps
gene_path=$5 # path to a list of genes, one per row, without header
agg_out_str=$6 # aggregate output suffix, e.g. _boot_res
post_aggregate_cleanup=${7:-keep} # keep or cleanup

activate_conda_env "${SCGENEHE_R_ENV:-r_env}"

if [[ "${post_aggregate_cleanup}" != "keep" && "${post_aggregate_cleanup}" != "cleanup" ]]; then
    echo "post_aggregate_cleanup must be 'keep' or 'cleanup'." >&2
    exit 1
fi

cleanup_bootstrap_dirs() {
    local gene_boot_out_path=$1
    local gene=$2
    local aggregate_file=$3

    if [[ ! -s "${aggregate_file}" ]]; then
        printf 'Refusing to clean bootstrap files for %s because aggregate output is missing or empty: %s\n' \
            "${gene}" "${aggregate_file}" >&2
        exit 1
    fi

    local i
    local boot_dir
    for ((i = 0; i < n_boot; i++)); do
        boot_dir="${gene_boot_out_path}/boot${i}"
        if [[ -d "${boot_dir}" ]]; then
            rm -rf -- "${boot_dir}"
        fi
    done
}

echo "Start"
mkdir -p "${agg_out_path}"

while read -r gene; do
    [[ -z "${gene}" ]] && continue
	printf '%s\n' " Processing $gene"
	gene_boot_out_path=$(resolve_gene_dir "${boot_out_path}" "${gene}" "boot0/${boot_out_str}.rda")

	Rscript "${SCRIPT_DIR}/agg_boot.R" \
		--boot_path="${gene_boot_out_path}" \
		--boot_out_str="${boot_out_str}" \
		--n_boot="${n_boot}" \
		--gene="${gene}" \
		--out_path="${agg_out_path}/" \
		--out_str="${agg_out_str}"

    if [[ "${post_aggregate_cleanup}" == "cleanup" ]]; then
        cleanup_bootstrap_dirs \
            "${gene_boot_out_path}" \
            "${gene}" \
            "${agg_out_path}/${gene}${agg_out_str}.csv"
    fi

done < "$gene_path"

echo "Done!"
