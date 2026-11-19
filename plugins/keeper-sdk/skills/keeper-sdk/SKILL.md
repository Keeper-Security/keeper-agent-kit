---
name: keeper-sdk
description: Integrate Keeper into application code using KSM or Vault/Commander SDKs. Choose the correct language, authentication model, package, and verified API without logging secrets.
---

# Keeper SDK Development

## Select the SDK family

| Requirement | Family |
| --- | --- |
| Application/CI workload retrieves scoped secrets without human Vault login | **KSM SDK** |
| Vault CRUD, sharing, enterprise users/roles/teams, or supported PAM automation | **Vault/Commander SDK** |
| Existing shell script needs runtime injection | **keeper-secrets**, not a new SDK integration |
| Local AI agent uses existing governed operations | **keeper-mcp**, not a custom credential reader |

Read [references/safety.md](references/safety.md) before writing code. User
confirmation does not substitute for backend authorization. Do not bypass MCP
restrictions with custom SDK code.

## Language coverage

KSM documents Python, Java/Kotlin, JavaScript/TypeScript, .NET, Go, Ruby, Rust, and
PowerShell integration. These are not the same packages as the Vault SDKs.

Vault/Commander options include the original Python Commander library, the newer
Python `keepersdk` / `keepercli`, .NET SDK / PowerCommander, and additional
language implementations. Verify release maturity and API coverage individually;
do not imply universal CLI/SDK feature parity or confuse the KSM Rust SDK with a
Vault/Commander Rust implementation.

Read [references/languages.md](references/languages.md) for language entry points.
Use the installed package's types/help and official version-specific examples.

## Workflow

1. Identify language/runtime, workload identity, region, and minimum record scope.
2. Choose a published package/version, using the project's dependency manager and
   lockfile. Do not overwrite existing dependencies or upgrade everything.
3. Arrange user/admin-controlled bootstrap. A KSM one-time token binds durable
   credentials on the first supported access call; construction alone may not
   complete binding. Remove bootstrap tokens after success.
4. Protect bound configuration with a documented storage backend. Base64 is not
   encryption. Do not copy INI CLI profiles into an SDK JSON storage adapter.
5. Fetch only needed records/fields, handle missing or ambiguous records, and
   pass values directly to the intended API/client in memory.
6. Test with synthetic credentials and mocks before approved live read-only tests.
   Check failures/partial results without logging records or exception payloads.

## Examples

The packaged [Python example](examples/python/keeper_secret.py) and
[TypeScript example](examples/typescript/keeper-secret.ts) return a selected
password to a consuming application; neither prints it or performs bootstrap.
Both require an existing bound KSM JSON configuration and an exact record UID.
See [references/examples.md](references/examples.md) for installation and tests.

These samples are building blocks, not an excuse for an agent to execute a secret
read and capture its return value. Integrate them into the authorized application.

## Advanced concerns

- **PAM links:** request linked credentials explicitly when needed. Resource and
  credential records differ; link accessors and typed helpers vary by version and
  language. Do not infer that an empty links collection means no links exist if
  links were never requested.
- **Updates:** verify edit permissions, refresh record revision before subsequent
  writes, and inspect each item in a batch/partial response.
- **Rotation:** changing a record's password is not target-system rotation. Use
  supported PAM workflows unless a separately reviewed transactional integration
  is explicitly required.
- **Cache/timeouts:** check SDK-specific semantics and stale-data policy. A
  per-attempt network timeout is not necessarily an end-to-end deadline. Do not
  cache a bootstrap token or credentials in a global temporary path.
- **Protection:** use documented keyring, AWS KMS, Azure, GCP, Oracle, or HSM
  integrations where supported, rather than custom encryption/key handling.

## Guardrails

Never log passwords, tokens, full records, config files, or backend exception
objects. Do not disable TLS verification, put credentials in URLs/argv, embed
master passwords in scripts, or retry non-idempotent mutations blindly.

## Sources

- [KSM SDK library](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library)
- [Vault SDKs](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library/vault-sdks)
- [Commander SDKs](https://docs.keeper.io/keeperpam/commander-sdk/keeper-commander-sdks)
- [Linked credentials](https://docs.keeper.io/keeperpam/secrets-manager/about/linked-credentials)
