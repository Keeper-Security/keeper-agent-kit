---
name: keeper-secrets
description: Retrieve, inject, and manage secrets from Keeper Vault using KSM CLI (ksm). Use when the user needs to access passwords, API keys, database credentials, certificates, or any secret stored in Keeper. Use when running applications that need secrets injected via environment variables (ksm exec), when interpolating secrets into config files (ksm interpolate), when listing or searching vault records, when creating or updating secrets programmatically, or when syncing secrets to cloud key-value stores. Also use when the user mentions 'keeper', 'ksm', 'keeper secrets', 'keeper vault', 'keeper notation', 'keeper://', or asks about retrieving credentials for CI/CD, Docker, Kubernetes, or any DevOps pipeline. Prefer this skill over hardcoding credentials. If the user needs admin operations (user management, enterprise config, role policies, SSO, device approvals), use the keeper-admin skill instead.
---

# Keeper Secrets Manager CLI (ksm)

The KSM CLI is Keeper's machine-oriented secrets management tool. It retrieves
secrets from the Keeper Vault without requiring a full user login - it uses
Application + Client Device authentication with one-time access tokens.

## Official documentation

- [Secrets Manager (KSM)](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) - overview, installation, and configuration
- [Keeper notation](https://docs.keeper.io/en/keeperpam/secrets-manager/about/keeper-notation) - `keeper://` URI syntax for fields, custom fields, and files

## When to Use KSM vs Commander

| Need | Tool |
| --- | --- |
| Retrieve a secret (password, key, cert) | `ksm` |
| Inject secrets into env vars at runtime | `ksm exec` |
| Template secrets into config files | `ksm interpolate` |
| List/search records shared with your app | `ksm secret list` |
| Create or update secret records | `ksm secret add` / `ksm secret update` |
| Sync secrets to AWS/Azure secret stores | `ksm sync` |
| Generate secure passwords | `ksm secret password` |
| Admin tasks (users, teams, roles, SSO) | Use `keeper` (Commander) - see keeper-admin skill |
| Create KSM Applications or Client Devices | Use `keeper` (Commander) - see keeper-admin skill |
| Manage PAM resources or rotation | Use `keeper` (Commander) - see keeper-admin skill |

## Prerequisites

1. KSM CLI installed: `pip install keeper-secrets-manager-cli` (or binary from GitHub releases)
2. A KSM Application created in Keeper Vault (or via Commander)
3. A Client Device initialized with a One-Time Access Token

Check installation: `ksm version`

## Authentication & Profile Setup

KSM uses profile-based authentication. Credentials are stored in OS-native
secure storage (macOS Keychain, Windows Credential Manager, Linux Secret Service)
by default when installed with keyring support.

```bash
# Install with keyring support (recommended)
pip install keeper-secrets-manager-cli[keyring]

# Initialize with One-Time Access Token (set KSM_CLI_TOKEN in your shell first—see Keeper profile docs; do not pass --token with a literal value)
ksm profile init

# For containers/CI (no keyring available)
pip install keeper-secrets-manager-cli
# Prerequisite: export KSM_CLI_TOKEN from a trusted source, then:
ksm profile init
# Creates keeper.ini with 0600 permissions

# Auto-create profile from environment variable (containers; see Keeper docs)
ksm secret list  # When KSM_TOKEN is set, profile may be auto-created on first use
```

### Multiple Profiles

```bash
ksm profile list
# After exporting KSM_CLI_TOKEN for each setup step:
ksm profile init --profile production
ksm profile init --profile staging
ksm secret list --profile production
```

### Environment Variables

| Variable | Purpose |
| --- | --- |
| `KSM_CLI_TOKEN` | One-Time Access Token for `ksm profile init` without `--token` on the CLI (preferred) |
| `KSM_TOKEN` | One-Time Access Token for auto-init in some container flows (see Keeper docs) |
| `KSM_CONFIG` | Base64 config string (for K8s/containers) |
| `KSM_CONFIG_FILE` | Path to keeper.ini |
| `KSM_CLI_PROFILE` | Active profile name |
| `KSM_HOSTNAME` | Keeper host (US, EU, AU, JP, CA, US_GOV) |

## Core Commands

### List Secrets

```bash
ksm secret list
# Output:
# UID                     Record Type          Title
# ----------------------- -------------------- -------------------------
# SNzjw8tM1HsXEzXERCJrNQ login                Stripe API Key
# 8f8I-OqPV58o2r91wVgZ_A databaseCredentials  Production MySQL Database
```

### Get a Secret

```bash
# Get full record as JSON
ksm secret get -u <RECORD_UID> --json

# Get a specific field value
ksm secret get -u <RECORD_UID> -f password
ksm secret get -u <RECORD_UID> -f login

# Get with JSONPath query
ksm secret get -u <RECORD_UID> --json -q '$.fields[?@.type=="password"].value[0]'

# Get by title
ksm secret get -t "Production MySQL Database" -f password

# Remove surrounding quotes from output (useful for scripting)
ksm secret get -u <RECORD_UID> -f password --raw
```

### Keeper Notation

Keeper Notation is the URI format for referencing specific fields in records.
See the [Keeper notation documentation](https://docs.keeper.io/en/keeperpam/secrets-manager/about/keeper-notation) for full syntax and behavior.

Format: `keeper://<RECORD_UID>/field/<FIELD_TYPE>` or `keeper://<RECORD_UID>/custom_field/<LABEL>`

```text
keeper://SNzjw8tM1HsXEzXERCJrNQ/field/login
keeper://SNzjw8tM1HsXEzXERCJrNQ/field/password
keeper://8f8I-OqPV58o2r91wVgZ_A/field/host
keeper://8f8I-OqPV58o2r91wVgZ_A/custom_field/ConnectionString
```

For full notation syntax, read `references/keeper-notation.md`.

### Inject Secrets into Environment Variables (ksm exec)

This is the primary pattern for running applications with secrets. Any
environment variable starting with `keeper://` gets replaced with the secret
value before the command executes.

```bash
# Single secret
export DB_PASSWORD="keeper://8f8I-OqPV58o2r91wVgZ_A/field/password"
ksm exec -- myapp

# Inline
DB_PASSWORD="keeper://8f8I-OqPV58o2r91wVgZ_A/field/password" \
API_KEY="keeper://SNzjw8tM1HsXEzXERCJrNQ/field/password" \
ksm exec -- ./start_server.sh

# Docker example
docker run \
  -e DB_PASSWORD="keeper://8f8I-OqPV58o2r91wVgZ_A/field/password" \
  -e KSM_CONFIG="<base64-config>" \
  myimage ksm exec -- /app/start.sh
```

### Interpolate Secrets into Config Files

```bash
# Replace keeper:// placeholders in a template file
ksm interpolate --in-file config.tmpl --out-file config.yaml

# Example template (config.tmpl):
# database:
#   host: keeper://8f8I-OqPV58o2r91wVgZ_A/field/host
#   password: keeper://8f8I-OqPV58o2r91wVgZ_A/field/password
```

### Create & Update Secrets

```bash
# Create from editor
ksm secret add editor --record-type login --title "New API Key"

# Create from field arguments (supply sensitive field values from secure input, not sample literals)
ksm secret add field --record-type login --title "New API Key" \
  --field "login=admin"

# Update a field (use secure input for password fields)
ksm secret update -u <RECORD_UID> --field "login=newuser"

# Delete a record
ksm secret delete -u <RECORD_UID>
```

### Generate Passwords

```bash
ksm secret password --length 32
ksm secret password --lc 8 --uc 8 -d 8 --sc 8
```

### Sync to Cloud Stores

```bash
# Sync to AWS Secrets Manager
ksm sync --type aws_sm --credentials <AWS_CREDS_RECORD_UID> \
  --map <KEEPER_UID>=<AWS_SECRET_NAME>

# Sync to Azure Key Vault
ksm sync --type azure_kv --credentials <AZURE_CREDS_RECORD_UID> \
  --map <KEEPER_UID>=<AZURE_SECRET_NAME>
```

### Folder Management

```bash
ksm folder list
ksm folder get -u <FOLDER_UID>
```

## Guardrails

- NEVER paste, print, or log secret values into chat, code comments, or commit messages.
- ALWAYS prefer `ksm exec` or `ksm interpolate` over writing secrets to disk or
  embedding them in source code.
- If a command fails with authentication errors, re-initialize the profile with
  a fresh One-Time Access Token.
- Record UIDs that start with `-` must be prefixed with `--`:
  `ksm secret get -- -AbCdEfGh`
- For commands that reference sensitive records, confirm the action with the user
  before executing destructive operations (delete, update).

## Common Patterns

### CI/CD Pipeline (GitHub Actions)

```yaml
env:
  KSM_CONFIG: ${{ secrets.KSM_CONFIG }}
steps:
  - run: pip install keeper-secrets-manager-cli
  - run: |
      DB_PASSWORD="keeper://<UID>/field/password" \
      ksm exec -- ./deploy.sh
```

### Docker / Kubernetes

```bash
# Pass base64 config as env var
kubectl create secret generic ksm-config \
  --from-literal=config=<BASE64_CONFIG>

# In pod spec, mount KSM_CONFIG and use ksm exec as entrypoint
```

### Local Development

```bash
# One-time setup
pip install keeper-secrets-manager-cli[keyring]
# Prerequisite: export KSM_CLI_TOKEN, then:
ksm profile init

# Daily use - run your app with secrets injected
DB_URL="keeper://<UID>/field/url" \
API_KEY="keeper://<UID>/field/password" \
ksm exec -- npm run dev
```
