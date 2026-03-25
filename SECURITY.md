# Security

We take security seriously. This repository contains **documentation and agent skills** for Keeper’s official CLIs-not a standalone crypto implementation. Still, mistakes in docs or examples could mislead users; please report problems responsibly.

## Supported versions

Security fixes are applied to the **default branch** of this repository (`main` or as documented in release notes). Use the latest commit or tagged release when deploying skills to your agents.

## Reporting a vulnerability

**Please do not** open a public GitHub issue for undisclosed security vulnerabilities.

Instead:

1. **Email:** Use the contact channel published on [Keeper Security Support](https://keepersecurity.com/support) for security-sensitive reports related to Keeper products and this Keeper Security agent kit.  
2. **GitHub private reporting:** If [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability) is enabled for `Keeper-Security/agent-kit`, you may use it for issues specific to this repository (documentation, CI, skill content).

Include:

- A clear description of the issue and its impact  
- Steps to reproduce (if applicable)  
- Affected files or workflows (e.g. a specific skill or workflow name)  

We will acknowledge receipt as soon as we can and coordinate disclosure after a fix is available.

## Scope (in scope for this repo)

- Misleading or unsafe examples in skills or reference docs  
- Instructions that could cause secrets to be exposed in logs or chat  
- CI or automation that could leak tokens or weaken validation  

## Out of scope

- Vulnerabilities in Keeper’s cloud services or CLIs themselves - report those through [Keeper Security](https://keepersecurity.com/support) or the appropriate product channel  
- Social engineering or compromised user machines  

## Safe use reminders

- Do not paste real passwords, recovery keys, or KSM tokens into AI chats or public issues.  
- Use placeholders in examples (`<TOKEN>`, `keeper://…` with fake UIDs).  
- Prefer OS keyring and least-privilege KSM applications for automation.  

Thank you for helping keep users safe.
