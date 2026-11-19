---
name: keeper-setup
description: Choose, install, configure, and troubleshoot Keeper interfaces for local AI access, developer tools, CLI secrets, SDKs, integrations, and administration. Install only what the task requires.
---

# Keeper Setup and Capability Selection

## Choose before installing

Ask what will run, where, and under whose authority. Local human-approved access
differs from unattended application/device access. Inspect available tools first;
do not install a CLI when an existing permitted interface already fits the task.

| Task | Skill / route |
| --- | --- |
| Local governed agent operations | **keeper-mcp** / Keeper Desktop MCP |
| Protected local configuration, Property Files, SSH Agent | **keeper-developer** / Developer Center |
| Shell runtime injection | **keeper-secrets** / KSM CLI |
| Application code | **keeper-sdk** / KSM or Vault SDK |
| CI/CD, Kubernetes, Terraform, USS, enterprise integrations | **keeper-integrations** |
| Enterprise, MSP, KEPM, Vault administration | **keeper-admin** / supported admin tools |
| PAM sessions, JIT, queries, rotation | **keeper-pam** |

Read [references/safety.md](references/safety.md) before setup or authentication.
Never bypass an MCP policy denial by switching interfaces.

## Prerequisites

Confirm product version/channel, OS, account region, licensing, and required scope.
Developer Center / Property Files are documented as Preview for Vault 18.7 as of
November 18, 2026. Validate actual availability and mount support for the installed
Desktop variant; do not assume all features work on Linux or the web/mobile Vault.
SDKs and CLIs have distinct runtime requirements; no single Python requirement
applies to all Keeper tools.

## Quick Install

### Desktop MCP and Developer Center

Use **Developer Center > Local Tools > MCP for AI Agents > Set Up**, or the MCP
Setup action in AI Agent Access. Follow the official installer flow and copy the
actual absolute executable path from the user's setup dialog. MCP client formats
differ; do not overwrite existing server configuration. Start metadata-only with
read-only access to a small record/folder scope. The user approves in Desktop.

### KSM CLI

Use an official supported installer, or an isolated Python environment:

```bash
python -m pip install 'keeper-secrets-manager-cli[keyring]'
ksm version
```

An admin provisions a scoped application and device. In the user's secure
terminal, initialize using `KSM_CLI_TOKEN`:

```bash
ksm profile init --profile-name development
ksm --profile-name development secret list
unset KSM_CLI_TOKEN
```

Do not ask the user to paste the token into chat. Keyring availability is platform
dependent. Bound configs and base64 exports are credentials, not encrypted merely
because they are encoded. CLI INI profiles and SDK JSON configs are not interchangeable.

### Commander

```bash
python -m pip install keepercommander
keeper --version
keeper shell
```

The user completes login/MFA through a supported secure interaction. Review
persistent login, biometrics, device registration, timeout, and enterprise policies
before opting into them. Prefer the host's interactive terminal; tmux is optional
and any session must be task-owned and isolated. Do not capture authentication
prompts, token output, or secret-bearing scrollback into the conversation.

## Troubleshooting

| Symptom | Safe checks |
| --- | --- |
| Missing MCP tools | Version/channel, client tool refresh, capability scope, beta consent, policy; do not bypass |
| Desktop connection denied | Signed-in state, user consent, correct installed path and Desktop variant |
| KSM auth failure | Correct profile/region, complete binding, revoked device, IP lock, storage permissions |
| Consumed/expired bootstrap token | Inspect device state before an authorized new-device bootstrap; do not blindly retry |
| Keyring unavailable | Supported backend or explicitly approved protected config; no plaintext chat workaround |
| Command flag rejected | Installed `--help` and official version-specific docs; stop rather than guess |
| Wrong region | Use the tenant's documented host/token prefix; do not change region based on location |

## Guardrails

Install from official sources, pin reviewed versions in deployment dependencies,
verify release signatures/checksums where provided, and obtain approval for installs.
Do not change global runtimes or install all Keeper products as a prerequisite.

## Sources

- [Developer Center](https://docs.keeper.io/keeperpam/developer-and-mcp/developer-center)
- [MCP setup](https://docs.keeper.io/keeperpam/developer-and-mcp/ai-agent-access/keeper-mcp-setup)
- [KSM CLI](https://docs.keeper.io/keeperpam/secrets-manager/secrets-manager-command-line-interface)
- [Commander installation](https://docs.keeper.io/keeperpam/commander-cli/commander-installation-setup)
