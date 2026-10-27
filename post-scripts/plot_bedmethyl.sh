#!/bin/bash
set -euo pipefail

SCRIPT_PATH="$(dirname $0)/common/plot_bedmethyl.py"
ENV_PATH="$(dirname $0)/.conda/bedmethyl-plot"

if ! command -v conda >/dev/null 2>&1; then
    echo "Error: conda was not found. Install Miniconda or Anaconda first." >&2
    exit 1
fi

if [[ "$#" -lt 4 ]]; then
    echo "Usage: $0 <file.bed.gz> <contig> <start> <end> [--sample-name NAME]"
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "Error: input file does not exist: $1" >&2
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
