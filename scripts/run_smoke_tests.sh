#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

activate_conda_env() {
    local env_name=$1
    if command -v conda >/dev/null 2>&1; then
        local conda_base
        conda_base=$(conda info --base)
        set +u
        # shellcheck disable=SC1091
        source "${conda_base}/etc/profile.d/conda.sh"
        conda activate "${env_name}"
        set -u
    else
        printf 'conda is required to activate environment %s\n' "${env_name}" >&2
        exit 1
    fi
}

cd "${REPO_ROOT}"

python3 -m unittest \
    tests.test_example_schema \
    tests.test_no_local_paths

if [[ "${SCGENEHE_SKIP_PY_SMOKE:-0}" != "1" ]]; then
    if [[ -n "${SCGENEHE_PY_ENV:-}" ]]; then
        activate_conda_env "${SCGENEHE_PY_ENV}"
    fi
    python3 -m unittest tests.test_bootstrap_smoke
fi

if [[ "${SCGENEHE_SKIP_R_SMOKE:-0}" != "1" ]]; then
    if [[ -n "${SCGENEHE_R_ENV:-}" ]]; then
        activate_conda_env "${SCGENEHE_R_ENV}"
    fi
    bash tests/smoke_agg_boot.sh
fi
