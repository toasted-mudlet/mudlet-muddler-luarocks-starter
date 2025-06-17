#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -z "$1" ]; then
  echo "Usage: $0 <version_string>"
  exit 1
fi
VERSION_STRING="$1"

FILES=(
  "muddler/mfile"
  "muddler/README.md"
)

for REL_PATH in "${FILES[@]}"; do
  FILE="$PROJECT_ROOT/$REL_PATH"
  if [[ -f "$FILE" ]]; then
    sed -i.bak "s/{{VERSION}}/$VERSION_STRING/g" "$FILE"
    rm "${FILE}.bak"
    echo "Injected version into $REL_PATH"
  else
    echo "Warning: $REL_PATH not found"
  fi
done
