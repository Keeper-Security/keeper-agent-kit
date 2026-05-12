# OpenClaw × Keeper Commander CLI — Skill implementation overview

This page describes how a **Keeper Commander** capability is packaged as an **OpenClaw skill** so local agents can manage vaults, enterprise administration, and privileged access safely and consistently.

---

## Purpose

**Keeper Commander** (`keeper`) is Keeper Security’s full-featured CLI and shell for vault operations, enterprise admin, KeeperPAM, KSM application management, and automation. **OpenClaw skills** are reusable instruction bundles (Markdown with structured front matter) that teach an agent *when* to use a tool, *which* commands apply, and *what* guardrails must hold.

Together, a Commander-focused skill lets OpenClaw delegate complex Keeper workflows without hard-coding Keeper logic into the agent’s core prompt.

---

## How OpenClaw loads skills (context)

OpenClaw discovers skills from several locations (highest precedence first):

1. **Workspace skills** — e.g. `<workspace>/skills` (per-agent or per-project)
2. **Managed / local skills** — typically `~/.openclaw/skills`
3. **Bundled skills** — shipped with the OpenClaw install

Additional directories may be configured (for example via `skills.load.extraDirs` in `~/.openclaw/openclaw.json`). When the same skill name exists in more than one place, **workspace wins**, then managed/local, then bundled.

Skills are usually distributed via **ClawHub** (`clawhub install …`) or copied from a trusted private repository. Treat third-party skills as **untrusted code**: review source, permissions, and behavior before installation.

---

## What the Keeper Commander skill teaches the agent

A well-designed Commander skill encodes:

| Concern | What the skill specifies |
| --- | --- |
| **Triggering** | When to prefer Commander vs other tools (e.g. KSM-only secret injection). |
| **Prerequisites** | Python version, `pip install keepercommander`, optional `tmux`, account permissions. |
| **Workflow** | Order of operations: verify CLI, confirm auth, search metadata before reads, avoid leaking secrets. |
| **Command surface** | Pointers to a command reference and official Keeper docs; use of `keeper --help` / subcommand help. |
| **Interactive execution** | How to preserve login, MFA, and shell context across agent tool invocations (see below). |
| **Guardrails** | No passwords on the command line, confirm destructive actions, redirect runtime secret injection to KSM patterns. |

Official Commander documentation: [Commander CLI overview](https://docs.keeper.io/en/keeperpam/commander-cli/overview).

---

## Skill bundle layout (implementation shape)

A minimal skill directory looks like:

```text
skills/keeper-admin/          # or ~/.openclaw/skills/keeper-admin/
├── SKILL.md                  # Primary instructions + YAML front matter (name, description)
└── references/               # Optional deep references
    ├── commander-commands.md
    ├── enterprise-mgmt.md
    ├── pam-commands.md
    └── …
```

- **`SKILL.md` (or `skill.md`)** — YAML front matter (`name`, `description`) plus narrative instructions the model follows when the skill is active.
- **`references/`** — Long command lists and scenarios kept out of the main file so the agent loads detail only when needed.

OpenClaw’s ecosystem often uses `skill.md`; Cursor and other agents may expect `SKILL.md`. Use the filename your host expects, or provide both if you support multiple runtimes.

---

## Critical implementation detail: interactive Commander and `tmux`

Agent shell tools often allocate a **fresh TTY per command**. Keeper Commander, however, relies on **interactive sessions**, **MFA**, and **persistent device login** in many setups.

The recommended pattern in the skill is:

1. Create a **dedicated `tmux` session** with a predictable **socket path** (optionally overridden by an environment variable such as `TMUX_SOCKET_DIR`).
2. Start `keeper shell` (or `keeper-commander shell`) inside that session.
3. **Drive** the session with `send-keys` and **read** output with `capture-pane`.

This preserves authentication context and matches how human operators run Commander over SSH or long-lived terminals.

Example variables (conceptual):

- `SOCKET_DIR` — defaults under `${TMPDIR:-/tmp}/keeper-tmux-sockets` unless overridden.
- `SOCKET` — e.g. `keeper-commander.sock` under that directory.
- `SESSION` — unique session name per auth flow (e.g. timestamped `keeper-auth-…`).

The skill should document **how to tear down** the session when work is done, unless the user explicitly wants a persistent shell.

---

## Commander vs Keeper Secrets Manager (routing)

The skill should steer the agent clearly:

| User need | Preferred path |
| --- | --- |
| Enterprise users, teams, roles, nodes | Commander |
| KSM application / client device lifecycle | Commander |
| Password rotation configuration, PAM gateways, remote connect | Commander |
| Interactive vault browsing, batch files, API server mode | Commander |
| **Runtime** secret fetch / env injection for apps | **KSM** (`ksm`) — separate skill |

This split avoids giving application-style automation a full interactive vault session when KSM is the right tool.

---

## Security and compliance (skill-level)

Document explicitly in the skill:

1. **Never** pass master passwords, API tokens, or vault field values on the command line or in URLs (process listing and shell history).
2. Prefer **interactive login**, **persistent device login**, or **documented** non-interactive patterns from Keeper’s official docs—not ad-hoc scripting.
3. **Do not** echo secret field values into chat unless the user explicitly requests it for debugging—and warn first.
4. Require **user confirmation** before destructive enterprise or vault operations.
5. **Supply-chain**: pin or review the Git revision of the skill; prefer installs from a known organization (e.g. Keeper Security’s agent kit) over unvetted ClawHub uploads.

---

## Installing this skill on OpenClaw

High-level steps:

1. Install **OpenClaw CLI** and (if you use it) **ClawHub** per your deployment.
2. Install **Keeper Commander** (`pip install keepercommander`) on the same machine or container where the agent runs shell commands.
3. Copy or install the skill into **`/skills`** (workspace-highest precedence) or **`~/.openclaw/skills`** (shared on the host), following OpenClaw’s precedence rules.
4. Configure **minimum** filesystem and network permissions for the agent user.
5. Run a **smoke test**: `keeper version`, then interactive login in the documented `tmux` pattern, then a non-destructive command such as `whoami` in the Commander shell.

---

## Related reading

- [OpenClaw skills (conceptual overview)](https://www.digitalocean.com/resources/articles/what-are-openclaw-skills) — skill format, ClawHub, security considerations.
- [Keeper Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview) — installation, shell, batch mode.
- [Keeper Security Agent Kit](https://github.com/Keeper-Security/keeper-agent-kit) — maintained `keeper-admin`, `keeper-secrets`, and `keeper-setup` skill plugins for multiple agent platforms.

---

## GitBook navigation hint

Suggested placement under your GitBook space:

- **Parent**: Integrations → OpenClaw  
- **Siblings**: Skill authoring, ClawHub policy, deployment hardening  
- **Child pages**: Commander command reference, KSM skill overview, tmux runbook

Add this file to `SUMMARY.md` as needed, for example:

```markdown
* [OpenClaw](openclaw/README.md)
  * [Keeper Commander skill overview](openclaw-keeper-commander-skill-overview.md)
```
