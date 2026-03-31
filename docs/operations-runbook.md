# Operations Runbook

## Purpose
This runbook turns the integrated handover logic into a compact set of operator priorities that make sense in a public portfolio.

It is not a replacement for full internal documentation. It is a readable example of how I think about supportability, dependencies, and day-to-day maintenance.

## Support Priorities
1. Preserve tenant boundaries.
2. Preserve approved administrative entry paths.
3. Preserve storage and backup continuity.
4. Reconfirm monitoring visibility after any change.

## Service Dependency View
| Service Plane | Primary Components | What Depends on It | Main Failure Symptom | First Health Check |
| --- | --- | --- | --- | --- |
| Entry and management | Jump hosts, OPNsense admin path, browser-based admin tools | Most troubleshooting workflows | Team cannot reach consoles or internal systems quickly | Verify approved remote-access and bastion reachability |
| Identity and naming | AD/Samba AD, DNS, DHCP | Client login, hostname resolution, share access | User lookup fails or service names do not resolve | Check service state, DNS query behavior, and representative client resolution |
| Compute and hosted services | Proxmox VE and tenant workloads | Web delivery, jump services, admin tooling | VMs or containers unavailable | Verify platform health and workload state |
| Storage and file services | Isolated SAN path, mounted volumes, file-service layer | Share access and some service workflows | Shares disappear or mounted storage degrades | Check iSCSI session, mounted volume state, and storage-facing interfaces |
| Backup and recovery | Veeam control plane, repository path, offsite target | Restore readiness and backup continuity | Jobs fail or offsite copy stalls | Verify latest job state, repository reachability, and target path health |
| Monitoring | Grafana, InfluxDB, exported metrics | Operator visibility and trend analysis | Dashboards fail or data goes stale | Confirm dashboard access and data-source freshness |

## Daily Cadence
- Confirm the approved management path is available.
- Review firewall and tunnel state.
- Review backup success and offsite-copy status.
- Check Grafana for unusual host resource trends.
- Confirm the most important administrative interfaces still respond.

## Weekly Cadence
- Review repository free space.
- Reconfirm DNS and DHCP health across identity services.
- Validate representative client name resolution.
- Check storage-facing interface health and mounted paths.
- Review whether public showcase artifacts still match the current lab story.

## Monthly Cadence
- Apply the approved patch cycle.
- Export configuration backups where possible.
- Review temporary exceptions or stale rules.
- Perform a representative restore or recovery check.

## Public Portfolio Use
This runbook is also a communication tool:
- It shows that I think in service planes, not just devices.
- It shows I separate normal maintenance from fast triage.
- It shows I understand that documentation is part of operational quality.
