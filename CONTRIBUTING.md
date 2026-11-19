# Contributing to Keeper Security Agent Kit

## How to Contribute

Use a feature branch and a focused PR. Preserve existing plugin names and independently
installable skill bundles. Do not publish private product specifications, internal
tickets, credentials, or unreleased implementation details into this public kit.
Prefer current public documentation and published packages; distinguish documentation,
default-branch source, release artifacts, and actual deployment.

## Development Setup

The distribution is primarily Markdown/JSON, with small tested SDK examples and
portable Python validation. Validation does not log in to Keeper or call its APIs.
Use Python 3.10+ (CI uses 3.12), Node 20+, and optional Task for local development.
Install test dependencies in an isolated environment, not your global runtime:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/python scripts/validate_plugins.py
.venv/bin/python -m unittest discover -s tests -v
.venv/bin/rumdl check .
```

On Windows use `.venv\Scripts\python.exe` and `.venv\Scripts\rumdl.exe`. The optional `task validate` / shell
wrapper respects `PYTHON`; it is compatible with macOS system Bash 3.2.

```bash
PYTHON="$PWD/.venv/bin/python" task validate
```

For the TypeScript example, in `plugins/keeper-sdk/skills/keeper-sdk/examples/typescript`:

```bash
npm ci --ignore-scripts
npm run check
npm test
```

`task fmt` requires the `rumdl` executable on PATH. Use the pinned Python package
in the development environment or the existing optional `task install` tooling.
Formatting fixes should be reviewed, not silently applied to unrelated content.

## Skills and Packaging

Each plugin has matching Claude and Cursor `plugin.json` manifests and an entry
in both root marketplaces. Keep its version equal to `version.txt`; release-please
updates plugin versions using the existing glob configuration. Do not manually
bump release versions or the changelog for an ordinary feature PR.

Every `SKILL.md` needs valid YAML `name` and `description`, a concise body, clear
routing, sources, prerequisites, and guardrails. Names match directories, and
descriptions are at most 200 characters to keep routing metadata compact.

References and examples must remain inside the skill directory so manual/Skills
CLI installation works independently. Cross-skill guidance may name another
skill, but must not rely on a relative path to a sibling plugin or repository root.
The canonical [safety contract](docs/safety.md) is copied into each skill's
`references/safety.md`; update all copies together. Validation prevents drift.

## Testing Guidelines

GitHub Actions validates manifests, frontmatter, release versions, packaged safety,
relative links, known unsafe example regressions, published KSM command parsing,
and SDK examples. Python validation runs on Linux, macOS, and Windows. TypeScript
is type-checked against a pinned real SDK and exercised with synthetic adapters.
No test credentials or live vault access are required.

These checks are not full agent behavior tests. Use [TEST_PROMPTS.md](TEST_PROMPTS.md)
and record client/model/version, tool availability, proposed actions, and pass/fail
observations when evaluating actual assistants. Live tests require separate user
authorization and nonproduction scope; never execute destructive prompts against
real customers as an automated smoke test.

External Keeper documentation links and package versions are checked separately
by `scripts/check_upstream.py` and a scheduled/manual workflow. Findings require
human review; the job does not auto-edit skills, update dependencies, or publish.

## Updating Product Guidance

1. Identify the authoritative public page and versioned API/package.
2. Check actual syntax/types and release status. Never copy CLI options between SDKs.
3. Add a narrow example and regression test; prefer metadata or synthetic data.
4. Update [docs/compatibility.md](docs/compatibility.md) with version, verification
   date, evidence, and limitations. Source implementation does not establish deployment.
5. Verify external links and review safety/availability gates.

## Submission Checklist

- [ ] Validation, Python tests, TypeScript tests/type checking, and Markdown checks pass.
- [ ] New plugins are in both marketplaces and carry the packaged safety contract.
- [ ] Examples do not print secrets, pass resolved credentials in argv, or bypass policies.
- [ ] Preview/beta/platform/license gates and testing limitations are explicit.
- [ ] Public sources are cited; no internal documentation has been copied.
- [ ] PR explains the changes, test evidence, and any remaining live-test gaps.

## Commit Messages and Releases

Use Conventional Commits, for example `feat(skills): add governed MCP workflows`
or `fix(examples): correct KSM profile syntax`. The PR title follows the same
format. Release-please creates the release PR and updates `version.txt`, manifests,
and `CHANGELOG.md`; merging that release PR publishes the release. Never push
directly to `main`, force-push, or fabricate a release date.

## Questions and Security

Use [GitHub Issues](https://github.com/Keeper-Security/keeper-agent-kit/issues)
for bugs or requests. Use [SECURITY.md](SECURITY.md) for private vulnerability
reporting, not a public issue with credentials or customer data.
