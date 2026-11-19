# Keeper Security Agent Kit

Teach AI coding assistants to choose and safely use Keeper's developer tools,
governed MCP capabilities, Secrets Manager, SDKs, integrations, and administration
workflows. Skills are instructions, not an MCP server or a permission grant.
Installing this kit does not install Keeper software or authorize vault access.

## Choose the right capability

| Your task | Start with | Interface |
| --- | --- | --- |
| Choose tools, install, authenticate, troubleshoot setup | [keeper-setup](plugins/keeper-setup/skills/keeper-setup/SKILL.md) | Task-specific onboarding |
| Give a local AI agent scoped Keeper access | [keeper-mcp](plugins/keeper-mcp/skills/keeper-mcp/SKILL.md) | Keeper Desktop MCP |
| Replace local plaintext configuration, configure developer tools | [keeper-developer](plugins/keeper-developer/skills/keeper-developer/SKILL.md) | Developer Center, Property Files, SSH Agent |
| Inject application secrets from a shell | [keeper-secrets](plugins/keeper-secrets/skills/keeper-secrets/SKILL.md) | KSM CLI (`ksm`) |
| Integrate Keeper into application code | [keeper-sdk](plugins/keeper-sdk/skills/keeper-sdk/SKILL.md) | KSM or Vault/Commander SDK |
| Configure CI/CD, Kubernetes, Terraform, cloud sync, or enterprise integrations | [keeper-integrations](plugins/keeper-integrations/skills/keeper-integrations/SKILL.md) | Purpose-built integrations |
| Manage users, teams, roles, MSP tenants, Vault, or KEPM | [keeper-admin](plugins/keeper-admin/skills/keeper-admin/SKILL.md) | Commander (`keeper`), supported admin interfaces |
| Request privileged access, query databases, launch sessions, rotate credentials | [keeper-pam](plugins/keeper-pam/skills/keeper-pam/SKILL.md) | KeeperPAM and authorized MCP/CLI workflows |

Use supported, authorized MCP tools for local agent operations when appropriate.
Use KSM application/device access for unattended workloads. A denied MCP operation
is **not** permission to fall back to a CLI or broaden access.

### Availability

Developer Center and Property Files are documented as **Preview for Vault 18.7**
as of November 18, 2026. Preview, beta, operating-system support, product versions,
licenses, and policy settings vary. Discover actual tools and permissions; never
infer availability from an installation or a documentation screenshot.
See the [compatibility matrix](docs/compatibility.md) for verification boundaries.

## Prerequisites

Install only what your task needs:

- **Desktop MCP / Property Files:** supported Keeper Desktop version, signed-in
  session, user approval, and permitted capabilities. Do not assume Linux support.
- **KSM:** an application with scoped record/folder access and a bound device
  configuration. CLI installation can use Python or an official installer.
- **Commander / SDKs:** supported runtime or binary and an appropriately scoped
  account. Administration requires the corresponding delegated permissions.
- **KeeperPAM / integrations:** product-specific licenses, connectivity, resources,
  and configuration as documented. An integration catalog card installs nothing.

## Installation

Pick one installation path. Install the skills needed for your workflow, or all
eight for broad coverage. Existing `keeper-secrets`, `keeper-admin`, and
`keeper-setup` names remain compatible.

### Claude Code Marketplace

```text
/plugin marketplace add Keeper-Security/keeper-agent-kit
/plugin install keeper-setup@keeper-security
/plugin install keeper-mcp@keeper-security
/plugin install keeper-developer@keeper-security
```

Install other plugins from the table above using the same naming convention.

### Skills CLI

```bash
npx skills add Keeper-Security/keeper-agent-kit
# Optional: select a client or a user-wide installation
npx skills add Keeper-Security/keeper-agent-kit -a cursor
npx skills add Keeper-Security/keeper-agent-kit -a codex
npx skills add Keeper-Security/keeper-agent-kit -g
```

### Manual installation

Copy the **skill directories**, including their references and examples, not the
outer plugin directories. Review the source and use a reviewed release/ref.

```bash
git clone https://github.com/Keeper-Security/keeper-agent-kit
cd keeper-agent-kit
mkdir -p ~/.claude/skills
cp -r plugins/*/skills/* ~/.claude/skills/
```

| Agent | Typical skills path |
| --- | --- |
| Claude Code | `~/.claude/skills/` |
| Cursor | `~/.cursor/skills/` |
| Codex | `~/.codex/skills/` |
| GitHub Copilot | `~/.github/skills/` |

Other clients, including OpenCode and OpenClaw, may support skills; follow the
client's current installation instructions rather than assuming these paths.
Client skill support and MCP support are separate prerequisites.

## Usage

- "Set up Keeper MCP with read-only access to my development folder."
- "Help me replace my local .env with a Keeper Property File without reading it into chat."
- "Integrate KSM into my Python app; keep credentials out of logs."
- "Choose between the Kubernetes Injector and External Secrets Operator."
- "Query this PAM database read-only and close access when finished."
- "Preview a team membership change before applying it."

See [TEST_PROMPTS.md](TEST_PROMPTS.md) for routing and safety evaluations.

## Security

Never paste credentials into the AI conversation or pass resolved secrets in
command arguments. Confirm high-risk changes, respect policy denials, and scope
access to the task. Secret values can still leak through an authorized consuming
process, application logs, query results, generated files, or Terraform state.
See [SECURITY.md](SECURITY.md) for vulnerability reporting.

## Documentation

- [Developer Center](https://docs.keeper.io/keeperpam/developer-and-mcp/developer-center)
- [Keeper MCP setup](https://docs.keeper.io/keeperpam/developer-and-mcp/ai-agent-access/keeper-mcp-setup)
- [KSM SDKs](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library)
- [Integrations](https://docs.keeper.io/keeperpam/secrets-manager/integrations)
- [Commander](https://docs.keeper.io/keeperpam/commander-cli/overview)
- [Keeper documentation index](https://docs.keeper.io/llms.txt)
- [Compatibility and maintenance](docs/compatibility.md)

## Uninstall

Remove the installed `keeper-*` skill directories or use your client's plugin
uninstaller / Skills CLI. This does not uninstall Keeper software or revoke
devices, persistent sessions, MCP approvals, or mounted destinations. Review and
revoke those separately when no longer needed.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Run validation before submitting changes;
GitHub Actions also validates packages, examples, and regression checks.
Report bugs and requests in [GitHub Issues](https://github.com/Keeper-Security/keeper-agent-kit/issues).

## License

See [LICENSE.md](LICENSE.md).
