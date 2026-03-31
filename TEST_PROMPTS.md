# Test Prompts for Skill Activation

Use these prompts to verify that skills are properly loaded and AI agents recognize when to use them.

## keeper-secrets Activation Tests

### Should Trigger keeper-secrets

✅ These prompts should activate the keeper-secrets skill:

1. **"I need to pull a database password from Keeper for my app"**
   - Keywords: Keeper, password, database
   - Expected: keeper-secrets suggestion for KSM CLI usage

2. **"How do I inject secrets into my Docker container using Keeper?"**
   - Keywords: Keeper, secrets, Docker, inject
   - Expected: keeper-secrets with docker/ksm exec examples

3. **"Set up ksm exec to pass API keys to my Node.js server"**
   - Keywords: ksm exec, API keys
   - Expected: keeper-secrets with ksm exec patterns and examples

4. **"List all secrets available to my KSM application"**
   - Keywords: KSM application, secrets
   - Expected: keeper-secrets with `ksm secret list` command

5. **"Interpolate Keeper secrets into my kubernetes config template"**
   - Keywords: Keeper secrets, interpolate, kubernetes
   - Expected: keeper-secrets with ksm interpolate and K8s patterns

6. **"Use keeper notation to reference the password field"**
   - Keywords: keeper notation, password field
   - Expected: keeper-secrets with Keeper notation reference

7. **"I'm setting up CI/CD and need to inject database credentials"**
   - Keywords: CI/CD, credentials, inject
   - Expected: keeper-secrets with ksm exec and CI/CD patterns

8. **"How do I rotate passwords stored in Keeper?"**
   - Keywords: rotate, passwords, Keeper
   - Expected: keeper-secrets for simple rotations, keeper-admin for automated

9. **"Generate a secure password and store it in Keeper"**
   - Keywords: generate password, store, Keeper
   - Expected: keeper-secrets with `ksm secret password` and create commands

### Should NOT Trigger keeper-secrets

❌ These prompts should NOT activate keeper-secrets:

1. **"What's the weather today?"**
   - No keeper/secrets keywords
   - Expected: No skill suggestion

2. **"Help me write a Python script"**
   - Generic programming (unless combined with keeper context)
   - Expected: No skill suggestion (or general assistance)

3. **"Set up 1Password CLI for my app"**
   - Competitor tool
   - Expected: No keeper skill suggestion

4. **"I need to manage users in Keeper and assign them to teams"**
   - Enterprise admin operation
   - Expected: keeper-admin, not keeper-secrets

## keeper-admin Activation Tests

### Should Trigger keeper-admin

✅ These prompts should activate the keeper-admin skill:

1. **"Create a new KSM application in Keeper for our staging environment"**
   - Keywords: KSM application, create, Keeper admin
   - Expected: keeper-admin with secrets-manager app commands

2. **"Add a user to our Keeper enterprise and assign them to the Engineering team"**
   - Keywords: add user, enterprise, team
   - Expected: keeper-admin with enterprise-user and enterprise-team commands

3. **"Set up password rotation for our database credentials in Commander"**
   - Keywords: password rotation, Commander, automated
   - Expected: keeper-admin with pam rotation commands

4. **"Export our vault records to JSON for backup"**
   - Keywords: export vault, JSON, backup
   - Expected: keeper-admin with import/export commands

5. **"Approve pending device requests in Keeper"**
   - Keywords: device approval, Keeper admin
   - Expected: keeper-admin with device-approve commands

6. **"Lock a user account that's no longer with the company"**
   - Keywords: lock user, account management
   - Expected: keeper-admin with enterprise-user lock command

7. **"Set up SAML SSO for our Keeper enterprise"**
   - Keywords: SAML, SSO, enterprise configuration
   - Expected: keeper-admin with SSO/SAML configuration

8. **"I need to set enforcement policies for master passwords"**
   - Keywords: enforcement, policies, master password
   - Expected: keeper-admin with enterprise-role enforcement commands

9. **"Launch an SSH session to our production server through Keeper PAM"**
   - Keywords: SSH session, PAM, production
   - Expected: keeper-admin with `connect` and PAM commands

10. **"List all privileged access gateways and their status"**
    - Keywords: gateways, privileged access, PAM
    - Expected: keeper-admin with `pam gateway list`

### Should NOT Trigger keeper-admin

❌ These prompts should NOT activate keeper-admin:

1. **"I need the database password to connect to prod"**
   - Developer secret retrieval, not admin
   - Expected: keeper-secrets, not keeper-admin

2. **"How do I install KSM CLI?"**
   - Installation/setup, not administration
   - Expected: keeper-setup, not keeper-admin

3. **"List all my vault records"**
   - Ambiguous: machine-oriented listing (`ksm secret list`) fits **keeper-secrets**; interactive vault browsing via Commander fits **keeper-admin**
   - Expected: Often **keeper-secrets** first; do not treat wrong routing as a bug without checking which CLI the user means

## keeper-setup Activation Tests

### Should Trigger keeper-setup

✅ These prompts should activate the keeper-setup skill:

1. **"Install the Keeper CLI tools on my Mac"**
   - Keywords: install, Keeper CLI
   - Expected: keeper-setup with installation instructions

2. **"Set up keeper commander with persistent login"**
   - Keywords: setup, keeper commander, persistent login
   - Expected: keeper-setup with Commander configuration

3. **"My ksm token expired, how do I re-authenticate?"**
   - Keywords: ksm token, authentication, setup
   - Expected: keeper-setup with re-initialization steps

4. **"What are the prerequisites for using Keeper CLI?"**
   - Keywords: prerequisites, requirements, Keeper CLI
   - Expected: keeper-setup with prerequisites section

5. **"I'm getting 'keyring not available', how do I fix it?"**
   - Keywords: keyring error, KSM setup issue
   - Expected: keeper-setup with troubleshooting

6. **"Install both KSM CLI and Commander on Ubuntu"**
   - Keywords: install, KSM, Commander, specific OS
   - Expected: keeper-setup with platform-specific instructions

7. **"Initialize KSM with my One-Time Access Token"**
   - Keywords: initialize, KSM, token
   - Expected: keeper-setup with profile init instructions

### Should NOT Trigger keeper-setup

❌ These prompts should NOT activate keeper-setup:

1. **"I need a secret from Keeper"**
   - Retrieval, not setup
   - Expected: keeper-secrets

2. **"Create a new KSM application"**
   - Admin operation, not setup
   - Expected: keeper-admin

3. **"Update Python on my system"**
   - System administration, not Keeper-specific setup
   - Expected: No Keeper skill

## Cross-Skill Scenarios

These scenarios might involve multiple skills:

### Scenario 1: New Developer Onboarding

**Prompt:** "I'm a new developer. Set me up with Keeper to access our database credentials."

**Expected Flow:**

1. keeper-setup: "Install KSM CLI"
2. keeper-setup: "Initialize with token"
3. keeper-secrets: "Use `ksm secret list` to see available secrets"
4. keeper-secrets: "Use `ksm exec` to inject secrets into applications"

### Scenario 2: Setting Up Automated Rotation

**Prompt:** "I need to set up automated password rotation for our database accounts."

**Expected Flow:**

1. keeper-admin: "Create PAM configuration"
2. keeper-admin: "Configure rotation policy"
3. keeper-admin: "Monitor rotation history"

### Scenario 3: New Environment Setup

**Prompt:** "Help me set up Keeper secrets for our new staging environment."

**Expected Flow:**

1. keeper-setup: "Install CLI tools on staging servers"
2. keeper-admin: "Create KSM application for staging"
3. keeper-admin: "Create client device and token"
4. keeper-setup: "Initialize with token on servers"
5. keeper-secrets: "Use `ksm exec` in deployment scripts"

## Negative Test Cases

Use these to check that the agent does **not** treat every message as a CLI task. **Important:** Our skills’ descriptions tell the model to use them when the user mentions **Keeper**, `ksm`, `keeper`, etc. Prompts that include those words may still load a skill even when the user is asking for docs, pricing, or integrations-so “negative” here means *no **operational** CLI workflow*, not *no Keeper-related reply*. For a stricter “no skill” test, use prompts with **no** Keeper vocabulary (e.g. weather, generic Python).

1. **"What's the weather today?"** - No Keeper context; strong negative for skill routing.

2. **"I'm using a different password manager, what's the best approach?"** - Third-party tool; should not assume Keeper CLIs.

3. **"What features does the enterprise plan include?"** - Product/sales; not a CLI how-to.

4. **"What's the Keeper API rate limit?"** - May still attach a Keeper skill because of the word *Keeper*; expect **general** or docs-style answer, not `ksm`/`keeper` command sequences.

5. **"How do I backup my personal vault?"** - May reasonably route to **keeper-admin** (export/backup flows) or stay generic; **not** a reliable “no skill” case.

6. **"Can Keeper integrate with my existing tools?"** - Broad product question; same caveat as (4) if the agent mentions Keeper skills.
