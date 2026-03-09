#!/usr/bin/env pwsh

Param()
Set-StrictMode -Version Latest

# Helper: write text into existing file without replacing inode (preserves hard links)
function Write-PreserveInode {
    param(
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [string] $Text
    )
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Truncate, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    try {
        $fs.Write($bytes, 0, $bytes.Length)
        $fs.Flush()
    } finally {
        $fs.Close()
    }
}

# PowerShell hook to update Last Update lines on Windows (PowerShell Core or Windows PowerShell)
$date = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')
$files = @('LLM-D_Inference_Scheduler.md', 'README.md', 'LLM-D_Inference_Scheduler (Short).md')
$changed = $false
foreach ($f in $files) {
    if (Test-Path $f) {
        $content = Get-Content $f -Raw
        if ($content -match '(?m)^Last Update:') {
            $new = ($content -replace '(?m)^Last Update:.*', "Last Update: $date")
            if ($new -ne $content) {
                Write-PreserveInode -Path $f -Text $new
                $changed = $true
            }
        } else {
            $lines = Get-Content $f
            if ($lines.Count -ge 1) {
                $firstLine = $lines[0]
                $rest = if ($lines.Count -gt 1) { $lines[1..($lines.Count-1)] } else { @() }
                $out = @()
                $out += $firstLine
                $out += ''
                $out += "Last Update: $date"
                $out += $rest
                $text = $out -join [Environment]::NewLine
                Write-PreserveInode -Path $f -Text $text
                $changed = $true
            }
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
