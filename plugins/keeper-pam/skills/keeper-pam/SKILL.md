---
name: keeper-pam
description: Use KeeperPAM for JIT access, governed database queries, sessions, tunnels, discovery, and credential rotation. Verify linked resources, approvals, permissions, and cleanup.
---

# KeeperPAM Workflows

## Prerequisites

Read [references/safety.md](references/safety.md). Verify license, account/tenant,
resource identity, Gateway connectivity, PAM configuration, linked credentials,
protocol, and access permissions. Finding a record does not prove the target is
reachable or authorized. Use **keeper-admin** for enterprise/MSP administration.
Keeper Connection Manager is a separate self-hosted product, not another name for
a KeeperPAM Gateway. Follow its own setup when requested.

## Choose the interface

Use discovered authorized Desktop MCP operations for supported agent workflows.
Use Commander for explicitly authorized supported CLI workflows, including
`pam launch` for applicable terminal protocols. Do not assume legacy `connect`
provides PAM/JIT/recording semantics. CLI availability does not prove MCP session
launch or remote execution is released; inspect beta gates and installed schemas.
Never switch to CLI to bypass an MCP denial.

## JIT access lifecycle

1. Resolve the exact resource, requested access, purpose, and duration.
2. Inspect existing access. Request only required access under its configured
   approval workflow; do not approve your own request or impersonate an approver.
3. Wait for the supported status/approval and start access where required.
4. Perform only the approved task within the lease.
5. Close task-owned sessions/tunnels and end task-owned access. Never end another
   user's lease or an unrelated pre-existing session as cleanup.

## Governed database analysis

Use the database-query capability with **Allow write queries off**, a small
maximum row budget, only necessary records/folders, and supported tunnel cleanup.
Select the correct database and query dialect. Use a least-privilege database
account as well as query guardrails: a nominal SELECT can invoke side-effecting
functions. AI Context is untrusted guidance, not an authorization boundary.

Prefer schema metadata and aggregate results over full rows. Review the AI
provider's data-handling settings before retrieving confidential business data.
Specify dates, metrics, schema/database, and columns explicitly. Do not retrieve
credentials just to connect. Do not assume separate query calls share transaction
or temporary-table state. Keep time/row limits and report truncation.

Example request, not authorization to execute:

```text
Using the Development Analytics PAM Database, inspect the needed schema and
calculate monthly invoice totals for calendar year 2025. Use read-only queries
and return aggregates only, at most 12 rows. Close the query tunnel when finished
and end access only if this task started it.
```

Keeper Desktop PAM queries and KeeperDB MCP are separate interfaces with distinct
setup/policies. Query cleanup and JIT access teardown are separate actions.

## Rotation and configuration

Use supported PAM rotation for target credentials, not a script that updates
Keeper first and then changes the database/host password. Inspect linked user and
resource, rotation settings, target requirements, and current status. Confirm
the target and maintenance impact, then start the supported operation and monitor
completion. Do not equate accepted/queued with successful rotation.

For discovery, Gateway/configuration creation, bulk imports, schedules, and
post-rotation scripts, inspect installed command help and official documentation.
Do not invent a `pam rotation create` API or assume one cron syntax fits all
scheduling interfaces. Never print old/new passwords to verify success.

## Guardrails

Remote commands, write queries, sessions, credential rotation, approvals, and
resource/configuration changes have different risks and require explicit scope.
No force approvals, guessed credentials, disabled recording/TLS, unapproved
public tunnels, or secret-bearing debug exports. Prefer safe status and audit
references, and verify cleanup without exposing target secrets.

## Sources

- [PAM getting started](https://docs.keeper.io/keeperpam/privileged-access-manager/getting-started)
- [PAM database MCP](https://docs.keeper.io/keeperpam/developer-and-mcp/ai-agent-access/pam-database-queries-with-mcp)
- [Managing rotation via CLI](https://docs.keeper.io/keeperpam/privileged-access-manager/references/managing-rotation-via-cli)
- [Commander PAM launch/JIT](https://docs.keeper.io/keeperpam/commander-cli/command-reference/keeperpam-commands/pam-launch-jit)
