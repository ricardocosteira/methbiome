#!/bin/bash
DEST_DIR="$(dirname $0)/combined_mpas_$(date +%s)" # Add Unix epoch to make unique
ENV_PATH="$(dirname $0)/.conda/krakentools"

set -euo pipefail
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <directory1> <directory2> ..."
    exit 1
fi

for dir in "$@"; do
    if [ ! -d "$dir" ]; then
        echo "$dir is not a valid directory. Exiting."
        exit 1
    fi
done

mkdir -p "$DEST_DIR"

for dir in "$@"; do
    echo "Copying contents of directory: $dir to $DEST_DIR"
    cp -r "$dir/"*.mpa "$DEST_DIR/"
done

echo "All contents copied successfully."

if [ ! -d "$ENV_PATH" ]; then
    echo "Creating new environment at: $ENV_PATH"
    mkdir -p "$ENV_PATH"
    conda create --prefix "$ENV_PATH" -c conda-forge -c bioconda krakentools=1.2.1 -y
fi

echo 'Combining reports'

conda run -p "$ENV_PATH" bash -c "
    set -euo pipefail
    cd "$DEST_DIR"
    combine_mpa.py -i ./*.mpa -o 'all_combined_report.kreports.mpa'
"

echo "Done!"
