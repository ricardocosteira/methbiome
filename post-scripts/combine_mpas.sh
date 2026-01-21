#!/bin/bash
DEST_DIR="$(dirname $0)/combined_mpas_$(date +%s)" # Add Unix epoch to make unique
ENV_PATH="$(dirname $0)/.conda/krakentools"

source "$(dirname $0)/.common.sh"

if [ ! -d "$ENV_PATH" ]; then
    echo "Creating new environment at: $ENV_PATH"
    mkdir -p "$ENV_PATH"
    conda create --prefix "$ENV_PATH" -c conda-forge -c bioconda krakentools=1.2.1 -y
fi

echo 'Combining reports'

conda run -p "$ENV_PATH" bash -c "
    set -euo pipefail
    cd "$DEST_DIR"
    combine_mpa.py -i ./*.mpa -o 'combined.kreports.mpa'
"

echo "Done!"
