# Nested Shared Folders

Read [safety.md](safety.md). Folder permission model and record schema are separate.
Do not equate a newer typed record with a nested-shared record or convert existing
classic records merely to follow a preferred workflow.

## Discover and operate

Inspect actual resource metadata, inheritance, ownership, and installed commands.
Supported Commander registrations include:

```text
nsf-list
nsf-record-details
nsf-mkdir
nsf-record-add
nsf-record-update
nsf-share-folder
nsf-share-record
```

Use command help for flags. Preview recipients, inherited permissions, expiry,
and changes before writing. Removal, recursive folder deletion, conversion,
ownership transfer, and bulk permission changes are high risk and need exact
scope and explicit confirmation. Do not assume rollback or atomic conversion.

## Sources

- [Commander nested sharing](https://docs.keeper.io/keeperpam/commander-cli/command-reference/keeper-drive-commands)
- [Nested sharing model](https://docs.keeper.io/enterprise-guide/sharing/nested-share-subfolders)
