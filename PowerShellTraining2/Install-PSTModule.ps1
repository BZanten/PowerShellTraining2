
if (Test-Path $home\Documents\WindowsPowerShell\Modules) {
  $DestinPath = "$home\Documents\WindowsPowerShell\Modules"
} else {
  $DestinPath = $Env:psmodulepath -split ';' | Where-Object { $_ -match 'C:\\'  } | Select-Object -First 1
}



Copy-Item -Path $PSScriptRoot -Destination (Join-Path $DestinPath "PowershellTraining1") -Recurse

