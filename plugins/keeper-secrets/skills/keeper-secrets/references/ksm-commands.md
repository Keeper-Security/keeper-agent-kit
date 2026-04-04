# KSM CLI Command Reference

Complete reference for all `ksm` (Keeper Secrets Manager CLI) subcommands.

Official documentation: [Secrets Manager (KSM)](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) · [Keeper notation](https://docs.keeper.io/en/keeperpam/secrets-manager/about/keeper-notation).

## Installation

```bash
# With keyring support (recommended)
pip install keeper-secrets-manager-cli[keyring]

# Without keyring (containers/CI)
pip install keeper-secrets-manager-cli

# Binary installers
# https://github.com/Keeper-Security/secrets-manager/releases
```

## Global Options

```bash
--profile <name>          # Use named profile (default: 'default')
--config-file <path>      # Path to keeper.ini
--format <format>         # Output format: json, csv, table (default: table)
--raw                     # Raw output without formatting
--verbose, -v             # Verbose output
--help, -h                # Show help
```

## Profile Commands

### profile init

Initialize a new profile with One-Time Access Token.

Prefer **`KSM_CLI_TOKEN`** in the environment so the token is not passed as a `--token` argument (see [Keeper profile command](https://docs.keeper.io/en/keeperpam/secrets-manager/secrets-manager-command-line-interface/profile-command)). `--token` overrides the environment if both are set.

```bash
ksm profile init
ksm profile init --profile production
ksm profile init --hostname keepersecurity.com
ksm profile init --ini-file /etc/keeper/config.ini
```

**Options:**

- `--token <token>` - One-Time Access Token (prefer `KSM_CLI_TOKEN` instead of a literal on the CLI)
- `--profile <name>` - Profile name (default: 'default')
- `--hostname <host>` - Keeper host (keepersecurity.com, keepersecurity.eu, etc.)
- `--ini-file <path>` - Path to config file (default: ~/.keeper/keeper.ini)
- `--private-key <path>` - Private key file path
- `--skip-keyring` - Don't use OS keyring, use keeper.ini instead

### profile list

List all configured profiles.

```bash
ksm profile list
ksm profile list --json
```

**Output:**

```text
Profile Name          Status          Last Used
default               Active          2025-03-25 14:32:00
production            Active          2025-03-24 09:15:00
staging               Inactive        2025-03-20 16:45:00
```

### profile update

Update profile settings.

```bash
ksm profile update --profile production --hostname keepersecurity.eu
ksm profile update --hostname keepersecurity.com.au
```

**Options:**

- `--profile <name>` - Profile to update
- `--hostname <host>` - Update Keeper host

### profile delete

Delete a profile.

```bash
ksm profile delete --profile staging
```

**Options:**

- `--profile <name>` - Profile to delete
- `--force` - Don't prompt for confirmation

## Secret Commands

### secret list

List all secrets available to the application.

```bash
ksm secret list
ksm secret list --profile production
ksm secret list --json
ksm secret list --folder-uid <FOLDER_UID>
```

**Output:**

```text
UID                     Record Type          Title
----------------------- -------------------- -------------------------
SNzjw8tM1HsXEzXERCJrNQ login                Stripe API Key
8f8I-OqPV58o2r91wVgZ_A databaseCredentials  Production MySQL Database
```

**Options:**

- `--profile <name>` - Use specific profile
- `--json` - Output as JSON
- `--folder-uid <uid>` - Filter by folder
- `--exclude-folders <uids>` - Exclude folder UIDs
- `--format <format>` - Output format (json, csv, table)

### secret get

Get a specific secret record or field.

```bash
# Get full record as JSON
ksm secret get -u SNzjw8tM1HsXEzXERCJrNQ --json

# Get specific field
ksm secret get -u SNzjw8tM1HsXEzXERCJrNQ -f password
ksm secret get -u SNzjw8tM1HsXEzXERCJrNQ -f login

# Get by record title
ksm secret get -t "Production MySQL Database" -f password

# Get with JSONPath query
ksm secret get -u SNzjw8tM1HsXEzXERCJrNQ --json -q '$.fields[?@.type=="password"].value[0]'

# Raw output (no quotes)
ksm secret get -u SNzjw8tM1HsXEzXERCJrNQ -f password --raw

# Using Keeper notation
ksm secret get keeper://SNzjw8tM1HsXEzXERCJrNQ/field/password
```

**Options:**

- `-u, --uid <uid>` - Record UID
- `-t, --title <title>` - Record title (searches by exact match)
- `-f, --field <field>` - Field type (password, login, url, host, port, etc.)
- `--custom-field <label>` - Get custom field by label
- `--json` - Output full record as JSON
- `-q, --query <jsonpath>` - JSONPath query on JSON output
- `--raw` - Raw output without quotes or escaping
- `--profile <name>` - Use specific profile

**Standard Field Types:**

- `login` - Username/login field
- `password` - Password field
- `url` - Website URL
- `host` - Server host/IP
- `port` - Port number
- `domain` - Domain name

### secret add

Create a new secret record.

```bash
# Interactive editor
ksm secret add editor --record-type login --title "New Secret"

# From command-line fields (set password fields via interactive editor or secure input—not sample literals)
ksm secret add field --record-type login --title "API Key" \
  --field "login=user@example.com"

# Add to specific folder
ksm secret add field --record-type login --title "DB Cred" \
  --field "login=admin" \
  --folder-uid <FOLDER_UID>

# Custom fields
ksm secret add field --record-type login --title "Custom" \
  --custom-field "label=value"
```

**Options:**

- `editor` - Use interactive editor (default)
- `field` - Add from command-line
- `--record-type <type>` - Record type (login, bankAccount, address, etc.)
- `--title <title>` - Record title (required)
- `--field <key=value>` - Standard field (repeatable)
- `--custom-field <label=value>` - Custom field (repeatable)
- `--folder-uid <uid>` - Target folder
- `--profile <name>` - Use specific profile

### secret update

Update fields in an existing secret.

```bash
# Update password
ksm secret update -u SNzjw8tM1HsXEzXERCJrNQ --field "password=newpass123"

# Update multiple fields
ksm secret update -u SNzjw8tM1HsXEzXERCJrNQ \
  --field "password=newpass" \
  --field "login=newuser"

# Update custom field
ksm secret update -u SNzjw8tM1HsXEzXERCJrNQ \
  --custom-field "ConnectionString=new-value"

# Update by title
ksm secret update -t "API Key" --field "password=rotated"
```

**Options:**

- `-u, --uid <uid>` - Record UID
- `-t, --title <title>` - Record title
- `--field <key=value>` - Update standard field (repeatable)
- `--custom-field <label=value>` - Update custom field (repeatable)
- `--profile <name>` - Use specific profile

### secret delete

Delete a secret record.

```bash
ksm secret delete -u SNzjw8tM1HsXEzXERCJrNQ
ksm secret delete -t "Deprecated Secret"
ksm secret delete -u SNzjw8tM1HsXEzXERCJrNQ --force  # No confirmation
```

**Options:**

- `-u, --uid <uid>` - Record UID
- `-t, --title <title>` - Record title
- `--force` - Don't prompt for confirmation
- `--profile <name>` - Use specific profile

### secret password

Generate a random secure password.

```bash
# 32 character password
ksm secret password --length 32

# Custom character mix
ksm secret password --lc 8 --uc 8 --digits 8 --symbols 8

# No special characters
ksm secret password --length 20 --symbols 0

# Multiple passwords
ksm secret password --count 5 --length 20
```

**Options:**

- `--length <n>` - Total password length (default: 16)
- `--lc <n>` - Lowercase letters (default: random mix)
- `--uc <n>` - Uppercase letters
- `-d, --digits <n>` - Digits
- `-s, --symbols <n>` - Special characters
- `--count <n>` - Generate N passwords
- `--exclude <chars>` - Exclude specific characters

## Folder Commands

### folder list

List all folders in vault.

```bash
ksm folder list
ksm folder list --json
```

### folder get

Get folder details.

```bash
ksm folder get -u <FOLDER_UID>
ksm folder get -u <FOLDER_UID> --json
```

**Options:**

- `-u, --uid <uid>` - Folder UID

## Execution Commands

### exec

Execute a command with secrets injected into environment variables.

```bash
# Single secret
export DB_PASSWORD="keeper://SNzjw8tM1HsXEzXERCJrNQ/field/password"
ksm exec -- myapp

# Multiple secrets inline
DB_PASS="keeper://8f8I-OqPV58o2r91wVgZ_A/field/password" \
API_KEY="keeper://SNzjw8tM1HsXERCJrNQ/field/password" \
ksm exec -- ./start_server.sh

# With shell
ksm exec -- bash -c 'echo $DB_PASSWORD'

# Docker run
docker run -e DB_PASS="keeper://UID/field/password" \
  -e KSM_CONFIG=<base64> \
  myimage ksm exec -- /start.sh
```

**How it works:**

1. Parse environment variables
2. Detect those starting with `keeper://`
3. Resolve each one using Keeper notation
4. Replace with actual secret values
5. Execute command with populated env

**Options:**

- `--profile <name>` - Use specific profile
- Additional args are the command to execute

### interpolate

Replace Keeper notation placeholders in files.

```bash
# Simple interpolation
ksm interpolate --in-file config.tmpl --out-file config.yaml

# Inline
ksm interpolate --in-file config.yaml

# Standard input/output
cat config.tmpl | ksm interpolate > config.yaml
```

**Template example (config.tmpl):**

```yaml
database:
  host: keeper://8f8I-OqPV58o2r91wVgZ_A/field/host
  port: keeper://8f8I-OqPV58o2r91wVgZ_A/field/port
  user: keeper://8f8I-OqPV58o2r91wVgZ_A/field/login
  password: keeper://8f8I-OqPV58o2r91wVgZ_A/field/password
```

**Options:**

- `--in-file <path>` - Template file to read
- `--out-file <path>` - Output file
- `--backup` - Create .backup of original
- `--profile <name>` - Use specific profile

## Sync Commands

### sync

Sync secrets to cloud secret managers.

```bash
# Sync to AWS Secrets Manager
ksm sync --type aws_sm \
  --credentials SNzjw8tM1HsXERCJrNQ \
  --map 8f8I-OqPV58o2r91wVgZ_A=prod/database

# Sync to Azure Key Vault
ksm sync --type azure_kv \
  --credentials SNzjw8tM1HsXERCJrNQ \
  --map 8f8I-OqPV58o2r91wVgZ_A=prod-database-secret

# Sync to Generic HTTP endpoint
ksm sync --type generic_http \
  --credentials SNzjw8tM1HsXERCJrNQ \
  --map 8f8I-OqPV58o2r91wVgZ_A=https://api.example.com/secrets
```

**Options:**

- `--type <type>` - Target type (aws_sm, azure_kv, generic_http)
- `--credentials <uid>` - Record with cloud credentials
- `--map <keeper_uid>=<target_name>` - Secret mappings (repeatable)
- `--dry-run` - Show what would sync without doing it
- `--profile <name>` - Use specific profile

## Configuration

### Config File Location

- macOS: `~/.keeper/keeper.ini`
- Linux: `~/.keeper/keeper.ini` or `$XDG_CONFIG_HOME/keeper/keeper.ini`
- Windows: `%APPDATA%\Keeper\keeper.ini`

### keeper.ini Format

```ini
[default]
hostname = keepersecurity.com
private_key = <base64-encoded-key>
client_id = <client-id>

[production]
hostname = keepersecurity.com
private_key = <base64-encoded-key>
client_id = <client-id>
```

### Environment Variables

- `KSM_CLI_TOKEN` - One-Time Access Token for `ksm profile init` without passing `--token` on the command line (preferred)
- `KSM_TOKEN` - One-Time Access Token for auto-init (e.g. containers; see Keeper docs)
- `KSM_CONFIG` - Base64-encoded config (replaces keeper.ini)
- `KSM_CONFIG_FILE` - Path to keeper.ini
- `KSM_HOSTNAME` - Override keeper host
- `KSM_PROFILE` - Active profile name

## Error Handling

| Error | Cause | Solution |
| --- | --- | --- |
| "Not authenticated" | Invalid/expired token | Re-run `ksm profile init` |
| "Token expired" | Client device removed | Create new device in Vault/Commander |
| "IP lock: Access denied" | IP not in allow list | Use `--unlock-ip` or init from allow list IP |
| "Field not found" | Invalid field type/name | Check with `ksm secret get -u <uid> --json` |
| "Permission denied" | No access to record | Check record sharing in Vault |

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Authentication error
- `3` - Invalid arguments
- `4` - Record not found

## Common Workflows

### Rotate a Database Password

```bash
# Generate new password
NEW_PASS=$(ksm secret password --length 32)

# Update in Keeper
ksm secret update -u 8f8I-OqPV58o2r91wVgZ_A --field "password=$NEW_PASS"

# Update in database
ksm exec -- mysql -h $(ksm secret get -u 8f8I-OqPV58o2r91wVgZ_A -f host) \
  -u $(ksm secret get -u 8f8I-OqPV58o2r91wVgZ_A -f login) \
  -p$(ksm secret get -u 8f8I-OqPV58o2r91wVgZ_A -f password) \
  -e "ALTER USER 'user'@'%' IDENTIFIED BY '$NEW_PASS';"
```

### Batch List All Secrets

```bash
ksm secret list --json | jq '.[] | {uid, title, record_type}'
```

### Export to Environment Script

```bash
ksm secret list --json | jq -r '.[] |
  "export \(.title | ascii_upcase | gsub("[- ]"; "_"))_PASSWORD=\(.uid)"' > creds.sh
source creds.sh
ksm exec -- ./myapp
```
