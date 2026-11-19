# Compatibility and Verification

Last reviewed: **November 18, 2026**. This kit teaches workflows; it does not grant
permissions, bundle product binaries, or make every described feature available.
Always verify installed versions, capabilities, schemas, licenses, and account policy.

## Capability Matrix

| Surface | Verification / availability | Required runtime or controls |
| --- | --- | --- |
| Developer Center / Property Files | Public guide labels Preview for Vault 18.7 | Supported Desktop version/channel/distribution and mount prerequisites; do not assume Linux/web/mobile mounts |
| Keeper Desktop MCP | Public setup uses local stdio and signed-in Desktop; actual tools are runtime-discovered | Connection consent plus specific capability/resource scope; beta/platform gates vary |
| Enterprise AI controls/reporting | Documented feature area, not verified deployed for every initial preview build | Verify actual release/policy/UI coverage; do not promise a complete audit event set |
| KSM CLI | Parser checks against published **1.5.0**, no callbacks/network | Python 3.10+ for this tested package; official binaries have separate requirements |
| KSM Python example | API-signature and mock checks against **17.3.0** | Already bound private SDK JSON config; runtime requirement depends on package |
| KSM TypeScript example | Type checking and mock tests against **17.6.0** | Node; dependencies and dev tools pinned in example lockfile |
| Other KSM languages | Public guide entry points reviewed; no runnable examples tested here | Verify per-language APIs, config protection, cache/timeout/link behavior |
| Commander CLI / Service Mode | Public docs and fetched default-branch command registrations reviewed | Supported login/identity, delegated rights, finite API command allowlist and secure hosting |
| Vault/Commander SDKs | Public SDK docs and language-family distinctions reviewed | No cross-language parity promise; verify published package/API and auth model |
| PAM / JIT / database queries | Public workflow prerequisites reviewed | Resource/configuration/Gateway/linked credentials, access approval, query guardrails and DB permissions |
| Universal Secrets Sync | Public guide covers Gateway-based AWS/Azure/GCP/GitHub/HashiCorp push | Applicable PAM license, Gateway/application/configuration, Sync Identity, enforcement permission |
| CI/CD / IaC / enterprise integrations | Public official setup links and safety checklists | Pin chosen integration; live setup is not tested by this repository's CI |

## Source Evidence

Public documentation is navigable from [llms.txt](https://docs.keeper.io/llms.txt).
The following default refs were fetched successfully on November 18, 2026;
local modifications were **not** included. Default branch is not production.

| Repository / ref | Full commit | Successful fetch (UTC) | Evidence |
| --- | --- | --- | --- |
| secrets-manager / origin/master | `b2c1c4ffc4a67966d68b739038df0e470f374f72` | 19:41:33 | [CLI parser](https://github.com/Keeper-Security/secrets-manager/blob/b2c1c4ffc4a67966d68b739038df0e470f374f72/integration/keeper_secrets_manager_cli/keeper_secrets_manager_cli/__main__.py) |
| Commander / origin/master | `b92a3706eaa802903d43abd64385d5077def1944` | 19:41:31 | [Service commands](https://github.com/Keeper-Security/Commander/blob/b92a3706eaa802903d43abd64385d5077def1944/keepercommander/commands/start_service.py), [NSF registration](https://github.com/Keeper-Security/Commander/blob/b92a3706eaa802903d43abd64385d5077def1944/keepercommander/commands/nested_share_folder/__init__.py) |

Parser tests check the published KSM package as well as source-reviewed syntax.
Newer AWS CLI sync options and additional MCP beta operations are deliberately
described as discover-and-verify, not assumed available in these pinned packages.
No live vault, target rotation, database, or tenant mutation was used to validate
the kit. Mock tests and metadata lint do not establish deployment or authorization.

## Maintenance

- Required CI checks packages, safe examples, relative links, and pinned API/parser contracts.
- Scheduled/manual upstream checks flag missing public documentation links and
  changed package versions for review. They never auto-publish or upgrade dependencies.
- Before changing versions, run the adapter/parser tests and the manual cases in
  [../TEST_PROMPTS.md](../TEST_PROMPTS.md); update this evidence matrix.
- Reconfirm Desktop preview/beta status, platforms, and controls before removing gates.
- Copy [safety.md](safety.md) into every independently installable skill; validation checks identity.
