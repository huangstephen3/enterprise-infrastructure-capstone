# Fast Triage Guide

This guide keeps the first round of troubleshooting short and practical.

## Principles
- Check the management path early because many other checks depend on it.
- Look for shared failure domains before debugging individual workloads.
- Verify a healthy expectation, not just the presence of a process.
- Capture a small amount of evidence quickly, then go deeper if needed.

## Symptom-First Triage
| Symptom | Inspect First | Fastest Check | Healthy Expectation | Likely Fault Domain |
| --- | --- | --- | --- | --- |
| Cannot reach the environment from the approved path | Jump hosts or firewall admin path | Reachability check to the known admin endpoint | Admin path responds | Remote-access, firewall, or jump-host issue |
| Internal service names do not resolve | Identity or DNS nodes | DNS query from a representative client or admin system | Expected records return | DNS service, record issue, or resolver drift |
| Domain user lookup or login fails | Identity service plane | Directory-service status and a simple user lookup | User lookup succeeds | Identity service, trust, or client configuration issue |
| File shares are missing or inconsistent | Storage and file-service layer | Check mounted volume, iSCSI session, and share availability | Mounted storage and shares are present | Storage path, file-service layer, or permissions issue |
| Backup copy fails | Backup repository path and inter-site dependency | Verify repository reachability and last job state | Repository reachable and recent job success | Repository path, offsite dependency, or backup control issue |
| Monitoring dashboard is unavailable or stale | Monitoring plane | Check dashboard response and data-source freshness | Dashboard loads and data is current | Dashboard service, metrics pipeline, or platform stress |

## What to Record
- The symptom in one sentence
- The first system checked
- The quickest evidence collected
- The most likely fault domain
- The next deeper check if the first check is unhealthy
