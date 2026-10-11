#!/bin/bash
# Generate a Vib recipe from recipe.in.yml with the C preprocessor.
# Usage: scripts/gen-recipe.sh OUTPUT [-DNAME[=value] ...]
# Run from anywhere; the output path is relative to the repo root.
set -eu
cd "$(dirname "$0")/.."
output="$1"
shift

PREPROCESSOR_EXTRA_ARGS="$@"

call_preprocessor() {
    local __RECIPE__="recipe.yml"
    local __OUTPUT__="out.$__RECIPE__"

    for arg in "$@"; do
        case "$arg" in
            recipe=*) __RECIPE__="${arg#*=}" ;;
            output=*) __OUTPUT__="${arg#*=}" ;;
            *)        echo "Unknown argument: $arg" >&2; return 1 ;;
        esac
    done

    echo "$__RECIPE__ -> $__OUTPUT__"

    cpp -P -undef -traditional-cpp ${PREPROCESSOR_EXTRA_ARGS} ${__RECIPE__} | cat -s | sed 's/@@//g' | sed '1{/^$/d}' > "$__OUTPUT__"
}

call_preprocessor "output=$output"

TO_PREPROCESS=$(grep -oP '\bPREPROCESS\s*\(\K[^)]*' recipe.yml)

if [ -n "$TO_PREPROCESS" ]; then
    mkdir -p out.modules
    for i in $TO_PREPROCESS; do
        call_preprocessor "recipe=$i" "output=out.$i";
    done
fi