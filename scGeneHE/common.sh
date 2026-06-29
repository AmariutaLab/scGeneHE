#!/bin/bash

set -euo pipefail

script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd
}

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
        echo "conda is required to activate environment '${env_name}'." >&2
        exit 1
    fi
}

txt_suffix() {
    local suffix=$1
    if [[ "${suffix}" == *.txt ]]; then
        printf '%s\n' "${suffix}"
    else
        printf '%s.txt\n' "${suffix}"
    fi
}

gene_prefix_for_output() {
    local base=$1
    local gene=$2
    if [[ "$(basename "${base}")" == "${gene}" ]]; then
        mkdir -p "${base}"
        printf '%s/%s\n' "${base}" "${gene}"
    else
        mkdir -p "${base}/${gene}"
        printf '%s/%s/%s\n' "${base}" "${gene}" "${gene}"
    fi
}

gene_dir_for_output() {
    local base=$1
    local gene=$2
    if [[ "$(basename "${base}")" == "${gene}" ]]; then
        mkdir -p "${base}"
        printf '%s\n' "${base}"
    else
        mkdir -p "${base}/${gene}"
        printf '%s/%s\n' "${base}" "${gene}"
    fi
}

resolve_gene_dir() {
    local base=$1
    local gene=$2
    local required_relative_path=$3
    local candidates=(
        "${base}/${gene}"
        "${base}"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [[ -e "${candidate}/${required_relative_path}" ]]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done

    printf 'Could not find expected per-gene file for gene %s under %s: %s\n' \
        "${gene}" "${base}" "${required_relative_path}" >&2
    return 1
}

resolve_existing_prefix() {
    local base=$1
    local gene=$2
    local required_suffix=$3
    local candidates=(
        "${base}/${gene}/${gene}"
        "${base}/${gene}"
        "${base}"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [[ -e "${candidate}${required_suffix}" ]]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done

    printf 'Could not find expected file for gene %s under %s with suffix %s\n' \
        "${gene}" "${base}" "${required_suffix}" >&2
    return 1
}

resolve_plink_prefix() {
    local base=$1
    local gene=$2
    local candidates=(
        "${base}/${gene}/${gene}"
        "${base}/${gene}"
        "${base}"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [[ -e "${candidate}.bed" && -e "${candidate}.bim" && -e "${candidate}.fam" ]]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    done

    printf 'Could not find PLINK prefix for gene %s under %s\n' "${gene}" "${base}" >&2
    return 1
}
