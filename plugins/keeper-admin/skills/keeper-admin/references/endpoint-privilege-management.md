# Keeper Endpoint Privilege Manager

Read [safety.md](safety.md). KEPM is endpoint privilege management, not a PAM
Gateway or generic Vault policy. Verify KEPM licensing, target platform, delegated
rights, and the installed CLI/SDK surface before making changes.

Commander documentation describes an `epm` surface; historical source/SDKs may use
`pedm` aliases. Inspect installed help instead of guessing `kepm`/`epm`/`pedm`
interchangeability. Supported areas include deployment, agents, policies,
collections, provisioning, and approvals, depending on version.

For a policy change, show the target devices/users, filters, action, inheritance,
and proposed diff. For approval, verify the requester's identity, requested action,
target, duration, and policy. Do not approve all pending requests or elevate the
agent to troubleshoot a denial. Verify safe status and audit metadata afterward.

## Source

[KEPM commands](https://docs.keeper.io/keeperpam/commander-cli/command-reference/endpoint-privilege-manager-commands)
