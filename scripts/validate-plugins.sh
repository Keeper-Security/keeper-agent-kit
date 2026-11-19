#!/usr/bin/env bash
# Bash 3.2-compatible entry point; validation is portable Python.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "${PYTHON:-python3}" "$ROOT/scripts/validate_plugins.py" "$@"
