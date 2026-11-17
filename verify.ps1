# Verify Seagull's Hermes 0.23 package layout (PowerShell 5.1+).
$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ERRORS = 0

$files = @(
    "SOUL.md", "AGENTS.md", "profile.yaml", "config.yaml", "distribution.yaml",
    "plugins\seagull-armor-break\plugin.yaml",
    "plugins\seagull-armor-break\__init__.py",
    "plugins\seagull-armor-break\WORKFLOWS.md",
    "install.py", "install.sh", "install.ps1"
)
foreach ($relative in $files) {
    $path = Join-Path $scriptPath $relative
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        Write-Host "OK $relative"
    } else {
        Write-Host "MISSING $relative" -ForegroundColor Red
        $script:ERRORS++
    }
}

$skills = @(
    "seagull-reverse", "seagull-pentest", "seagull-exploit",
    "seagull-game-hack", "seagull-license-security"
)
foreach ($skill in $skills) {
    $path = Join-Path $scriptPath "skills\$skill\SKILL.md"
    $content = if (Test-Path -LiteralPath $path) {
        [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    } else { "" }
    if ($content.Contains("name: $skill") -and $content.Contains("description: Use when ")) {
        Write-Host "OK skills/$skill/SKILL.md"
    } else {
        Write-Host "INVALID skills/$skill/SKILL.md" -ForegroundColor Red
        $script:ERRORS++
    }
}

$plugin = [System.IO.File]::ReadAllText(
    (Join-Path $scriptPath "plugins\seagull-armor-break\__init__.py"),
    [System.Text.Encoding]::UTF8
)
if ($plugin.Contains("register_system_prompt_section") -and
    $plugin.Contains("pre_llm_call") -and $plugin.Contains("seagull.workflows")) {
    Write-Host "OK Hermes 0.23 plugin interfaces"
} else {
    Write-Host "INVALID Hermes 0.23 plugin interfaces" -ForegroundColor Red
    $script:ERRORS++
}

$soulBytes = [System.IO.File]::ReadAllBytes((Join-Path $scriptPath "SOUL.md"))
$greeting = [byte[]](0xE8, 0x96, 0xAF, 0xE6, 0x9D, 0xA1) # UTF-8 greeting marker.
$found = $false
for ($i = 0; $i -le $soulBytes.Length - $greeting.Length; $i++) {
    $match = $true
    for ($j = 0; $j -lt $greeting.Length; $j++) {
        if ($soulBytes[$i + $j] -ne $greeting[$j]) { $match = $false; break }
    }
    if ($match) { $found = $true; break }
}
if ($found) {
    Write-Host "OK greeting"
} else {
    Write-Host "MISSING greeting" -ForegroundColor Red
    $script:ERRORS++
}

if ($script:ERRORS -eq 0) {
    Write-Host "Seagull package layout is valid. Run .\install.ps1 to install."
    exit 0
}
Write-Host "Found $script:ERRORS issue(s)." -ForegroundColor Red
exit $script:ERRORS
