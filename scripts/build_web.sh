#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_VERSION="${GODOT_VERSION:-4.3}"
CACHE_DIR="${XDG_CACHE_HOME:-$ROOT_DIR/.cache}/mosslight"
if command -v godot >/dev/null 2>&1; then
  BIN="$(command -v godot)"
elif command -v godot4 >/dev/null 2>&1; then
  BIN="$(command -v godot4)"
else
  BIN="$CACHE_DIR/godot"
fi
DATA_DIR="$CACHE_DIR/data"
TEMPLATE_DIR="$DATA_DIR/godot/export_templates/${GODOT_VERSION}.stable"
mkdir -p "$CACHE_DIR" "$ROOT_DIR/build/web"
if [[ "$BIN" == "$CACHE_DIR/godot" && ! -x "$BIN" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Godot is not installed. Install it with: brew install --cask godot"
    echo "Then run this command again."
    exit 1
  fi
  archive="$CACHE_DIR/godot.zip"
  url="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
  echo "Downloading Godot ${GODOT_VERSION} headless..."
  curl --retry 5 --retry-all-errors --connect-timeout 20 -fL "$url" -o "$archive"
  unzip -oq "$archive" -d "$CACHE_DIR/unpack"
  mv "$CACHE_DIR/unpack"/Godot_v${GODOT_VERSION}-stable_linux.x86_64 "$BIN"
  chmod +x "$BIN"
fi
if [[ "$BIN" == "$CACHE_DIR/godot" && ! -f "$TEMPLATE_DIR/web_release.zip" ]]; then
  template_archive="$CACHE_DIR/export_templates.tpz"
  template_url="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
  echo "Downloading Godot Web export templates..."
  curl --retry 5 --retry-all-errors --connect-timeout 20 -fL -C - "$template_url" -o "$template_archive"
  rm -rf "$CACHE_DIR/templates_unpack"
  unzip -oq "$template_archive" -d "$CACHE_DIR/templates_unpack"
  mkdir -p "$TEMPLATE_DIR"
  cp -R "$CACHE_DIR/templates_unpack/templates/." "$TEMPLATE_DIR/"
fi
cd "$ROOT_DIR"
XDG_DATA_HOME="$DATA_DIR" "$BIN" --headless --editor --path . --export-release Web build/web/index.html
echo "Web build ready: $ROOT_DIR/build/web/index.html"
