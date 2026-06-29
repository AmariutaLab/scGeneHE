#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -ne 4 ]]; then
    echo "Usage: $0 <gene_list> <plink_prefix_or_dir> <n_marker> <out_dir>" >&2
    exit 1
fi

gene_path=$1 # path to the gene list, one gene per row, without header
plink_file_path=$2 # PLINK prefix or directory containing per-gene PLINK prefixes
n_marker=$3 # number of genetic markers used to generate GRM
out_file_path=$4 # output directory for per-gene GRM files

echo "Start"

while read -r gene; do
    [[ -z "${gene}" ]] && continue
    printf '%s\n' "Processing $gene" 
    plink_prefix=$(resolve_plink_prefix "${plink_file_path}" "${gene}")
    out_prefix=$(gene_prefix_for_output "${out_file_path}" "${gene}")

    activate_conda_env saige
    echo "Sparse GRM ====================="
    createSparseGRM.R \
        --plinkFile="${plink_prefix}" \
        --nThreads=4 \
        --outputPrefix="${out_prefix}" \
        --numRandomMarkerforSparseKin="${n_marker}" \
        --relatednessCutoff=0.125 

    activate_conda_env r_env
    echo "Standardize GRM ================="
    Rscript "${SCRIPT_DIR}/trace.R" \
        --grm_path="${out_prefix}_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx" \
        --n_marker="${n_marker}" \
        --out="${out_prefix}"

done < "$gene_path"
echo "Done!"
