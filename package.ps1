# Seagull Profile - Package and Release Script

$version = "1.0.0"
$packageName = "seagull-profile-v$version"
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Seagull Profile - Package Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Run verification first
Write-Host "[1] Running integrity check..." -ForegroundColor Yellow
.\verify.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Verification failed. Aborting package." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2] Creating package..." -ForegroundColor Yellow

# Create temp directory
$tempDir = Join-Path $env:TEMP $packageName
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Copy files
Write-Host "  Copying files to temp directory..." -ForegroundColor Gray
Copy-Item "SOUL.md" $tempDir
Copy-Item "AGENTS.md" $tempDir
Copy-Item "profile.yaml" $tempDir
Copy-Item "README.md" $tempDir
Copy-Item "README.zh-CN.md" $tempDir
Copy-Item "LICENSE" $tempDir
Copy-Item "requirements.txt" $tempDir
Copy-Item "install.sh" $tempDir
Copy-Item "install.ps1" $tempDir
Copy-Item "verify.ps1" $tempDir
Copy-Item -Recurse "skills" $tempDir
Copy-Item "distribution.yaml" $tempDir
Copy-Item "config.yaml" $tempDir
Copy-Item "activate-seagull.ps1" $tempDir
Copy-Item "seagull-update.ps1" $tempDir
Copy-Item "DEPLOY_zh-CN.md" $tempDir

# Plugin ships under dist/plugins/<name>/ so a profile install lands it at
# profiles/<name>/plugins/<name>/. Hermes plugin discovery is capped at two
# levels (plugins/<cat>/<name>/plugin.yaml); keep that shape in the archive.
$pluginDest = Join-Path $tempDir "plugins"
New-Item -ItemType Directory -Path $pluginDest -Force | Out-Null
Copy-Item -Recurse "seagull-armor-break" $pluginDest
Get-ChildItem -Path $pluginDest -Recurse -Directory -Filter "__pycache__" -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Create archive
$archiveName = "$packageName-$timestamp.zip"
Write-Host "  Creating archive: $archiveName" -ForegroundColor Gray
Compress-Archive -Path "$tempDir\*" -DestinationPath $archiveName -Force

# Cleanup
Remove-Item $tempDir -Recurse -Force

# Calculate hash
$hash = (Get-FileHash $archiveName -Algorithm SHA256).Hash

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Package created successfully!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "File: $archiveName" -ForegroundColor Yellow
Write-Host "Size: $([math]::Round((Get-Item $archiveName).Length / 1KB, 2)) KB"
Write-Host "SHA256: $hash" -ForegroundColor Gray
Write-Host ""
Write-Host "Ready to distribute!" -ForegroundColor Cyan
