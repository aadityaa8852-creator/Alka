#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT/frontend"
if ! command -v npm >/dev/null 2>&1; then echo "Node.js 20+ and npm are required. Install from https://nodejs.org/ then retry."; exit 1; fi
if [ ! -d node_modules ]; then npm install; fi
exec npm run dev
