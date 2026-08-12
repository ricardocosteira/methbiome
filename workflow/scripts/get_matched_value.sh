#!/bin/bash
## Get the matched value for a file name based on a paired mapping string.
## If the provided file name contains a substring that matches a key in the mapping string, the corresponding value will be returned.
## If the provided file name contains multiple substrings that match keys in the mapping string, the value corresponding to one of the longest matching key will be returned.
## If no match is found, the default value will be returned.

## Arguments:
## 1. sample_name: The name of the sample to search for a match.
## 2. key:value pairs: A comma-separated string of key:value pairs to search for
## 3. parent directory: The parent directory to prepend to the matched value if a match is found.
## 4. default value: The value path to return if no match is found.

get_matched_value() {
    matched_value="$4"
    score=0

    for pair in $2; do
        key="${pair%%:*}"
        val="${pair##*:}"

        if [[ "$1" == *"$key"* && "${#key}" > "$score" ]]; then
            matched_value="$3/$val"
            score="${#key}"
        fi
    done
    echo "$matched_value"
}
