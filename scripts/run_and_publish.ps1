# CHRONOS execution capture and publish runner
# Usage: .\scripts\run_and_publish.ps1 -ScriptPath .\03_Simulations\Python\chronos_01_time_dilation.py
# Run from the repository root. Requires Python and Git; GitHub authentication must already work.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptPath,
    [string]$PythonCommand = "python"
)

$ErrorActionPreference = "Stop"
$repoRoot = (Get-Location).Path
$resolvedScript = (Resolve-Path -LiteralPath $ScriptPath).Path
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot ".git"))) {
    throw "Run this script from the root of a cloned CHRONOS Git repository."
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$runId = "CHRONOS-RUN-$timestamp-$([guid]::NewGuid().ToString('N').Substring(0,8))"
$runDir = Join-Path $repoRoot "results\execution_logs\$runId"
New-Item -ItemType Directory -Path $runDir -Force | Out-Null

$stdoutPath = Join-Path $runDir "stdout.txt"
$stderrPath = Join-Path $runDir "stderr.txt"
$scriptHash = (Get-FileHash -LiteralPath $resolvedScript -Algorithm SHA256).Hash
$pythonVersion = (& $PythonCommand --version 2>&1 | Out-String).Trim()
$osVersion = [System.Environment]::OSVersion.VersionString
$started = Get-Date

$quotedScript = '"' + $resolvedScript + '"'
$process = Start-Process -FilePath $PythonCommand -ArgumentList @("-u", $quotedScript) -WorkingDirectory (Split-Path -Parent $resolvedScript) -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -Wait -PassThru

$finished = Get-Date
$status = if ($process.ExitCode -eq 0) { "PASS" } else { "FAIL" }
$duration = [math]::Round(($finished - $started).TotalSeconds, 3)
$interpretation = if ($process.ExitCode -eq 0) {
    "The process returned exit code 0. Review captured output and generated artifacts before treating the scientific result as validated."
} else {
    "The process returned a non-zero exit code. This run is preserved as a failure; correct the cause and execute again under a new run ID."
}

$record = @"
# Execution record — $runId

- **Status:** $status
- **Exit code:** $($process.ExitCode)
- **Started:** $($started.ToString("o"))
- **Finished:** $($finished.ToString("o"))
- **Duration:** $duration seconds
- **Script:** $resolvedScript
- **SHA-256:** $scriptHash
- **Python:** $pythonVersion
- **Operating system:** $osVersion

## Captured output

- Standard output: [stdout.txt](stdout.txt)
- Standard error: [stderr.txt](stderr.txt)

## Interpretation

$interpretation

## Publication

This record and both output streams are staged and committed by the runner. Git push is attempted immediately after the local commit.
"@

$recordPath = Join-Path $runDir "README.md"
Set-Content -LiteralPath $recordPath -Value $record -Encoding UTF8

git add -- $runDir
if ($LASTEXITCODE -ne 0) { throw "git add failed. Run artifacts remain in $runDir" }
git commit -m "Record $runId ($status)"
if ($LASTEXITCODE -ne 0) { throw "git commit failed. Run artifacts remain in $runDir" }
git push
if ($LASTEXITCODE -ne 0) {
    Write-Error "Execution was recorded locally, but GitHub publication failed. Run git push after fixing authentication or connectivity."
    exit 2
}

Write-Host ""
Write-Host "CHRONOS execution: $runId"
Write-Host "Scientific process status: $status (exit code $($process.ExitCode))"
Write-Host "Published run record: results/execution_logs/$runId/"
exit $process.ExitCode
