Param()
Write-Host "Setting git core.hooksPath to .githooks (repository local hooks)"
git config core.hooksPath .githooks
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to set core.hooksPath. Run this command manually: git config core.hooksPath .githooks" -ForegroundColor Red
    exit 1
}
Write-Host "core.hooksPath set. Ensure you have execution rights for scripts on Windows if using PowerShell hooks."
Write-Host "To enable (bash): git config core.hooksPath .githooks"
Write-Host "To enable (PowerShell): run this script from PowerShell as .\scripts\setup-hooks.ps1"
