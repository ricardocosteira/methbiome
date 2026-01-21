#!/bin/bash
DEST_DIR="$(dirname $0)/combined_multiqc_$(date +%s)"
ENV_PATH="$(dirname $0)/.conda/multiqc"

source "$(dirname $0)/.common.sh"

if [ ! -d "$ENV_PATH" ]; then
    echo "Creating new environment at: $ENV_PATH"
    mkdir -p "$ENV_PATH"
    conda create --prefix "$ENV_PATH" -c conda-forge -c bioconda multiqc=1.33 -y
fi

echo 'Combining reports'

conda run -p "$ENV_PATH" bash -c "
    set -euo pipefail
    cd "$DEST_DIR"
    multiqc .
"

echo "Done!"
