# Bit.Hub comm guard (PowerShell)
function Enable-BitHubChannel {
  param(
    [Parameter(Mandatory)] [string] $ChannelName
  )
  # Enforce: signed policy, allow-list, and audit span
  Assert-SignedPolicy "/policies/comm.bitshell"
  Assert-AllowList $ChannelName
  Start-AuditSpan -Name "comm:$ChannelName"

  # Refuse covert/undeclared channels
  if (Test-UndeclaredChannel $ChannelName) {
    throw "Blocked: undeclared/covert channels are prohibited."
  }

  Write-Host "Channel $ChannelName enabled under audit."
}

function Disable-BitHubChannel {
  param([string] $ChannelName)
  Stop-AuditSpan -Name "comm:$ChannelName"
  Write-Host "Channel $ChannelName disabled and audit closed."
}
