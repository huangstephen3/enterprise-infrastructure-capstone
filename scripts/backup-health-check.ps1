param(
    [string]$ConfigPath = ".\\config\\sample-endpoints.json",
    [string]$OutputPath = ".\\reports\\latest-health-report.md",
    [int]$TimeoutSeconds = 5
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json

if (-not $config.services) {
    throw "No services defined in $ConfigPath"
}

$supportsSkipCertificateCheck = $null -ne (Get-Command Invoke-WebRequest).Parameters["SkipCertificateCheck"]

function Test-TcpEndpoint {
    param(
        [Parameter(Mandatory = $true)][string]$HostName,
        [Parameter(Mandatory = $true)][int]$Port
    )

    $test = Test-NetConnection -ComputerName $HostName -Port $Port -InformationLevel Detailed -WarningAction SilentlyContinue

    return [pscustomobject]@{
        Reachable = [bool]$test.TcpTestSucceeded
        Evidence = if ($test.TcpTestSucceeded) { "TCP connection succeeded" } else { "TCP connection failed" }
        RemoteAddress = $test.RemoteAddress
        Target = "$HostName`:$Port"
        Protocol = "tcp"
    }
}

function Test-HttpEndpoint {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [int[]]$ExpectedStatus = @(200, 301, 302)
    )

    $requestParams = @{
        Uri = $Url
        Method = "Get"
        TimeoutSec = $TimeoutSeconds
        MaximumRedirection = 0
        ErrorAction = "Stop"
    }

    if ($supportsSkipCertificateCheck) {
        $requestParams["SkipCertificateCheck"] = $true
    }

    try {
        $response = Invoke-WebRequest @requestParams
        $statusCode = [int]$response.StatusCode
    }
    catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        else {
            return [pscustomobject]@{
                Reachable = $false
                Evidence = $_.Exception.Message
                RemoteAddress = "n/a"
                Target = $Url
                Protocol = "http"
                StatusCode = "n/a"
            }
        }
    }

    $healthy = $ExpectedStatus -contains $statusCode

    return [pscustomobject]@{
        Reachable = $healthy
        Evidence = "HTTP status $statusCode"
        RemoteAddress = "n/a"
        Target = $Url
        Protocol = "http"
        StatusCode = $statusCode
    }
}

$results = foreach ($service in $config.services) {
    $name = $service.name
    $kind = if ($service.kind) { $service.kind.ToString().ToLowerInvariant() } else { "tcp" }
    $category = if ($service.category) { $service.category } else { "uncategorized" }
    $criticality = if ($service.criticality) { $service.criticality } else { "medium" }
    $notes = if ($service.notes) { $service.notes } else { "" }

    try {
        if ($kind -eq "http") {
            $expectedStatus = @()
            if ($service.expectedStatus) {
                $expectedStatus = @($service.expectedStatus | ForEach-Object { [int]$_ })
            }
            if (-not $expectedStatus -or $expectedStatus.Count -eq 0) {
                $expectedStatus = @(200, 301, 302)
            }
            $check = Test-HttpEndpoint -Url $service.url -ExpectedStatus $expectedStatus
        }
        else {
            $check = Test-TcpEndpoint -HostName $service.host -Port ([int]$service.port)
        }

        [pscustomobject]@{
            Name = $name
            Category = $category
            Criticality = $criticality
            Kind = $check.Protocol
            Target = $check.Target
            Reachable = [bool]$check.Reachable
            Evidence = $check.Evidence
            RemoteAddress = $check.RemoteAddress
            Notes = $notes
            CheckedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }
    catch {
        [pscustomobject]@{
            Name = $name
            Category = $category
            Criticality = $criticality
            Kind = $kind
            Target = if ($service.url) { $service.url } else { "$($service.host):$($service.port)" }
            Reachable = $false
            Evidence = $_.Exception.Message
            RemoteAddress = "n/a"
            Notes = $notes
            CheckedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }
}

$reportDir = Split-Path -Parent $OutputPath
if ($reportDir -and -not (Test-Path -LiteralPath $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir | Out-Null
}

$healthyCount = @($results | Where-Object { $_.Reachable }).Count
$unhealthyCount = @($results | Where-Object { -not $_.Reachable }).Count
$highPriorityFailures = @($results | Where-Object { -not $_.Reachable -and $_.Criticality -eq "high" })

$lines = @(
    "# Enterprise Infrastructure Capstone Health Report",
    "",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "",
    "## Summary",
    "",
    "- Total checks: $($results.Count)",
    "- Healthy: $healthyCount",
    "- Unhealthy: $unhealthyCount",
    "- High-priority failures: $($highPriorityFailures.Count)",
    "",
    "## Service Results",
    "",
    "| Service | Category | Type | Target | Criticality | Reachable | Evidence | Checked At |",
    "| --- | --- | --- | --- | --- | :---: | --- | --- |"
)

foreach ($result in $results) {
    $status = if ($result.Reachable) { "Yes" } else { "No" }
    $lines += "| $($result.Name) | $($result.Category) | $($result.Kind) | $($result.Target) | $($result.Criticality) | $status | $($result.Evidence) | $($result.CheckedAt) |"
}

$lines += ""
$lines += "## Operational Interpretation"
$lines += "- Treat management-path failures first because they block visibility into the rest of the environment."
$lines += "- Treat storage and backup failures as platform-level issues, especially when repository reachability is involved."
$lines += "- Use this report as a first-pass signal, then verify the affected service plane with CLI or console evidence."
$lines += ""
$lines += "## Notes"
$lines += "- This report is generated from a sanitized endpoint list."
$lines += "- Replace example hosts and URLs with lab-safe values before real use."
$lines += "- Sample categories reflect the service planes described in the public architecture notes."

Set-Content -LiteralPath $OutputPath -Value $lines -Encoding UTF8
Write-Host "Report written to $OutputPath"
