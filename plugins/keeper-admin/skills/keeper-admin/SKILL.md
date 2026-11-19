---
name: keeper-admin
description: Manage Keeper enterprise users, teams, roles, MSP tenants, Vault permissions, KSM applications, KEPM, and Commander Service Mode. Preview administrative changes and verify delegated permissions.
---

# Keeper Administration

## When to Use Commander

Use Commander for supported Vault and enterprise operations, not as a universal
substitute for all Keeper products. Use authorized, discovered MCP admin tools
where available; never assume admin/MSP coverage or bypass a denied MCP operation
with Commander. SDK development uses **keeper-sdk**; PAM/JIT/rotation uses
**keeper-pam**; unattended secret delivery uses **keeper-secrets**.

## Prerequisites

- A supported Commander binary or Python installation (`keepercommander`).
- An account with the specific delegated permissions required by the task.
- Explicit tenant/Managed Company context and resource identity.
- Read [references/safety.md](references/safety.md) before operating.

## Workflow

1. Verify `keeper --version`, `keeper --help`, and the installed subcommand help.
2. Authenticate through supported user-controlled login. Never request a master
   password, MFA code, API key, or session config in chat.
3. Verify account/tenant context with `whoami` in an authenticated shell.
4. Inspect metadata and permissions. Record schema and folder permission model
   are separate: a typed record is not automatically a Nested Shared Folder record.
5. Preview exact changes, recipients, permission flags, expiry, and affected scope.
6. Confirm high-risk actions, apply only that scope, and verify safe status.
7. Restore MSP context and close task-owned interactive sessions when finished.

## Vault Operations

Read [references/commander-commands.md](references/commander-commands.md) and
[references/nested-sub-folders.md](references/nested-sub-folders.md). Determine
classic versus nested sharing from actual metadata and installed capabilities.
Do not guess command flags or retrieve full record values just to classify it.
For a new folder/record, discuss permission inheritance and the destination model.

Sharing requires explicit recipients, rights, and expiry decisions. Import/export
may expose an entire vault; never export to plaintext as a routine discovery step.
Treat ownership transfer, purge, bulk permissions, and user deletion as high risk.

## Enterprise Administration

- [Enterprise management](references/enterprise-mgmt.md): users, teams, roles,
  policies, reporting, device approval, and safe offboarding.
- [MSP management](references/msp-management.md): explicit MC selection and
  return to MSP context; no automatic cross-tenant bulk changes.
- [Endpoint Privilege Manager](references/endpoint-privilege-management.md):
  verify supported command aliases and approval/policy permissions.

## KSM Application Administration

Application creation, secret-resource access grants, device bootstrap, and sharing
the application record with another user are **different operations**.
Use verified `secrets-manager` help or discovered authorized MCP KSM tools.
Default resource grants to read-only. Device creation produces a sensitive token;
let the user deliver it through a secure bootstrap channel without capturing it.
Do not retry device creation blindly after losing its output.

## Service Mode and Automation

Read [references/service-mode.md](references/service-mode.md) before exposing
Commander over HTTP. Supported lifecycle commands include `service-create`,
`service-start`, `service-status`, and `service-stop`.

Use a dedicated scoped identity, command allowlists, TLS, network restrictions,
and separate expiring API keys. Service Mode intentionally blocks some interactive,
session, and local-file commands. Its config-storage requirements can differ from
normal keyring login. Never open a public tunnel by default.

Batch commands use a supported command-file invocation after the user establishes
appropriate authentication. Persistent login is optional and policy-dependent,
not a prerequisite to every headless workflow and not something to enable silently.

## Guardrails

No resolved secrets in argv, logs, chat, exports, or terminal scrollback. User
confirmation does not override product permissions. Do not use force flags until
the specific affected objects and consequences have been approved. For PAM use
[references/pam-commands.md](references/pam-commands.md) and
[references/rotation-commands.md](references/rotation-commands.md).

## Sources

- [Commander](https://docs.keeper.io/keeperpam/commander-cli/overview)
- [Command reference](https://docs.keeper.io/keeperpam/commander-cli/command-reference)
- [Roles and permissions](https://docs.keeper.io/enterprise-guide/roles)
