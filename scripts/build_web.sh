#!/usr/bin/env bash
# Export the web build headlessly. Works on Linux containers and macOS dev machines.
# - Linux: downloads Godot 4.3 linux binary + export templates into XDG data dirs.
# - macOS: prefers a system Godot (godot/godot4 on PATH or .cache/mosslight unpack bundle);
#   export templates are read from ~/Library/Application Support/Godot/export_templates.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_VERSION="${GODOT_VERSION:-4.3}"
CACHE_DIR="${XDG_CACHE_HOME:-$ROOT_DIR/.cache}/mosslight"
mkdir -p "$CACHE_DIR" "$ROOT_DIR/build/web"

detect_godot() {
  if command -v godot >/dev/null 2>&1; then command -v godot; return; fi
  if command -v godot4 >/dev/null 2>&1; then command -v godot4; return; fi
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local bundle="$CACHE_DIR/unpack/Godot.app/Contents/MacOS/Godot"
    if [[ -x "$bundle" ]]; then echo "$bundle"; return; fi
    if [[ -x "$CACHE_DIR/godot" ]]; then echo "$CACHE_DIR/godot"; return; fi
  else
    if [[ -x "$CACHE_DIR/godot" ]]; then echo "$CACHE_DIR/godot"; return; fi
  fi
  echo ""
}

install_linux_godot() {
  # Match the container/host architecture: arm64 machines (e.g. Apple Silicon
  # running arm64 containers) need the linux.arm64 build, x86_64 the classic one.
  local arch
  arch="$(uname -m)"
  local asset
  if [[ "$arch" == "arm64" || "$arch" == "aarch64" ]]; then
    asset="Godot_v${GODOT_VERSION}-stable_linux.arm64.zip"
  else
    asset="Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
  fi
  local url="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${asset}"
  echo "Downloading Godot ${GODOT_VERSION} linux binary (${arch})..."
  curl --retry 5 --retry-all-errors --connect-timeout 20 -fL "$url" -o "$CACHE_DIR/godot.zip"
  unzip -oq "$CACHE_DIR/godot.zip" -d "$CACHE_DIR/unpack_linux"
  mv "$CACHE_DIR/unpack_linux"/Godot_v${GODOT_VERSION}-stable_linux.* "$CACHE_DIR/godot"
  chmod +x "$CACHE_DIR/godot"
}

install_linux_templates() {
  # Godot on Linux looks in ~/.local/share/godot/export_templates/<version>
  local tpl_dir="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
  if [[ -f "$tpl_dir/web_nothreads_release.zip" ]]; then echo "$tpl_dir"; return; fi
  mkdir -p "$tpl_dir"
  # Preferred: the two web template zips are vendored in-repo (16MB total) so
  # builds work on servers that cannot reach github.com reliably.
  local vendored="$ROOT_DIR/vendor/templates"
  if [[ -f "$vendored/web_nothreads_release.zip" && -f "$vendored/web_release.zip" ]]; then
    cp "$vendored/web_nothreads_release.zip" "$vendored/web_release.zip" "$tpl_dir/"
    echo "$tpl_dir"
    return
  fi
  # Fallback: download the full tpz from github with resume + http1.1.
  local url="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
  echo "Downloading Godot ${GODOT_VERSION} export templates (~900MB, one-time)..."
  local ok=0
  for attempt in 1 2 3 4 5; do
    if curl -sS --http1.1 --retry 5 --retry-all-errors --connect-timeout 20 -fL -C - "$url" -o "$CACHE_DIR/templates.tpz"; then
      ok=1
      break
    fi
    echo "template download attempt $attempt failed, resuming..."
    sleep 3
  done
  if [[ "$ok" != "1" ]]; then
    echo "FATAL: could not download export templates"
    exit 1
  fi
  unzip -oq "$CACHE_DIR/templates.tpz" -d "$CACHE_DIR/templates_unpack"
  cp "$CACHE_DIR/templates_unpack/templates/web_nothreads_release.zip" "$tpl_dir/"
  cp "$CACHE_DIR/templates_unpack/templates/web_release.zip" "$tpl_dir/"
  echo "$tpl_dir"
}

BIN="$(detect_godot)"
if [[ -z "$BIN" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Godot not found. Install with: brew install --cask godot (or place the app in .cache/mosslight/unpack)."
    exit 1
  fi
  install_linux_godot
  BIN="$CACHE_DIR/godot"
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  install_linux_templates >/dev/null
fi

cd "$ROOT_DIR"
"$BIN" --headless --path . --export-release Web build/web/index.html
echo "Web build ready: $ROOT_DIR/build/web/index.html"
