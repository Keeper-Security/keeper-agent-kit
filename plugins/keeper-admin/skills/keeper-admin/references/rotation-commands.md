# Credential Rotation

Read [safety.md](safety.md). Use supported KeeperPAM rotation, not a generic
"change the vault password, then run ALTER USER" shell recipe. A vault record
edit does not rotate a target credential and can leave the stored password wrong.

## Workflow

1. Identify the exact linked PAM user/resource and applicable configuration/Gateway.
2. Inspect rotation permissions, target plugin, current settings, and active jobs.
3. Review target password policy, dependencies, maintenance impact, schedules,
   timezone, service restarts, and any post-rotation scripts.
4. Confirm the target and change. Use the installed supported rotation operation
   or discovered authorized MCP capability.
5. Monitor status/history through safe metadata. A queued/accepted request is not
   a completed successful rotation. Inspect failure state before retrying.
6. Verify application access using the normal approved credential-delivery path;
   never print or hash old/new passwords as proof.

## CLI help first

```text
help pam
pam rotation --help
```

Inspect actual subcommands for configuration, start, status, and history. Do not
invent `pam rotation create`, pause/resume/test modes, policy fields, or a cron
contract. Supported flags and scheduling format vary by implementation/version.
Dry-run behavior must be verified; do not promise it leaves passwords unchanged
unless the specific product operation guarantees that.

## Bulk work and custom scripts

Bulk rotation needs an approved target list, staggered execution, per-item status,
and a recovery/escalation plan. Do not force completion or alter recording/security
controls to make a failed rotation pass. Use supported SaaS plugins and documented
post-rotation hooks. Treat custom scripts as privileged code; review inputs,
logging, dependency integrity, and secret lifetime before deployment.

## Sources

- [Managing rotation via CLI](https://docs.keeper.io/keeperpam/privileged-access-manager/references/managing-rotation-via-cli)
- [Password rotation](https://docs.keeper.io/keeperpam/privileged-access-manager/password-rotation)
- [SaaS rotation](https://docs.keeper.io/keeperpam/privileged-access-manager/password-rotation/rotation-use-cases/saas-plugins/saas-rotation-via-commander)
