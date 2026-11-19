# OpenClaw and Keeper Agent Skills

The Keeper Agent Kit packages instructions for agents, not Keeper software or
permission grants. Use the client's current skill-installation documentation;
skills support and MCP support are independent. This guide does not install or
publish an OpenClaw marketplace package.

## Select the capability

Start with `keeper-setup`. Choose governed Desktop MCP for supported local agent
operations, Developer Center Property Files for supported local configuration,
KSM for unattended secrets delivery, SDKs for application code, and purpose-built
integrations for pipelines/IaC. Commander remains appropriate for supported
administration; `keeper-pam` covers JIT, sessions, queries, and rotation.

## Install and operate

Copy the selected `plugins/<plugin>/skills/<skill>` directory, including references
and examples, into the client's documented skills location. Do not copy only
`SKILL.md` or assume a particular precedence/path without checking the client.
Install only required Keeper products and configure least-privilege access.

For interactive Commander use a supported persistent terminal. Tmux is optional,
not mandatory; use per-invocation private sessions, fail on creation errors, and
never attach to another task's authenticated terminal. Do not read authentication,
tokens, or secret-bearing scrollback into the agent conversation. Close only the
task-owned terminal; device persistent-login consent has a separate lifecycle.

Never bypass a denied MCP capability with Commander, ask for credentials in chat,
or print secrets as a connection test. Verify safe metadata/status, preview
high-risk changes, and let the user handle Keeper approval prompts.

## References

- [Agent kit](https://github.com/Keeper-Security/keeper-agent-kit)
- [Developer Center](https://docs.keeper.io/keeperpam/developer-and-mcp/developer-center)
- [MCP setup](https://docs.keeper.io/keeperpam/developer-and-mcp/ai-agent-access/keeper-mcp-setup)
- [Commander](https://docs.keeper.io/keeperpam/commander-cli/overview)
