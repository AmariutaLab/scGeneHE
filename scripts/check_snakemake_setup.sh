#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

cd "${REPO_ROOT}"

if ! command -v snakemake >/dev/null 2>&1; then
    printf 'snakemake was not found on PATH.\n' >&2
    printf 'Activate the workflow environment first, for example: conda activate scgenehe-snakemake\n' >&2
    exit 1
fi

printf 'snakemake: %s\n' "$(snakemake --version)"

required_files=(
    "workflow/Snakefile"
    "workflow/config/config.example.yaml"
    "scGeneHE/generate_grm.sh"
    "scGeneHE/estimate_point.sh"
    "scGeneHE/bootstrap_real.sh"
    "scGeneHE/estimate_boot.sh"
    "scGeneHE/agg_boot.sh"
    "example/gene_list.txt"
)

for path in "${required_files[@]}"; do
    if [[ ! -e "${path}" ]]; then
        printf 'required file is missing: %s\n' "${path}" >&2
        exit 1
    fi
done

for script in scGeneHE/*.sh scripts/*.sh tests/*.sh; do
    bash -n "${script}"
done

python3 -m unittest \
    tests.test_example_schema \
    tests.test_no_local_paths

bash tests/smoke_snakemake_dry_run.sh

printf '\nSnakemake setup check completed successfully.\n'
printf 'This confirms the workflow driver can parse and dry-run the bundled example config.\n'
printf 'Run scripts/run_smoke_tests.sh for the fuller developer smoke test suite.\n'
