#!/usr/bin/env pwsh
Param()
Set-StrictMode -Version Latest

# PowerShell hook to update Last Update lines on Windows (PowerShell Core or Windows PowerShell)
$date = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')
$files = @('LLM-D_Inference_Scheduler.md', 'README.md', 'LLM-D_Inference_Scheduler (Short).md')
$changed = $false
foreach ($f in $files) {
    if (Test-Path $f) {
        $content = Get-Content $f -Raw
        if ($content -match '^Last Update:') {
            $new = ($content -replace '(?m)^Last Update:.*', "Last Update: $date")
            if ($new -ne $content) {
                $new | Set-Content $f -NoNewline
                $changed = $true
            }
        } else {
            $firstLine = Get-Content $f -TotalCount 1
            $rest = Get-Content $f | Select-Object -Skip 1
            $out = @()
            $out += $firstLine
            $out += ''
            $out += "Last Update: $date"
            $out += $rest
            $out | Set-Content $f -NoNewline
            $changed = $true
        }
    }
}

if (-not $changed) {
    Write-Host 'No files updated.'
    exit 0
}

git add $files
$diff = git diff --cached --quiet; if ($LASTEXITCODE -eq 0) { Write-Host 'Nothing to commit'; exit 0 }
git commit -m "chore: update Last Update dates (hook)"

exit 0
