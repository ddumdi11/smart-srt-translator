param(
  [switch]$DryRun
)

Write-Host "Cleaning build artifacts in repo root..."

# Helper to pass -WhatIf when DryRun is specified
$whatIf = @{}
if ($DryRun) { $whatIf = @{ WhatIf = $true } }

# 1) Remove dist/ and build/
foreach ($p in @('dist','build')) {
  if (Test-Path $p) {
    Write-Host "Removing $p/" -ForegroundColor Yellow
    Remove-Item -Recurse -Force $p @whatIf
  } else {
    Write-Host "$p/ not found (ok)" -ForegroundColor DarkGray
  }
}

# 2) Remove top-level *.egg-info (do NOT recurse into venv)
$egg = Get-ChildItem -Path . -Directory -Filter *.egg-info -ErrorAction SilentlyContinue
if ($egg) {
  foreach ($d in $egg) {
    Write-Host "Removing $($d.FullName)" -ForegroundColor Yellow
    Remove-Item -Recurse -Force $d.FullName @whatIf
  }
} else {
  Write-Host "No top-level *.egg-info found (ok)" -ForegroundColor DarkGray
}

Write-Host "Done. Rebuild with: python -m build" -ForegroundColor Green

