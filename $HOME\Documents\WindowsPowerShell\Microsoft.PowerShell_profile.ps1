# Create a BitHub shell profile locally
$profilePath = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

@'
function Import-BitHubManifest {
    param([string]$Path)
    Write-Host "Simulating import of manifest from $Path"
}

function Import-SwarmNetConfig {
    param([string]$Path)
    Write-Host "Simulating import of swarmnet config from $Path"
}

function Start-Win13Beta {
    Write-Host "Simulating Windows 13 beta boot in Bit.Hub..."
}

function Open-Trace {
    param([string]$Id)
    Write-Host "Simulating opening trace $Id"
}
'@ | Out-File -FilePath $profilePath -Encoding UTF8

# Reload your profile so the functions are available
. $profilePath
