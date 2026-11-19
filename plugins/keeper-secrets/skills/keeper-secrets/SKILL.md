---
name: keeper-secrets
description: Use Keeper KSM CLI for scoped application secrets, keeper notation, runtime injection, templates, and explicit CLI sync. Not Desktop MCP, SDK development, or enterprise administration.
---

# Keeper Secrets Manager CLI

## When to Use KSM

Use `ksm` for shell-based, application/device-scoped secrets delivery, including
CI/CD and containers. For application code use **keeper-sdk**; for purpose-built
integrations use **keeper-integrations**. Local human-approved workflows may fit
**keeper-developer** or **keeper-mcp** better. Administration uses **keeper-admin**;
target credential rotation uses **keeper-pam**, not a record-password update.

## Prerequisites

- KSM CLI and a scoped KSM application/device configuration.
- Required records/folders shared with the application; edit rights only if needed.
- Verify `ksm version` and command help before using version-specific flags.
- Read [references/safety.md](references/safety.md) before operating.

## Workflow

1. Identify the environment, application/profile, and intended operation.
2. Inspect metadata with `ksm secret list`; resolve ambiguous titles before acting.
3. Inject only required secrets into an approved consuming process. Do not capture
   secret-bearing commands or full-record JSON in the agent's output.
4. Preview and confirm mutations/sync scope before applying them.
5. Report safe status only and clean up task-owned files or processes.

KSM commands do not require an interactive terminal or tmux. Use a secure terminal
only for user-controlled bootstrap or other explicitly interactive work.

## Core Commands

```bash
ksm version
ksm secret list
ksm secret list --title '^Development API$'
ksm folder list
```

### Authentication

Install using a supported installer or a virtual environment:

```bash
python -m pip install 'keeper-secrets-manager-cli[keyring]'
# User supplies KSM_CLI_TOKEN in their secure terminal, never in chat.
ksm profile init --profile-name development
ksm --profile-name development secret list
```

The token bootstraps durable device credentials; it is not reused for every call.
Remove bootstrap variables after successful binding. OS keyring behavior depends
on the platform and installation; configuration files and base64 exports remain
sensitive. Diagnose configuration, scope, IP lock, and device status before
recreating a device on every authentication failure.

### Runtime injection: ksm exec

```bash
API_KEY='keeper://<RECORD_UID>/field/password' ksm exec -- ./myapp
```

Only notation, not a resolved secret, is supplied in this command. The child
process receives the secret and must not print it. Do not wrap the command in
`echo`, dump its environment, or expand secrets into command arguments.

### File delivery: ksm interpolate

```bash
# Output path is a user-approved, protected file; umask applies on POSIX.
(umask 077; ksm interpolate config.tmpl -o /approved/private/config.yaml)
```

Interpolation writes **plaintext** when directed to a file; without `-o` it can
print secrets to stdout. It is not equivalent to a protected Property File mount.
Never evaluate or source interpolated output as shell code. Agree on permissions,
retention, backups, and deletion first. JSON/YAML values must be serialized safely;
text substitution is not a universal format-aware serializer.

## Guardrails

- Never print secrets, tokens, TOTP codes, full-record dumps, or bootstrap config.
- Do not broaden permissions or disable TLS/IP controls to fix an access denial.
- Confirm deletion, edits, access changes, and external sync separately.
- Do not export a CLI INI file and assume it is an SDK JSON configuration.
- Read [references/ksm-commands.md](references/ksm-commands.md) for verified syntax,
  [references/keeper-notation.md](references/keeper-notation.md) for field paths,
  and [references/ksm-exec-patterns.md](references/ksm-exec-patterns.md) for delivery.

## Sources

- [KSM CLI](https://docs.keeper.io/keeperpam/secrets-manager/secrets-manager-command-line-interface)
- [Profile command](https://docs.keeper.io/keeperpam/secrets-manager/secrets-manager-command-line-interface/profile-command)
- [Keeper notation](https://docs.keeper.io/keeperpam/secrets-manager/about/keeper-notation)
