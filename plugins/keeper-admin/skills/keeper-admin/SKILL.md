---
name: keeper-admin
description: Manage Keeper Vault, enterprise administration, PAM, and privileged access using Keeper Commander CLI (keeper). Use when the user needs to manage vault records interactively, run enterprise admin tasks (user/team/role management, SSO config, device approvals, compliance reporting), manage KSM Applications and Client Devices, configure password rotation, launch remote sessions (SSH, RDP, database), import/export data, or perform any administrative operation on Keeper. Also use when the user mentions 'keeper commander', 'keeper shell', 'keeper admin', asks about managing users/teams/roles/nodes in Keeper, needs to create KSM applications, or wants to automate Keeper admin tasks. If the user only needs to retrieve or inject secrets for an application, use the keeper-secrets skill instead.
---

# Keeper Commander CLI (keeper)

Commander is Keeper's full-featured admin CLI and terminal UI. Everything
available in the Keeper Vault UI and Admin Console can be done via Commander.
It authenticates as a user (not a machine application) and provides the full
breadth of vault, enterprise, and PAM operations.

## Official documentation

- [Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview) - overview, installation, and shell usage
- [Secrets Manager (KSM)](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) - creating KSM Applications and Client Devices that `ksm` uses; runtime secret injection belongs in the **keeper-secrets** skill

## When to Use Commander vs KSM

| Need | Tool |
| --- | --- |
| Enterprise admin (users, teams, roles, nodes) | `keeper` |
| Create KSM Applications and Client Devices | `keeper` |
| Password rotation setup/management | `keeper` |
| Launch remote sessions (SSH, RDP, DB) | `keeper` |
| Import/export vault data | `keeper` |
| Interactive vault browsing | `keeper` |
| Run as REST API service | `keeper` |
| Compliance reporting and audit | `keeper` |
| Retrieve secrets for an app at runtime | Use `ksm` - see keeper-secrets skill |
| Inject secrets into env vars / config files | Use `ksm` - see keeper-secrets skill |

## Prerequisites

1. Python 3.10+
2. Install: `pip install keepercommander`
3. A Keeper account with appropriate admin permissions
4. Tmux

Check installation: `keeper version`



## Workflow

1. Use `references/commander-commands.md` for interacting with Keeper commander, Use `--help` for getting more information for the command.
2. Verify the session is opened via interactive tmux session.
3. Verify available binaries in related python environments:
  - `keeper --help`
  - `ksm --help`
4. Confirm session or auth state before any secret read.
5. Check login status using whoami, if not logged in, complete login process and then continue rest flow.
6. ALAWYS ask the user inputs for REQUIRED fields, DONT GUESS REQUIRED fields.
7. Search or inspect metadata first, then retrieve only the exact requested field, do not expose any sensitive data.
8. Prefer secret injection or one-command environment scoping over writing secrets to disk.
9. If syntax differs from expectation, fall back to `--help` and Keeper docs immediately.
10. ALWAYS ask confirmation from users for any delete operations.


## REQUIRED tmux session

The shell tool uses a fresh TTY per command. To preserve Keeper interactive context, authentication state, and MFA prompts, run interactive Keeper commands or secrets manager command inside a dedicated tmux session.


Example pattern:

```bash
SOCKET_DIR="${TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/keeper-tmux-sockets}"
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/keeper-commander.sock"
SESSION="keeper-auth-$(date +%Y%m%d-%H%M%S)"

tmux -S "$SOCKET" new -d -s "$SESSION" -n shell
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -- "keeper shell || keeper-commander shell || bash" Enter
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -120
```

Then drive the session carefully:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- "whoami"
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -120
```

Kill the tmux session when the task is complete unless the user wants a persistent Keeper shell.

## Authentication

```bash
# Interactive login (preferred — credentials are not passed as CLI arguments)
keeper shell
# Prompts for email + master password + 2FA

# Persistent login (recommended for ongoing CLI use)
keeper shell
My Vault> this-device register
My Vault> this-device persistent-login ON

# Biometric authentication (supported platforms)
My Vault> biometric register
```

Do **not** pass master passwords, API tokens, or vault field values on the command
line (e.g. `--password`), in URLs, or in generated scripts—they appear in process
listings and shell history. For automation, use interactive setup once, enable
persistent device login where appropriate, or follow the official Commander CLI
documentation for supported non-interactive patterns.

## Vault Operations

### Browse & Search

```bash
My Vault> list                    # List records in current folder
My Vault> ls -l                   # Detailed listing with UIDs
My Vault> search "database"       # Search across all records
My Vault> tree                    # Show folder tree
My Vault> cd "Shared Folder"      # Navigate to folder
My Vault> get <RECORD_UID>        # Show full record details
```

### Record Management

```bash
My Vault> add --record-type login --title "New Record" \
  --field login=admin
# Set passwords and other sensitive fields via interactive prompts, or supply values only from the user’s secure input—never embed sample secrets in commands.

My Vault> edit <RECORD_UID>
# Or non-interactive field updates for non-secret fields only, e.g. --field login=newuser

My Vault> rm <RECORD_UID>

My Vault> record-history <RECORD_UID>
```

### Sharing

```bash
My Vault> share-record -e user@company.com -a grant -u <RECORD_UID>
My Vault> share-folder -e user@company.com -a grant -u <FOLDER_UID>
```

### Import / Export

```bash
My Vault> import --format json records.json
My Vault> export --format json --output vault_export.json
```

## Enterprise Administration

These commands require enterprise admin privileges.

### User Management

```bash
My Vault> enterprise-user --add user@company.com
My Vault> enterprise-user --invite user@company.com
My Vault> enterprise-user --delete user@company.com
My Vault> enterprise-user --lock user@company.com
My Vault> enterprise-user --unlock user@company.com
```

### Team & Role Management

```bash
My Vault> enterprise-team --add "Engineering Team"
My Vault> enterprise-role --add-user user@company.com --role "Admin Role"
My Vault> enterprise-role --enforcement MASTER_PASSWORD_MINIMUM_LENGTH:12
```

### Device Approvals

```bash
My Vault> device-approve             # List pending approvals
My Vault> device-approve --approve <DEVICE_ID>
My Vault> device-approve --deny <DEVICE_ID>
```

### Reporting

```bash
My Vault> audit-report --format csv --output audit.csv
My Vault> compliance-report
```

## Secrets Manager Administration

Commander is used to create and manage the KSM Applications and Client Devices
that the KSM CLI connects through.

```bash
# Create an Application
My Vault> secrets-manager app create --name "Production App" \
  --shared-folder <FOLDER_UID>

# List Applications
My Vault> secrets-manager app list

# Add a Client Device (generates One-Time Access Token)
My Vault> secrets-manager client add --app <APP_UID> \
  --name "Web Server 1" --unlock-ip

# Remove a Client Device
My Vault> secrets-manager client remove --app <APP_UID> \
  --client "Web Server 1"

# Share Application with another user
My Vault> secrets-manager share --app <APP_UID> --email admin2@company.com
```

The One-Time Access Token output from `client add` is configured on the target
machine using the **keeper-setup** skill (token via `KSM_CLI_TOKEN` or other
supported secure methods—**not** as a literal `--token` argument in shared
examples or chat).

## KeeperPAM Operations

```bash
# List PAM resources (gateways, connections)
My Vault> pam gateway list
My Vault> pam configuration list

# Launch SSH session
My Vault> connect <RECORD_UID>

# Manage password rotation
My Vault> pam rotation list
My Vault> pam rotation start --record <RECORD_UID>
```

## Service Mode (REST API)

Commander can run as a headless REST API for automation.

```bash
keeper --batch-mode api-server --port 8089
```

## Automation (Batch Commands)

```bash
# Run commands from a file
keeper --batch-mode --commands-file commands.txt

# Pipe commands
echo "list" | keeper --batch-mode --user admin@co.com
```

## References
- Use `references/endpoint-privilege-management.md` for endpoint privilege management commands like kepm, epm, pedm commands
- Use `references/enterprise-mgmt.md` for enterprise management scenarios and commands.
- Use `references/pam-commands.md` for privileged access management or KeeperPAM functionalities.
- Use `references/msp-management.md` for commands specific to Managed Service Provider (MSP) tenants

## Guardrails

- NEVER expose the user's master password in logs, chat, or code.
- NEVER print secret field values into chat unless explicitly requested for
  a specific debugging purpose - and warn the user first.
- For destructive operations (delete user, delete record, modify role
  enforcement), always confirm with the user before executing.
- If the user needs runtime secret injection for an application, redirect
  them to the keeper-secrets skill and KSM CLI.
- Commander requires a full user login - it cannot be used in headless
  environments without persistent login configured.
- ALWAYS ask confirmation from users for any DELETE operations.

For detailed command reference, read `references/commander-commands.md`. For `keeper://` URIs and `ksm exec` / `ksm interpolate`, see [Keeper notation](https://docs.keeper.io/en/keeperpam/secrets-manager/about/keeper-notation) and the **keeper-secrets** skill.
