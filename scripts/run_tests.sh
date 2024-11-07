#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BUSTED_BIN="$PROJECT_ROOT/lua_modules/bin/busted"
BUSTED_CONFIG="$PROJECT_ROOT/busted.lua"
SRC_DIR="$PROJECT_ROOT/src"

if [[ ! -x "$BUSTED_BIN" ]]; then
  echo "Error: Busted not found at $BUSTED_BIN"
  echo "Please install dependencies with:"
  echo "  cd $PROJECT_ROOT"
  echo "  ./luarocks install --tree=lua_modules busted"
  exit 1
fi

if [[ ! -f "$BUSTED_CONFIG" ]]; then
  echo "Error: busted.lua config not found at $BUSTED_CONFIG"
  exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Error: src directory not found at $SRC_DIR"
  exit 1
fi

"$BUSTED_BIN" -f "$BUSTED_CONFIG" "$SRC_DIR"
