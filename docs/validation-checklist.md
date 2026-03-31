# Validation Checklist

Use this checklist to turn infrastructure work into repeatable operational evidence instead of one-time build notes.

## Daily Checks
- Confirm the approved jump or management path is reachable.
- Review firewall interface state and any site-to-site tunnel health if inter-site protection matters.
- Review Proxmox host health and confirm core workloads are up.
- Confirm the latest local backup and offsite-copy jobs completed successfully.
- Check Grafana for unusual CPU, memory, network, or I/O behavior.

## Weekly Checks
- Review free space on local and offsite repositories.
- Confirm DNS and DHCP health for each tenant identity plane.
- Reconfirm that representative clients can resolve the expected internal service names.
- Check SAN-facing or storage-facing interfaces and mounted paths.
- Verify browser-based admin tools still respond on their expected ports.

## Monthly Checks
- Apply the approved patch cycle.
- Export configuration backups where supported.
- Review temporary firewall exceptions and remove stale entries.
- Perform one representative restore or recovery validation.

## After Any Major Change
- Re-test administrative access paths.
- Re-test authentication and name resolution.
- Re-test VM or service state for the affected platform.
- Re-test local backup success and offsite reachability where applicable.
- Re-test monitoring visibility so alerts do not silently fail after change work.

## Evidence to Capture
- Dashboard screenshot or ticket note for daily checks
- Ops checklist or change record for weekly checks
- Restore evidence for monthly checks
- Post-change validation note after any significant modification

## Public Portfolio Hygiene
- Remove sensitive IPs, usernames, internal paths, and credentials before publishing artifacts.
- Prefer sanitized diagrams and written validation summaries over raw console output dumps.
- Keep links current for GitHub, LinkedIn, portfolio, and downloadable resume files.
