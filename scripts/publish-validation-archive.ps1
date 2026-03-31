[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SummaryPath,

    [string]$OutputPath = ".\\docs\\final-validation-archive.md",

    [string]$JsonOutputPath,

    [string]$SnapshotTitle = "Enterprise Infrastructure Capstone Validation Archive",

    [datetime]$DecommissionDate = [datetime]"2026-04-17",

    [int]$SelectedItemLimit = 12
)

$ErrorActionPreference = "Stop"
$englishCulture = [System.Globalization.CultureInfo]::GetCultureInfo("en-US")

function Sanitize-ToolkitText {
    param(
        [AllowNull()]
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    $sanitized = $Text
    $sanitized = [regex]::Replace($sanitized, '\b(?:\d{1,3}\.){3}\d{1,3}\b', '<redacted-ip>')
    $sanitized = $sanitized -replace 'Cisco123!', '<redacted-secret>'
    $sanitized = [regex]::Replace($sanitized, '(?im)(password\s*[:=]\s*)(\S+)', '$1<redacted-secret>')
    $sanitized = $sanitized.TrimEnd()

    return $sanitized
}

function New-ParsedResult {
    param(
        [string]$Status,
        [string]$Test
    )

    [ordered]@{
        Status       = $Status
        Test         = Sanitize-ToolkitText $Test
        Device       = ""
        Section      = ""
        Method       = ""
        Site         = ""
        Assessment   = ""
        Likely       = ""
        RelatedPass  = @()
        Commands     = @()
        Check        = ""
        DetailsLines = @()
    }
}

function Get-SectionGroupName {
    param(
        [string]$Section
    )

    if ([string]::IsNullOrWhiteSpace($Section)) {
        return "Unspecified"
    }

    $parts = $Section -split '\s*/\s*'
    if ($parts.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($parts[0])) {
        return $parts[0].Trim()
    }

    return $Section.Trim()
}

function Convert-SummaryToResults {
    param(
        [string[]]$Lines
    )

    $metadata = [ordered]@{
        Generated      = ""
        ToolkitVersion = ""
    }

    $results = New-Object System.Collections.Generic.List[object]
    $current = $null
    $mode = ""

    foreach ($line in $Lines) {
        $rawLine = if ($null -eq $line) { "" } else { [string]$line }
        $trimmed = $rawLine.TrimEnd()

        if ($trimmed -match '^Generated:\s*(.+)$') {
            $metadata.Generated = Sanitize-ToolkitText $matches[1]
            continue
        }

        if ($trimmed -match '^Toolkit Version:\s*(.+)$') {
            $metadata.ToolkitVersion = Sanitize-ToolkitText $matches[1]
            continue
        }

        if ($trimmed -match '^\[(PASS|FAIL|REVIEW)\]\s+(.+)$') {
            if ($null -ne $current) {
                $results.Add([pscustomobject]$current)
            }

            $current = New-ParsedResult -Status $matches[1] -Test $matches[2]
            $mode = ""
            continue
        }

        if ($null -eq $current) {
            continue
        }

        if ($mode -eq "Commands") {
            if ($trimmed -match '^\s{2,}(.+)$') {
                $current.Commands += Sanitize-ToolkitText $matches[1]
                continue
            }

            if ([string]::IsNullOrWhiteSpace($trimmed)) {
                continue
            }

            $mode = ""
        }

        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }

        if ($trimmed -match '^Device:\s*(.*)$') {
            $current.Device = Sanitize-ToolkitText $matches[1]
            continue
        }

        if ($trimmed -match '^Section:\s*(.*)$') {
            $current.Section = Sanitize-ToolkitText $matches[1]
            continue
        }

        if ($trimmed -match '^Method:\s*(.*)$') {
            $current.Method = Sanitize-ToolkitText $matches[1]
            continue
        }

        if ($trimmed -match '^Site:\s*(.*)$') {
            $current.Site = Sanitize-ToolkitText $matches[1]
            continue
        }

        if ($trimmed -match '^Assessment:\s*(.*)$') {
            $current.Assessment = Sanitize-ToolkitText $matches[1]
            continue
        }

        if ($trimmed -match '^Likely:\s*(.*)$') {
            $current.Likely = Sanitize-ToolkitText $matches[1]
            continue
        }

        if ($trimmed -match '^Related PASS:\s*(.*)$') {
            $current.RelatedPass = @(
                ($matches[1] -split '\s*;\s*') |
                    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
                    ForEach-Object { Sanitize-ToolkitText $_ }
            )
            continue
        }

        if ($trimmed -match '^Command:\s*(.*)$') {
            $current.Commands += Sanitize-ToolkitText $matches[1]
            continue
        }

        if ($trimmed -eq 'Commands:') {
            $mode = "Commands"
            continue
        }

        if ($trimmed -match '^Check:\s*(.*)$') {
            $current.Check = Sanitize-ToolkitText $matches[1]
            continue
        }

        $current.DetailsLines += Sanitize-ToolkitText $trimmed
    }

    if ($null -ne $current) {
        $results.Add([pscustomobject]$current)
    }

    return [pscustomobject]@{
        Metadata = [pscustomobject]$metadata
        Results  = $results.ToArray()
    }
}

function New-CountRow {
    param(
        [string]$Name,
        [object[]]$Items
    )

    $passCount = @($Items | Where-Object { $_.Status -eq "PASS" }).Count
    $failCount = @($Items | Where-Object { $_.Status -eq "FAIL" }).Count
    $reviewCount = @($Items | Where-Object { $_.Status -eq "REVIEW" }).Count

    [pscustomobject]@{
        Name   = $Name
        PASS   = $passCount
        FAIL   = $failCount
        REVIEW = $reviewCount
        Total  = @($Items).Count
    }
}

$resolvedSummaryPath = (Resolve-Path -LiteralPath $SummaryPath).Path
$summaryLines = Get-Content -LiteralPath $resolvedSummaryPath
$parsed = Convert-SummaryToResults -Lines $summaryLines
$results = @($parsed.Results)

if (-not $JsonOutputPath) {
    $JsonOutputPath = [System.IO.Path]::ChangeExtension($OutputPath, ".json")
}

$summaryDirectory = Split-Path -Parent $OutputPath
if ($summaryDirectory -and -not (Test-Path -LiteralPath $summaryDirectory)) {
    New-Item -ItemType Directory -Path $summaryDirectory | Out-Null
}

$jsonDirectory = Split-Path -Parent $JsonOutputPath
if ($jsonDirectory -and -not (Test-Path -LiteralPath $jsonDirectory)) {
    New-Item -ItemType Directory -Path $jsonDirectory | Out-Null
}

$sectionRows = @(
    $results |
        Group-Object { Get-SectionGroupName $_.Section } |
        Sort-Object Name |
        ForEach-Object {
            New-CountRow -Name $_.Name -Items $_.Group
        }
)

$statusPriority = @{
    FAIL   = 0
    REVIEW = 1
    PASS   = 2
}

$selectedItems = @(
    $results |
        Sort-Object `
            @{ Expression = { $statusPriority[$_.Status] } }, `
            @{ Expression = { Get-SectionGroupName $_.Section } }, `
            @{ Expression = { $_.Test } } |
        Select-Object -First $SelectedItemLimit
)

$followUpItems = @(
    $results |
        Where-Object { $_.Status -ne "PASS" } |
        Sort-Object `
            @{ Expression = { $statusPriority[$_.Status] } }, `
            @{ Expression = { Get-SectionGroupName $_.Section } }, `
            @{ Expression = { $_.Test } }
)

$summaryStats = [pscustomobject]@{
    Total  = $results.Count
    PASS   = @($results | Where-Object { $_.Status -eq "PASS" }).Count
    FAIL   = @($results | Where-Object { $_.Status -eq "FAIL" }).Count
    REVIEW = @($results | Where-Object { $_.Status -eq "REVIEW" }).Count
}

$markdown = New-Object System.Collections.Generic.List[string]
$markdown.Add("# $SnapshotTitle")
$markdown.Add("")
$markdown.Add("This archive was imported from a live validation summary captured before the capstone lab closed. The environment is scheduled to shut down after $($DecommissionDate.ToString('MMMM d, yyyy', $englishCulture)), so this document preserves what was validated while the infrastructure was still online.")
$markdown.Add("")
$markdown.Add("## Snapshot")
$markdown.Add("")
$markdown.Add("- Source summary: ``$([System.IO.Path]::GetFileName($resolvedSummaryPath))``")
$markdown.Add("- Summary generated: $($parsed.Metadata.Generated)")
$markdown.Add("- Toolkit version: $($parsed.Metadata.ToolkitVersion)")
$markdown.Add("- Imported checks: $($summaryStats.Total)")
$markdown.Add("- PASS: $($summaryStats.PASS)")
$markdown.Add("- FAIL: $($summaryStats.FAIL)")
$markdown.Add("- REVIEW: $($summaryStats.REVIEW)")
$markdown.Add("")
$markdown.Add("## Why This Matters")
$markdown.Add("")
$markdown.Add("- Preserves cross-site validation evidence after the live lab is no longer available.")
$markdown.Add("- Shows repeatable operator workflow across service blocks, not just screenshots or one-time build notes.")
$markdown.Add("- Redacts raw IPv4 addresses and known shared secrets before the result is published.")
$markdown.Add("")

if ($sectionRows.Count -gt 0) {
    $markdown.Add("## Service-Block Coverage")
    $markdown.Add("")
    $markdown.Add("| Area | PASS | FAIL | REVIEW | Total |")
    $markdown.Add("| --- | ---: | ---: | ---: | ---: |")
    foreach ($row in $sectionRows) {
        $markdown.Add("| $($row.Name) | $($row.PASS) | $($row.FAIL) | $($row.REVIEW) | $($row.Total) |")
    }
    $markdown.Add("")
}

if ($selectedItems.Count -gt 0) {
    $markdown.Add("## Selected Validation Items")
    $markdown.Add("")
    $markdown.Add("| Status | Test | Device | Section |")
    $markdown.Add("| --- | --- | --- | --- |")
    foreach ($item in $selectedItems) {
        $markdown.Add("| $($item.Status) | $($item.Test) | $($item.Device) | $($item.Section) |")
    }
    $markdown.Add("")
}

if ($followUpItems.Count -gt 0) {
    $markdown.Add("## Follow-Up Items")
    $markdown.Add("")
    foreach ($item in $followUpItems) {
        $markdown.Add("### [$($item.Status)] $($item.Test)")
        $markdown.Add("")
        if ($item.Section) {
            $markdown.Add("- Section: $($item.Section)")
        }
        if ($item.Device) {
            $markdown.Add("- Device: $($item.Device)")
        }
        if ($item.Check) {
            $markdown.Add("- Check: $($item.Check)")
        }
        if ($item.Assessment) {
            $markdown.Add("- Assessment: $($item.Assessment)")
        }
        if ($item.Likely) {
            $markdown.Add("- Likely Cause: $($item.Likely)")
        }
        if ($item.RelatedPass.Count -gt 0) {
            $markdown.Add("- Related PASS: $($item.RelatedPass -join '; ')")
        }
        if ($item.DetailsLines.Count -gt 0) {
            $markdown.Add("- Notes: $($item.DetailsLines -join ' ')")
        }
        $markdown.Add("")
    }
}

$markdown.Add("## Publication Notes")
$markdown.Add("")
$markdown.Add("- This document is an archival snapshot, not a claim that the lab is still running today.")
$markdown.Add("- Pair this archive with sanitized screenshots, topology notes, and the public runbook for the strongest recruiter-facing presentation.")
$markdown.Add("- Keep the original raw toolkit outputs outside the public repo if they still contain internal-only details.")

Set-Content -LiteralPath $OutputPath -Value $markdown -Encoding UTF8

$jsonPayload = [pscustomobject]@{
    title             = $SnapshotTitle
    sourceSummary     = [System.IO.Path]::GetFileName($resolvedSummaryPath)
    importedAt        = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    decommissionDate  = $DecommissionDate.ToString("yyyy-MM-dd")
    metadata          = $parsed.Metadata
    summary           = $summaryStats
    sectionBreakdown  = $sectionRows
    results           = @(
        $results | ForEach-Object {
            [pscustomobject]@{
                status      = $_.Status
                test        = $_.Test
                device      = $_.Device
                section     = $_.Section
                sectionRoot = Get-SectionGroupName $_.Section
                method      = $_.Method
                site        = $_.Site
                assessment  = $_.Assessment
                likelyCause = $_.Likely
                relatedPass = $_.RelatedPass
                commands    = $_.Commands
                check       = $_.Check
                details     = $_.DetailsLines
            }
        }
    )
}

$jsonPayload | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $JsonOutputPath -Encoding UTF8

Write-Host "Validation archive written to $OutputPath"
Write-Host "JSON archive written to $JsonOutputPath"
