# Contributing to Keeper Security Agent Kit

Thank you for your interest in contributing! This document provides guidelines for making contributions.

## Code of Conduct

- Be respectful and inclusive
- No harassment, discrimination, or abuse
- Focus on constructive feedback
- Respect privacy and security

## How to Contribute

### Reporting Issues

Found a bug? Have a feature request?

1. Check existing [GitHub Issues](https://github.com/Keeper-Security/keeper-agent-kit/issues)
2. Create new issue with:
   - Clear title
   - Detailed description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Environment (OS, Python version, agent)
   - Screenshots if helpful

### Improving Documentation

Skills and reference docs are always being improved.

1. Fork the repository
2. Edit files in `skills/*/` or reference documentation
3. Ensure frontmatter is correct (see below)
4. Test readability and formatting
5. Submit pull request with clear description

**SKILL.md Frontmatter Requirements:**

```yaml
---
name: keeper-secrets
description: >-
  One-line summary followed by details. Keep under 200 characters for API
  compatibility, though full descriptions work fine in Claude Code. Use this
  field to help AI agents understand when to use this skill.
---
```

### Adding Examples

New examples for CI/CD, Docker, Kubernetes, etc. are welcome!

1. Add to relevant reference file (e.g., `ksm-exec-patterns.md`)
2. Include:
   - Clear section heading
   - Problem statement
   - Solution with code
   - Explanation of key parts
   - Common pitfalls

### Updating References

Keep reference documentation current with official Keeper docs.

1. Check [Keeper Documentation](https://docs.keeper.io) for latest syntax
2. Update relevant reference file
3. Test commands work as documented
4. Include version info if applicable

## Development setup

This repo is Markdown-only (no build step for the skills themselves). To run the same formatting checks as CI and hooks locally, install the tooling below.

### Required: Task and Cargo

1. **[Task](https://taskfile.dev/installation/)** - install the `task` CLI so you can run tasks from [`Taskfile.yaml`](Taskfile.yaml) (`task fmt`, `task install`, etc.).
2. **[Rust and Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)** - required because `task install` uses [cargo-binstall](https://github.com/cargo-bins/cargo-binstall) to pull prebuilt binaries (e.g. [rumdl](https://github.com/rvben/rumdl)).

Then clone and install dev tools:

```bash
git clone https://github.com/Keeper-Security/keeper-agent-kit
cd keeper-agent-kit
task install
```

### Optional: pre-commit

```bash
pip install pre-commit
pre-commit install
```

You also need **`jq`** on your PATH for `scripts/validate.sh` (e.g. `brew install jq` on macOS).

Hooks call `task fmt` (rumdl), validate **commit messages** (Conventional Commits via `scripts/validate-commit-msg.sh`), and **`task validate`** (full check: `scripts/validate.sh` — manifests, skills, triggers, examples, root docs). `default_install_hook_types` includes `commit-msg`, so `pre-commit install` registers both stages. Before you open a PR, run `task fmt`, **`task validate`** (or `pre-commit run plugin-ci --all-files`), or `pre-commit run --all-files`.

### Commit messages (Conventional Commits)

All commits on the default branch should follow [Conventional Commits](https://www.conventionalcommits.org/) so automation can build the changelog and releases:

- Format: `type(scope): subject` or `type: subject` (scope optional). Breaking changes: `feat!: subject` or `feat(scope)!: subject`.
- **Types** we use: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- **Subject**: at least a few words after the colon; be specific.

Examples: `feat(skills): add ksm interpolate example`, `fix(ci): pin release-please action`, `docs: link changelog from readme`.

Pull requests are checked by **Semantic PR** (`.github/workflows/semantic-pull-request.yml`): the **PR title** must use the same convention (recommended when you squash-merge so the title becomes the commit message).

### Releases and changelog

- **[release-please](https://github.com/googleapis/release-please)** runs on pushes to `main` (`.github/workflows/release-please.yml`). It opens a **release pull request** that bumps `version.txt`, `.release-please-manifest.json`, `CHANGELOG.md`, and every version field listed in `release-please-config.json` → `extra-files` (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` `metadata.version` and each plugin’s `version`, `.cursor-plugin/marketplace.json` `metadata.version`, `plugins/**/.cursor-plugin/plugin.json`, and the versioned example in `docs/add-a-plugin.md`).
- When that release PR is **merged**, GitHub receives a **release** with notes derived from those commits (and the updated changelog).
- Configure paths in `release-please-config.json` and `.release-please-manifest.json`.

#### `version.txt` (how the version is updated)

- **Role** - One line, semver only (e.g. `1.2.3`). With **`release-type: simple`** in `release-please-config.json`, this file is the **canonical project version** release-please reads and writes.
- **Normal workflow** - **Do not** edit `version.txt` by hand to ship a release. Land conventional commits on `main`, let release-please open its **release PR**, review it, and **merge that PR**. The PR updates `version.txt` together with `.release-please-manifest.json`, `CHANGELOG.md`, and all paths in `release-please-config.json` → `extra-files` (see above).
- **Avoid drift** - If you ever change a version **outside** that flow (unusual), update **every** file release-please keeps in sync so they all match; mismatches break automation and CI expectations.

### Optional: run CI workflows locally with [act](https://github.com/nektos/act)

Use **[`.github/ACT.md`](.github/ACT.md)** for prerequisites, how `act` maps to GitHub Actions, and the exact commands. From the repo root, **`./scripts/act-all.sh`** (or **`task act`**) runs **`task validate`** first (same checks as the **pre-commit** `plugin-ci` hook), then **act** against **semantic-pull-request** and **release-please**. Plugin validation is **not** duplicated on GitHub; use pre-commit (or `task validate`) before you push. **semantic-pull-request** and **release-please** often do not finish inside act without GitHub API access; see **ACT.md**.

## Testing Guidelines

### SKILL.md Validation

Each skill file must:

- Have valid YAML frontmatter
- `name` field: 1-64 characters, alphanumeric + hyphens
- `description` field: 1-200 characters preferred (longer OK for Claude Code)
- Markdown is valid and renders correctly

**Manual test:**

```bash
# Check frontmatter
cat skills/keeper-secrets/SKILL.md | head -20

# Verify markdown (using your editor)
# - Headings are hierarchical (##, ###, not ###, ##)
# - Code blocks have language specified
# - Links are valid
- Tables format correctly
```

### Command Testing

If adding new commands to reference docs:

```bash
# Test against actual Keeper CLI if you have access
ksm secret list
keeper shell
# Run documented commands and verify output

# Or reference official Keeper documentation to verify accuracy
```

### Installation Testing

After making changes, test that the Keeper Security agent kit loads:

```bash
# Claude Code
cp -r skills/keeper-* ~/.claude/skills/
ls ~/.claude/skills/keeper-*/SKILL.md

# Should list three files:
# ~/.claude/skills/keeper-secrets/SKILL.md
# ~/.claude/skills/keeper-admin/SKILL.md
# ~/.claude/skills/keeper-setup/SKILL.md
```

## Submission Checklist

Before submitting a pull request:

- [ ] `task fmt` (or `pre-commit run --all-files`) passes
- [ ] Changes follow existing style and formatting
- [ ] SKILL.md files have valid frontmatter
- [ ] Markdown renders correctly
- [ ] Code examples are tested (or reference official docs)
- [ ] No hardcoded UIDs or credentials in examples
- [ ] Links are valid and point to official sources
- [ ] Commit messages (and **PR title** if you squash-merge) follow [Conventional Commits](#commit-messages-conventional-commits)
- [ ] PR description explains what changed and why

## Pull Request Process

1. Fork and create a feature branch: `git checkout -b feature/my-improvement`
2. Make your changes
3. Test locally
4. Commit with a conventional message, e.g. `git commit -m "docs(ksm): add Docker Compose example to ksm-exec-patterns"`
5. Push to your fork
6. Open pull request with:
   - Clear title
   - Description of changes
   - Reference to related issue if applicable
   - Testing notes

## Documentation Standards

### Markdown Style

- **Headings:** Use `##` for main sections, `###` for subsections
- **Code blocks:** Always specify language (`bash`, `yaml`, `json`, etc.)
- **Lists:** Use `-` for unordered, numbers for ordered
- **Tables:** Use proper markdown table syntax
- **Bold:** For important terms and emphasis
- **Inline code:** For commands, file paths, variables

### Example Format

Structure pages with `##` / `###` headings, short paragraphs, fenced code with a language tag, and tables when comparing columns.

**Sample patterns:**

```bash
# Code example with language specified
ksm secret list
```

```text
**Key points:**

- Bullet 1
- Bullet 2

| Column 1 | Column 2 |
| --- | --- |
| Cell 1 | Cell 2 |
```

### Security Guidelines

- **Never include:** Hardcoded UIDs, actual passwords, real tokens
- **Use:** `<PLACEHOLDER>`, `<RECORD_UID>`, `<TOKEN>` in examples
- **Document:** Security considerations and warnings
- **Link:** To official security docs when relevant

### Bias & Inclusivity

- Use inclusive language
- Avoid gendered pronouns (use "they/them" or rephrase)
- Be respectful of different skill levels
- Provide context for jargon and acronyms

## Style Guidelines

### Consistency

- Match existing formatting and terminology
- Use "Keeper" (not "keeper") when referring to product
- Use "KSM CLI" (not "ksm") when referring to tool formally
- Command examples: Use actual command syntax (`ksm`, `keeper`)

### Tone

- Professional but approachable
- Assume reader may not be familiar with security/PAM
- Provide context and explain "why" not just "how"
- Be concise but comprehensive

### Organization

- Logical flow from simple to complex
- Group related content together
- Use headers to break up long sections
- Provide table of contents for reference docs

## Content Areas

### Skill Files (SKILL.md)

Focus on:

- **When to use** - Clarify skill purpose and when agent should use it
- **Prerequisites** - What users need before using
- **Core concepts** - Key ideas explained simply
- **Common patterns** - Most used workflows
- **Guardrails** - Security and safety guidelines

### Reference Files

Focus on:

- **Complete reference** - All commands and options
- **Examples** - Real-world usage patterns
- **Troubleshooting** - Common issues and solutions
- **Best practices** - Recommended approaches

## Versioning

**Plugin / repo version** - [release-please](https://github.com/googleapis/release-please) manages **one** semver for the whole distribution: `version.txt`, `.release-please-manifest.json`, `CHANGELOG.md`, **`.claude-plugin/plugin.json`**, **`.claude-plugin/marketplace.json`** (`metadata.version` and each listed plugin’s `version`), **`.cursor-plugin/marketplace.json`** (`metadata.version`), **`plugins/**/.cursor-plugin/plugin.json`**, and the **docs/example** block in **`docs/add-a-plugin.md`** (see `release-please-config.json` → `extra-files`). CI runs **`scripts/verify-repo-versions.py`** to ensure `version.txt` matches those files. It does **not** bump per-skill versions; skills under `skills/` ship as part of that plugin release.

**Change significance** (for commit messages and changelog tone; not separate skill semver in this repo):

- **MAJOR** - Breaking changes to command syntax or CLI
- **MINOR** - New features, new commands, additions
- **PATCH** - Documentation fixes, clarifications, typos

## License

By contributing, you agree your contributions will be licensed under Apache 2.0 (same as the project).

## Questions?

- Open an issue with the `question` label
- Check existing issues for answers
- Review [Keeper Documentation](https://docs.keeper.io)
- Contact [Keeper Security Support](https://www.keepersecurity.com/support/)

## Recognition

Contributors will be recognized in:

- CONTRIBUTORS.md file
- GitHub contributors graph
- Release notes for major contributions

Thank you for helping make Keeper Security Agent Kit better! 🎉
