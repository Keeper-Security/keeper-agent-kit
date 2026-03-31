# Keeper Security Agent Kit for AI Agents

Teach AI coding agents to use **Keeper Secrets Manager (KSM)** and **Keeper Commander** from the terminal: retrieve and inject secrets, manage vaults, and run enterprise admin workflows-without putting credentials in chat or source control.

---

## What you get

| Skill | Use it for | CLI |
| --- | --- | --- |
| `keeper-secrets` | App secrets, `ksm exec`, templates, CI/CD | `ksm` |
| `keeper-admin` | Users, teams, PAM, enterprise vault ops | `keeper` |
| `keeper-setup` | Install CLIs, profiles, first-time setup | Both |

Each skill ships with **reference docs** under `skills/*/references/` (command lists, Keeper notation, patterns for Docker/Kubernetes/CI).

---

## Prerequisites

- A [Keeper Security](https://keepersecurity.com) account
- **KSM (`keeper-secrets`):** Python 3.10+ (or a binary release); a Secrets Manager **Application** and **Client Device** in the vault when you use `ksm`
- **Commander (`keeper-admin`):** Python 3.10+; your Keeper account (and 2FA if enabled)
- macOS, Linux, or Windows (WSL recommended on Windows)

**Install and configure the CLIs** using Keeper’s documentation ([KSM CLI](https://docs.keeper.io/en/keeperpam/secrets-manager/overview), [Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview)). The `keeper-setup` skill also guides first-time setup.

---

## Installation

Pick **one** path. Official paths may require the plugin to be listed in each marketplace.

### Claude Code (plugin)

```bash
/plugin marketplace add Keeper-Security/agent-kit
/plugin install keeper-secrets@keeper-security
```

### Any agent (Vercel Skills CLI)

```bash
npx skills add Keeper-Security/agent-kit
```

Optional flags:

```bash
npx skills add Keeper-Security/agent-kit -a cursor    # target one agent
npx skills add Keeper-Security/agent-kit -g           # global install
```

### Manual (copy skills into the agent’s skills folder)

Clone the repo, then copy the three skill folders to **your** agent’s skills directory (create it if needed):

```bash
git clone https://github.com/Keeper-Security/agent-kit
cd agent-kit
```

| Agent | Typical skills path |
| --- | --- |
| Claude Code | `~/.claude/skills/` |
| Cursor | `~/.cursor/skills/` |
| Codex | `~/.codex/skills/` |
| GitHub Copilot | `~/.github/skills/` |

```bash
# example: Claude Code
mkdir -p ~/.claude/skills
cp -r skills/keeper-secrets skills/keeper-admin skills/keeper-setup ~/.claude/skills/
ls ~/.claude/skills/
```

Repeat for each agent you use; paths differ per product.

### Verification

```bash
ls ~/.claude/skills/keeper-*   # adjust path for your agent
```

In the agent, try prompts like: *“Help me inject secrets from Keeper into my app”* (should lean on `keeper-secrets`) or *“How do I set up KSM?”* (`keeper-setup`). For more structured smoke tests, see [TEST_PROMPTS.md](TEST_PROMPTS.md).

### Uninstall

Remove the skill directories from that agent’s `skills` folder, or with Vercel Skills: `npx skills remove keeper-secrets` (and the other two). To remove the Keeper CLIs from your machine, follow the uninstall guidance in the [KSM CLI](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) and [Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview) docs.

---

## Documentation

**Keeper (install, configure, command reference):**

- [KSM CLI](https://docs.keeper.io/en/keeperpam/secrets-manager/overview) - install, profiles, commands  
- [Commander CLI](https://docs.keeper.io/en/keeperpam/commander-cli/overview) - install, shell, admin commands  
- [Keeper notation](https://docs.keeper.io/en/keeperpam/secrets-manager/about/keeper-notation) - `keeper://` references for secrets  

---

## Security

The **[Keeper Security](https://keepersecurity.com)** agent kit is documentation for agents: it should **not** encourage pasting secrets into chat. Operations use Keeper’s authentication and OS-backed storage where configured.

- [SECURITY.md](SECURITY.md) - how to report vulnerabilities  
- Design notes: avoid logging secrets; use one-time tokens and least privilege for KSM apps  

---

## Contributing

We welcome issues and pull requests.

1. Check [existing issues](https://github.com/Keeper-Security/agent-kit/issues) before filing a new one.  
2. For changes: fork, branch, keep edits focused; follow [CONTRIBUTING.md](CONTRIBUTING.md) (frontmatter for `SKILL.md`, no real secrets in examples, `pre-commit run --all-files` and `task fmt` after [development setup](CONTRIBUTING.md#development-setup)).  
3. Pull requests should describe **what** changed and **why**, and note how you tested.

Details: **[CONTRIBUTING.md](CONTRIBUTING.md)** (code of conduct, docs standards, PR checklist).

---

## License

Licensed under the **Apache License, Version 2.0**. You may use, modify, and distribute this project under those terms.

Full text: **[LICENSE](LICENSE.md)**.

---

## Support

- **Issues & features:** [github.com/Keeper-Security/agent-kit/issues](https://github.com/Keeper-Security/agent-kit/issues)  
- **Keeper Security Support:** [keepersecurity.com/support](https://keepersecurity.com/support)  
- **Docs:** [docs.keeper.io](https://docs.keeper.io)  

---

## Compared to 1Password CLI–style skills

| Capability | Typical 1Password skill | Keeper |
| --- | --- | --- |
| CLIs | `op` | `ksm` + `keeper` |
| Developer injection | `op run` / inject | `ksm exec` / `ksm interpolate` |
| Enterprise admin | Limited | Commander (users, teams, KSM apps, PAM, etc.) |
| PAM / rotation | Varies | Documented in `keeper-admin` references |
| Agent distribution | Often one channel | Claude Code plugin + Vercel Skills (many agents) |

The **[Keeper Security](https://keepersecurity.com)** agent kit covers **both** developer (KSM) and admin (Commander) paths in one place.
