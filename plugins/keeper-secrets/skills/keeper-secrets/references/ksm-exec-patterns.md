# Secret Delivery Patterns

Read [safety.md](safety.md). Choose delivery by runtime and identity; do not force
every workflow through `ksm exec` or create plaintext files by default.

## Local application

```bash
API_KEY='keeper://<RECORD_UID>/field/password' ksm exec -- ./myapp
```

Use a pre-bound application/profile and an approved executable. Do not dump child
environments, turn on shell tracing, print secret lengths/hashes for diagnostics,
or pass resolved secrets through shell substitutions. A process can still expose
its environment or log values; use a trusted consumer and least-privilege identity.

Local applications that require files may fit Developer Center Property Files.
Prefer user-approved supported mounts over generating plaintext `.env` files.
Without Desktop or for unattended runtimes, select KSM SDK/CLI or an integration.

## CI/CD

Use the platform's documented Keeper integration where appropriate. For an
explicit CLI wrapper, deliver bound configuration using the platform's protected
credential mechanism. Do not assume every CLI installation consumes the same
`KSM_CONFIG` variable or accepts an INI profile encoded as SDK JSON.

Pin dependencies, disable tracing, prevent secrets/config from entering artifacts,
and verify application success without printing values. Untrusted pull requests
must not inherit production application credentials.

## Containers and Kubernetes

Install the chosen CLI/package in the image, but deliver credentials at runtime.
Never put tokens/config in Docker build arguments, layers, or committed manifests.
Review exposure from container inspection and host environment access.

For Kubernetes choose between the Injector, External Secrets Operator, and direct
KSM access. Mounted runtime files, child environment variables, and Kubernetes
Secret resources have different persistence and refresh behavior. Confirm RBAC,
namespace, config delivery, and rotation behavior. See the integration guides;
do not print injected files with `kubectl exec ... cat` as verification.

## Explicit plaintext file delivery

```bash
(umask 077; ksm interpolate config.tmpl -o /approved/private/config.yaml)
```

Obtain approval for the path, check existing files/symlinks before writing, and
arrange restricted permissions and retention. The process's umask does not fix
permissions of an existing permissive file. Do not create plaintext backups,
`source`/`eval` the result, or capture stdout. Delete only the exact task-owned file
after use; never recursively delete a user's configuration directory.

## Sources

- [Exec](https://docs.keeper.io/keeperpam/secrets-manager/secrets-manager-command-line-interface/exec-command)
- [Integrations](https://docs.keeper.io/keeperpam/secrets-manager/integrations)
- [Property Files](https://docs.keeper.io/keeperpam/developer-and-mcp/overview)
