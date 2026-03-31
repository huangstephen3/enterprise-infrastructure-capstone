# Architecture Notes

## Goal
Create a small but credible infrastructure showcase that demonstrates how I think about segmentation, monitoring, backup validation, and administrative access.

## Service Layers
- Firewall and routing: OPNsense concepts for traffic control, NAT, and remote access policy
- Virtualization: Proxmox VE as the main host for lab services and experiments
- Identity and administration: Windows and Linux management workflows, browser-based admin tools, and documented support notes
- Monitoring: Grafana and InfluxDB for visibility into system state
- Backup and recovery: health checks, backup status review, and recovery-first thinking

## Design Principles
- Keep public examples sanitized
- Prefer diagrams and runbooks over raw screenshots without context
- Show what was validated, not just what was configured
- Make every public artifact readable by a recruiter in under two minutes

## Evidence to Add Over Time
- Sanitized screenshots of dashboards
- Short write-ups of issues solved in the home lab
- Exported, non-sensitive dashboard JSON
- Additional PowerShell or Ansible utilities
