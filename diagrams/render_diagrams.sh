#!/usr/bin/env bash
# Render all Mermaid `.mmd` files in this directory to `.svg` using
# the Mermaid CLI via `npx`.
#
# Usage:
#   ./render_diagrams.sh
#
# This script expects `node`/`npx` to be available on PATH. It will call
# `npx -y @mermaid-js/mermaid-cli` for each `*.mmd` file.

set -euo pipefail
echo "Rendering Mermaid diagrams to SVG..."
cd "$(dirname "$0")"
shopt -s nullglob
files=( *.mmd )
if [ ${#files[@]} -eq 0 ]; then
  echo "No .mmd files found in $(pwd)"
  exit 0
fi
for f in "${files[@]}"; do
  out="${f%.mmd}.svg"
  echo "Rendering $f -> $out"
  npx -y @mermaid-js/mermaid-cli -i "$f" -o "$out"
done
echo "Done."

echo "Rendering Graphviz .dot files to SVG..."
shopt -s nullglob
dot_files=( *.dot )
if [ ${#dot_files[@]} -ne 0 ]; then
  # prefer dot on PATH
  if command -v dot >/dev/null 2>&1; then
    DOT_CMD="dot"
  elif [ -x "/c/Program Files/Graphviz/bin/dot.exe" ]; then
    DOT_CMD="/c/Program Files/Graphviz/bin/dot.exe"
  else
    DOT_CMD=""
  fi

  for f in "${dot_files[@]}"; do
    out="${f%.dot}.svg"
    echo "Rendering $f -> $out"
    if [ -n "$DOT_CMD" ]; then
      "$DOT_CMD" -Tsvg "$f" -o "$out"
    else
      echo "  dot not found; using Docker fallback (requires Docker)."
      docker run --rm -v "${PWD}:/work" -w /work eclipse/graphviz dot -Tsvg "$f" -o "$out"
    fi
  done
fi

echo "Done."
