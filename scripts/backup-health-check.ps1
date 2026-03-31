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

$results = foreach ($service in $config.services) {
    $name = $service.name
    $targetHost = $service.host
    $port = [int]$service.port

    try {
        $test = Test-NetConnection -ComputerName $targetHost -Port $port -InformationLevel Detailed -WarningAction SilentlyContinue
        [pscustomobject]@{
            Name = $name
            Host = $targetHost
            Port = $port
            Reachable = [bool]$test.TcpTestSucceeded
            RemoteAddress = $test.RemoteAddress
            CheckedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }
    catch {
        [pscustomobject]@{
            Name = $name
            Host = $targetHost
            Port = $port
            Reachable = $false
            RemoteAddress = "n/a"
            CheckedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }
}

$reportDir = Split-Path -Parent $OutputPath
if ($reportDir -and -not (Test-Path -LiteralPath $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir | Out-Null
}

$lines = @(
    "# Home Lab Health Report",
    "",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "",
    "| Service | Host | Port | Reachable | Remote Address | Checked At |",
    "| --- | --- | ---: | :---: | --- | --- |"
)

foreach ($result in $results) {
    $status = if ($result.Reachable) { "Yes" } else { "No" }
    $lines += "| $($result.Name) | $($result.Host) | $($result.Port) | $status | $($result.RemoteAddress) | $($result.CheckedAt) |"
}

$lines += ""
$lines += "## Notes"
$lines += "- This report is generated from a sanitized endpoint list."
$lines += "- Replace example hosts with lab-safe values before real use."

Set-Content -LiteralPath $OutputPath -Value $lines -Encoding UTF8
Write-Host "Report written to $OutputPath"
