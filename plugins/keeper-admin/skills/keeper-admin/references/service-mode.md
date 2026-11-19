# Commander Service Mode

Read [safety.md](safety.md). Service Mode is self-hosted middleware around a
Commander session, not Keeper's public backend API or Desktop MCP.

## Setup and lifecycle

After approved user-controlled authentication:

```text
service-create
service-status
service-start
service-stop
```

Creation can emit an API key; use a secure terminal/output destination and do not
capture it in chat. Subsequent startup loads the configured service. Inspect
installed help for configuration additions, queue modes, Docker setup, and
integration-specific setup commands. Configuration storage requirements can
differ: documented app/Docker setup commands may require local `config.json`
instead of OS keyring storage. Review this tradeoff explicitly with the user.

## Security and behavior

- Dedicated least-privilege service identity and a finite command allowlist.
- TLS, approved network bindings, IP allowlists, rate limits, expiring API keys.
- Separate keys/permissions per integration; protect both local and Vault config.
- Synchronous v1 versus queued asynchronous v2: inspect status rather than
  assuming request acceptance means completion.
- Interactive/session commands and some local file access are intentionally
  blocked. Use documented `FILEDATA` where applicable, not host paths.
- Do not expose public Ngrok/Cloudflare/Tailscale endpoints by default. This is
  separate from encrypted KeeperPAM tunnels.

Documented restrictions include legacy connect/SSH/rotate commands, most PAM
tunnel operations, and local file export/download/run operations. Verify the
current restriction list and integration-specific allowlist; never tunnel around
them or turn off controls to make a request pass.

## Source

[Service Mode REST API](https://docs.keeper.io/keeperpam/commander-cli/service-mode-rest-api)
