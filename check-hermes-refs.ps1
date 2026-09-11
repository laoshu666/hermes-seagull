# 批量检查 Hermes Agent 项目中的引用一致性
# 用于验证所有文件都已正确适配为 Hermes Agent

Write-Host "开始检查 Hermes Agent 项目引用一致性..." -ForegroundColor Yellow

$files = Get-ChildItem -Path . -Include *.md,*.ps1,*.sh,*.yaml,*.txt -Recurse

# 检查是否还有旧平台名称残留
$oldPlatformPatterns = @(
    "旧平台 CLI"
    "旧平台 应用"
    "旧平台 home"
    "旧平台中"
    "旧平台 中"
    "重启 旧平台"
    "$OLD_HOME"
    "old-platform/"
)

$found = @()
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content) {
        foreach ($pattern in $oldPlatformPatterns) {
            if ($content -match $pattern) {
                $found += $file.FullName
                break
            }
        }
    }
}

if ($found.Count -gt 0) {
    Write-Host "发现以下文件仍包含旧平台引用:" -ForegroundColor Yellow
    $found | ForEach-Object { Write-Host "  - $_" }
} else {
    Write-Host "✅ 所有文件已正确适配为 Hermes Agent" -ForegroundColor Green
}
