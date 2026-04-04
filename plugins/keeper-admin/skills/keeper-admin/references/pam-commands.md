# KeeperPAM Commands Reference

Complete reference for Keeper PAM (Privileged Access Management) commands.

## Overview

KeeperPAM manages privileged accounts and access across infrastructure.

**Key components:**

- Gateways - Proxy access to resources
- Configurations - Definitions of resources (servers, databases, applications)
- Connections - Active sessions to privileged resources
- Sessions - Recorded activity for compliance
- Rotation - Automated password rotation

## Gateway Management

### List Gateways

```bash
My Vault> pam gateway list
My Vault> pam gateway list --json
```

**Gateway information:**

- `gateway_id` - Unique identifier
- `name` - Human-readable name
- `host` - IP/hostname
- `port` - Connection port
- `status` - active, inactive, offline
- `last_sync` - Last sync time

### Create Gateway

```bash
# SSH gateway
My Vault> pam gateway create --name "SSH Gateway" \
  --host gateway.example.com --port 22 \
  --type ssh

# RDP gateway (for Windows access)
My Vault> pam gateway create --name "RDP Gateway" \
  --host rdp.example.com --port 3389 \
  --type rdp

# Generic TCP gateway
My Vault> pam gateway create --name "App Gateway" \
  --host app.example.com --port 8443
```

### Update Gateway

```bash
My Vault> pam gateway update --gateway <GATEWAY_ID> \
  --host gateway2.example.com

My Vault> pam gateway update --name "SSH Gateway" \
  --port 2222
```

### Delete Gateway

```bash
My Vault> pam gateway delete <GATEWAY_ID>
My Vault> pam gateway delete --name "Old Gateway"
```

### Gateway Health

```bash
# Check gateway status
My Vault> pam gateway status <GATEWAY_ID>

# Sync gateway state
My Vault> pam gateway sync <GATEWAY_ID>
```

## Configuration Management

Configurations define what resources can be accessed through PAM.

### List Configurations

```bash
My Vault> pam configuration list
My Vault> pam configuration list --json
My Vault> pam configuration list --type ssh
```

**Configuration types:**

- ssh - SSH servers
- rdp - Windows RDP
- database - Databases (MySQL, PostgreSQL, Oracle, MSSQL)
- application - Custom applications
- cloud - Cloud resources (AWS, Azure, GCP)

### Create SSH Configuration

```bash
My Vault> pam configuration create --type ssh \
  --name "Production Web Server" \
  --host web.prod.example.com \
  --port 22 \
  --username ubuntu \
  --gateway <GATEWAY_ID>

# With key-based auth
My Vault> pam configuration create --type ssh \
  --name "App Server" \
  --host app.prod.example.com \
  --username appuser \
  --key <PRIVATE_KEY_RECORD_UID> \
  --gateway <GATEWAY_ID>
```

### Create RDP Configuration

```bash
My Vault> pam configuration create --type rdp \
  --name "Admin Workstation" \
  --host admin-pc.example.com \
  --port 3389 \
  --domain COMPANY \
  --username admin \
  --gateway <GATEWAY_ID>
```

### Create Database Configuration

```bash
My Vault> pam configuration create --type database \
  --name "Production PostgreSQL" \
  --host db.prod.example.com \
  --port 5432 \
  --database_type postgres \
  --username postgres \
  --password <PASSWORD_RECORD_UID> \
  --gateway <GATEWAY_ID>

# MySQL
My Vault> pam configuration create --type database \
  --name "Prod MySQL" \
  --host mysql.prod.example.com \
  --port 3306 \
  --database_type mysql \
  --username admin

# Oracle
My Vault> pam configuration create --type database \
  --name "Enterprise Oracle" \
  --host oracle.prod.example.com \
  --port 1521 \
  --database_type oracle \
  --service PROD \
  --username sys
```

### Update Configuration

```bash
My Vault> pam configuration update --config <CONFIG_ID> \
  --host newhost.example.com \
  --port 2222

# Update credentials
My Vault> pam configuration update --name "Web Server" \
  --password <NEW_PASSWORD_RECORD_UID>
```

### Delete Configuration

```bash
My Vault> pam configuration delete <CONFIG_ID>
My Vault> pam configuration delete --name "Old Server"
```

## Session Management

### Launch Connection

Launch a session to a privileged resource.

```bash
# SSH connection
My Vault> connect <CONFIG_UID>

# RDP connection
My Vault> connect <CONFIG_UID> --protocol rdp

# Database connection
My Vault> connect <CONFIG_UID> --protocol db
```

### List Active Sessions

```bash
My Vault> connect --list
My Vault> connect --list --json

# Show session details
My Vault> connect --show <SESSION_ID>
```

**Session information:**

- `session_id` - Session identifier
- `user` - User who started session
- `resource` - Target resource name
- `start_time` - Session start
- `duration` - Duration in minutes
- `status` - active, closed, failed

### Monitor Session Activity

```bash
# Real-time activity
My Vault> connect --monitor <SESSION_ID>

# Show session commands (if recorded)
My Vault> connect --activity <SESSION_ID>
```

### Terminate Session

```bash
My Vault> connect --disconnect <SESSION_ID>
My Vault> connect --disconnect <SESSION_ID> --force
```

## Rotation Management

Automated password rotation for privileged accounts.

### List Rotation Policies

```bash
My Vault> pam rotation list
My Vault> pam rotation list --json
```

### Create Rotation Policy

```bash
# Rotate every 30 days
My Vault> pam rotation create --record <RECORD_UID> \
  --interval 30 \
  --unit days

# Rotate every Sunday at 2 AM
My Vault> pam rotation create --record <RECORD_UID> \
  --schedule "0 2 * * 0"

# Rotation strategy
My Vault> pam rotation create --record <RECORD_UID> \
  --strategy random_password  # random_password, passphrase, rotate_only

# Complex passwords
My Vault> pam rotation create --record <RECORD_UID> \
  --password-length 32 \
  --include-uppercase true \
  --include-lowercase true \
  --include-digits true \
  --include-symbols true
```

### Start Rotation

```bash
# Rotate now
My Vault> pam rotation start --record <RECORD_UID>

# Rotate with confirmation
My Vault> pam rotation start --record <RECORD_UID> --confirm

# Batch rotate multiple records
for uid in UID1 UID2 UID3; do
  echo "pam rotation start --record $uid"
done | keeper --batch-mode
```

### Check Rotation Status

```bash
My Vault> pam rotation status --job <JOB_ID>
My Vault> pam rotation status --record <RECORD_UID>
```

**Rotation status:**

- `pending` - Scheduled but not yet started
- `in_progress` - Rotation in process
- `completed` - Successfully rotated
- `failed` - Rotation failed
- `paused` - Manually paused

### Rotation History

```bash
My Vault> pam rotation history --record <RECORD_UID>
My Vault> pam rotation history --record <RECORD_UID> --json

# Show last 10 rotations
My Vault> pam rotation history --record <RECORD_UID> --limit 10
```

### Pause/Resume Rotation

```bash
# Pause policy
My Vault> pam rotation pause --record <RECORD_UID>

# Resume policy
My Vault> pam rotation resume --record <RECORD_UID>
```

### Update Rotation Policy

```bash
My Vault> pam rotation update --record <RECORD_UID> \
  --interval 7 \
  --unit days

# Change schedule
My Vault> pam rotation update --record <RECORD_UID> \
  --schedule "0 3 * * 1"  # Every Monday at 3 AM
```

### Delete Rotation Policy

```bash
My Vault> pam rotation delete --record <RECORD_UID>
```

## Vault Integration

PAM records are stored in Keeper Vault.

### Store PAM Record

```bash
# Create PAM login record (set password flag at runtime via interactive add or secure input)
My Vault> add --record-type login --title "Prod DB Admin" \
  --field login=postgres \
  --field host=db.prod.example.com \
  --field port=5432 \
  --custom-field database=production

# Add to PAM folder
My Vault> add --folder <PAM_FOLDER_UID> \
  --record-type login --title "App Server" \
  --field login=appuser \
  --field host=app.prod.example.com
```

### Share PAM Access

```bash
# Share with user
My Vault> share-record -e user@company.com -a grant \
  -u <RECORD_UID>

# Share with team
My Vault> share-folder -e team-lead@company.com -a grant \
  -u <PAM_FOLDER_UID>
```

### Search PAM Resources

```bash
# Find production servers
My Vault> search "production"

# Find by record type
My Vault> search --type login

# Find by custom field
My Vault> search --custom-field database=production
```

## Auditing & Compliance

### Session Recording

```bash
# Enable recording for configuration
My Vault> pam configuration update --config <CONFIG_ID> \
  --record-sessions true

# Playback session recording
My Vault> pam session playback --session <SESSION_ID>
```

### Access Audit

```bash
# Who accessed what
My Vault> audit-report --event-type pam_access

# Failed access attempts
My Vault> audit-report --event-type pam_failed_access

# Password rotation audit
My Vault> audit-report --event-type pam_rotation
```

### Compliance Reports

```bash
# PAM compliance report
My Vault> pam compliance-report

# Generate PDF
My Vault> pam compliance-report --format pdf \
  --output compliance.pdf
```

## Common Workflows

### Set Up SSH Access to Production

```bash
# Create gateway (once)
My Vault> pam gateway create --name "SSH Gateway" \
  --host ssh-gateway.prod.example.com --port 22

# Create configurations for each server
My Vault> pam configuration create --type ssh \
  --name "Production Web 1" \
  --host web1.prod.example.com \
  --username ubuntu \
  --gateway <GATEWAY_ID>

My Vault> pam configuration create --type ssh \
  --name "Production Web 2" \
  --host web2.prod.example.com \
  --username ubuntu \
  --gateway <GATEWAY_ID>

# Enable rotation
My Vault> pam rotation create --record <WEB1_UID> --interval 30 --unit days
My Vault> pam rotation create --record <WEB2_UID> --interval 30 --unit days

# Share with devops team
My Vault> share-folder -e devops@company.com -a grant -u <PAM_FOLDER_UID>

# Team accesses servers
# (Each developer can now)
My Vault> connect <WEB1_CONFIG_UID>
```

### Automated Database Password Rotation

```bash
# Create configuration
My Vault> pam configuration create --type database \
  --name "Prod MySQL" \
  --host mysql.prod.example.com \
  --database_type mysql \
  --username admin \
  --record <PASSWORD_RECORD_UID>

# Schedule daily rotation at 2 AM
My Vault> pam rotation create --record <MYSQL_UID> \
  --schedule "0 2 * * *" \
  --password-length 32 \
  --include-symbols true

# Monitor rotations
My Vault> pam rotation history --record <MYSQL_UID>
```

### Compliance: MFA + Recording

```bash
# Create gateway with MFA
My Vault> pam gateway create --name "Secure Gateway" \
  --host gateway.example.com \
  --require-mfa true

# Create configuration with recording
My Vault> pam configuration create --type ssh \
  --name "Critical Server" \
  --host critical.prod.example.com \
  --record-sessions true \
  --gateway <SECURE_GATEWAY_ID>

# Audit access
My Vault> audit-report --event-type pam_access --from "2025-01-01"
```

## Troubleshooting

| Issue | Solution |
| --- | --- |
| Connection refused | Check gateway connectivity, firewall rules, port |
| Authentication failed | Verify credentials in configuration, check remote system |
| Rotation failed | Check password complexity requirements, target system limits |
| Gateway offline | Restart gateway service, check network connectivity |
| Session timeout | Increase session timeout in gateway settings, check inactivity |
| Slow connections | Network latency, gateway performance, try different gateway |
