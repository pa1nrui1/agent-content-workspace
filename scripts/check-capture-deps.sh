#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

missing=0

check_cmd() {
  local name="$1"
  local install_hint="$2"

  if command -v "$name" >/dev/null 2>&1; then
    echo "OK: $name"
  else
    echo "MISSING: $name"
    echo "  Install: $install_hint"
    missing=$((missing + 1))
  fi
}

echo "Checking capture dependencies..."
echo

check_cmd node "Install Node.js 18+ from https://nodejs.org or your package manager."
check_cmd npm "Install npm with Node.js."
check_cmd curl "Install curl with your system package manager."
check_cmd ffmpeg "macOS: brew install ffmpeg"

if [[ -n "${WHISPER_MODEL:-}${WHISPER_CPP_MODEL:-}" ]] && command -v whisper-cli >/dev/null 2>&1; then
  echo "OK: whisper-cli with model env"
elif python3 -c "import faster_whisper" >/dev/null 2>&1; then
  echo "OK: faster-whisper"
elif command -v whisper-cli >/dev/null 2>&1; then
  echo "MISSING: whisper model env or faster-whisper"
  echo "  Set WHISPER_MODEL / WHISPER_CPP_MODEL, or run: pip install -r requirements-capture.txt"
  missing=$((missing + 1))
else
  echo "MISSING: whisper-cli or faster-whisper"
  echo "  Install whisper.cpp or run: pip install -r requirements-capture.txt"
  missing=$((missing + 1))
fi

if [[ -d node_modules/playwright ]]; then
  echo "OK: node_modules/playwright"
else
  echo "MISSING: node_modules/playwright"
  echo "  Install: npm install"
  missing=$((missing + 1))
fi

if npx --yes playwright --version >/dev/null 2>&1; then
  echo "OK: playwright cli"
else
  echo "MISSING: playwright cli"
  echo "  Install: npm install && npx playwright install chromium"
  missing=$((missing + 1))
fi

echo
if [[ "$missing" -gt 0 ]]; then
  echo "Capture dependency check failed with $missing missing item(s)."
  exit 1
fi

echo "Capture dependencies are ready."
