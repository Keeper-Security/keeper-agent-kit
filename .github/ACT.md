# Running Validation Locally

Use the commands in [CONTRIBUTING.md](../CONTRIBUTING.md#development-setup) for
fast local validation. They require no live Keeper account. Hosted CI runs the
same Python checks on Linux, macOS, and Windows and tests the TypeScript adapter.

## Optional act smoke test

[act](https://github.com/nektos/act) runs the Linux validation jobs in Docker.
Install act and start Docker before using `task act` or:

```bash
./scripts/act-all.sh
```

The script validates packages locally first, then runs the Linux validation and
TypeScript jobs. It does not run release-please or PR-title API actions. Act can
fetch images, packages, and actions; it is not an offline network sandbox. It
cannot reproduce macOS system Bash, Windows paths, keyrings, or Desktop approval.

## Workflows

| File | Purpose |
| --- | --- |
| [validate.yml](workflows/validate.yml) | Packages, versions, safety, links, Markdown, Python parser/SDK tests, TypeScript checks |
| [upstream-review.yml](workflows/upstream-review.yml) | Scheduled/manual public documentation-index and package drift report; read-only |
| [semantic-pull-request.yml](workflows/semantic-pull-request.yml) | Conventional Commit PR-title validation on GitHub |
| [release-please.yml](workflows/release-please.yml) | Release PR and publication on GitHub; not a local validation step |

Do not pass credentials on the command line to simulate API actions. Use actual
hosted checks for GitHub API workflows. Local validation and mocked SDK tests do
not establish live product access or enterprise authorization.
