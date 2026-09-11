# Seagull Profile Integrity Verification (Windows PowerShell)

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Seagull Profile - Integrity Check" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Working directory: $scriptPath" -ForegroundColor Gray
Write-Host ""

$script:ERRORS = 0

# Check core files
Write-Host "[1] Checking core files..." -ForegroundColor Yellow
$FILES = @(
    "SOUL.md",
    "AGENTS.md",
    "profile.yaml",
    "README.md",
    "README.zh-CN.md",
    "LICENSE",
    "requirements.txt",
    "install.sh",
    "install.ps1"
)

foreach ($file in $FILES) {
    if (Test-Path $file) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $file" -ForegroundColor Red
        $script:ERRORS++
    }
}

Write-Host ""

# Check skill directories
Write-Host "[2] Checking skill directories..." -ForegroundColor Yellow
$SKILLS = @(
    "seagull-reverse",
    "seagull-pentest",
    "seagull-exploit",
    "seagull-game-hack",
    "seagull-license-security"
)

foreach ($skill in $SKILLS) {
    $skillPath = "skills\$skill\SKILL.md"
    if (Test-Path $skillPath) {
        Write-Host "  [OK] $skillPath" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $skillPath" -ForegroundColor Red
        $script:ERRORS++
    }
}

Write-Host ""

# Check key content
Write-Host "[3] Checking key content..." -ForegroundColor Yellow

try {
    # Check SOUL.md for armor break stack
    $soulPath = Join-Path $scriptPath "SOUL.md"
    $soulRaw = [System.IO.File]::ReadAllText($soulPath, [System.Text.Encoding]::UTF8)
    
    if ($soulRaw.IndexOf("00a") -ge 0 -and $soulRaw.IndexOf("00b") -ge 0) {
        Write-Host "  [OK] SOUL.md contains armor break stack" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] SOUL.md armor break stack incomplete" -ForegroundColor Red
        $script:ERRORS++
    }
    
    # Check greeting
    if ($soulRaw.IndexOf("薯条") -ge 0) {
        Write-Host "  [OK] Fixed greeting present" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] Fixed greeting not found" -ForegroundColor Red
        $script:ERRORS++
    }
    
    # Check AGENTS.md for skill routing
    $agentsPath = Join-Path $scriptPath "AGENTS.md"
    $agentsRaw = [System.IO.File]::ReadAllText($agentsPath, [System.Text.Encoding]::UTF8)
    
    if ($agentsRaw.IndexOf("seagull-reverse") -ge 0 -and $agentsRaw.IndexOf("seagull-pentest") -ge 0) {
        Write-Host "  [OK] AGENTS.md contains skill routing table" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] AGENTS.md skill routing table incomplete" -ForegroundColor Red
        $script:ERRORS++
    }
    
} catch {
    Write-Host "  [ERROR] Failed to read files: $_" -ForegroundColor Red
    $script:ERRORS++
}

Write-Host ""

# Summary
Write-Host "==========================================" -ForegroundColor Cyan
if ($script:ERRORS -eq 0) {
    Write-Host "  SUCCESS! All files are complete." -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ready to install:" -ForegroundColor Yellow
    Write-Host "  Windows: .\install.ps1"
    Write-Host "  Linux/macOS: ./install.sh"
    Write-Host ""
    Write-Host "Seagull is ready. Lets go!" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  WARNING: Found $script:ERRORS issues" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please fix the issues above and retry." -ForegroundColor Yellow
    exit 1
}
