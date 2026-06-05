# Nested Sub Folder Commands

Commands that support nested sub folder creation for newer or default workflows.
Nested Share Subfolders is built on the Keeper v3 API. The commands listed below operate exclusively on Nested Share folders and records and use the nsf- prefix to keep them clearly separated from the classic vault commands.

# Record Management
```bash
My Vault> nsf-record-add          # Create a Nested share record
My Vault> nsf-mkdir               # Create a Nested share folder
My Vault> nsf-rndir               # Rename or recolor a Nested share folder
My Vault> nsf-rmdir               # Remove a Nested share folder and its entire contents
My Vault> nsf-record-update       # Update an existing Nested share record
My Vault> nsf-rm                  # Remove (trash, permanently delete, or unlink) a Nested share record
```

# Sharing Commands

```bash
My Vault> nsf-share-folder          # Grant or revoke folder sharing
My Vault> nsf-share-record          # Grant, update, revoke, or transfer ownership of a record share
My Vault> nsf-record-permission     # Bulk-update record sharing permissions for every record inside a folder
```

Use -h to know exact syntax and working for each sub-commands.

Refer [keeper official NSF command documentation](https://docs.keeper.io/keeperpam/commander-cli/command-reference/nested-shared-folder) instead of guessing a particular command.

