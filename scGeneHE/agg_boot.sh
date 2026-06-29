#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -ne 6 ]]; then
    echo "Usage: $0 <boot_out_dir> <boot_out_prefix> <agg_out_dir> <n_boot> <gene_list> <agg_out_suffix>" >&2
    exit 1
fi

boot_out_path=$1 # output directory of bootstrap estimates
boot_out_str=$2 # bootstrap output file prefix
agg_out_path=$3 # output directory of aggregated bootstrap results
n_boot=$4 # number of bootstraps
gene_path=$5 # path to a list of genes, one per row, without header
agg_out_str=$6 # aggregate output suffix, e.g. _boot_res

activate_conda_env "${SCGENEHE_R_ENV:-r_env}"

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

done < "$gene_path"

echo "Done!"
