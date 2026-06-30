#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

INCLUDE_THIRD_PARTY=0
if [[ "${1:-}" == "--include-third-party" ]]; then
  INCLUDE_THIRD_PARTY=1
fi

RG_BASE=(
  rg
  --line-number
  --hidden
  --glob '!.git/**'
  --glob '!node_modules/**'
  --glob '!dist/**'
  --glob '!build/**'
  --glob '!scripts/privacy-scan.sh'
)

RG_FIRST_PARTY=("${RG_BASE[@]}" --glob '!third-party/skills/**')

if [[ "$INCLUDE_THIRD_PARTY" -eq 0 ]]; then
  RG_BASE+=(--glob '!third-party/skills/**')
fi

failures=0

scan_required_clean() {
  local title="$1"
  local pattern="$2"

  echo "== $title =="
  if "${RG_BASE[@]}" "$pattern" .; then
    failures=$((failures + 1))
    echo
  else
    echo "OK"
    echo
  fi
}

scan_warning_only() {
  local title="$1"
  local pattern="$2"

  echo "== $title =="
  if "${RG_BASE[@]}" "$pattern" .; then
    echo "Review matches above manually."
    echo
  else
    echo "OK"
    echo
  fi
}

scan_required_clean_first_party() {
  local title="$1"
  local pattern="$2"

  echo "== $title =="
  if "${RG_FIRST_PARTY[@]}" "$pattern" .; then
    failures=$((failures + 1))
    echo
  else
    echo "OK"
    echo
  fi
}

echo "Privacy scan root: $ROOT_DIR"
if [[ "$INCLUDE_THIRD_PARTY" -eq 1 ]]; then
  echo "Mode: include third-party source"
else
  echo "Mode: first-party files only. Use --include-third-party to scan vendored skills too."
fi
echo

scan_required_clean_first_party "First-party local absolute path leakage" '(/Users/[^/[:space:]]+|/home/[^/[:space:]]+|C:\\Users\\[^\\[:space:]]+)'

if [[ -n "${PRIVACY_EXTRA_PATTERN:-}" ]]; then
  scan_required_clean "User-provided private keywords" "$PRIVACY_EXTRA_PATTERN"
else
  echo "== User-provided private keywords =="
  echo "Skipped. Set PRIVACY_EXTRA_PATTERN to scan names, accounts, organizations, or private project names."
  echo
fi

scan_required_clean "Common credential values" '(github_pat_[A-Za-z0-9_]{20,}|gh[opsu]_[A-Za-z0-9_]{30,}|sk-(proj-)?[A-Za-z0-9_-]{32,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[0-9A-Za-z-]{20,})'

scan_warning_only "Credential assignment-like text" '(token|secret|api[_-]?key|authorization|cookie|password|passwd|auth)[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9_./+=:-]{16,}'

scan_warning_only "Generic sensitive terms for manual review" '真实姓名|手机号|身份证|客户|当事人|案号|token|secret|cookie|auth|Authorization'

echo "== File name check =="
if find . -path './third-party/skills/*' -prune -o -type f -print | perl -ne 'print if /[^\x00-\x7F]/' | grep .; then
  failures=$((failures + 1))
  echo
else
  echo "OK"
  echo
fi

if [[ "$failures" -gt 0 ]]; then
  echo "Privacy scan failed with $failures high-risk finding group(s)." >&2
  exit 1
fi

echo "Privacy scan passed."
