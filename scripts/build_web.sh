#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_VERSION="${GODOT_VERSION:-4.3}"
CACHE_DIR="${XDG_CACHE_HOME:-$ROOT_DIR/.cache}/mosslight"
BIN="$CACHE_DIR/godot"
mkdir -p "$CACHE_DIR" "$ROOT_DIR/build/web"
if [[ ! -x "$BIN" ]]; then
  archive="$CACHE_DIR/godot.zip"
  url="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
  echo "Downloading Godot ${GODOT_VERSION} headless..."
  curl -fL "$url" -o "$archive"
  unzip -oq "$archive" -d "$CACHE_DIR/unpack"
  mv "$CACHE_DIR/unpack"/Godot_v${GODOT_VERSION}-stable_linux.x86_64 "$BIN"
  chmod +x "$BIN"
fi
cd "$ROOT_DIR"
"$BIN" --headless --editor --path . --export-release Web build/web/index.html
echo "Web build ready: $ROOT_DIR/build/web/index.html"
