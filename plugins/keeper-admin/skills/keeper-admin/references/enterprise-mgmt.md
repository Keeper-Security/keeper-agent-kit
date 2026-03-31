# Enterprise Management Commands

Comprehensive reference for managing enterprise users, teams, roles, and policies.

## Prerequisites

- Admin or Owner role in Keeper Enterprise
- Access to Keeper Commander
- `keeper shell` or batch mode

## User Management

### Add User

```bash
My Vault> enterprise-user --add user@company.com

# Batch multiple adds
My Vault> enterprise-user --add user1@company.com
My Vault> enterprise-user --add user2@company.com
My Vault> enterprise-user --add user3@company.com
```

### Invite User

After adding, send invitation.

```bash
My Vault> enterprise-user --invite user@company.com

# Batch invitations
for user in user1@company.com user2@company.com; do
  echo "enterprise-user --invite $user"
done | keeper --batch-mode
```

### List Users

```bash
# Interactive list
My Vault> enterprise-user --list

# JSON output for parsing
My Vault> enterprise-user --list --json

# Show with details
My Vault> enterprise-user --list --format table
```

**User fields in JSON:**

- `user_id` - Internal user ID
- `email` - Email address
- `display_name` - User's name
- `status` - active, pending, locked, deleted
- `created` - Account creation date
- `last_login` - Last login timestamp

### Update User

```bash
# Update display name
My Vault> enterprise-user --update user@company.com --name "John Doe"

# Update phone
My Vault> enterprise-user --update user@company.com --phone "+1-555-1234"

# Update other fields
My Vault> enterprise-user --update user@company.com --title "Engineer"
```

### Lock User

Prevent user login without deleting.

```bash
My Vault> enterprise-user --lock user@company.com

# List locked users
My Vault> enterprise-user --list --json | jq '.[] | select(.status == "locked")'
```

### Unlock User

```bash
My Vault> enterprise-user --unlock user@company.com
```

### Delete User

```bash
# Delete with confirmation
My Vault> enterprise-user --delete user@company.com

# Force delete (no confirmation)
My Vault> enterprise-user --delete user@company.com --force

# Delete multiple
My Vault> enterprise-user --delete user1@company.com --force
My Vault> enterprise-user --delete user2@company.com --force
```

**Warning:** Deleting a user removes their vault access and transfers ownership.

## Team Management

### Create Team

```bash
My Vault> enterprise-team --add "Engineering"
My Vault> enterprise-team --add "Security"
My Vault> enterprise-team --add "DevOps"

# Multiple teams
for team in Engineering Security DevOps Finance; do
  echo "enterprise-team --add \"$team\""
done | keeper --batch-mode
```

### List Teams

```bash
My Vault> enterprise-team --list
My Vault> enterprise-team --list --json
```

### Add User to Team

```bash
My Vault> enterprise-team --add-user user@company.com --team "Engineering"

# Batch add users to team
for user in user1@company.com user2@company.com user3@company.com; do
  echo "enterprise-team --add-user $user --team \"Engineering\""
done | keeper --batch-mode
```

### Remove User from Team

```bash
My Vault> enterprise-team --remove-user user@company.com --team "Engineering"
```

### Delete Team

```bash
My Vault> enterprise-team --delete "Engineering"
My Vault> enterprise-team --delete "Engineering" --force
```

## Role Management

### List Roles

```bash
My Vault> enterprise-role --list
My Vault> enterprise-role --list --json
```

**Standard roles:**

- `Owner` - Full enterprise admin
- `Admin` - Administrative access
- `User` - Standard user
- `Auditor` - Read-only audit access

### Assign Role to User

```bash
# Make user an admin
My Vault> enterprise-role --add-user user@company.com --role "Admin"

# Make user an auditor
My Vault> enterprise-role --add-user user@company.com --role "Auditor"
```

### Remove Role from User

```bash
My Vault> enterprise-role --remove-user user@company.com --role "Admin"
```

## Enforcement Policies

Set security policies for the enterprise.

### Master Password Requirements

```bash
# Minimum length
My Vault> enterprise-role --enforcement MASTER_PASSWORD_MINIMUM_LENGTH:12

# Require digits
My Vault> enterprise-role --enforcement MASTER_PASSWORD_REQUIRE_DIGITS:true

# Require special characters
My Vault> enterprise-role --enforcement MASTER_PASSWORD_REQUIRE_SPECIAL:true
```

### Two-Factor Authentication

```bash
# Require 2FA
My Vault> enterprise-role --enforcement TWO_FACTOR_REQUIRED:true

# Require 2FA expiration (days)
My Vault> enterprise-role --enforcement TWO_FACTOR_DURATION:30
```

### IP Whitelisting

```bash
# Set IP whitelist
My Vault> enterprise-role --enforcement IP_WHITELIST:192.168.1.0/24

# Multiple subnets
My Vault> enterprise-role --enforcement IP_WHITELIST:192.168.0.0/16,10.0.0.0/8
```

### Session Timeout

```bash
# Inactivity timeout (minutes)
My Vault> enterprise-role --enforcement SESSION_TIMEOUT:30
```

### Device Restrictions

```bash
# Require device approval
My Vault> enterprise-role --enforcement DEVICE_APPROVAL_REQUIRED:true

# Limit concurrent devices
My Vault> enterprise-role --enforcement MAX_DEVICES:5
```

### SSO / SAML

```bash
# Require SSO login
My Vault> enterprise-role --enforcement SSO_REQUIRED:true

# SSO provider
My Vault> enterprise-role --enforcement SSO_PROVIDER:okta
```

## Organization Structure

### Node Management

Enterprise can be organized into nodes (departments, locations).

```bash
# Create node
My Vault> enterprise-node --add "Engineering Department"

# List nodes
My Vault> enterprise-node --list

# Add user to node
My Vault> enterprise-node --add-user user@company.com --node "Engineering"

# Add team to node
My Vault> enterprise-node --add-team "Engineering" --node "Engineering Department"
```

## Device Management

### List Devices

```bash
My Vault> device-approve --list
My Vault> device-approve --list --json
```

### Approve Device

```bash
My Vault> device-approve --approve <DEVICE_ID>
```

### Deny Device

```bash
My Vault> device-approve --deny <DEVICE_ID>
```

### Show Device Details

```bash
My Vault> device-approve --show <DEVICE_ID>
```

## SSO / SAML Configuration

### Configure SAML Provider

```bash
# Set SAML issuer
My Vault> enterprise-sso --provider okta \
  --issuer "https://okta.company.com/app/123/sso/saml" \
  --certificate "/path/to/cert.pem"

# Alternative providers: okta, azure, google, generic
```

### SCIM Integration

```bash
# Enable SCIM
My Vault> enterprise-scim --enable

# Get SCIM endpoint
My Vault> enterprise-scim --show-endpoint

# Authenticate SCIM calls
My Vault> enterprise-scim --token <TOKEN>
```

## Compliance & Audit

### Generate User Report

```bash
# Export all users
My Vault> enterprise-user --list --json > users.json

# Show status distribution
My Vault> enterprise-user --list --json | jq 'group_by(.status) | map({status: .[0].status, count: length})'
```

### Audit Trail

```bash
# User login activity
My Vault> audit-report --event-type login

# User creation/deletion
My Vault> audit-report --event-type user_created,user_deleted

# Permission changes
My Vault> audit-report --event-type permission_changed
```

### Data Loss Prevention (DLP)

```bash
# Monitor export operations
My Vault> audit-report --event-type export

# Monitor vault access
My Vault> audit-report --event-type record_viewed,record_updated
```

## Common Workflows

### Onboard New Team

```bash
# Create team
My Vault> enterprise-team --add "Data Science"

# Create team folder
My Vault> folder create --name "Data Science Team"

# Add users
My Vault> enterprise-team --add-user user1@company.com --team "Data Science"
My Vault> enterprise-team --add-user user2@company.com --team "Data Science"
My Vault> enterprise-team --add-user user3@company.com --team "Data Science"

# Share folder with team
My Vault> share-folder -e user1@company.com -a grant -u <FOLDER_UID>
My Vault> share-folder -e user2@company.com -a grant -u <FOLDER_UID>
My Vault> share-folder -e user3@company.com -a grant -u <FOLDER_UID>
```

### Off-Board User

```bash
# Remove from teams
My Vault> enterprise-team --remove-user departing@company.com \
  --team "Engineering"
My Vault> enterprise-team --remove-user departing@company.com \
  --team "DevOps"

# Revoke access to shared items
My Vault> share-folder -e departing@company.com -a revoke -u <FOLDER_UID>

# Optional: transfer records to new owner
# (Manual process in UI or via script)

# Lock or delete
My Vault> enterprise-user --lock departing@company.com
# Or after archiving:
My Vault> enterprise-user --delete departing@company.com
```

### Enforce Security Policy

```bash
# Require strong passwords
My Vault> enterprise-role --enforcement MASTER_PASSWORD_MINIMUM_LENGTH:14

# Require 2FA everywhere
My Vault> enterprise-role --enforcement TWO_FACTOR_REQUIRED:true

# Set session timeout
My Vault> enterprise-role --enforcement SESSION_TIMEOUT:15

# Limit concurrent devices
My Vault> enterprise-role --enforcement MAX_DEVICES:3

# Require device approval
My Vault> enterprise-role --enforcement DEVICE_APPROVAL_REQUIRED:true
```

### Generate Compliance Report

```bash
# Export user list with status
My Vault> enterprise-user --list --json | jq '.[] | {email, status, created, last_login}' > user_audit.json

# Export audit log
My Vault> audit-report --format csv --output audit_trail.csv

# Export roles
My Vault> enterprise-role --list --json > roles.json

# Generate combined compliance report
ksm exec -- python <<'EOF'
import json
import csv
from datetime import datetime

users = json.load(open('user_audit.json'))
roles = json.load(open('roles.json'))

report = {
  'generated': datetime.now().isoformat(),
  'total_users': len(users),
  'active_users': len([u for u in users if u['status'] == 'active']),
  'users_without_recent_login': [u['email'] for u in users if u.get('last_login') and u['last_login'] < '2025-01-01'],
  'roles_configured': [r['name'] for r in roles]
}

print(json.dumps(report, indent=2))
EOF
```

## Troubleshooting

| Issue | Solution |
| --- | --- |
| User invitation not sent | Ensure user is added first with `--add`, then `--invite` |
| Can't add user to team | Verify user exists and team exists, check permissions |
| Enforcement policy not applied | Policies apply to new logins; existing sessions see old policy |
| SAML/SCIM not working | Verify certificates, endpoints, and authentication tokens |
| Performance issues with large teams | Use batch commands, avoid real-time list operations |
