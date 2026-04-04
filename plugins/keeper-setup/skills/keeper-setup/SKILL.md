---
name: keeper-setup
description: Install and configure Keeper CLI tools (KSM CLI and Commander) for the Keeper Security agent kit. Use when the user needs to install keeper-secrets-manager-cli (ksm) or keepercommander (keeper), set up authentication, initialize profiles, configure persistent login, or troubleshoot Keeper CLI connectivity. Also use when the user says 'install keeper', 'setup keeper', 'configure keeper cli', or asks how to get started with Keeper's command line tools.
---

# Keeper CLI Setup & Configuration

## Official documentation

- [Secrets Manager (KSM)](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) - concepts, KSM CLI install, and app/device setup
- [Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview) - concepts, install, and interactive shell
- [Keeper notation](https://docs.keeper.io/en/keeperpam/secrets-manager/about/keeper-notation) - `keeper://` URIs used by `ksm exec` and `ksm interpolate` (see **keeper-secrets** skill for usage)

Keeper provides two CLI tools. Install what you need:

| Tool | Package | Purpose |
| --- | --- | --- |
| KSM CLI (`ksm`) | `keeper-secrets-manager-cli` | Machine secrets retrieval & injection |
| Commander (`keeper`) | `keepercommander` | Admin, vault management, PAM, sessions |

## Installation security

- **Prefer PyPI** (`pip install …`) so you consume the published packages with version pins in your own dependency files. That is the default path for these tools.
- **Official sources only**: release binaries and source live under the **Keeper-Security** organization on GitHub. Before running any installer or `pip install` from a clone, confirm the remote URL and publisher match Keeper’s official documentation; use release tags or checksums published on the release page when you need extra assurance.
- **Agents must not** fabricate or echo one-time tokens, master passwords, or vault field values in chat or generated scripts. Direct the user to paste or inject secrets only in their own secure terminal or secret store.

## Quick Install

### KSM CLI

```bash
# With OS-native keyring (recommended for workstations)
pip install keeper-secrets-manager-cli[keyring]

# Without keyring (for containers, CI/CD, headless)
pip install keeper-secrets-manager-cli

# Verify
ksm version
```

**Binary installers** (no Python required) are published for Windows, macOS, and Linux on the official **Keeper-Security/secrets-manager** GitHub Releases page linked from [Secrets Manager CLI](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) documentation. Download only from that release page; verify checksums or signatures when the release provides them.

### Commander

```bash
pip install keepercommander

# Optional: install from a local clone of the official repository (verify remote and use a tagged release)
git clone https://github.com/Keeper-Security/Commander.git
cd Commander
git checkout <release-tag>
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt && pip install -e .

# Verify
keeper version
```

## First-Time Setup

### KSM CLI Setup

You need a One-Time Access Token from a KSM Application. If you don't have
one, your Keeper admin can create it via the Vault UI or Commander
(see keeper-admin skill).

Provide the token **via environment variable** so it is not passed as a `--token`
argument (which can show up in shell history and process listings). Official docs:
[Profile command / init](https://docs.keeper.io/en/keeperpam/secrets-manager/secrets-manager-command-line-interface/profile-command).

```bash
# Prerequisite: export KSM_CLI_TOKEN in this shell from Vault or Commander output (see Keeper profile docs). Never paste token values into chat or committed files.
ksm profile init
# Optional: unset KSM_CLI_TOKEN when finished in this shell.

ksm secret list  # Verify access
```

In CI or secret managers, inject the same variable without placing the value on the command line. For containers, see also `KSM_TOKEN` / `KSM_INI_DIR` behavior in the Keeper Secrets Manager CLI documentation.

### Commander Setup

```bash
keeper shell
# Enter your email, master password, and 2FA code
# Then enable persistent login:
My Vault> this-device register
My Vault> this-device persistent-login ON
```

## Keeper Regions

| Region | Host | Token Prefix |
| --- | --- | --- |
| US | keepersecurity.com | US: |
| EU | keepersecurity.eu | EU: |
| AU | keepersecurity.com.au | AU: |
| JP | keepersecurity.jp | JP: |
| CA | keepersecurity.ca | CA: |
| US Gov | govcloud.keepersecurity.us | GOV: |

## Troubleshooting

| Issue | Fix |
| --- | --- |
| "Not authenticated" | Re-run `ksm profile init` after setting `KSM_CLI_TOKEN` from a new Client Device token |
| "Token expired" | Generate a new Client Device in Commander or Vault UI |
| IP lock errors | Use `--unlock-ip` when creating the client, or init from the locked IP |
| Keyring not available | Install with `[keyring]` extra or use `--ini-file` flag |
| Python version error | KSM CLI requires Python 3.10+, Commander requires 3.10+ |
| Permission denied on keeper.ini | File should be 0600; check with `ls -la keeper.ini` |

## What's Next

- To retrieve and inject secrets (including Keeper notation): see the **keeper-secrets** skill
- To manage enterprise, users, PAM: see the **keeper-admin** skill
