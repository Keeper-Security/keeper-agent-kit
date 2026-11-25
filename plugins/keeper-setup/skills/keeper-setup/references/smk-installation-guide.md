## Overview

Self-Managed Keeper (SMK) is a self-hosted, container-based deployment of Keeper's identity security platform. It provides credential management, secrets management and privileged access management within infrastructure your organization owns and operates, including on-premises data centers, private clouds and fully air-gapped networks.

## Installation
Follow official documentation at [here](https://docs.keeper.io/keeperpam/self-managed-keeper/self-managed-keeper-overview/installation)

## System requirements
[Follow official documentation here](https://docs.keeper.io/keeperpam/self-managed-keeper/self-managed-keeper-overview/installation/system-requirements)

## TLS Configurations
[Follow official documentation here](https://docs.keeper.io/keeperpam/self-managed-keeper/self-managed-keeper-overview/installation/tls-certificates)

## Preparing for installation
[Follow official documentation here](https://docs.keeper.io/keeperpam/self-managed-keeper/self-managed-keeper-overview/installation/preparing-for-installation)

## Docker installation
[Follow official documentation here](https://docs.keeper.io/keeperpam/self-managed-keeper/self-managed-keeper-overview/installation/auto-docker-install)

## Managing the Service

From inside the extracted bundle directory, the `./smk` command manages the entire deployment and its underlying containers.

| Command | Description |
|---------|-------------|
| `./smk up` | Start, or reconcile after a configuration change, every selected service. |
| `./smk down` | Stop every service. Non-destructive; installation data is preserved. |
| `./smk status` | Show what's running. |
| `./smk doctor` | Check whether the parts of the deployment agree with each other. |
| `./smk version` | Identify the installed build's exact version. |
| `./smk wizard` | Open the guided backup, restore, and upgrade menu. |
| `./smk backup --output <path>` | Capture a verified backup. The installation stays in maintenance afterwards. |
| `./smk restore <backup>` | Restore from a verified backup. |
| `./smk support collect` | Create a sanitized archive for a support case. |
| `./smk remove` | Delete the containers and Docker volumes. Destructive; asks you to type `remove`. |
| `./smk help` | List every available command. |

**Note:** Every selected core service restarts automatically after a host reboot. A service you stopped explicitly stays stopped.

Every selected core service restarts automatically after a host reboot. A service you stopped explicitly stays stopped.