# Milestone gate (CLAUDE.md): format, analyze, test. Pass -Integration to also
# run integration_test (required from M3; needs a device or desktop target).
param([switch]$Integration)
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

function Invoke-Step([string]$exe, [string[]]$arguments) {
  & $exe @arguments
  if ($LASTEXITCODE -ne 0) { throw "$exe $($arguments -join ' ') failed" }
}

Invoke-Step flutter @('gen-l10n')
Invoke-Step dart @('format', '--set-exit-if-changed', '.')
Invoke-Step flutter @('analyze')
Invoke-Step flutter @('test')
if ($Integration) { Invoke-Step flutter @('test', 'integration_test') }
