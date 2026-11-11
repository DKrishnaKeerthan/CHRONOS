# CHRONOS execution capture and immediate publication
# Run from the cloned repository root.
# Example:
# .\scripts\run_and_publish.ps1 -ScriptPath .\03_Simulations\Python\chronos_01_time_dilation.py -ArtifactPath .\03_Simulations\Python\chronos_01_time_dilation.png

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptPath,
    [string]$PythonCommand = "python",
    [string[]]$ArtifactPath = @()
)

$ErrorActionPreference = "Stop"
$repoRoot = (Get-Location).Path
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot ".git"))) {
    throw "Run this script from the root of a cloned CHRONOS Git repository."
}

$resolvedScript = (Resolve-Path -LiteralPath $ScriptPath).Path
$relativeScript = [System.IO.Path]::GetRelativePath($repoRoot, $resolvedScript).Replace("\", "/")
if ($relativeScript.StartsWith("../") -or [System.IO.Path]::IsPathRooted($relativeScript)) {
    throw "The script must be inside this repository so its exact source can be archived."
}

$python = Get-Command -Name $PythonCommand -CommandType Application -ErrorAction Stop | Select-Object -First 1
$pythonExe = $python.Source
if (-not $pythonExe) { throw "Could not resolve Python executable: $PythonCommand" }

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$runId = "CHRONOS-RUN-$timestamp-$([guid]::NewGuid().ToString('N').Substring(0,8))"
$relativeRunDir = "results/execution_logs/$runId"
$runDir = Join-Path $repoRoot ($relativeRunDir.Replace("/", "\"))
$sourceDir = Join-Path $runDir "source"
$artifactDir = Join-Path $runDir "artifacts"
New-Item -ItemType Directory -Path $sourceDir -Force | Out-Null
New-Item -ItemType Directory -Path $artifactDir -Force | Out-Null

$stdoutPath = Join-Path $runDir "stdout.txt"
$stderrPath = Join-Path $runDir "stderr.txt"
$sourceSnapshot = Join-Path $sourceDir ([System.IO.Path]::GetFileName($resolvedScript))
Copy-Item -LiteralPath $resolvedScript -Destination $sourceSnapshot
$scriptHash = (Get-FileHash -LiteralPath $resolvedScript -Algorithm SHA256).Hash
$snapshotHash = (Get-FileHash -LiteralPath $sourceSnapshot -Algorithm SHA256).Hash
$pythonVersion = (& $pythonExe --version 2>&1 | Out-String).Trim()
$osVersion = [System.Environment]::OSVersion.VersionString
$started = Get-Date
$exitCode = 9009

try {
    $quotedScript = '"' + $resolvedScript + '"'
    $process = Start-Process -FilePath $pythonExe -ArgumentList @("-u", $quotedScript) -WorkingDirectory (Split-Path -Parent $resolvedScript) -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -Wait -PassThru
    $exitCode = $process.ExitCode
}
catch {
    Add-Content -LiteralPath $stderrPath -Value ("RUNNER ERROR: " + $_.Exception.Message) -Encoding UTF8
}

$finished = Get-Date
$status = if ($exitCode -eq 0) { "PASS" } elseif ($exitCode -eq 9009) { "INTERRUPTED" } else { "FAIL" }
$duration = [math]::Round(($finished - $started).TotalSeconds, 3)

$artifactNotes = @()
foreach ($item in $ArtifactPath) {
    $candidate = if ([System.IO.Path]::IsPathRooted($item)) { $item } else { Join-Path $repoRoot $item }
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        $resolvedArtifact = (Resolve-Path -LiteralPath $candidate).Path
        $destination = Join-Path $artifactDir ([System.IO.Path]::GetFileName($resolvedArtifact))
        Copy-Item -LiteralPath $resolvedArtifact -Destination $destination -Force
        $hash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
        $artifactNotes += "- $([System.IO.Path]::GetFileName($resolvedArtifact)) — SHA-256: $hash"
    }
    else {
        $artifactNotes += "- MISSING: $item (not present after execution)"
    }
}
if ($artifactNotes.Count -eq 0) { $artifactNotes = @("- No artifact paths were supplied to the runner.") }

$interpretation = switch ($status) {
    "PASS" { "The process returned exit code 0. This is a software execution result, not by itself proof that the scientific model or interpretation is correct." }
    "FAIL" { "The process returned a non-zero exit code. This failed execution is retained; fix the cause and rerun under a new unique ID." }
    default { "The process could not be launched or completed normally. The runner error, if any, is retained in stderr.txt." }
}

$record = @"
# Execution record — $runId

- **Status:** $status
- **Exit code:** $exitCode
- **Started:** $($started.ToString("o"))
- **Finished:** $($finished.ToString("o"))
- **Duration:** $duration seconds
- **Script (repository-relative):** $relativeScript
- **Source SHA-256:** $scriptHash
- **Archived source:** source/$([System.IO.Path]::GetFileName($resolvedScript))
- **Archived source SHA-256:** $snapshotHash
- **Python executable:** $pythonExe
- **Python version:** $pythonVersion
- **Operating system:** $osVersion

## Captured output

- Standard output: stdout.txt
- Standard error: stderr.txt

## Artifacts

$($artifactNotes -join [Environment]::NewLine)

## Interpretation

$interpretation

## Reproducibility

The exact executed Python source is archived with this run. Source and archived-source SHA-256 values should match. Each execution receives a unique directory; later runs do not overwrite earlier successes or failures.

## Publication

The runner stages this execution directory only, commits it, and pushes the current branch to origin immediately after execution. If push fails, the complete record remains committed locally for a later push.
"@

Set-Content -LiteralPath (Join-Path $runDir "README.md") -Value $record -Encoding UTF8

git add -- $relativeRunDir
if ($LASTEXITCODE -ne 0) { throw "git add failed. Execution files remain at $runDir" }

git commit -m "Record $runId ($status)"
if ($LASTEXITCODE -ne 0) { throw "git commit failed. Execution files remain at $runDir" }

git push origin HEAD
if ($LASTEXITCODE -ne 0) {
    Write-Error "Execution was committed locally, but GitHub publication failed. Resolve the Git push issue and run: git push origin HEAD"
    exit 2
}

Write-Host ""
Write-Host "CHRONOS execution: $runId"
Write-Host "Process status: $status (exit code $exitCode)"
Write-Host "Archived source: $relativeRunDir/source/"
Write-Host "Published execution record: $relativeRunDir/"
exit $exitCode
