#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="${SCRIPT_DIR}/common/plot_bedmethyl.py"
ENV_PATH="${SCRIPT_DIR}/.conda/bedmethyl-plot"

if ! command -v conda >/dev/null 2>&1; then
    echo "Error: conda was not found. Install Miniconda or Anaconda first." >&2
    exit 1
fi

if (( $# < 4 )); then
    echo "Usage: $0 <file.bed.gz> <contig> <start> <end> [--sample-name NAME]" >&2
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "Error: input file does not exist: $1" >&2
    exit 1
fi

if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Error: plotting script not found: $SCRIPT_PATH" >&2
    exit 1
fi

if [[ ! -d "$ENV_PATH" ]]; then
    echo "Creating Conda environment at: $ENV_PATH"
    mkdir -p "$(dirname "$ENV_PATH")"
    conda create --prefix "$ENV_PATH" \
        -c conda-forge -c bioconda \
        python=3.12 pysam pandas matplotlib seaborn \
        -y
fi

echo "Generating methylation plot..."
conda run --prefix "$ENV_PATH" \
    python "$SCRIPT_PATH" "$@"
