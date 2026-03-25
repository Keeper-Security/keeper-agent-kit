# Changelog

All notable changes to **Keeper Security Agent Kit** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-25

### Added

- **Skills** - Three agent skills with reference documentation under `skills/*/references/`:
  - `keeper-secrets` - KSM CLI (`ksm`): secrets retrieval, `ksm exec`, `ksm interpolate`, Keeper notation, Docker/Kubernetes/CI patterns.
  - `keeper-admin` - Keeper Commander (`keeper`): vault, enterprise admin, PAM, rotation, and related command references.
  - `keeper-setup` - Installing and configuring the KSM and Commander CLIs, regions, and troubleshooting.
- **Distribution** - Claude Code plugin metadata (`.claude-plugin/`), marketplace listing, and install paths via [Vercel Skills CLI](https://github.com/vercel-labs/skills) (`npx skills add`) or manual copy into an agent’s skills directory.
- **Documentation** - README, CONTRIBUTING, SECURITY, `TEST_PROMPTS.md`, and links to official Keeper docs (Secrets Manager overview, Commander overview, Keeper notation).
- **CI** - GitHub Actions workflows to validate plugin JSON, marketplace JSON, SKILL frontmatter, reference files, and skill trigger/content checks; `python3-yaml` installed in workflows for reliable frontmatter parsing locally and on runners.
- **Developer tooling** - `Taskfile` tasks for Markdown (`task fmt`), dependencies (`task install`), and running CI locally with [act](https://github.com/nektos/act) (`task act`); [`.github/ACT.md`](.github/ACT.md) documents local workflow runs.
- **Community** - Issue templates, pull request template, `CODEOWNERS`, Apache 2.0 [`LICENSE.md`](LICENSE.md).

[1.0.0]: https://github.com/Keeper-Security/agent-kit/releases/tag/v1.0.0
