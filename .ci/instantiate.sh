#!/usr/bin/env bash

# This script runs `Pkg.instantiate()` inside a bounded retry loop.

dir="${1:-}"

if [ -z "$dir" ]; then
  echo "Usage: $0 <julia-project-dir>" >&2
  exit 2
fi
if [ ! -d "$dir" ]; then
  echo "Error: '$dir' is not a directory." >&2
  exit 2
fi

try_count=0
while [ "$try_count" -lt 9 ]; do
  julia --color=yes --project="$dir" -e 'import Pkg; Pkg.instantiate()'
  if [ $? -eq 0 ]; then exit 0; fi
  try_count=$((try_count + 1))
  sleep 20
done

exit 1
