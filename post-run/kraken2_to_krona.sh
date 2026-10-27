#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENV_PATH="${SCRIPT_DIR}/.conda/kraken-krona"

if ! command -v conda >/dev/null 2>&1; then
    echo "Error: conda was not found. Install Miniconda or Anaconda first." >&2
    exit 1
fi

if (( $# == 0 )); then
    echo "Usage: $0 <folder1> [folder2 ...]" >&2
    exit 1
fi

for dir in "$@"; do
    if [[ ! -d "$dir" ]]; then
        echo "Error: not a valid directory: $dir" >&2
        exit 1
    fi
done

reports=()

for dir in "$@"; do
    shopt -s nullglob
    files=("$dir"/*.kreport2)
    shopt -u nullglob

    reports+=("${files[@]}")
done

if (( ${#reports[@]} == 0 )); then
    echo "Error: no .kreport2 files found in the supplied folders." >&2
    exit 1
fi

if [[ ! -d "$ENV_PATH" ]]; then
    echo "Creating Conda environment at: $ENV_PATH"
    mkdir -p "$(dirname "$ENV_PATH")"
    conda create --prefix "$ENV_PATH" \
        -c conda-forge -c bioconda \
        krona -y
    conda run --prefix "$ENV_PATH" ktUpdateTaxonomy.sh
fi

OUTPUT_DIR="$(mktemp -d "${SCRIPT_DIR}/results/krona_XXXXXXXX")"
KRONA_HTML="${OUTPUT_DIR}/multi-krona.html"

echo "Generating Krona plot from ${#reports[@]} report(s)..."
conda run --prefix "$ENV_PATH" ktImportTaxonomy \
    -t 5 -m 3 \
    -o "$KRONA_HTML" \
    "${reports[@]}"

echo "Done! Krona plot saved to: $KRONA_HTML"
