#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
SHADERS_DIR="$ROOT_DIR/shaders"

mkdir -p "$SHADERS_DIR"

today="$(date +%Y-%m-%d)"
filename="$today.glsl"
filepath="$SHADERS_DIR/$filename"

if [[ -e "$filepath" ]]; then
  i=2
  while [[ -e "$SHADERS_DIR/${today}-${i}.glsl" ]]; do
    ((i++))
  done
  filepath="$SHADERS_DIR/${today}-${i}.glsl"
fi

touch "$filepath"
echo "Created: $filepath"
