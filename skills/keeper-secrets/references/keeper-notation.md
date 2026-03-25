# Keeper Notation Reference

Keeper Notation is a URI syntax for referencing specific fields and attachments
in Keeper records. It's used with `ksm exec`, `ksm interpolate`, and other commands.

Official documentation: [Keeper notation](https://docs.keeper.io/en/keeperpam/secrets-manager/about/keeper-notation) (docs.keeper.io). This file expands on syntax and patterns for agents.

## Basic Syntax

```text
keeper://<RECORD_UID>[/field/<FIELD_TYPE>][/custom_field/<LABEL>][/file/<FILE_NAME>]
```

## Examples

### Standard Fields

```text
keeper://SNzjw8tM1HsXEzXERCJrNQ/field/password
keeper://SNzjw8tM1HsXEzXERCJrNQ/field/login
keeper://8f8I-OqPV58o2r91wVgZ_A/field/url
keeper://8f8I-OqPV58o2r91wVgZ_A/field/host
keeper://8f8I-OqPV58o2r91wVgZ_A/field/port
keeper://8f8I-OqPV58o2r91wVgZ_A/field/domain
keeper://8f8I-OqPV58o2r91wVgZ_A/field/otp
```

### Custom Fields

```text
keeper://SNzjw8tM1HsXEzXERCJrNQ/custom_field/API_Token
keeper://SNzjw8tM1HsXEzXERCJrNQ/custom_field/ConnectionString
keeper://SNzjw8tM1HsXEzXERCJrNQ/custom_field/SSH_Key
```

### Files/Attachments

```text
keeper://SNzjw8tM1HsXEzXERCJrNQ/file/certificate.pem
keeper://SNzjw8tM1HsXEzXERCJrNQ/file/id_rsa
keeper://SNzjw8tM1HsXEzXERCJrNQ/file/config.json
```

### Whole Record (JSON)

```text
keeper://SNzjw8tM1HsXEzXERCJrNQ
# Returns entire record as JSON (useful with jq for complex queries)
```

## Standard Field Types

These field types exist in most login-type records:

| Field Type | Purpose | Example |
| --- | --- | --- |
| `login` | Username / account identifier | `admin@example.com` |
| `password` | Password / secret credential | `MySecurePassword123` |
| `url` | Website URL | `https://example.com` |
| `host` | Server hostname or IP | `db.example.com` |
| `port` | Network port number | `5432` |
| `domain` | Domain name | `example.com` |
| `otp` | One-Time Password / TOTP | `123456` (requires TOTP secrets) |
| `securityQuestion` | Security question text | `What is your first pet's name?` |
| `securityAnswer` | Security answer | `Fluffy` |
| `mailAddress` | Email address | `user@example.com` |
| `securityCode` | Code / PIN | `1234` |

## Custom Fields

Custom fields are user-defined in the Keeper record. Reference them by their label:

```text
keeper://RECORD_UID/custom_field/FieldLabel
```

Custom fields can contain any type of text data.

**Example record with custom fields:**

```text
Title: AWS Credentials
login: AKIAIOSFODNN7EXAMPLE
password: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Custom fields:
  - Label: "AWS_ACCOUNT_ID"
    Value: "123456789012"
  - Label: "AWS_REGION"
    Value: "us-west-2"

Notation:
keeper://RECORD_UID/field/login
keeper://RECORD_UID/field/password
keeper://RECORD_UID/custom_field/AWS_ACCOUNT_ID
keeper://RECORD_UID/custom_field/AWS_REGION
```

## File Attachments

Records can contain file attachments. Reference them by filename:

```text
keeper://RECORD_UID/file/filename.ext
```

**Common use cases:**

```text
keeper://RECORD_UID/file/certificate.pem      # SSL certificate
keeper://RECORD_UID/file/id_rsa                # SSH private key
keeper://RECORD_UID/file/config.json           # Configuration file
keeper://RECORD_UID/file/credentials.p12       # PKCS#12 keystore
```

**Extracting files:**

```bash
# Extract file to stdout
ksm secret get keeper://RECORD_UID/file/certificate.pem

# Extract file to disk
ksm secret get keeper://RECORD_UID/file/certificate.pem > cert.pem

# Use with ksm exec
CERT_FILE="keeper://RECORD_UID/file/certificate.pem" \
ksm exec -- openssl x509 -in $CERT_FILE -text
```

## Usage in Commands

### With ksm exec

```bash
# Single secret
export DB_PASSWORD="keeper://8f8I-OqPV58o2r91wVgZ_A/field/password"
ksm exec -- psql -h $DB_HOST -U $DB_USER -W $DB_PASSWORD

# Multiple secrets
DB_HOST="keeper://8f8I-OqPV58o2r91wVgZ_A/field/host" \
DB_PORT="keeper://8f8I-OqPV58o2r91wVgZ_A/field/port" \
DB_USER="keeper://8f8I-OqPV58o2r91wVgZ_A/field/login" \
DB_PASS="keeper://8f8I-OqPV58o2r91wVgZ_A/field/password" \
ksm exec -- ./app.sh
```

### With ksm interpolate

Template file content:

```yaml
database:
  host: keeper://8f8I-OqPV58o2r91wVgZ_A/field/host
  port: keeper://8f8I-OqPV58o2r91wVgZ_A/field/port
  username: keeper://8f8I-OqPV58o2r91wVgZ_A/field/login
  password: keeper://8f8I-OqPV58o2r91wVgZ_A/field/password

api:
  key: keeper://SNzjw8tM1HsXEzXERCJrNQ/field/password
  token: keeper://SNzjw8tM1HsXEzXERCJrNQ/custom_field/AccessToken

ssl:
  certificate: keeper://CERT_UID/file/cert.pem
  key: keeper://KEY_UID/file/key.pem
```

```bash
ksm interpolate --in-file config.tmpl --out-file config.yaml
```

### With Docker

```dockerfile
FROM mybase:latest

# Set secret references as build args
ARG DB_PASSWORD="keeper://8f8I-OqPV58o2r91wVgZ_A/field/password"
ARG API_KEY="keeper://SNzjw8tM1HsXEzXERCJrNQ/field/password"

ENV DB_PASSWORD=$DB_PASSWORD
ENV API_KEY=$API_KEY

ENTRYPOINT ["ksm", "exec", "--"]
CMD ["./start.sh"]
```

```bash
docker run \
  -e DB_PASSWORD="keeper://8f8I-OqPV58o2r91wVgZ_A/field/password" \
  -e API_KEY="keeper://SNzjw8tM1HsXEzXERCJrNQ/field/password" \
  -e KSM_CONFIG="<base64>" \
  myapp
```

### With Kubernetes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: DB_PASSWORD
      value: "keeper://8f8I-OqPV58o2r91wVgZ_A/field/password"
    - name: API_KEY
      value: "keeper://SNzjw8tM1HsXEzXERCJrNQ/field/password"
    - name: KSM_CONFIG
      valueFrom:
        secretKeyRef:
          name: ksm-config
          key: config
    command: ["ksm", "exec", "--"]
    args: ["./start.sh"]
```

## Advanced Patterns

### Resolving Multiple Fields

```bash
# Get all fields from a record
ksm secret get -u RECORD_UID --json | jq '.fields[] | {type, value}'

# Extract with jq
ksm secret get -u RECORD_UID --json | jq -r '.fields[] | select(.type=="password") | .value[0]'
```

### Chaining with Other Tools

```bash
# Use with openssl
CERT=$(ksm secret get keeper://CERT_UID/file/cert.pem)
openssl x509 -in <(echo "$CERT") -text

# Use with curl
API_KEY=$(ksm secret get keeper://API_UID/field/password)
curl -H "Authorization: Bearer $API_KEY" https://api.example.com/data
```

### TOTP Generation

```bash
# If record has TOTP configured
OTP=$(ksm secret get keeper://RECORD_UID/field/otp)
echo "Current OTP: $OTP"
```

## Special Characters in Labels

If custom field labels contain special characters, URL-encode them:

```text
keeper://RECORD_UID/custom_field/Field%20Label%20With%20Spaces
keeper://RECORD_UID/custom_field/Field-With-Dashes
keeper://RECORD_UID/custom_field/Field_With_Underscores
```

## Record Discovery

Find UIDs for notation:

```bash
# List all records
ksm secret list
# Output shows UIDs you can use

# List by title
ksm secret list | grep "Database"

# Get as JSON for scripting
ksm secret list --json | jq '.[] | select(.title | contains("Database")) | .uid'
```

## Security Best Practices

1. **Never hardcode UIDs in source code** - use environment variables or config files
2. **Always prefer notation over plaintext** - let ksm resolve at runtime
3. **Keep notation in templates, not databases** - use `ksm interpolate` for config generation
4. **Rotate access regularly** - follow your organization's secret rotation policy
5. **Use `--raw` flag carefully** - shell escaping can leak secrets in error messages

## Troubleshooting

| Issue | Solution |
| --- | --- |
| "Notation not found" | Verify UID and field type exist, check record sharing |
| "Field type invalid" | Check standard field types, ensure custom_field uses exact label |
| "File not found" | Verify attachment filename matches exactly (case-sensitive) |
| "Access denied" | Record must be shared with the KSM Application in Keeper |

## Notation Escaping

In shell contexts, handle special characters carefully:

```bash
# Single quotes preserve literal notation
export SECRET='keeper://UID/field/password'

# Double quotes need escaping
export SECRET="keeper:\/\/UID\/field\/password"  # Unnecessary

# No escaping needed with ksm exec
DB_PASS="keeper://UID/field/password" ksm exec -- psql
```
