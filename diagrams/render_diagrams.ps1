#!/usr/bin/env pwsh
<#
Render all Mermaid `.mmd` files in this directory to `.svg` using the
Mermaid CLI via `npx`.

Usage:
  .\render_diagrams.ps1

This script expects `node`/`npx` to be available on PATH. It will call
`npx -y @mermaid-js/mermaid-cli` for each `*.mmd` file.
#>
$ErrorActionPreference = 'Stop'
Write-Host "Rendering Mermaid diagrams to SVG..."
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $here
$files = Get-ChildItem -Filter '*.mmd' -File
if ($files.Count -eq 0) {
    Write-Host "No .mmd files found in $here"
    Pop-Location
    exit 0
}

# Optional PNG sizing: set environment variables MERMAID_PNG_WIDTH, MERMAID_PNG_HEIGHT or MERMAID_PNG_SCALE
$pngWidth = $env:MERMAID_PNG_WIDTH
$pngHeight = $env:MERMAID_PNG_HEIGHT
$pngScale = $env:MERMAID_PNG_SCALE

function Get-MermaidPngArgs {
  $args = @()
  if ($pngWidth) { $args += "-w"; $args += $pngWidth }
  if ($pngHeight) { $args += "-H"; $args += $pngHeight }
  if (-not $pngWidth -and -not $pngHeight -and $pngScale) { $args += "-s"; $args += $pngScale }
  return $args
}

function Get-SvgDimensions {
  param($svgPath)
  $raw = Get-Content -Raw -Path $svgPath
  if ($raw -match 'viewBox="[^"]*?\s+([0-9]+(?:\.[0-9]+)?)\s+([0-9]+(?:\.[0-9]+)?)"') {
    return @{ Width = [int][math]::Ceiling([double]$matches[1]); Height = [int][math]::Ceiling([double]$matches[2]) }
  }
  $w = $null; $h = $null
  if ($raw -match 'width="([0-9]+(?:\.[0-9]+)?)(px)?"') { $w = [int][math]::Ceiling([double]$matches[1]) }
  if ($raw -match 'height="([0-9]+(?:\.[0-9]+)?)(px)?"') { $h = [int][math]::Ceiling([double]$matches[1]) }
  if ($w -and $h) { return @{ Width = $w; Height = $h } }
  return $null
}

function Convert-SvgToPng {
  param($svgPath, $pngPath)
}
foreach ($f in $files) {
  $in = $f.Name
  $outSvg = [System.IO.Path]::ChangeExtension($in, '.svg')
  $outPng = [System.IO.Path]::ChangeExtension($in, '.png')
  Write-Host "Rendering $in -> $outSvg"
  npx -y @mermaid-js/mermaid-cli -i $in -o $outSvg

  Write-Host "Rendering $in -> $outPng (direct from mermaid-cli)"
  $dims = Get-SvgDimensions $outSvg
  if ($dims -and $dims.Width -and $dims.Height) {
    $args = @()
    $args += "-w"; $args += $dims.Width
    $args += "-H"; $args += $dims.Height
    npx -y @mermaid-js/mermaid-cli -i $in -o $outPng @args
  } else {
    $pngArgs = Get-MermaidPngArgs
    if ($pngArgs.Count -gt 0) { npx -y @mermaid-js/mermaid-cli -i $in -o $outPng @pngArgs }
    else { npx -y @mermaid-js/mermaid-cli -i $in -o $outPng }
  }
}

Write-Host "Rendering Graphviz .dot files to SVG..."
$dotPath = $null
try { $dotCmd = Get-Command dot -ErrorAction Stop; $dotPath = $dotCmd.Source } catch {}
if (-not $dotPath) {
  $candidate = 'C:\Program Files\Graphviz\bin\dot.exe'
  if (Test-Path $candidate) { $dotPath = $candidate }
  else {
    $candidate2 = 'C:\Program Files (x86)\Graphviz\bin\dot.exe'
    if (Test-Path $candidate2) { $dotPath = $candidate2 }
  }
}

$dotFiles = Get-ChildItem -Filter '*.dot' -File
foreach ($f in $dotFiles) {
  $in = $f.Name
  $outSvg = [System.IO.Path]::ChangeExtension($in, '.svg')
  $outPng = [System.IO.Path]::ChangeExtension($in, '.png')
  Write-Host "Rendering $in -> $outSvg"
  if ($dotPath) {
    & $dotPath -Tsvg $in -o $outSvg
  } else {
    Write-Host "`tdot not found on PATH; attempting Docker fallback (requires Docker)."
    docker run --rm -v ${PWD}:/work -w /work eclipse/graphviz dot -Tsvg $in -o $outSvg
  }

    Write-Host "Rendering $in -> $outPng"
    if ($dotPath) { & $dotPath -Tpng $in -o $outPng }
    else { docker run --rm -v ${PWD}:/work -w /work eclipse/graphviz dot -Tpng $in -o $outPng }
}
Pop-Location
Write-Host "Done."
