#!/bin/sh
# Generate a Vib recipe from recipe.in.yml with the C preprocessor.
# Usage: scripts/gen-recipe.sh OUTPUT [-DNAME[=value] ...]
# Run from anywhere; the output path is relative to the repo root.
set -eu
cd "$(dirname "$0")/.."
output="$1"
shift
cpp -P -undef -traditional-cpp "$@" recipe.yml | cat -s | sed '1{/^$/d}' > "$output"
