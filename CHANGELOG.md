# Changelog

All notable changes to **Keeper Security Agent Kit** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/0.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0](https://github.com/Keeper-Security/keeper-agent-kit/compare/v1.0.0...v1.1.0) (2026-05-12)


### Features

* Keeper admin skill enhancement ([#9](https://github.com/Keeper-Security/keeper-agent-kit/issues/9)) ([b24108b](https://github.com/Keeper-Security/keeper-agent-kit/commit/b24108b896f1c800cd4f76224f0bf15c21d6b10b))

## [1.0.0](https://github.com/Keeper-Security/keeper-agent-kit/compare/v0.2.2...v1.0.0) (2026-04-04)


### Features

* v1.0.0 release ([9f5d66f](https://github.com/Keeper-Security/keeper-agent-kit/commit/9f5d66f3c37be522faf1a83ed9a67fd8dae644b4))

## [0.2.2](https://github.com/Keeper-Security/keeper-agent-kit/compare/v0.2.1...v0.2.2) (2026-04-04)


### Bug Fixes

* address snyk findings and harden skills ([#6](https://github.com/Keeper-Security/keeper-agent-kit/issues/6)) ([23efabf](https://github.com/Keeper-Security/keeper-agent-kit/commit/23efabfe5d87afcd388947b4050026d698e7e5b3))

## [0.2.1](https://github.com/Keeper-Security/keeper-agent-kit/compare/v0.2.0...v0.2.1) (2026-03-31)


### Bug Fixes

* rename repo to keeper-agent-kit ([1be1f84](https://github.com/Keeper-Security/keeper-agent-kit/commit/1be1f841388f7c27346ac0816c8fde53a9763f0e))

## [0.2.0](https://github.com/Keeper-Security/agent-kit/compare/v0.1.0...v0.2.0) (2026-03-31)

### Features

- adds updated support for claude and cursor marketplace ([#3](https://github.com/Keeper-Security/agent-kit/issues/3)) ([efccb1a](https://github.com/Keeper-Security/agent-kit/commit/efccb1a55a65d0fc84b05d18beea7fae3dba380c))
- initial commit ([aef4ab0](https://github.com/Keeper-Security/agent-kit/commit/aef4ab0d8fe469443118dcfeec073b939b62e2fa))

## [0.1.0] - 2026-03-31

### Added

- **Plugins** - Three agent plugins with reference documentation under `plugins/*/references/`:
  - `keeper-admin` - Keeper Commander (`keeper`): vault, enterprise admin, PAM, rotation, and related command references.
  - `keeper-secrets` - KSM CLI (`ksm`): secrets retrieval, `ksm exec`, `ksm interpolate`, Keeper notation, Docker/Kubernetes/CI patterns.
  - `keeper-setup` - Installing and configuring the KSM and Commander CLIs, regions, and troubleshooting.
- **Distribution** - Claude Code plugin metadata (`.claude-plugin/`), Cursor plugin metadata (`.cursor-plugin/`), marketplace listing, and install paths via [Vercel Skills CLI](https://github.com/vercel-labs/skills) (`npx skills add`) or manual copy into an agent’s skills directory.
- **Documentation** - README, CONTRIBUTING, SECURITY, `TEST_PROMPTS.md`, and links to official Keeper docs (Secrets Manager overview, Commander overview, Keeper notation).
- **CI** - GitHub Actions workflows to validate plugin JSON, marketplace JSON, SKILL frontmatter, reference files, and skill trigger/content checks; `python3-yaml` installed in workflows for reliable frontmatter parsing locally and on runners.
- **Developer tooling** - `Taskfile` tasks for Markdown (`task fmt`), dependencies (`task install`), and running CI locally with [act](https://github.com/nektos/act) (`task act`); [`.github/ACT.md`](.github/ACT.md) documents local workflow runs.
- **Community** - Issue templates, pull request template, `CODEOWNERS`, Apache 2.0 [`LICENSE.md`](LICENSE.md), and pre-commit hooks for Markdown format checks, Conventional Commit messages, and plugin/skill validation when you commit.

[0.1.0]: https://github.com/Keeper-Security/keeper-agent-kit/releases/tag/v0.1.0
