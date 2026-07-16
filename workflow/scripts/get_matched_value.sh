#!/bin/bash
## Get the matched value for a file name based on a paired mapping string.
## If the provided file name contains a substring that matches a key in the mapping string, the corresponding value will be returned.
## If no match is found, a default value will be returned.

## Arguments:
## 1. sample_name: The name of the sample to search for a match.
## 2. key:value pairs: A comma-separated string of key:value pairs to search for
## 3. parent directory: The parent directory to prepend to the matched value if a match is found.
## 4. default value: The value path to return if no match is found.

get_matched_value() {
    MATCHED_VAL="$4"

    for pair in "$2"; do
        KEY="${{pair%%:*}}"
        VAL="${{pair##*:}}"

        if [[ "$1" == *"$KEY"* ]]; then
            MATCHED_VAL="$3/$VAL"
            break
        fi
    done
    echo "$MATCHED_VAL"
}
