#!/bin/bash
DEST_DIR="$(dirname $0)/combined_multiqc_$(date +%s)"
ENV_PATH="$(dirname $0)/.conda/multiqc"

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
    cp -r "$dir/"* "$DEST_DIR/"
done

echo "All contents copied successfully."

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
