# SDK Language Selection

Read [safety.md](safety.md). Choose a **family** before choosing a language.

## KSM: application/device-scoped secrets

| Language | Official guide |
| --- | --- |
| Python | [Python SDK](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library/python-sdk) |
| Java / Kotlin | [Java SDK](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library/java-sdk) |
| JavaScript / TypeScript | [JavaScript SDK](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library/javascript-sdk) |
| .NET | [.NET SDK](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library/.net-sdk) |
| Go | [Go SDK](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library/golang-sdk) |
| Ruby | [Ruby SDK](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library/ruby-sdk) |
| Rust | [Rust SDK](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library/rust-sdk) |
| PowerShell | [KSM SecretManagement plugin](https://docs.keeper.io/keeperpam/secrets-manager/integrations/powershell-plugin) |

Packages include Python `keeper-secrets-manager-core` and npm
`@keeper-security/secrets-manager-core`. These are not Python `keepersdk` or npm
`@keeper-security/keeper-sdk-javascript`. Use each guide to verify current package
names, runtimes, storage adapters, notation, error types, caching, and timeout APIs.

## Vault / Commander: user-session and administrative automation

- [Commander SDKs](https://docs.keeper.io/keeperpam/commander-sdk/keeper-commander-sdks):
  Python `keepersdk`, original Python Commander as a library, .NET, PowerCommander.
- [Vault SDK index](https://docs.keeper.io/keeperpam/secrets-manager/developer-sdk-library/vault-sdks):
  public entry points and additional language implementations.
- [Python Commander as a library](https://docs.keeper.io/keeperpam/commander-cli/commander-installation-setup/developer-mode/commander-cli-as-sdk).

Do not assume equivalent classes, CLI flags, authentication, NSF support, enterprise
coverage, or PAM features across implementations. Additional SDKs must be verified
against their published release before recommending installation. A repository
README or merged change is not proof of a supported deployment.

## Link and configuration differences

[PAM linked credentials](https://docs.keeper.io/keeperpam/secrets-manager/about/linked-credentials)
are opt-in. Typed helpers have evolved independently across languages/releases;
check the installed API instead of copying one language's helper names to another.
File attachments and PAM resource links are separate relationships.

Bound configuration is durable credential material. Protect the config/cache and
use supported storage adapters; never assume OS keyring defaults apply to every
SDK. User-session persistent login must comply with enterprise policy.
