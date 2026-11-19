# Enterprise Administration

Read [safety.md](safety.md). Verify the account, tenant, delegated admin rights,
node scope, and installed command help before changes. Role names and permissions
are customer-defined; do not assume built-in roles named Admin/Owner/Auditor.

## Users, teams, and roles

Inspect `enterprise-user`, `enterprise-team`, `enterprise-role`, and
`enterprise-node` help. Do not invent `--list`/`--json` flags, schema fields, or
uniform CRUD flags for every command. Name/UID ambiguities must be resolved.

For onboarding, preview each user, destination node, team membership, role, and
whether invitation/provisioning is already managed by SCIM, SSO/JIT, or Bridge.
Avoid competing sources of truth. Bulk work needs an approved finite target list,
per-item results, and a recovery plan; do not silently continue on partial failures.

For roles/policies, inspect current settings and show the exact proposed diff.
Verify policy names, value types, inheritance, and applicable role scope in the
installed implementation. Never generate arbitrary uppercase enforcement names
or elevate a user by assigning a guessed "Admin" role.

## Offboarding and device approval

Locking access, transferring an account, and deleting a user are separate actions.
Deletion does not automatically guarantee safe ownership transfer. Review account
transfer policies, retained records, team memberships, service identities, and
active access before applying an offboarding plan. Obtain explicit confirmation.

Verify device identity and requester before approval; never approve all pending
devices as login troubleshooting. SSO device approvals and MCP connection consent
are different mechanisms.

## Reporting and enterprise controls

Use supported audit/compliance/risk reports with narrow filters and approved
destinations. Reports can contain sensitive metadata. ARAM, SIEM delivery,
compliance features, and AI Governance have their own licensing/version gates.
Do not promise complete MCP audit events or enterprise enforcement merely because
the UI documentation lists them. Verify the installed release and permitted controls.

## Sources

- [Enterprise management commands](https://docs.keeper.io/keeperpam/commander-cli/command-reference/enterprise-management-commands)
- [Delegated administration](https://docs.keeper.io/enterprise-guide/delegated-administration)
- [Roles](https://docs.keeper.io/enterprise-guide/roles)
- [Account transfer](https://docs.keeper.io/enterprise-guide/account-transfer-policy)
- [Event reporting](https://docs.keeper.io/enterprise-guide/event-reporting)
