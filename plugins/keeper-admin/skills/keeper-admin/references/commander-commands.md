# Keeper Commander Command Reference

Complete reference for Keeper Commander CLI commands.

Official documentation: [Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview) · [Secrets Manager (KSM)](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) (KSM apps and `ksm`).

## Getting Started

```bash
# Start interactive shell
keeper shell

# Avoid passing passwords or tokens on the command line; use interactive shell or official docs for supported automation.

# Batch mode (run commands from file)
keeper --batch-mode --commands-file commands.txt

# REST API mode
keeper --batch-mode api-server --port 8089
```

## Help Commands

```bash
My Vault> ?                    # Show all commands
My Vault> ? list               # Help on specific command
My Vault> help                 # Full help
```

## Navigation & Display

### list

List records in current folder.

```bash
My Vault> list
My Vault> list --json
My Vault> ls -l                # Long format with UIDs
```

### cd

Change to a folder.

```bash
My Vault> cd "Shared Folder"
My Vault> cd ..                # Go up one level
My Vault> cd /                 # Go to root
```

### tree

Show folder tree.

```bash
My Vault> tree
My Vault> tree --folder <FOLDER_UID>
```

### pwd

Print working directory (current folder).

```bash
My Vault> pwd
```

## Search & Get

### search

Search records by title or content.

```bash
My Vault> search "database"
My Vault> search "password" --format json
My Vault> search "api key" --limit 10
```

### get

Get record details.

```bash
My Vault> get <RECORD_UID>
My Vault> get <RECORD_UID> --json
My Vault> get -t "Record Title"    # Get by title
```

## Record Management

### add

Create a new record.

```bash
My Vault> add                  # Interactive mode
My Vault> add --record-type login --title "New Login"
My Vault> add --record-type login --title "API Key" \
  --field login=user@example.com
# Add password and other sensitive fields interactively or via secure input—do not put secrets in example commands.
My Vault> add --folder <FOLDER_UID> --record-type login
```

**Record types:**

- login
- bankAccount
- address
- creditCard
- identity
- document
- databaseCredentials
- sshKey
- note
- photo
- socialAccount
- license

### edit

Edit a record.

```bash
My Vault> edit <RECORD_UID>    # Interactive editor
My Vault> edit <RECORD_UID> --field login=newuser
# For password fields, use interactive edit or values from secure input only.
My Vault> edit -t "Record Title"
```

### rm

Delete a record.

```bash
My Vault> rm <RECORD_UID>
My Vault> rm -t "Record Title"
My Vault> rm <RECORD_UID> --force  # No confirmation
```

### copy

Copy a record.

```bash
My Vault> copy <RECORD_UID> --title "Copy of Record"
My Vault> copy <RECORD_UID> --folder <FOLDER_UID>
```

### record-history

Show change history of a record.

```bash
My Vault> record-history <RECORD_UID>
My Vault> record-history <RECORD_UID> --json
```

## Folder Management

### folder list

List all folders.

```bash
My Vault> folder list
My Vault> folder list --json
```

### folder create

Create a new folder.

```bash
My Vault> folder create --name "DevOps"
My Vault> folder create --name "Production" --parent <PARENT_UID>
```

### folder delete

Delete a folder.

```bash
My Vault> folder delete <FOLDER_UID>
My Vault> folder delete -n "Old Folder"
```

## Sharing

### share-record

Share a record with a user.

```bash
My Vault> share-record -e user@company.com -a grant -u <RECORD_UID>
My Vault> share-record -e user@company.com -a revoke -u <RECORD_UID>
My Vault> share-record -e user@company.com -a edit -u <RECORD_UID>
```

**Actions:**

- `grant` - Give access
- `revoke` - Remove access
- `edit` - Change to editable access

### share-folder

Share a folder with a user.

```bash
My Vault> share-folder -e user@company.com -a grant -u <FOLDER_UID>
My Vault> share-folder -e user@company.com -a edit -u <FOLDER_UID>
```

## Import / Export

### import

Import records from file.

```bash
My Vault> import --format json records.json
My Vault> import --format csv records.csv
My Vault> import --folder <FOLDER_UID> records.json
```

### export

Export records to file.

```bash
My Vault> export --format json --output vault_export.json
My Vault> export --format csv --output vault_export.csv
My Vault> export --folder <FOLDER_UID> --format json
```

## Enterprise User Management

Requires enterprise admin privileges.

### enterprise-user

Manage enterprise users.

```bash
# Add user
My Vault> enterprise-user --add user@company.com

# Invite user
My Vault> enterprise-user --invite user@company.com

# List users
My Vault> enterprise-user --list
My Vault> enterprise-user --list --json

# Update user
My Vault> enterprise-user --update user@company.com --name "John Doe"

# Lock user
My Vault> enterprise-user --lock user@company.com

# Unlock user
My Vault> enterprise-user --unlock user@company.com

# Delete user
My Vault> enterprise-user --delete user@company.com --force
```

## Enterprise Team Management

### enterprise-team

Manage teams.

```bash
# Add team
My Vault> enterprise-team --add "Engineering"

# List teams
My Vault> enterprise-team --list
My Vault> enterprise-team --list --json

# Add user to team
My Vault> enterprise-team --add-user user@company.com --team "Engineering"

# Remove user from team
My Vault> enterprise-team --remove-user user@company.com --team "Engineering"

# Delete team
My Vault> enterprise-team --delete "Engineering"
```

## Role & Permission Management

### enterprise-role

Manage roles and enforce policies.

```bash
# List roles
My Vault> enterprise-role --list

# Add user to role
My Vault> enterprise-role --add-user user@company.com --role "Admin"

# Remove user from role
My Vault> enterprise-role --remove-user user@company.com --role "Auditor"

# Set enforcement
My Vault> enterprise-role --enforcement MASTER_PASSWORD_MINIMUM_LENGTH:12
My Vault> enterprise-role --enforcement TWO_FACTOR_DURATION:30
My Vault> enterprise-role --enforcement IP_WHITELIST:192.168.1.0/24
```

## Device & Login Management

### this-device

Manage current device.

```bash
My Vault> this-device register
My Vault> this-device persistent-login ON
My Vault> this-device persistent-login OFF
My Vault> this-device biometric register
```

### device-approve

Manage device approvals.

```bash
# List pending approvals
My Vault> device-approve

# Approve device
My Vault> device-approve --approve <DEVICE_ID>

# Deny device
My Vault> device-approve --deny <DEVICE_ID>

# Show device details
My Vault> device-approve --show <DEVICE_ID>
```

## Secrets Manager Administration

### secrets-manager app

Create and manage KSM Applications.

```bash
# Create application
My Vault> secrets-manager app create --name "Production API" \
  --shared-folder <FOLDER_UID>

# List applications
My Vault> secrets-manager app list
My Vault> secrets-manager app list --json

# Update application
My Vault> secrets-manager app update --app <APP_UID> \
  --name "Prod API v2"

# Delete application
My Vault> secrets-manager app delete --app <APP_UID>
```

### secrets-manager client

Create and manage Client Devices (machine accounts).

```bash
# Add client device (generates One-Time Token)
My Vault> secrets-manager client add --app <APP_UID> \
  --name "Web Server 1"
# Output includes a one-time token; treat it as secret and configure the target per keeper-setup (KSM_CLI_TOKEN, not pasted into chat).

# Add with IP unlocking
My Vault> secrets-manager client add --app <APP_UID> \
  --name "Production Server" --unlock-ip

# List clients
My Vault> secrets-manager client list --app <APP_UID>

# Remove client
My Vault> secrets-manager client remove --app <APP_UID> \
  --client "Web Server 1"

# Refresh client token (revokes old token)
My Vault> secrets-manager client refresh --app <APP_UID> \
  --client "Web Server 1"
```

### secrets-manager share

Share applications with users.

```bash
# Share app with user
My Vault> secrets-manager share --app <APP_UID> \
  --email user@company.com

# Share with team
My Vault> secrets-manager share --app <APP_UID> \
  --team "Engineering"

# Revoke access
My Vault> secrets-manager revoke --app <APP_UID> \
  --email user@company.com
```

## KeeperPAM Commands

### pam gateway

Manage PAM gateways.

```bash
# List gateways
My Vault> pam gateway list
My Vault> pam gateway list --json

# Create gateway
My Vault> pam gateway create --name "SSH Gateway" \
  --host gateway.example.com --port 22

# Delete gateway
My Vault> pam gateway delete <GATEWAY_ID>
```

### pam configuration

Manage PAM resources and connections.

```bash
# List configurations
My Vault> pam configuration list

# Create SSH resource
My Vault> pam configuration create --type ssh \
  --name "Production DB" --host db.example.com \
  --port 5432 --username postgres

# Create RDP resource
My Vault> pam configuration create --type rdp \
  --name "Admin PC" --host admin.example.com
```

### connect

Launch remote sessions (SSH, RDP, database).

```bash
# Launch session (opens connection)
My Vault> connect <RECORD_UID>

# List active sessions
My Vault> connect --list

# Terminate session
My Vault> connect --disconnect <SESSION_ID>
```

### pam rotation

Manage password rotation.

```bash
# List rotation policies
My Vault> pam rotation list

# Start rotation job
My Vault> pam rotation start --record <RECORD_UID>

# Check rotation status
My Vault> pam rotation status --job <JOB_ID>

# View rotation history
My Vault> pam rotation history --record <RECORD_UID>
```

## Reporting & Compliance

### audit-report

Generate audit logs.

```bash
# Generate audit report
My Vault> audit-report --format csv --output audit.csv

# Filter by date range
My Vault> audit-report --from "2025-01-01" --to "2025-03-31"

# Show specific event types
My Vault> audit-report --event-type login,logout
```

### compliance-report

Generate compliance report.

```bash
My Vault> compliance-report
My Vault> compliance-report --format json --output compliance.json
```

### event-list

List recent events.

```bash
My Vault> event-list
My Vault> event-list --limit 100
My Vault> event-list --json
```

## Server/API Mode

### api-server

Run Commander as REST API service.

```bash
# Start API server
keeper --batch-mode api-server --port 8089

# With authentication
keeper --batch-mode --user admin@co.com api-server --port 8089

# API endpoints (after starting):
# GET  /api/records
# GET  /api/records/{uid}
# POST /api/records
# PUT  /api/records/{uid}
# DELETE /api/records/{uid}
```

## Batch Processing

### commands-file

Run commands from file.

```bash
# Create commands.txt
list
search "database"
get <RECORD_UID>
enterprise-user --list

# Run batch
keeper --batch-mode --commands-file commands.txt
```

### Piping

Pipe commands into Commander.

```bash
# From echo
echo "list" | keeper --batch-mode --user admin@co.com

# From file
cat commands.txt | keeper --batch-mode
```

## Global Options

```bash
--user <email>             # Keeper user email
# Avoid --password: use interactive login or documented secure automation; CLI passwords leak via process listings and history.
--profile <path>           # Profile file location
--batch-mode               # Batch/non-interactive mode
--config <path>            # Config file
--commands-file <file>     # Read commands from file
--verbose                  # Verbose output
--json                     # JSON output format
--help                     # Show help
```

## Common Workflows

### Onboard New User

```bash
# Create user
My Vault> enterprise-user --add newuser@company.com

# Invite them
My Vault> enterprise-user --invite newuser@company.com

# Add to team
My Vault> enterprise-team --add-user newuser@company.com \
  --team "Engineering"

# Share folder
My Vault> share-folder -e newuser@company.com -a grant \
  -u <TEAM_FOLDER_UID>
```

### Create KSM Application

```bash
# Create app
My Vault> secrets-manager app create --name "Web API" \
  --shared-folder <APP_FOLDER_UID>

# Get app UID (from output or list)
My Vault> secrets-manager app list --json | jq '.[] | select(.name == "Web API") | .uid'

# Create client device
My Vault> secrets-manager client add --app <APP_UID> \
  --name "Production Web Server"
# Note the One-Time Token displayed

# On the server: initialize KSM CLI using KSM_CLI_TOKEN (see keeper-setup skill and Keeper profile init docs)—do not pass tokens on the command line.
```

### Rotate Database Password

```bash
# Get record
My Vault> get <DB_UID>

# Update password via interactive edit (also update in DB); do not embed secrets in commands.
My Vault> edit <DB_UID>

# Verify
My Vault> get <DB_UID> --json | jq '.fields[] | select(.type=="password")'
```

### Audit Access

```bash
# Show who has access to a record
My Vault> get <RECORD_UID> --json | jq '.shared_with'

# Generate access report
My Vault> audit-report --event-type "record_access"
```

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Authentication error
- `3` - Command syntax error
- `4` - Item not found

## Command References

Refer [Keeper commander command reference documentation](https://docs.keeper.io/en/keeperpam/commander-cli/command-reference)
