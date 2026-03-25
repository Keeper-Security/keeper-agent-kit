#!/usr/bin/env bash
# Run act against every workflow under .github/workflows (local CI smoke test).
#
# validate-plugin + test-skills must succeed (same as GitHub push CI).
# semantic-pull-request and release-please call the GitHub API; act usually
# cannot complete those jobs locally — we still run them to exercise YAML and
# container setup; non-zero exit is expected and does not fail this script.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

EVENT_PR="${ROOT}/.github/act/event-pull_request.json"

run_list_push() {
  local wf=$1
  echo "==> act -l  ${wf}"
  act -l -W ".github/workflows/${wf}"
  echo "==> act push  ${wf}"
  act push -W ".github/workflows/${wf}"
}

echo "=== Workflows: validate-plugin, test-skills (must pass locally) ==="
run_list_push validate-plugin.yml
run_list_push test-skills.yml

echo ""
echo "=== Workflow: semantic-pull-request (pull_request; GitHub API required for success) ==="
act -l -W .github/workflows/semantic-pull-request.yml
if [[ ! -f "${EVENT_PR}" ]]; then
  echo "Missing ${EVENT_PR}"
  exit 1
fi
set +e
act pull_request -W .github/workflows/semantic-pull-request.yml -e "${EVENT_PR}"
sem=$?
set -e
if [[ "${sem}" -ne 0 ]]; then
  echo ""
  echo "Note: semantic-pull-request uses pulls.get (GitHub API). Failure here is normal in act without a token that can reach api.github.com."
fi

echo ""
echo "=== Workflow: release-please (push; GitHub API required for success) ==="
act -l -W .github/workflows/release-please.yml
set +e
act push -W .github/workflows/release-please.yml
rp=$?
set -e
if [[ "${rp}" -ne 0 ]]; then
  echo ""
  echo "Note: release-please calls the GitHub API via secrets.GITHUB_TOKEN. Failure here is normal locally."
fi

echo ""
echo "=== act run finished (validate-plugin + test-skills passed above) ==="
