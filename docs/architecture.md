# Architecture Notes

## Goal
Present a public-safe version of a multi-tenant infrastructure story that is still recognizable as real support work.

This repository is not meant to expose a full internal build. It is meant to show how I reason about service placement, administrative boundaries, storage and backup dependencies, and validation from an operator point of view.

## Public-Safe Source Basis
This showcase is informed by a larger integrated handover package that combined a simulated private-cloud environment and simulated public-cloud environment into one operational narrative. The public version keeps the design logic and support mindset while removing secrets and environment-specific details.

## Scope Clarification
- Primary hands-on implementation focus: the simulated private-cloud side
- Broader integrated capstone context: a simulated private-cloud primary environment plus a simulated public-cloud secondary environment
- Public naming note: original course materials used numeric site labels, but this public version describes the environments by role for clarity
- Reason the simulated public-cloud side appears in the public narrative: it provides the MSP boundary, cross-site protection path, and recovery dependencies that make the overall design explainable

## Core Operating Assumptions
- Tenant isolation is more important than any single VM or host.
- Approved management entry paths matter because healthy services are still hard to support when bastion access is broken.
- Storage and backup continuity are platform concerns, not just backup-tool concerns.
- A design is only credible if the validation path is documented.

## Service Planes

### 1. Entry and Management
- OPNsense administrative boundary
- Approved jump hosts or browser-based management paths
- Windows Admin Center and Cockpit for platform administration

Purpose:
Centralize privileged access and reduce uncontrolled administrative reachability.

### 2. Compute and Workload Hosting
- Shared Proxmox VE compute platform
- Tenant workloads hosted on shared hardware with segmented network paths

Purpose:
Support multiple service stacks while keeping roles understandable and supportable.

### 3. Identity and Naming
- Windows-oriented identity workflows for one tenant
- Samba AD, DNS, and DHCP workflows for another tenant
- Client login, hostname resolution, and share access depend on this layer

Purpose:
Preserve tenant-specific service behavior without collapsing everything into a single identity model.

### 4. Storage and Protection
- Isolated SAN transport for storage-facing paths
- Backup coordination through Veeam-oriented workflows
- Offsite protection path over a controlled inter-site route

Purpose:
Keep storage traffic deliberate, preserve recoverability, and separate sync behavior from true backup-backed recovery.

### 5. Monitoring and Operator Visibility
- Grafana and InfluxDB for infrastructure visibility
- Browser-accessible management tools for faster day-to-day operations
- Validation scripts and runbooks for repeatable health checks

Purpose:
Move from "configured once" to "supportable over time."

## Shared Platform Story
The environment can be explained from three perspectives without changing the underlying story:

- Network engineering: segmentation, bounded entry, routing, and policy behavior
- Systems administration: identity, naming, storage, backup, and client-service alignment
- Service delivery: operational support, recoverability, and daily maintenance ownership

That consistency is one of the strongest signals the original handover provided, so the public repo keeps the same framing.

## High-Consequence Change Points
- Shared firewall and routing layer
- Shared compute platform
- Shared storage and recovery path
- Approved administrative entry path

If one of these is unhealthy, many other service checks become noisy or misleading.

## Evidence Model Used in This Repo
- Design notes: why the environment is arranged the way it is
- Validation checklists: what should be checked routinely
- Triage notes: where to look first when symptoms appear
- Automation example: a PowerShell script that turns endpoint checks into a readable report

## Design Principles
- Keep public examples sanitized
- Prefer architecture plus validation over screenshots alone
- Show service relationships, not just software names
- Make technical depth optional: quick overview first, deeper notes second

## Next Additions That Would Strengthen This Repo
- Sanitized dashboard screenshots
- A topology diagram derived from the integrated handover
- A sample restore or recovery validation note
- One or two short incident write-ups showing troubleshooting discipline
