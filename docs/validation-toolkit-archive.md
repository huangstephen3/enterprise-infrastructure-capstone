# Validation Toolkit Archive Plan

## Why This Note Exists
The integrated capstone had a larger live validation toolkit than this public repository currently exposes. That toolkit was designed for final demonstration and support verification across the simulated private-cloud and simulated public-cloud sides of the project.

The lab environment is scheduled to close after April 17, 2026. Because of that, the right public strategy is not to promise an always-live demo. The better approach is to preserve a final validation snapshot, sanitize it, and publish it as archived operational evidence.

## What The Original Toolkit Already Shows
The private toolkit is stronger than a simple ping or port-check script. It demonstrates:

- Menu-driven PowerShell orchestration for service-block and hotseat workflows
- Cross-environment validation across the simulated private-cloud and simulated public-cloud sides rather than isolated single-host checks
- Mixed protocol validation using WinRM, SSH, HTTP/HTTPS, SMB, RDP-path, and backup-path evidence
- Coverage thinking by service block, tenant, and operator responsibility
- Exportable summary artifacts and session logs
- Clear separation between automated checks and manual follow-up items

That is worth showing to recruiters and interviewers because it proves repeatable validation thinking, not just one-time build work.

## What Should Be Published Publicly
Good GitHub evidence:

- A sanitized final validation archive in Markdown
- A machine-readable JSON version of the same snapshot
- A short explanation of what the toolkit covered
- Two to six sanitized screenshots from Proxmox, OPNsense, Grafana, Veeam, Windows Admin Center, or Cockpit
- One checklist or summary artifact that shows how validation was organized

Do not publish raw private toolkit files that still contain:

- Real IP addresses that you do not want public
- Shared passwords or embedded secrets
- Full host inventories from the original jumpbox toolkit
- Internal-only paths, usernames, or recovery details that should stay private

## Before The Lab Closes
Aim to freeze your public evidence no later than April 16, 2026, instead of waiting until the last possible day.

Recommended capture sequence from the approved jumpbox:

```powershell
cd $HOME\Desktop\test_service-group6-v0.1
powershell -ExecutionPolicy Bypass -File .\00_ServiceBlocks_Menu.ps1 -SelfTest
powershell -ExecutionPolicy Bypass -File .\00_ServiceBlocks_Menu.ps1 -MainOption 8
powershell -ExecutionPolicy Bypass -File .\00_ServiceBlocks_Menu.ps1 -MainOption 9
powershell -ExecutionPolicy Bypass -File .\00_ServiceBlocks_Menu.ps1 -MainOption M
powershell -ExecutionPolicy Bypass -File .\00_ServiceBlocks_Menu.ps1 -MainOption E
```

Then copy out:

- The exported summary text file from `04_Results`
- The latest session log from `04_Results`
- The matching checklist workbook or a PDF export of it
- Sanitized screenshots that prove the important service planes were up

## After The Lab Closes
After April 17, 2026, treat the environment as an archived capstone rather than a still-running public lab.

That means your GitHub and portfolio should say:

- This was validated in a live multi-site lab before decommission
- The repo now preserves the architecture, runbooks, triage logic, and final validation evidence
- The attached summary and screenshots are archival proof, not a promise of current reachability

That framing is strong for interviews because it is honest and still technically impressive.

## Turning A Private Summary Into A Public Artifact
Use [scripts/publish-validation-archive.ps1](../scripts/publish-validation-archive.ps1) after you export the final toolkit summary.

Example:

```powershell
pwsh -File .\scripts\publish-validation-archive.ps1 `
  -SummaryPath "C:\path\to\20260416_Validation_Summary.txt" `
  -OutputPath ".\docs\final-validation-archive.md"
```

The script:

- parses the exported summary
- redacts IPv4 addresses and known shared secrets
- groups results by service block
- produces a recruiter-friendly Markdown archive
- also emits JSON that can be reused on the portfolio site later

## Best Public Framing For Recruiters
The story to tell is not "my lab is still running forever."

The better story is:

`Built and used a PowerShell-based cross-environment validation toolkit to verify identity, DNS, HTTPS, storage, backup, and management paths across a simulated private-cloud and public-cloud enterprise infrastructure capstone; preserved the final validated state as sanitized operational evidence before lab decommission.`

That phrasing turns the lab shutdown into a professionalism point instead of a weakness.
