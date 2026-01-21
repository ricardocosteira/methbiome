#!/bin/bash
DEST_DIR="$(dirname $0)/combined_multiqc"
ENV_PATH="$(dirname $0)/.conda/multiqc"

source "$(dirname $0)/.common.sh"

if [ ! -d "$ENV_PATH" ]; then
    echo "Creating new environment at: $ENV_PATH"
    mkdir -p "$ENV_PATH"
    conda create --prefix "$ENV_PATH"  -c bioconda multiqc=1.33 -y
fi

echo "Activating environment: $ENV_PATH"
conda activate "$ENV_PATH"

echo 'Combining reports'

cd "$DEST_DIR"
multiqc .

echo "Done!"
