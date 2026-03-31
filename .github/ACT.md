# Running GitHub Actions locally with [act](https://github.com/nektos/act)

## What act is

**act** is a CLI that runs **GitHub Actions workflows on your computer** instead of on GitHub. It starts **Docker** containers that behave like GitHub’s `ubuntu-latest` runners, checks out your repo (or copies the working tree), and runs the same `run:` steps your YAML defines.

You use it to **smoke-test GitHub workflows before you push** (semantic PR, release-please). **Plugin and skill validation** runs via **pre-commit** (`plugin-ci`) or **`task validate`**, not as a hosted workflow.

## How it works (mental model)

1. **Event** - You tell act what happened, e.g. `push` or `pull_request`. Many of our workflows are written for `on: push` / `pull_request`, so `act push` is the usual choice.
2. **Workflow file** - You pass **which YAML** to run with `-W .github/workflows/<file>.yml`. act does **not** read `on: paths:` the same way GitHub does; if you pass a file, act runs that workflow.
3. **Jobs** - act lists jobs with `act -l -W …`, then runs them in Docker when you use `act push -W …`.
4. **Checkout** - `actions/checkout` inside the container gets your project files (warnings like `unable to get git ref` are common until you have at least one git commit; the tree is still copied).

Nothing is sent to GitHub when you run act; it is **fully local** (except pulling Docker images the first time).

## Prerequisites

1. **Docker** running (`docker info` should succeed).
2. **act** installed - [releases](https://github.com/nektos/act/releases) or e.g. `brew install act`. Use **act ≥ 0.2.86** when possible (security fixes).

## Run this repo’s CI locally (copy-paste)

From the **repository root**:

**Recommended - all workflows (same as `task act`):**

```bash
./scripts/act-all.sh
```

That script runs **`task validate`** first (same as the **pre-commit** `plugin-ci` hook; **must** succeed—the script exits non-zero if it fails). It then runs **semantic-pull-request** (`act pull_request` + [`.github/act/event-pull_request.json`](act/event-pull_request.json)) and **release-please** (`act push`) as **extra smoke tests**. Those two workflows call the **GitHub REST API** (`pulls.get`, release-please), so they **usually fail inside act** without a real `GITHUB_TOKEN`; that is expected and the script still exits **0** after plugin validation passes.

**Manual - plugin + skills only (no act):**

```bash
task validate
# or: pre-commit run plugin-ci --all-files
```

Requires **`jq`** (same as `scripts/validate.sh`).

**Manual - semantic PR workflow (`pull_request`):**

```bash
act -l -W .github/workflows/semantic-pull-request.yml
act pull_request -W .github/workflows/semantic-pull-request.yml -e .github/act/event-pull_request.json
```

**Manual - release-please (`push` to `main`):**

```bash
act -l -W .github/workflows/release-please.yml
act push -W .github/workflows/release-please.yml
```

Locally, **release-please** usually fails at the step that talks to the GitHub API; on GitHub it uses `secrets.GITHUB_TOKEN`. The YAML and job wiring are still validated by `act -l` and the start of the run.

## What each workflow does

| Workflow file | What it mainly validates |
| --- | --- |
| *(none on GitHub for plugins)* | Plugin/skill checks: **`task validate`** (also **pre-commit** hook `plugin-ci`). |
| [`semantic-pull-request.yml`](workflows/semantic-pull-request.yml) | PR title matches Conventional Commits (squash-merge title) |
| [`release-please.yml`](workflows/release-please.yml) | Release PR + changelog + GitHub Release via release-please |

## Convenience: Task wrapper

If you use [Task](https://taskfile.dev/), [`Taskfile.yaml`](../Taskfile.yaml) defines **`task validate`** (plugin validation) and **`task act`**, which runs [`scripts/act-all.sh`](../scripts/act-all.sh). For Markdown formatting before a PR, run **`task fmt`** separately. You can ignore Task and run `./scripts/act-all.sh` or the manual commands above.

## Differences vs running on GitHub

| Topic | On GitHub | With act |
| --- | --- | --- |
| `paths:` filters | Workflow may be skipped if paths don’t match | Ignored for “should this run?” - you chose the file with `-W` |
| Runners | GitHub-hosted Ubuntu | Docker image (e.g. `ghcr.io/catthehacker/ubuntu:act-latest`) |
| **`GITHUB_TOKEN`** | Injected automatically for each job as `secrets.GITHUB_TOKEN` (scoped to the repo, permissions from the workflow `permissions:` block). You do **not** add it under **Settings → Secrets**. | **Not** the same as GitHub’s token. act may set a placeholder or empty value; it does **not** mint a real token that can call `api.github.com` like the hosted runner. To exercise API-using actions locally you must pass a token yourself (e.g. `act … -s GITHUB_TOKEN=…` with a fine-scoped PAT)-optional and easy to get wrong, so we treat API workflows as **CI-only** for “full success.” |
| **release-please** / **semantic PR** actions | Full GitHub API + real `GITHUB_TOKEN` | May fail or partially run without a PAT; use for YAML/container smoke tests |

## Troubleshooting

| Issue | What to try |
| --- | --- |
| Docker not running | Start Docker Desktop / Linux daemon |
| `unable to get git ref` | Add an initial commit; harmless for file copy |
| Slow first run | Normal while Docker pulls the runner image |

## See also

- [CONTRIBUTING.md - Development setup](../CONTRIBUTING.md#optional-run-ci-workflows-locally-with-act)
- [GitHub: Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
