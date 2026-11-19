#!/usr/bin/env bash
# Validate locally, then smoke-test only the read-only Linux validation jobs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
task validate
act push -W .github/workflows/validate.yml -j packages-and-contracts --matrix os:ubuntu-latest
act push -W .github/workflows/validate.yml -j typescript-example
