#!/bin/bash
DEST_DIR="$(dirname $0)/combined_mpas"
ENV_PATH="$(dirname $0)/.conda/krakentools"

source "$(dirname $0)/.common.sh"

if [ ! -d "$ENV_PATH" ]; then
    echo "Creating new environment at: $ENV_PATH"
    mkdir -p "$ENV_PATH"
    conda create --prefix "$ENV_PATH" krakentools=1.2.1 -y
fi

echo "Activating environment: $ENV_PATH"
conda activate "$ENV_PATH"

echo 'Combining reports'

cd "$DEST_DIR"
combine_mpa.py -i ./*.mpa -o 'combined.kreports.mpa'

echo "Done!"
