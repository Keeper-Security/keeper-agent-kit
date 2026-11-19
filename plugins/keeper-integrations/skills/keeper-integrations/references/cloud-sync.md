# Cloud Secret Delivery and Synchronization

Read [safety.md](safety.md). Decide who retrieves the secret and where copies live.

## Direct KSM retrieval

Use KSM SDK/CLI for an application, pipeline, or script that needs scoped direct
access. Protect the bound device config. Read-only secret retrieval does not
automatically require a PAM Gateway or authorize changes to a cloud secret store.

## Explicit KSM CLI sync

CLI sync reads Keeper and writes an external store; it is one-way, not conflict
resolution. Verify installed flags, provider dependencies, selected mapping,
destination region/names, identity privileges, and missing-source behavior.

```bash
ksm sync --type aws --credentials '<CLOUD_CREDS_RECORD_UID>' --dry-run \
  --map 'development/api-key' 'keeper://<RECORD_UID>/field/password'
```

The credentials record must be available to the application. `--map` takes a
destination name and a notation reference. Documented targets are `aws`, `azure`,
`gcp`, and `json`. JSON output can include values; don't capture it. Verify
dry-run redaction for the installed version. Obtain confirmation before removing
dry-run or enabling a schedule. Review provider-specific record/folder options
against installed help rather than assuming new source features are released.

Source: [CLI sync](https://docs.keeper.io/keeperpam/secrets-manager/secrets-manager-command-line-interface/sync-command).

## Universal Secrets Sync

USS uses the registered customer Gateway to push automatically from Keeper to
configured AWS/Azure/GCP/GitHub Actions/HashiCorp stores. Confirm:

- Applicable PAM license, Gateway, associated KSM application, and supported configuration.
- Permission to configure USS and a dedicated least-privilege Sync Identity.
- Selected source folders, destination names, regions, metadata, and change behavior.
- Dry-run review before automatic writes and narrow safe audit/status verification.
- Cloud IAM/retention and application refresh when credentials rotate.

Migration/import of existing cloud secrets is separate from steady-state sync.
Native cloud retrieval after USS uses cloud SDK/IAM controls and maintains copies
outside Keeper; do not imply that those values inherit all Desktop MCP guardrails.

Sources: [USS](https://docs.keeper.io/keeperpam/privileged-access-manager/universal-secrets-sync),
[Setup](https://docs.keeper.io/keeperpam/privileged-access-manager/universal-secrets-sync/setup),
[Commander guide](https://docs.keeper.io/keeperpam/privileged-access-manager/universal-secrets-sync/commander-guide).
