# 通用引用替换工具（已完成 Hermes Agent 适配）
# 用于将其他项目适配为 Hermes Agent

$replacements = @{
    "OldPlatform CLI" = "Hermes Agent CLI"
    "OldPlatform 应用" = "Hermes Agent 应用"
    "OldPlatform home" = "Hermes Agent home"
    "OldPlatform中" = "Hermes Agent 中"
    "OldPlatform 中" = "Hermes Agent 中"
    "重启 OldPlatform" = "重启 Hermes Agent"
    "$OLD_HOME" = "$HERMES_HOME"
    "old-platform/" = "hermes/"
}

$files = @(
    "PROJECT_REPORT.txt"
    "DELIVERY.md"
    "INSTALL_GUIDE.md"
    "STRUCTURE.md"
    "QUICKSTART.md"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Encoding UTF8 -Raw
        foreach ($key in $replacements.Keys) {
            $content = $content -replace [regex]::Escape($key), $replacements[$key]
        }
        Set-Content $file $content -Encoding UTF8
        Write-Host "已处理: $file" -ForegroundColor Green
    }
}

Write-Host "替换完成！" -ForegroundColor Cyan
