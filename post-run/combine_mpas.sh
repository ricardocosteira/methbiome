#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENV_PATH="${SCRIPT_DIR}/.conda/krakentools"

if ! command -v conda >/dev/null 2>&1; then
    echo "Error: conda was not found. Install Miniconda or Anaconda first." >&2
    exit 1
fi

if (( $# == 0 )); then
    echo "Usage: $0 <directory1> <directory2> ..." >&2
    exit 1
fi

mpa_files=()

for dir in "$@"; do
    if [[ ! -d "$dir" ]]; then
        echo "Error: not a valid directory: $dir" >&2
        exit 1
    fi

    # Enable nullglob just for this loop, so a directory with no .mpa
    # files doesn't leave a literal "*.mpa" entry.
    shopt -s nullglob
    files=("$dir"/*.mpa)
    shopt -u nullglob

    mpa_files+=("${files[@]}")
done

if (( ${#mpa_files[@]} == 0 )); then
    echo "Error: no .mpa files found in the supplied directories." >&2
    exit 1
fi

if [[ ! -d "$ENV_PATH" ]]; then
    conda create --prefix "$ENV_PATH" \
        -c conda-forge -c bioconda krakentools=1.2.1 -y
fi

DEST_DIR="$(mktemp -d "${SCRIPT_DIR}/combined_mpas_XXXXXXXX")"

conda run -p "$ENV_PATH" combine_mpa.py \
    -i "${mpa_files[@]}" \
    -o "$DEST_DIR/all_combined_report.kreports.mpa"

echo "Done! Report saved to: $DEST_DIR/all_combined_report.kreports.mpa"
