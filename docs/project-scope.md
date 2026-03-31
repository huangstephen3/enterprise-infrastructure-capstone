# Project Scope and Contribution Split

## Why This Note Exists
The full capstone connected a simulated private-cloud primary environment with a simulated public-cloud secondary environment. This public repository is designed to be honest about scope while still showing the full service story.

## Primary Hands-On Contribution
I independently implemented and documented Site 1, the simulated private-cloud side of the project. That is the part of the capstone most directly reflected in the infrastructure details and operational evidence highlighted in this portfolio.

Publicly emphasized simulated private-cloud elements include:
- Segmented VLAN design and OPNsense-centered routing/policy logic
- Shared compute on Proxmox VE
- Tenant-separated Windows and Samba-based service stacks
- SAN, iSCSI, file-service, backup, and monitoring workflows
- Browser-based administration and support-oriented handover documentation

## Broader Integrated Project Context
The overall capstone also included a simulated public-cloud side. In the public narrative, that side matters because it explains:
- The MSP administration model
- Cross-site protection and backup-copy dependencies
- Inter-site VPN routing and firewall controls
- Recovery, dependency, and failure-domain thinking across the full project

## Public Naming Note
The original course handover packages used numeric environment labels. In this public portfolio, I describe the environments by role instead so the architecture reads more clearly.

## How To Read The Public Artifacts
- Resume: emphasizes that I independently built Site 1 and references the simulated public-cloud side only as integrated project context.
- Portfolio site: presents the capstone as one unified project while clarifying that Site 1 was my direct implementation responsibility.
- GitHub docs: keep the integrated operational story but avoid overstating personal ownership of every part of the simulated public-cloud side.

## Public-Safe Framing Principle
The goal is to show credible systems and support thinking without claiming work that was outside my direct implementation focus.
