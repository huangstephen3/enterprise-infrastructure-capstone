# Validation Checklist

Use this checklist when reviewing the home lab or preparing a recruiter-friendly update.

## Access and Segmentation
- Confirm the firewall or router still reflects the intended segmentation model
- Verify remote access is restricted to approved admin paths
- Check that any public-facing demo content is intentionally exposed

## Monitoring
- Confirm Grafana dashboards load
- Validate metrics collection is current
- Review any alerts, stale panels, or missing data sources

## Backup and Recovery
- Confirm the latest backup status is successful
- Check repository capacity or destination reachability
- Review recovery notes or restore-test evidence

## Admin Tooling
- Validate browser-based admin tools respond on expected ports
- Confirm credentials and secrets are not embedded in public artifacts
- Refresh documentation when services or topology change

## Public Portfolio Hygiene
- Remove sensitive IPs, usernames, or hostnames before publishing
- Replace internal screenshots with sanitized versions
- Keep links current for GitHub, LinkedIn, and resume downloads
