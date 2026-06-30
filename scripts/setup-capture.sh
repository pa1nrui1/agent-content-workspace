#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Setting up external source capture..."
echo

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required. Install Node.js 18+ first."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required. Install npm first."
  exit 1
fi

npm install
npx playwright install chromium

echo
echo "Checking remaining tools..."
bash scripts/check-capture-deps.sh

echo
echo "Setup complete."
echo "You can now run:"
echo '  node scripts/capture-source.mjs "<link>"'
