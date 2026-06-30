#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

if ! command -v snakemake >/dev/null 2>&1; then
    printf 'snakemake is not installed; skipping Snakemake dry-run smoke test.\n'
    exit 0
fi

cd "${REPO_ROOT}"

snakemake \
    --snakefile workflow/Snakefile \
    --configfile workflow/config/config.example.yaml \
    --cores 1 \
    --dry-run \
    --forceall \
    --printshellcmds
