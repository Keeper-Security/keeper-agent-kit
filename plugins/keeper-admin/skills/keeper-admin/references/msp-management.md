# MSP and Managed Company Context

Read [safety.md](safety.md). MSP identity, managed-company identity, license changes,
and tenant administration have different permissions. Never act across MCs just
because the account can list them.

## Workflow

1. Inspect MSP information and the intended MC using supported read commands.
2. Resolve the exact MC and delegated rights; do not select the first title match.
3. Preview the task, license/billing impact, users/resources, and tenant scope.
4. Use supported `switch-to-mc` / `switch-to-msp` context commands where applicable.
   Verify context before each change and return to MSP when finished.
5. Inspect per-item outcomes. MC removal, transfers, bulk role copying, and license
   reductions require explicit confirmation and an approved recovery plan.

Inspect installed help for `msp-info`, `msp-down`, `msp-add`, `msp-update`,
`msp-remove`, and reporting commands. Do not assume aliases, JSON schemas, or
identical capabilities across SDKs/MCP. Discovered MCP tools must explicitly
support the required tenant context; never infer cross-MC administration support.

## Source

[MSP commands](https://docs.keeper.io/keeperpam/commander-cli/command-reference/msp-management-commands)
