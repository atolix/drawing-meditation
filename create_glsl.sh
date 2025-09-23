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

# Write the default GLSL template into the new file
cat > "$filepath" << 'EOF'
#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform vec2 u_resolution;

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution;

    gl_FragColor = vec4(st.x, st.y, 1.0, 1.0);
}
EOF

echo "Created: $filepath"
