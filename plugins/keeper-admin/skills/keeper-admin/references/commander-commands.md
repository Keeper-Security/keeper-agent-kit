# Commander: Selected Workflows

Read [safety.md](safety.md). This is a task guide, not an exhaustive flag reference.
Use installed help and official version-specific documentation. Shell transcripts
are `text`, not scripts to execute in an OS shell.

## Start and inspect

```bash
keeper --version
keeper --help
keeper shell
```

User-controlled login/MFA happens outside chat. In an authenticated Commander shell:

```text
whoami
help
ls
tree
help record-add
help secrets-manager
```

Metadata can be sensitive too. Do not use full `get`/JSON output just to browse
records. Confirm record/folder sharing model separately from record schema.

## Vault and KSM

Use installed `record-add`, `record-update`, sharing and folder help for classic
operations, or the supported NSF commands for actual nested resources. Inspect
recipients, rights, and expiry before applying shares. Avoid plaintext export.

KSM applications, resource grants, devices, and user shares are distinct:

```text
secrets-manager app list
help secrets-manager
```

Application creation takes a name, not an invented combined `--name` /
`--shared-folder` provisioning operation. Grant required secrets separately.
Device creation emits a token: do it through a secure user-controlled channel.
Do not suggest `--unlock-ip` by default or confuse app-record sharing with giving
the recipient all the underlying secrets.

## Batch mode

After approved authentication and review of a non-secret command file:

```bash
keeper --batch-mode commands.txt
```

Use the positional command-file syntax supported by the installed CLI, not an
invented `--commands-file` option. No credentials in the file; no bulk destructive
commands without an exact approved target list and recovery plan.

## Interactive terminals

Prefer the agent host's supported persistent interactive terminal. Tmux is optional,
not required for KSM or all Commander operations. If needed, use a new private
directory/socket per invocation, check creation failure, and never attach to a
session belonging to another task. Do not key ownership only on workspace or a
second-resolution timestamp. Preserve the exact session handle between calls.

Do not capture authentication prompts or secret-bearing scrollback into the
conversation. On completion close only the task-owned session; enabling persistent
device login has a separate lifetime and requires its own consent/revocation.

## Sources

- [Commander reference](https://docs.keeper.io/keeperpam/commander-cli/command-reference)
- [Configuration and automation](https://docs.keeper.io/keeperpam/commander-cli/commander-installation-setup/configuration)
- [Service Mode](service-mode.md)
