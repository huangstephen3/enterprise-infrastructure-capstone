# Enterprise Infrastructure Capstone Showcase

This repository is a sanitized, public-safe distillation of my Enterprise Infrastructure Capstone, including the infrastructure, operations, and handover logic behind the delivered environment.

It is intentionally structured to be readable by a recruiter in a few minutes and useful to a technical reviewer who wants to see how I think about service boundaries, validation, and operational support.

## Scope Clarification
- Primary hands-on contribution: the simulated `private-cloud` side
- Broader capstone context: a simulated `private-cloud` primary environment plus a simulated `public-cloud` secondary environment
- Public naming note: the original course handover used numeric site labels, but this public repo describes the environments by architectural role to make the project easier to understand
- Why the simulated `public-cloud` side still appears here: it explains the MSP model, inter-site protection path, and recovery dependencies across the full project

For a direct scope summary, see [docs/project-scope.md](docs/project-scope.md).

## What This Repository Demonstrates
- Multi-tenant infrastructure thinking instead of isolated single-service demos
- A support-oriented view of systems administration, not just build steps
- Clear documentation habits: architecture, runbooks, validation, and triage
- Lightweight automation through a PowerShell health-report script
- A public-safe archive strategy for a larger cross-site validation toolkit that originally exercised WinRM, SSH, HTTP/HTTPS, SMB, and backup-path checks before lab decommission
- Public sharing discipline through sanitized examples and non-sensitive artifacts

## Environment Snapshot
- `2` tenant service stacks with different platform preferences
- `9` segmented VLANs and a bounded management path
- `12` documented workloads across shared infrastructure
- `10` local systems covered by documented backup scope
- `7` offsite backup-copy jobs routed through a site-to-site protection path
- Shared OPNsense, Proxmox VE, storage, monitoring, and Veeam workflows

## Operational Priorities
These priorities come directly from the integrated handover logic that informed this public version:

1. Preserve tenant boundaries first.
2. Preserve approved administrative and MSP entry paths second.
3. Treat storage and backup continuity as platform-level dependencies, not isolated service tasks.

## Technical Focus
- OPNsense for segmentation, policy enforcement, remote-access thinking, and bounded exposure
- Proxmox VE for shared compute and workload hosting
- Windows Server and Samba AD concepts for tenant-separated identity, DNS, DHCP, and admin paths
- Windows iSCSI, SMB-backed protection, and Veeam workflows for storage and recovery thinking
- Grafana, InfluxDB, Windows Admin Center, and Cockpit for operational visibility and browser-based administration
- PowerShell and documentation-backed automation for repeatable checks

## Architecture Snapshot
```mermaid
flowchart LR
  Internet["Internet / ISP"] --> FW["OPNsense Firewall"]
  FW --> Mgmt["Management / Jump Path"]
  FW --> C1["Company 1 Services"]
  FW --> C2["Company 2 Services"]
  FW --> SAN["Isolated SAN Transport"]
  FW --> VPN["Inter-site Protection Path"]
  C1 --> Proxmox["Shared Compute on Proxmox VE"]
  C2 --> Proxmox
  SAN --> Backup["Storage + Backup Workflows"]
  Mgmt --> Admin["WAC / Cockpit / Admin Hosts"]
  Proxmox --> Monitoring["Grafana + InfluxDB"]
  Admin --> Scripts["Validation + PowerShell Reporting"]
  Monitoring --> Scripts
  Backup --> Scripts
```

## Repository Layout
```text
.
|-- assets/
|-- config/
|-- docs/
|   |-- architecture.md
|   |-- operations-runbook.md
|   |-- triage-guide.md
|   `-- validation-checklist.md
|-- reports/
|-- scripts/
|-- .gitignore
`-- README.md
```

## Key Files
- [docs/project-scope.md](docs/project-scope.md): explains the simulated private-cloud side as the primary hands-on scope and the simulated public-cloud side as integrated project context
- [docs/architecture.md](docs/architecture.md): high-level design notes, service planes, and the public-safe operating model
- [docs/operations-runbook.md](docs/operations-runbook.md): support priorities, service dependencies, and maintenance cadence
- [docs/triage-guide.md](docs/triage-guide.md): fast first checks for common failure symptoms
- [docs/validation-checklist.md](docs/validation-checklist.md): daily, weekly, monthly, and post-change validation habits
- [docs/validation-toolkit-archive.md](docs/validation-toolkit-archive.md): explains how the original live test toolkit is preserved as archived evidence after the lab closes on April 17, 2026
- [config/sample-endpoints.json](config/sample-endpoints.json): categorized endpoint list for the health-report script
- [scripts/backup-health-check.ps1](scripts/backup-health-check.ps1): generates a Markdown report from TCP and HTTP endpoint checks
- [scripts/publish-validation-archive.ps1](scripts/publish-validation-archive.ps1): converts exported toolkit summaries into sanitized Markdown and JSON artifacts for GitHub and portfolio use

## Validation Evidence After Lab Closure
The original capstone lab is scheduled to close after April 17, 2026. Because of that, this public repo treats the live environment and the long-term showcase as two different things:

- Before April 17, 2026: run the full validation toolkit, export the summary, and capture final screenshots or checklist evidence.
- After April 17, 2026: publish the sanitized summary, archived screenshots, and operational notes as historical proof of what was validated while the environment was still online.

That keeps the project honest. It shows the live operational work happened, but it does not pretend the lab is still available forever.

## Public Sharing Rules
- No real credentials
- No production secrets or VPN configuration
- No sensitive internal hostnames, usernames, or private operational data
- No screenshots that expose unsafe implementation details
- Public examples should show design intent, evidence quality, and supportability

## Related Links
- Portfolio site: https://huangstephen3.github.io
- LinkedIn: https://www.linkedin.com/in/yiqinhuang2025
