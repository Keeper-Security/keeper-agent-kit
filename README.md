# Keeper Security Agent Kit for AI Agents

Teach AI coding agents to use **Keeper Secrets Manager (KSM)** and **Keeper Commander** from the terminal: retrieve and inject secrets, manage vaults, and run enterprise admin workflows-without putting credentials in chat or source control.

---

## What you get

| Plugin | Use it for | CLI |
| --- | --- | --- |
| [keeper-secrets](plugins/keeper-secrets/skills/keeper-secrets/SKILL.md) | App secrets, `ksm exec`, templates, CI/CD | `ksm` |
| [keeper-admin](plugins/keeper-admin/skills/keeper-admin/SKILL.md) | Users, teams, PAM, enterprise vault ops | `keeper` |
| [keeper-setup](plugins/keeper-setup/skills/keeper-setup/SKILL.md) | Install CLIs, profiles, first-time setup | Both |

---

## Prerequisites

- A [Keeper Security](https://keepersecurity.com) account
- [KSM CLI](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) (plugin: `keeper-secrets`)
- [Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview) (plugin: `keeper-admin`)
- Python 3.10+
- Linux, Windows, Mac OS

The `keeper-setup` skill will guide you through first-time setup if you don't have the CLIs installed.

---

## Installation

To install the Keeper Security Agent Kit, pick **one** path.

### Claude Code Marketplace

```bash
/plugin marketplace add Keeper-Security/keeper-agent-kit
/plugin install keeper-secrets@keeper-security
```

### Any agent via Vercel Skills CLI

```bash
# Add the Keeper Security Agent Kit
npx skills add Keeper-Security/keeper-agent-kit
```

Combine with optional flags to target a specific agent or install globally:

```bash
# target agent: cursor
npx skills add Keeper-Security/keeper-agent-kit -a cursor
# target agent: claude-code
npx skills add Keeper-Security/keeper-agent-kit -a claude-code
# target agent: codex
npx skills add Keeper-Security/keeper-agent-kit -a codex
# global install
npx skills add Keeper-Security/keeper-agent-kit -g
```

### Manual installation

Clone the repo, then copy the plugin folders to **your** agent’s skills directory (create it if needed):

```bash
git clone https://github.com/Keeper-Security/keeper-agent-kit
cd keeper-agent-kit
```

| Agent | Typical skills path |
| --- | --- |
| Claude Code | `~/.claude/skills/` |
| Cursor | `~/.cursor/skills/` |
| Codex | `~/.codex/skills/` |
| GitHub Copilot | `~/.github/skills/` |

#### Example manual installation for Claude Code

>NOTE: You may also create this at the project level by using `./.claude/skills/` instead of `~/.claude/skills/`.

```bash
mkdir -p ~/.claude/skills
cp -r plugins/*/skills/* ~/.claude/skills/
ls ~/.claude/skills
```

Repeat for each agent you use; paths differ per product.

## Usage

In the agent, try prompts like: *“Help me inject secrets from Keeper into my app”* (should lean on `keeper-secrets`) or *“How do I set up KSM?”* (`keeper-setup`).

For more structured smoke tests, see [TEST_PROMPTS.md](TEST_PROMPTS.md).

## Uninstall

Remove the skill directories from that agent’s `skills` folder, or with Vercel Skills: `npx skills remove keeper-secrets` (and the other two). To remove the Keeper CLIs from your machine, follow the uninstall guidance in the [KSM CLI](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) and [Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview) docs.

---

## Documentation

- **[KSM CLI](https://docs.keeper.io/en/keeperpam/secrets-manager/overview)** - install, profiles, commands  
- **[Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview)** - install, shell, admin commands  
- **[Keeper notation](https://docs.keeper.io/en/keeperpam/secrets-manager/about/keeper-notation)** - `keeper://` references for secrets  
- **[Issues & features](https://github.com/Keeper-Security/keeper-agent-kit/issues)**
- **[Keeper Security Support](https://keepersecurity.com/support)**
- **[Docs](https://docs.keeper.io)**

---

## Security

Security is a top priority. The **[SECURITY.md](SECURITY.md)** file contains information on how to report vulnerabilities.

## Contributing

We welcome issues and pull requests.

1. Check [existing issues](https://github.com/Keeper-Security/keeper-agent-kit/issues) before filing a new one.  
2. For changes: fork, branch, keep edits focused; follow [CONTRIBUTING.md](CONTRIBUTING.md).
3. Pull requests should describe **what** changed and **why**, and note how you tested.

---

## License

Licensed is provided in the **[LICENSE](LICENSE.md)** file.
