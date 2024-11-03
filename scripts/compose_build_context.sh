#!/usr/bin/env bash
set -euo pipefail

safe_rmrf() {
    local dir="$1"
    local allowed_prefix="$BUILD_DIR/src/resources"
    local abs_dir
    abs_dir="$(realpath -m "$dir")"
    allowed_prefix="${allowed_prefix%/}"
    if [[ "$abs_dir" == "$allowed_prefix"* && "$abs_dir" != "$allowed_prefix" ]]; then
        rm -rf -- "$abs_dir"
    else
        echo "Refusing to remove: '$abs_dir'. Only subdirectories of '$allowed_prefix' are allowed."
        exit 1
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SRC_DIR="$PROJECT_ROOT/src"
BUILD_DIR="$PROJECT_ROOT/muddler"
ROCKSPEC="$PROJECT_ROOT/mudlet-package-dev-1.rockspec"
LICENSE_FILE="$PROJECT_ROOT/LICENSE"
RESOURCES_DIR="$BUILD_DIR/src/resources"

# Path to project-local luarocks, if it exists
PROJECT_LUAROCKS="$PROJECT_ROOT/luarocks"

# Function to run luarocks, preferring project-local if available
run_luarocks() {
    if [[ -x "$PROJECT_LUAROCKS" ]]; then
        "$PROJECT_LUAROCKS" "$@"
    else
        luarocks "$@"
    fi
}

echo "Composing build context..."

if [[ -f "$ROCKSPEC" ]]; then
    echo "Reinstalling dependencies from '$ROCKSPEC'..."
    BUILD_LUA_VENDOR_DIR="$RESOURCES_DIR/lua/lua_modules"
    safe_rmrf "$BUILD_LUA_VENDOR_DIR"
    mkdir -p "$BUILD_LUA_VENDOR_DIR"
    run_luarocks install --tree="$BUILD_LUA_VENDOR_DIR" --deps-only "$ROCKSPEC"
else
    echo "Rockspec not found at '$ROCKSPEC', skipping dependency install."
fi

if [[ -d "$SRC_DIR" ]]; then
    BUILD_LUA_SCRIPTS_DIR="$RESOURCES_DIR/lua/scripts"
    safe_rmrf "$BUILD_LUA_SCRIPTS_DIR"
    mkdir -p "$BUILD_LUA_SCRIPTS_DIR"
    cp -r "$SRC_DIR"/. "$BUILD_LUA_SCRIPTS_DIR/"
    echo "  Source  -> $BUILD_LUA_SCRIPTS_DIR"
else
    echo "Source directory not found at '$SRC_DIR', skipping."
fi

if [[ -f "$LICENSE_FILE" ]]; then
    cp "$LICENSE_FILE" "$RESOURCES_DIR/LICENSE"
    echo "  LICENSE -> $RESOURCES_DIR/LICENSE"
else
    echo "LICENSE file not found at '$LICENSE_FILE', skipping."
fi

echo "Build context composed."
