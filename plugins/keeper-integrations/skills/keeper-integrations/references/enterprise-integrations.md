# Enterprise Integration Selection

Read [safety.md](safety.md). Distinguish provisioning, approval, incident delivery,
and credential retrieval: similar integration names can describe different products.

| Need | Entry point |
| --- | --- |
| Request/approve access in ITSM | [ServiceNow Workflow](https://docs.keeper.io/keeperpam/secrets-manager/integrations/servicenow-workflow), [Jira Workflow](https://docs.keeper.io/keeperpam/secrets-manager/integrations/jira-workflow), [Freshservice Workflow](https://docs.keeper.io/keeperpam/secrets-manager/integrations/freshservice-workflow) |
| Incident/event ingestion | [ServiceNow ITSM](https://docs.keeper.io/keeperpam/secrets-manager/integrations/servicenow-itsm), [Jira ITSM](https://docs.keeper.io/keeperpam/secrets-manager/integrations/jira-itsm), [Freshservice ITSM](https://docs.keeper.io/keeperpam/secrets-manager/integrations/freshservice-itsm) |
| ChatOps approvals | [Slack](https://docs.keeper.io/keeperpam/secrets-manager/integrations/slack-app), [Teams](https://docs.keeper.io/keeperpam/secrets-manager/integrations/teams-app), [Google Chat](https://docs.keeper.io/keeperpam/secrets-manager/integrations/google-chat-app) |
| Identity governance | [SailPoint SaaS](https://docs.keeper.io/keeperpam/secrets-manager/integrations/sailpoint-saas-connector), [SailPoint IIQ](https://docs.keeper.io/keeperpam/secrets-manager/integrations/sailpoint-iiq-connector) |
| Credential retrieval for ServiceNow MID | [Credential Resolver](https://docs.keeper.io/keeperpam/secrets-manager/integrations/servicenow) |
| SSO/SCIM provisioning | [Enterprise provisioning](https://docs.keeper.io/enterprise-guide/user-and-team-provisioning) |
| ARAM / SIEM | [Event reporting](https://docs.keeper.io/enterprise-guide/event-reporting) |

## Setup checklist

1. Establish tenant/MC context and required product/license/version.
2. Choose the official integration and inspect its authentication/backend model.
   Some use Commander Service Mode; others use scoped KSM or event endpoints.
3. Preview permissions, supported actions, callback/webhook audiences, and users.
4. Deliver credentials securely, restrict endpoint/network access, and verify
   webhook authenticity as documented; never invent signing or token semantics.
5. Test with a synthetic event or nonproduction request. Do not auto-approve a real
   access request, grant a role, or distribute secret-bearing incident payloads.
6. Verify safe status/audit delivery, redact logs, and document key rotation and
   deprovisioning. Respect integration-specific command allowlists.

No integration setup authorizes an AI agent to approve itself or bypass PAM,
MCP, enterprise policy, or the third-party platform's permissions.
