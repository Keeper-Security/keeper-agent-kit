# Password Rotation Commands

Comprehensive guide to password rotation in Keeper PAM.

## Overview

Password rotation automatically replaces privileged account passwords on a schedule
to reduce risk of compromise. Rotation can be automated or manual.

## Rotation Strategies

### Random Password Rotation

System generates random complex password, updates target system, stores in Keeper.

```bash
My Vault> pam rotation create --record <RECORD_UID> \
  --strategy random_password \
  --password-length 32 \
  --include-uppercase true \
  --include-lowercase true \
  --include-digits true \
  --include-symbols true
```

**Configuration:**

- `password-length` - 8-128 characters (default: 16)
- `include-uppercase` - A-Z (default: true)
- `include-lowercase` - a-z (default: true)
- `include-digits` - 0-9 (default: true)
- `include-symbols` - !@#$%^&* (default: true)

### Passphrase Rotation

Generate memorable multi-word passphrase instead of random string.

```bash
My Vault> pam rotation create --record <RECORD_UID> \
  --strategy passphrase \
  --passphrase-words 4 \
  --passphrase-separator "-"
```

**Options:**

- `passphrase-words` - 3-6 words (default: 4)
- `passphrase-separator` - Delimiter (default: "-")
- `passphrase-capitalize` - true/false

**Example output:** `correct-horse-battery-staple`

### Rotate-Only Strategy

Manually rotate password without generating new one. Useful for accounts where
password must follow specific pattern.

```bash
My Vault> pam rotation create --record <RECORD_UID> \
  --strategy rotate_only
```

## Rotation Scheduling

### One-Time Rotation

```bash
# Rotate now
My Vault> pam rotation start --record <RECORD_UID>

# With confirmation
My Vault> pam rotation start --record <RECORD_UID> --confirm
```

### Scheduled Rotation

#### Daily Rotation

```bash
# Every day at 2 AM
My Vault> pam rotation create --record <RECORD_UID> \
  --schedule "0 2 * * *"

# Every day at 6 PM
My Vault> pam rotation create --record <RECORD_UID> \
  --schedule "0 18 * * *"
```

#### Weekly Rotation

```bash
# Every Sunday at 3 AM
My Vault> pam rotation create --record <RECORD_UID> \
  --schedule "0 3 * * 0"

# Every Monday at 2 AM
My Vault> pam rotation create --record <RECORD_UID> \
  --schedule "0 2 * * 1"

# Weekdays (Mon-Fri) at 9 PM
My Vault> pam rotation create --record <RECORD_UID> \
  --schedule "0 21 * * 1-5"
```

#### Monthly Rotation

```bash
# First of month at 2 AM
My Vault> pam rotation create --record <RECORD_UID> \
  --schedule "0 2 1 * *"

# Last day of month at 11 PM
My Vault> pam rotation create --record <RECORD_UID> \
  --schedule "0 23 31 * *"
```

#### Interval-Based Rotation

```bash
# Every 30 days
My Vault> pam rotation create --record <RECORD_UID> \
  --interval 30 --unit days

# Every 7 days (weekly)
My Vault> pam rotation create --record <RECORD_UID> \
  --interval 7 --unit days

# Every 90 days (quarterly)
My Vault> pam rotation create --record <RECORD_UID> \
  --interval 90 --unit days

# Supported units: minutes, hours, days, weeks, months
```

## Rotation Status & History

### List Rotation Policies

```bash
# Show all policies
My Vault> pam rotation list

# JSON format
My Vault> pam rotation list --json

# Filter by status
My Vault> pam rotation list --status active

# Filter by record type
My Vault> pam rotation list --type database
```

### Get Policy Details

```bash
My Vault> pam rotation policy --record <RECORD_UID>

# Show when next rotation scheduled
My Vault> pam rotation policy --record <RECORD_UID> --next
```

### Check Rotation Status

For a specific job:

```bash
My Vault> pam rotation status --job <JOB_ID>
```

Status values:

- `pending` - Scheduled, not started
- `in_progress` - Currently rotating
- `completed` - Successfully completed
- `failed` - Failed (check error details)
- `paused` - Manually paused

### Rotation History

```bash
# Full history for a record
My Vault> pam rotation history --record <RECORD_UID>

# Recent 10 rotations
My Vault> pam rotation history --record <RECORD_UID> --limit 10

# JSON output for analysis
My Vault> pam rotation history --record <RECORD_UID> --json

# Filter by date range
My Vault> pam rotation history --record <RECORD_UID> \
  --from "2025-01-01" --to "2025-03-31"
```

**History includes:**

- Timestamp
- Old password (hashed for security)
- New password (hashed)
- Status (success/failed)
- Duration
- Error details if failed

### Failed Rotations

```bash
# Show failed jobs
My Vault> pam rotation history --record <RECORD_UID> --status failed

# Get error details
My Vault> pam rotation error --job <JOB_ID>
```

## Rotation Management

### Update Rotation Policy

```bash
# Change schedule
My Vault> pam rotation update --record <RECORD_UID> \
  --schedule "0 3 * * *"

# Change interval
My Vault> pam rotation update --record <RECORD_UID> \
  --interval 14 --unit days

# Change password generation
My Vault> pam rotation update --record <RECORD_UID> \
  --password-length 48 \
  --include-symbols true
```

### Pause Rotation

Temporarily stop rotation (e.g., during maintenance).

```bash
My Vault> pam rotation pause --record <RECORD_UID>

# Verify paused
My Vault> pam rotation list --record <RECORD_UID>
# Status should show "paused"
```

### Resume Rotation

```bash
My Vault> pam rotation resume --record <RECORD_UID>
```

### Delete Rotation Policy

```bash
# Remove policy (stops rotation)
My Vault> pam rotation delete --record <RECORD_UID>

# Confirm deletion
My Vault> pam rotation list  # Policy should no longer appear
```

## Rotation Targets

### Database Rotation

#### MySQL/MariaDB

```bash
# Create record with DB creds
My Vault> add --record-type databaseCredentials \
  --title "Production MySQL" \
  --field host=mysql.example.com \
  --field port=3306 \
  --field login=admin \
  --field password=current_password

# Enable rotation
My Vault> pam rotation create --record <RECORD_UID> \
  --target-type mysql \
  --schedule "0 2 * * *"
```

#### PostgreSQL

```bash
My Vault> add --record-type databaseCredentials \
  --title "Production PostgreSQL" \
  --field host=postgres.example.com \
  --field port=5432 \
  --field login=postgres \
  --field password=current_password

My Vault> pam rotation create --record <RECORD_UID> \
  --target-type postgresql \
  --schedule "0 2 * * *"
```

#### Oracle

```bash
My Vault> add --record-type databaseCredentials \
  --title "Enterprise Oracle" \
  --field host=oracle.example.com \
  --field port=1521 \
  --field login=sys \
  --field password=current_password \
  --custom-field database=PROD

My Vault> pam rotation create --record <RECORD_UID> \
  --target-type oracle \
  --schedule "0 3 * * *"
```

#### MSSQL

```bash
My Vault> pam rotation create --record <RECORD_UID> \
  --target-type mssql \
  --schedule "0 2 * * *"
```

### SSH/Linux Rotation

```bash
My Vault> add --record-type login \
  --title "Linux Root Account" \
  --field login=root \
  --field password=current_password \
  --field host=linux.prod.example.com

My Vault> pam rotation create --record <RECORD_UID> \
  --target-type ssh \
  --schedule "0 2 * * 0"  # Weekly on Sunday
```

### Active Directory / Windows

```bash
My Vault> add --record-type login \
  --title "AD Service Account" \
  --field login=svc_account \
  --field password=current_password \
  --custom-field domain=COMPANY

My Vault> pam rotation create --record <RECORD_UID> \
  --target-type active_directory \
  --schedule "0 2 1 * *"  # Monthly on 1st
```

### AWS IAM

```bash
My Vault> add --record-type login \
  --title "AWS Root Account" \
  --field login=admin_iam_user \
  --field password=current_password \
  --custom-field access_key_id=AKIAIOSFODNN7EXAMPLE

My Vault> pam rotation create --record <RECORD_UID> \
  --target-type aws_iam \
  --schedule "0 2 * * *"
```

### API Keys

```bash
My Vault> add --record-type login \
  --title "GitHub Token" \
  --custom-field repository=company/main
# Set the token/password field interactively or from secure input—do not embed secrets in example commands.

My Vault> pam rotation create --record <RECORD_UID> \
  --target-type github_api \
  --schedule "0 2 15 * *"  # Monthly on 15th
```

## Rotation Notifications

### Pre-Rotation Notifications

```bash
My Vault> pam rotation create --record <RECORD_UID> \
  --notify-before 1 \
  --notify-email admin@company.com
```

### Post-Rotation Notifications

```bash
My Vault> pam rotation update --record <RECORD_UID> \
  --notify-after true \
  --notify-on-failure true
```

### Notification Settings

```bash
# Notify on success and failure
My Vault> pam rotation update --record <RECORD_UID> \
  --notify-success true \
  --notify-failure true \
  --notify-email security@company.com,admin@company.com
```

## Batch Rotation

### Rotate Multiple Records

```bash
# Create rotation for multiple similar resources
for server in web1 web2 web3; do
  record=$(My Vault> search "$server" --json | jq -r '.[0].uid')
  echo "pam rotation create --record $record --schedule '0 2 * * *'"
done | keeper --batch-mode
```

### Bulk Rotation Schedule

```bash
# Database tier rotations at 2 AM
for db_uid in DB_UID1 DB_UID2 DB_UID3; do
  echo "pam rotation create --record $db_uid --schedule '0 2 * * *'"
done

# Application tier rotations at 3 AM
for app_uid in APP_UID1 APP_UID2; do
  echo "pam rotation create --record $app_uid --schedule '0 3 * * *'"
done
```

### Export Rotation Config

```bash
My Vault> pam rotation list --json > rotations.json

# Parse and analyze
jq '.[] | {record: .record_id, schedule: .schedule, status: .status}' rotations.json
```

## Best Practices

### Scheduling

1. **Stagger rotations** - Don't rotate all accounts simultaneously
2. **Off-hours rotation** - Schedule during maintenance windows (2-4 AM)
3. **No rotation on weekends** - Unless 24/7 support available
4. **Account for time zones** - Use UTC in schedules if multi-region

### Monitoring

```bash
# Check for failed rotations daily
My Vault> pam rotation list --status failed

# Alert on failures
# (Configure external monitoring)
```

### Testing

1. **Test rotation process** - Don't start with production
2. **Verify access post-rotation** - Ensure applications still work
3. **Check logs** - Verify target system accepted rotation

### Compliance

```bash
# Document rotation policies
My Vault> pam rotation list --json > compliance_rotations.json

# Export rotation history for audit
My Vault> audit-report --event-type pam_rotation \
  --from "2025-01-01" --to "2025-12-31" \
  --format csv --output rotation_audit.csv
```

## Troubleshooting

| Error | Cause | Fix |
| --- | --- | --- |
| "Authentication failed" | Wrong credentials | Update credentials in record |
| "Connection timeout" | Target unreachable | Check firewall, network, gateway |
| "Password policy violation" | Generated password doesn't match requirements | Adjust password generation settings |
| "Rotation already in progress" | Previous rotation still running | Check status, may need manual intervention |
| "Rotation permanently failed" | Target system incompatibility | Change rotation strategy or target |
| "Permission denied" | Account lacks rotation privileges | Grant necessary admin/sudo access |
| "Rotation not executing" | Schedule misconfigured | Verify cron syntax |

## Testing Rotation

### Manual Test Run

```bash
# Start rotation immediately (test)
My Vault> pam rotation start --record <RECORD_UID> --test

# Verify old password still works
ssh user@host  # Should work with old password

# Check new password in Keeper
My Vault> get <RECORD_UID> --json | jq '.fields[] | select(.type=="password")'
```

### Dry Run Before Automation

```bash
# Create rotation policy in "test" mode
My Vault> pam rotation create --record <RECORD_UID> \
  --schedule "0 3 * * *" \
  --dry-run true

# Monitor first scheduled run
My Vault> pam rotation status --record <RECORD_UID>
```

### Verify Post-Rotation

```bash
# Test account access with new password
ssh -u $(ksm secret get -u <RECORD_UID> -f login) \
    -p $(ksm secret get -u <RECORD_UID> -f password) \
    $(ksm secret get -u <RECORD_UID> -f host)

# Check rotation succeeded
My Vault> pam rotation history --record <RECORD_UID> --limit 1
```
