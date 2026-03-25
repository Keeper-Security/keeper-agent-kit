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

**Binary installers** (no Python required) are available for Windows, macOS,
and Linux at: <https://github.com/Keeper-Security/secrets-manager/releases>

### Commander

```bash
pip install keepercommander

# Or from source
git clone https://github.com/Keeper-Security/Commander
cd Commander
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

```bash
ksm profile init --token "US:XXXXXXXXXX"
ksm secret list  # Verify access
```

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
| "Not authenticated" | Re-run `ksm profile init` with a new token |
| "Token expired" | Generate a new Client Device in Commander or Vault UI |
| IP lock errors | Use `--unlock-ip` when creating the client, or init from the locked IP |
| Keyring not available | Install with `[keyring]` extra or use `--ini-file` flag |
| Python version error | KSM CLI requires Python 3.10+, Commander requires 3.10+ |
| Permission denied on keeper.ini | File should be 0600; check with `ls -la keeper.ini` |

## What's Next

- To retrieve and inject secrets (including Keeper notation): see the **keeper-secrets** skill
- To manage enterprise, users, PAM: see the **keeper-admin** skill
