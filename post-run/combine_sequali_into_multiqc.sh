#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENV_PATH="${SCRIPT_DIR}/.conda/multiqc"

if ! command -v conda >/dev/null 2>&1; then
    echo "Error: conda was not found. Install Miniconda or Anaconda first." >&2
    exit 1
fi

if (( $# == 0 )); then
    echo "Usage: $0 <directory1> <directory2> ..." >&2
    exit 1
fi

for dir in "$@"; do
    if [[ ! -d "$dir" ]]; then
        echo "Error: not a valid directory: $dir" >&2
        exit 1
    fi
done

if [[ ! -d "$ENV_PATH" ]]; then
    echo "Creating new environment at: $ENV_PATH"
    conda create --prefix "$ENV_PATH" \
        -c conda-forge -c bioconda multiqc=1.33 -y
fi

DEST_DIR="$(mktemp -d "${SCRIPT_DIR}/results/combined_multiqc_XXXXXXXX")"

echo "Running MultiQC on supplied directories"
conda run -p "$ENV_PATH" multiqc "$@" --outdir "$DEST_DIR"

echo "Done! MultiQC report saved to: $DEST_DIR"
