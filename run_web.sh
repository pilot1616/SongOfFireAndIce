#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$ROOT_DIR/scripts/build_web.sh"
PORT="${PORT:-8080}"
cd "$ROOT_DIR/build/web"
echo "Mosslight running at http://localhost:${PORT}"
exec python3 -m http.server "$PORT" --bind 0.0.0.0
