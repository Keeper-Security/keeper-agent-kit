# Endpoint Privilege Manager Commands

Commands that control Keeper Endpoint Privilege Manager (KEPM) capabilities

```
My Vault> epm -h                                                       
epm command [--options]

Command     Description
----------  ------------------------------------
sync-down   Sync down EPM data from the backend
deployment  Manage EPM deployments 
agent       Manage EPM agents
policy      Manage EPM policies
collection  Manage EPM collections 
scim        Sync EPM user/group collections from AD or AzureAD
approval    Manage EPM requests and approvals
```

Use epm sync-down to get latest approvals if a approval is not found.

## EPM Sub commands

```
sync-down
deployment
agent
policy
collection
approval
scim
```
Use -h to know exact syntac and working for each sub-commands.

Refer [keeper official EPM documentation](https://docs.keeper.io/en/keeperpam/commander-cli/command-reference/endpoint-privilege-manager-commands) instead of guessing a particular command.

