# prod://bithub/shell/profile.ps1
# Purpose: Set the Bit.Hub shell with latest modules, safety rails, and sim/prod routes

# 1) Safety rails
Set-ExecutionPolicy -Scope Process -ExecutionPolicy AllSigned -Force
$ErrorActionPreference = 'Stop'

# 2) Namespaces
$env:BIT_HUB_NS_SIM = "sim://"
$env:BIT_HUB_NS_PROD = "prod://"

# 3) Modules
Import-Module BitHub.Orchestrator
Import-Module ALN.VisualTrace
Import-Module SwarmNet.Safety
Import-Module Lakehouse.Pipelines

# 4) Context banner
Write-Host ("Bit.Hub Shell — Context: {0}" -f $(if($env:BH_CONTEXT){$env:BH_CONTEXT}else{"prod"})) -ForegroundColor Cyan

# 5) Guard: prevent sim artifacts from executing in prod
function Assert-RealityBoundary {
  param([string]$Path)
  if ($env:BH_CONTEXT -eq 'prod' -and $Path -like 'sim://*') {
    throw "Blocked: sim artifact in prod context."
  }
}

# 6) One-liners
function Start-Win13Beta { Invoke-BitHubRollout -Manifest "sim://manifests/win13-beta.manifest.yaml" }
function Open-Trace { param($Id) Show-VisualTrace -Id $Id }

# 7) BCI de-escalation gate
function Test-BCI {
  if (Test-Path "prod://bci/flags/deescalate.txt") { return $false } else { return $true }
}
