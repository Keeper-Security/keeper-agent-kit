# KSM CLI: Selected Commands

This is a curated guide, not an exhaustive command contract. Verify `ksm version`
and installed `--help`; newer default-branch features may not be in your release.
Read [safety.md](safety.md). Do not run secret-bearing output through an agent's
terminal capture.

## Profiles and global options

Global options precede the subcommand. Bootstrap uses user-supplied
`KSM_CLI_TOKEN` in a secure terminal, never a literal token argument in an agent
command. `KSM_CLI_PROFILE` selects a CLI profile; do not invent `KSM_PROFILE` or
assume a variable for SDK JSON configuration also selects a CLI INI file.

```bash
ksm profile init --profile-name development
ksm profile list
ksm profile active development
ksm --profile-name development secret list
ksm --ini-file /approved/private/keeper.ini secret list
```

Profile export/import can expose device credentials. Use documented formats and
a secure delivery channel; do not print exports or base64 configs in chat.

## Metadata and fields

```bash
ksm secret list
ksm secret list --title '^Development API$'
ksm secret list --folder '<FOLDER_UID>' --recursive
ksm folder list
```

`secret get --json`, `secret notation`, field reads, and TOTP generation can return
secrets. Integrate reads into the consuming application rather than displaying
them. Notation resolution is `ksm secret notation <NOTATION>`, not an invented
notation argument to `secret get`. Treat full-record output as sensitive.

## Writes

Record creation requires a storage folder. Field creation uses positional field
arguments, not an invented `--field` flag. The following is a non-secret skeleton
for a user-approved creation; confirm the actual type's required fields first:

```bash
ksm secret add field --storage-folder-uid '<FOLDER_UID>' \
  --record-type login --title 'Development account' login=developer
```

Update accepts `--uid` and supported field options. Its `--title` changes the
title; it is not a selector. Delete requires exact UID(s); do not assume a
`--force` confirmation flag exists. Confirm edits and deletion in the agent
workflow even when the CLI does not prompt. Password generation emits a secret;
prefer supported in-process generation or editor generation without capture.

## Delivery

```bash
API_KEY='keeper://<RECORD_UID>/field/password' ksm exec -- ./myapp
(umask 077; ksm interpolate config.tmpl -o /approved/private/config.yaml)
```

The first command injects into the child environment. The second writes plaintext;
protect the destination and arrange cleanup. Neither guarantees the consuming
application will avoid logging values. Never evaluate or source rendered output.

## CLI sync

```bash
ksm sync --type aws --credentials '<CLOUD_CREDS_RECORD_UID>' --dry-run \
  --map 'development/api-key' 'keeper://<RECORD_UID>/field/password'
```

Supported documented targets are `aws`, `azure`, `gcp`, and `json`. Mapping takes
two arguments: destination key and notation. JSON mode can expose values; do not
capture it as a supposedly safe plan. Check output safety for the installed
version even in dry-run mode. Provider dependencies must be installed separately.

Newer AWS record/folder sync options require a naming prefix; inspect installed
help before suggesting them. Review missing-source/deletion behavior before any
sync. This is explicit one-way CLI sync, not automatic Gateway-based USS.

## Sources

- [CLI](https://docs.keeper.io/keeperpam/secrets-manager/secrets-manager-command-line-interface)
- [Profile](https://docs.keeper.io/keeperpam/secrets-manager/secrets-manager-command-line-interface/profile-command)
- [Sync](https://docs.keeper.io/keeperpam/secrets-manager/secrets-manager-command-line-interface/sync-command)
- [Interpolation](https://docs.keeper.io/keeperpam/secrets-manager/secrets-manager-command-line-interface/interpolate-command)
