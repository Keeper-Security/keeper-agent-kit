# KeeperPAM Administration

For agent execution, JIT, queries, and teardown use the **keeper-pam** skill when
installed. This reference remains self-contained for administration-only installs.
Read [safety.md](safety.md).

## Model and prerequisites

KeeperPAM uses a registered customer Gateway, PAM configuration, resource records,
and linked user credentials. A Gateway is not an SSH/RDP record with a host/port;
PAM configurations are not generic `--type ssh` connection definitions.

Confirm license, region, Gateway health, configuration associations, record types,
permissions, and target connectivity. Do not assume a record is reachable merely
because it appears in discovery. Determine classic/nested resource support from
installed metadata/help rather than the record's title.

## Discover command support

```text
help pam
pam gateway list
pam configuration list
```

Use installed help for Gateway registration, configuration editing, discovery,
rotation, import, and tunnel operations. Do not invent create/update/delete
flags, output schemas, or health commands. Bootstrap output can contain tokens
and configs: do not capture it into the agent conversation.

## Sessions and access

For supported terminal protocols, inspect `pam launch` and JIT documentation;
do not assume legacy `connect` provides the same authorization/recording behavior.
Discover MCP session/command tools and beta gates instead of guessing their names.
Request only the intended resource/access duration and wait for approval.

Database queries should be read-only, bounded, and credential-free from the
agent's perspective. Close task-owned tunnels and end task-owned access leases
separately. Do not terminate unrelated sessions or bypass a denial with a CLI.

## Sources

- [PAM setup](https://docs.keeper.io/keeperpam/privileged-access-manager/getting-started)
- [Commander PAM commands](https://docs.keeper.io/keeperpam/commander-cli/command-reference/keeperpam-commands)
- [JIT](https://docs.keeper.io/keeperpam/privileged-access-manager/just-in-time-access-jit)
- [PAM database MCP](https://docs.keeper.io/keeperpam/developer-and-mcp/ai-agent-access/pam-database-queries-with-mcp)
