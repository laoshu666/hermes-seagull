# Seagull installer for Hermes 0.23 (Windows PowerShell 5.1+).
# Set HERMES_PYTHON to the Python environment used by Hermes.

param(
    [string]$Profile = "seagull"
)

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

$python = if ($env:HERMES_PYTHON) { $env:HERMES_PYTHON } else {
    $command = Get-Command python -ErrorAction SilentlyContinue
    if ($command) { $command.Source } else { "python" }
}

if (-not (Test-Path -LiteralPath $python) -and -not (Get-Command $python -ErrorAction SilentlyContinue)) {
    Write-Error "Python was not found. Install Hermes 0.23 and set HERMES_PYTHON."
    exit 1
}

$env:SEAGULL_PROFILE = $Profile
& $python "$PSScriptRoot\install.py"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Seagull installation failed. Set HERMES_PYTHON to Hermes' Python environment and retry."
    exit $LASTEXITCODE
}

