# Keeper Notation

Read [safety.md](safety.md). Notation identifies a secret without storing its
value. It is not a permission grant; the application's actual access still applies.

## Field references

```text
keeper://<RECORD_UID>/field/password
keeper://<RECORD_UID>/field/login
keeper://<RECORD_UID>/custom_field/API_KEY
keeper://<RECORD_UID>/field/host[hostName]
keeper://<RECORD_UID>/field/host[port]
keeper://<RECORD_UID>/file/certificate.pem
```

Inspect the real record schema. `host` can be an object with `hostName` and `port`;
do not invent separate fields or assume every login record has host/TOTP fields.
Prefer exact UIDs for stable automation; titles can change or be ambiguous.
Array/object selectors, escaping, and file-return types must match the selected
CLI/SDK version. Do not assume a URI with only the record UID exports full JSON.

## Runtime injection

```bash
API_KEY='keeper://<RECORD_UID>/custom_field/API_KEY' ksm exec -- ./myapp
```

The application must consume the environment directly. Parent-shell expansion
happens before injection; expanding `$API_KEY` in command arguments is not a safe
delivery mechanism. File notation may yield contents, not a filename. Never
assume `ksm exec` creates a temporary attachment file for a program expecting a path.

## Structured configuration and attachments

Use a supported Property File flow or SDK format-aware serialization for JSON/YAML.
If interpolation is explicitly selected, its output is plaintext and must be
protected. Multiline and special-character values need proper serialization.

Download an attachment only when a file-consuming workflow requires it, using an
approved private path, restricted permissions, and cleanup. Do not send it to
stdout or print private keys/certificates into diagnostics. TOTP seeds and generated
codes are sensitive; never echo them to verify notation.

## Source

[Keeper notation](https://docs.keeper.io/keeperpam/secrets-manager/about/keeper-notation)
