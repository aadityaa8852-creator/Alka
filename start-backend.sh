#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT/backend"
if ! command -v python3 >/dev/null 2>&1; then echo "Python 3 is required."; exit 1; fi
if [ ! -d .venv ]; then python3 -m venv .venv; fi
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
export DATABASE_URL="${DATABASE_URL:-sqlite:///./alka_ivf.db}"
export JWT_SECRET="${JWT_SECRET:-local-development-only-change-before-deployment}"
export FRONTEND_ORIGINS="${FRONTEND_ORIGINS:-http://localhost:5173,http://127.0.0.1:5173}"
exec uvicorn app:app --host 127.0.0.1 --port 8000 --reload
