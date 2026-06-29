#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

BOOT_DIR="${TMP_DIR}/boot"
OUT_DIR="${TMP_DIR}/out"
GENE_LIST="${TMP_DIR}/gene_list.txt"

mkdir -p "${BOOT_DIR}/CDC37/boot0" "${OUT_DIR}"
printf 'CDC37\n' > "${GENE_LIST}"

Rscript -e "modglmm <- list(theta = c(1, 0.2, 0.3)); save(modglmm, file = '${BOOT_DIR}/CDC37/boot0/smoke.rda')"

SCGENEHE_R_ENV="${SCGENEHE_R_ENV:-r_env}" \
    bash "${REPO_ROOT}/scGeneHE/agg_boot.sh" \
    "${BOOT_DIR}" smoke "${OUT_DIR}" 1 "${GENE_LIST}" _boot_res

EXPECTED_HEADER='gene,bootstrap,phi,tau_1,tau_2'
EXPECTED_ROW='CDC37,0,1,0.2,0.3'

actual_header=$(sed -n '1p' "${OUT_DIR}/CDC37_boot_res.csv")
actual_row=$(sed -n '2p' "${OUT_DIR}/CDC37_boot_res.csv")

if [[ "${actual_header}" != "${EXPECTED_HEADER}" ]]; then
    printf 'Unexpected aggregation header: %s\n' "${actual_header}" >&2
    exit 1
fi

if [[ "${actual_row}" != "${EXPECTED_ROW}" ]]; then
    printf 'Unexpected aggregation row: %s\n' "${actual_row}" >&2
    exit 1
fi
