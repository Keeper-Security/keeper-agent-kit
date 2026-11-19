---
name: keeper-integrations
description: Choose Keeper CI/CD, Kubernetes, Terraform, Ansible, IDE, cloud sync, ITSM, ChatOps, IGA, and SIEM integrations. Distinguish direct KSM retrieval, CLI sync, and Universal Secrets Sync.
---

# Keeper Integrations

## Workflow

Read [references/safety.md](references/safety.md). Identify the platform, workload
identity, intended secret destination, and whether the task reads data, provisions
access, synchronizes values, or requests approval. A catalog card links to setup
documentation; it does not install software or authorize an agent.

1. Prefer an appropriate supported integration over handwritten credential scripts.
2. Read that integration's official setup, runtime requirements, and current schema.
3. Scope application/device or service-account permissions to the workload.
4. Preview configuration, affected environments, persistence, and deletion behavior.
5. Let the user/admin deliver bootstrap credentials through a secure channel.
6. Verify with synthetic credentials or safe application status, not secret output.
7. Document revocation, rotation refresh behavior, cleanup, and ownership.

## Choose the integration

| Workflow | Choices / distinction |
| --- | --- |
| CI/CD | GitHub Actions, GitLab, Azure DevOps, Jenkins and other documented plugins; pin versions and protect runner output |
| Kubernetes | Injector runtime delivery vs External Secrets Operator persisted Kubernetes Secrets vs direct SDK/CLI retrieval |
| Terraform | KSM secret data access vs Commander Service Mode tenant administration; these are distinct providers |
| Configuration management | Ansible collection; keep secrets out of task output, facts, caches, and diffs |
| Local developer tools | VS Code, JetBrains, SSH Agent/Git signing, PowerShell; see **keeper-developer** |
| Cloud stores | Direct KSM, CLI sync, or Gateway-based Universal Secrets Sync; see below |
| ITSM / ChatOps | ServiceNow, Jira, Freshservice, Slack, Teams, Google Chat; distinguish access approvals from incident ingestion |
| Identity governance | SailPoint and supported SSO/SCIM flows; verify delegated admin permissions |
| Audit / SIEM | ARAM/event reporting prerequisites and destination-specific setup |

Read [references/devops-recipes.md](references/devops-recipes.md) for CI/CD,
Kubernetes, Terraform, and Ansible. Read
[references/enterprise-integrations.md](references/enterprise-integrations.md)
for ITSM, ChatOps, identity governance, and reporting.

## Secret delivery and cloud sync

| Model | Execution and tradeoff |
| --- | --- |
| Direct KSM SDK/CLI | Workload uses scoped device credentials to retrieve from Keeper |
| `ksm sync` | Explicit one-way CLI write into an external store; mapping/dependencies and schedule are operator-managed |
| Universal Secrets Sync (USS) | Gateway-based automatic pushes from Keeper to configured providers; PAM prerequisites and dedicated Sync Identity |
| Native cloud retrieval after USS | App uses cloud SDK/IAM; cloud copies and permissions must also be governed |

USS documents AWS Secrets Manager, Azure Key Vault, Google Cloud Secret Manager,
GitHub Actions, and HashiCorp Vault. It requires applicable licensing, a registered
Gateway and associated KSM application, supported configuration/identity, and
permission to configure USS. Review folders, names, regions, least-privilege
identity, and dry-run results before automatic sync. Initial migration/import is
a separate operation. Do not promise bidirectional conflict resolution.

Read [references/cloud-sync.md](references/cloud-sync.md). CLI sync output modes
can reveal values; avoid capturing JSON plans or secret-bearing diagnostics.

## Guardrails

Secrets may persist in generated files, CI artifacts, Kubernetes Secrets, cloud
stores, Terraform state/plan files, or integration configuration. `sensitive`
marking, masking, and base64 encoding do not eliminate that risk. Never print
secrets for verification, install unrestricted webhook endpoints, or broaden
policies to bypass an access denial. Pin official integration versions.

## Sources

- [Integration catalog](https://docs.keeper.io/keeperpam/secrets-manager/integrations)
- [Universal Secrets Sync](https://docs.keeper.io/keeperpam/privileged-access-manager/universal-secrets-sync)
- [Enterprise integrations](https://docs.keeper.io/enterprise-guide/integrations)
