#!/bin/bash
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
