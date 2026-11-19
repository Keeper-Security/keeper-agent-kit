# DevOps Integration Recipes

Read [safety.md](safety.md). These are setup checklists, not assumed API schemas.
Fetch the selected integration's current official example before generating config.

## CI/CD

1. Choose the platform's Keeper integration, a direct SDK, or explicit CLI wrapper.
2. Create an application scoped to the environment and required records; provision
   a device per intended workload rather than sharing a production bootstrap token.
3. Deliver bound configuration through the platform's protected credentials store.
4. Pin the official action/plugin or image. For GitHub Actions use a reviewed
   commit SHA, least-privilege job permissions, and trusted event/runner boundaries.
5. Map selected notation references to the consuming step. Disable tracing and
   value printing; avoid outputs/artifacts unless their sensitivity is understood.
6. Verify application status using synthetic credentials first. Document revocation,
   rotation refresh, cleanup, and runner/config retention.

Sources: [GitHub Actions](https://docs.keeper.io/keeperpam/secrets-manager/integrations/github-actions),
[GitLab](https://docs.keeper.io/keeperpam/secrets-manager/integrations/gitlab-plugin),
[Azure DevOps](https://docs.keeper.io/keeperpam/secrets-manager/integrations/azure-devops-plugin),
[Jenkins](https://docs.keeper.io/keeperpam/secrets-manager/integrations/jenkins-plugin).

## Kubernetes

| Choice | Use / persistence |
| --- | --- |
| Secrets Injector | Runtime delivery into supported files/env/Secret modes; choose mode and refresh behavior explicitly |
| External Secrets Operator | Synchronizes into Kubernetes Secret objects; etcd, RBAC, encryption at rest, and controllers become part of the boundary |
| Direct SDK/CLI | App owns retrieval, storage, refresh, and failures |

Confirm namespace/RBAC, admission webhook/controller permissions, pod selection,
runtime delivery mode, existing auth Secret, and image/chart version. Do not put
config values in `kubectl --from-literal` arguments or committed manifests; use a
supported protected file/store flow. Kubernetes base64 is not encryption.
Sidecar file refresh does not imply an existing process's environment is refreshed.
Verify with readiness/application status, not `cat` or `printenv`. Remove only
task-owned resources and revoke the device when retiring the workload.

Sources: [Injector](https://docs.keeper.io/keeperpam/secrets-manager/integrations/kubernetes-secrets-injector),
[External Secrets Operator](https://docs.keeper.io/keeperpam/secrets-manager/integrations/kubernetes-external-secrets-operator).

## Terraform

The **KSM provider** supplies secret access using scoped application/device config.
The **Commander provider** manages tenant/MSP configuration through Commander
Service Mode, requiring dedicated session/API-key/command permissions.
Do not copy one provider's configuration or credentials to the other.

Preview exact resources, tenant/MC context, drift, and deletions before apply.
Pin providers. Secret values can persist in state and saved plans even if marked
`sensitive`; protect the backend, encryption, access, logs, plan artifacts, and
retention. Never use plan output as a secret verification step. Prefer runtime
delivery when infrastructure provisioning does not need a secret value.

Sources: [KSM Terraform](https://docs.keeper.io/keeperpam/secrets-manager/integrations/terraform),
[Commander Terraform](https://docs.keeper.io/keeperpam/secrets-manager/integrations/terraform-provider-commander).

## Ansible

Use the official collection and scoped bound configuration. Apply `no_log: true`
to secret-bearing tasks; avoid `debug`, fact caches, diff output, and callback
plugins that reveal values. Check collection-version-specific redaction/check-mode
behavior, do not treat `no_log` as complete protection for later consumers.
Preview hosts/environment and writes; clean up only files created for this task.

Source: [Ansible](https://docs.keeper.io/keeperpam/secrets-manager/integrations/ansible).
