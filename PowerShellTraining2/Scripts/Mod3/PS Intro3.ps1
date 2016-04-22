
#
#  PS Intro 3
#
# PowerShell Introduction training
# Demonstration script
#
# Ben van Zanten
# Mar 2015

#region Extending PowerShell
# PSSnapins en modules
Get-Command -Noun PSSnapin
Get-PSSnapin
Get-PSSnapin -Registered

Add-PSSnapin <name>
Get-Command -Module <name>
#endregion

#region Compile custom PSSnapin
dir *.cs
ise .\PSDemoSnapin.cs

dir PSDemoSnapin.*
# Remove old files from previous demonstrations.
if (Test-Path .\PSDemoSnapin.dll) { Remove-Item .\PSDemoSnapin.dll -Force }
if (Test-Path .\PSDemoSnapin.InstallLog) { Remove-Item .\PSDemoSnapin.InstallLog -Force }
# Compile the source code to .DLL
C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe /target:library /reference:C:\Windows\Microsoft.NET\assembly\GAC_MSIL\System.Management.Automation\v4.0_3.0.0.0__31bf3856ad364e35\System.Management.Automation.dll PSDemoSnapin.cs
dir PSDemoSnapin.*
# Install the DLL in order to be able to use it  use the first (x86) or second (x64) InstallUtil command
Get-PSSnapin -Registered
C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe   PSDemoSnapin.dll
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe PSDemoSnapin.dll
Get-PSSnapin -Registered
Get-PSSnapin
Add-PSSnapin Valid.Demo.PSDemo
Get-PSSnapin
Get-Command -Module Valid.Demo.PSDemo
Write-Hi
Write-Hello
Get-Uptime
Get-This
Remove-PSSnapin Valid.Demo.PSDemo -passthru
C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe   /u PSDemoSnapin.dll
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /u PSDemoSnapin.dll
del PSDemoSnapin.dll

dir *.cs ; dir *.dll
#endregion

#region Demo Module
# Module
Get-Command -Noun Module
Get-Module
Get-Module -ListAvailable

Import-Module ActiveDirectory
Get-Command -Module ActiveDirectory
Help Get-ADUser
Get-ADUser -Filter "*"
Get-PSDrive | Sort Provider
Get-PSDrive -PSProvider ActiveDirectory
cd AD:
dir
cd 'AD:\DC=lng,DC=local'
dir
cd .\CN=Users
dir

#AutoLoad:
Get-Module
help Get-SmbShare
Get-Module
#endregion

#region PowerShell Providers
Get-PSProvider
Get-PSProvider -PSProvider FileSystem
Get-PSDrive
# Het zijn objecten  ;-)
Get-PSDrive | Sort Provider

Add-Module ActiveDirectory

# Create new provider. FileSystem
New-PSDrive -Name Opl -PSProvider FileSystem -Root \\NFCPCA01\Public\ITM\Infrastructuur\Documentatie\Powershell\Opleiding
Dir Opl:\*.ps1

# Create new provider. Registry
Get-PSDrive -PSProvider Registry
if (!(Get-PSDrive -Name HKCR -ErrorAction SilentlyContinue)) {
    New-PSDrive -PSPRovider Registry -Root HKEY_CLASSES_ROOT -Name HKCR
} 
Get-PSDrive -PSProvider Registry
Dir HKCR:\.doc
Remove-PSDrive -Name HKCR

#endregion


#region Enable Remoting
Help Enable-PSRemoting -ShowWindow
Get-Service WinRM
Enable-PSRemoting
Get-Service WinRM

# Show the configured end points!
Get-PSSessionConfiguration
Get-PSSessionConfiguration "Microsoft.PowerShell" | Select *

# use the winrm commandline tool to view settings
winrm get winrm/config

Test-WSMan
Test-WSMan  behpwa05
Test-WSMan  behpwa05 -Credential "FVLPROD\udaBZa"

#endregion

#region WSMAN:

cd WSMan:
dir
cd .\localhost
dir

dir .\Listener -Recurse | Select Name,Value
dir .\Shell
dir .\Client -Recurse
dir .\Service -Recurse

# the endpoints
dir .\Plugin

cd C:\

cls
#endregion

#region Configure TrustedHosts

Get-Item WSMan:\localhost\Client\TrustedHosts

Test-WSMan behpwa05
Invoke-Command -ScriptBlock { hostname } -ComputerName behpwa05
Invoke-Command -ScriptBlock { hostname } -ComputerName behpwa05  -Credential "FVLPROD\udaBZa"

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*.fvlprod.fvl"
Get-Item WSMan:\localhost\Client\TrustedHosts
Invoke-Command -ScriptBlock { hostname } -ComputerName behpwa05  -Credential "FVLPROD\udaBZa"

#endregion

#region Demo remoting

#Prereq: local administrative privileges are needed, lets temp. grant on a number of VDI desktops
40..50
40..50 | % { "VDIPM{0}" -f $_ }
40..50 | % { "VDIPM{0:D4}" -f $_ }
40..50 | % { "VDIPM{0:D4}" -f $_ } | % { Invoke-Command -ComputerName $_ -ScriptBlock { Net localgroup administrators }}
40..50 | % { "VDIPM{0:D4}" -f $_ } | % { Invoke-Command -ComputerName $_ -ScriptBlock { Net localgroup administrators "fvlprod\Domain users" /add }}
40..50 | % { "VDIPM{0:D4}" -f $_ } | % { Invoke-Command -ComputerName $_ -ScriptBlock { Net localgroup administrators }}

# Interactieve sessie naar een client
Enter-PSSession -ComputerName vdipm0040
hostname
dir C:\Temp
Get-Service BITS,CcmExec
Restart-Service CcmExec
Exit-PSSession

# Interactieve sessie naar een server.  "Telnet" - The PowerShell way
Enter-PSSession -ComputerName sqlpwa20 -Credential 'fvlprod\udabza'
hostname
dir C:\Temp
Get-Service BITS,CcmExec
Get-Module
Get-Module -ListAvailable
Import-Module SQLPS
Get-Command -Module SQLPS
Get-PSProvider
Get-PSDrive -PSProvider SqlServer
cd SQLSERVER:\
dir
cd SQL
dir
cd .\SQLPWA20
dir
cd .\VLB_EINDHOVEN
dir
cd .\Databases
dir
cd .\IntelSCSDb
dir
cd .\Tables
dir
Get-Command -Module SQLPS -Verb Invoke
help Invoke-Sqlcmd -ShowWindow
help Invoke-Sqlcmd
Invoke-SqlCmd -Query "Select * from dbo.amt"
Invoke-SqlCmd -Query "Select * from dbo.amt" | Format-Table -Property amt_id,uuic,amt_version,curr_amt_fqdn -AutoSize
cd \
cd C:\

Exit-PSSession


Invoke-Command -ComputerName 'vdipm0040','vdipm0042' -ScriptBlock {
  Get-Service CcmExec
}
# Returned objects are deserialized
Invoke-Command -ComputerName 'vdipm0040','vdipm0042' -ScriptBlock {
  Get-Service CcmExec
} | Get-Member
# Vergelijk met een lokaal ServiceObject
Get-Service | Get-Member

#Input Computerlijst via een file:
cat Servers.txt
cat Servers.txt | ForEach-Object { Invoke-Command -ComputerName $_ -ScriptBlock {  Get-Service CcmExec } }


# Zie Wiki page voor PowerShell remoting voorbeelden
Start-Process 'http://wikpla01.fvl.com/wiki/index.php/PowerShell_remoting'

$CredBvZ = Get-Credential 'fvlprod\udabza'
Import-Module ActiveDirectory
$VerbosePreference='Continue'
ForEach ($COMPUTER in $(Get-ADComputer -Filter * -Searchbase "OU=VM,OU=Win7,OU=FvLWorkstations,DC=fvlprod,DC=fvl")){
# $CMName | sort | ForEach-Object { Invoke-Command -ComputerName $_ -ScriptBlock {  Get-Service CcmExec } }
  if (Test-Connection -ComputerName $COMPUTER.Name -Count 1 -ErrorAction SilentlyContinue) {
    Write-Debug "Connecting to $($COMPUTER.Name)"
    Invoke-Command $COMPUTER.Name { Get-Service CcmExec } -Credential $CredBvZ # -AsJob
  } else {
    Write-Verbose "$($COMPUTER.Name) not reachable"
  }
}

Get-Command -Noun Job*
Get-Job
Get-Job -Newest 1
Get-Job  | Receive-Job


#Local parameters are NOT known remotely!
# Arguments:  Local arguments don't work
$Log='security'
$Aantal = 5
$CmpList = 'vdipm0040','vdipm0042','behpwa05'
# DOES NOT work, local vars are not known remote
Invoke-Command -ComputerName $CmpList -ScriptBlock {
  Get-EventLog -LogName $Log -Newest $Aantal
}
# DOES work, if local vars are passed as parameter
Invoke-Command -ComputerName $CmpList -ScriptBlock {
  Param($a, $b)  Get-EventLog -LogName $a -Newest $b
} -ArgumentList $Log,$Aantal


# Non Persistent:
$CmpList = 'vdipm0040','vdipm0043'
Invoke-Command -ComputerName $CmpList -ScriptBlock { $a=3 }
Invoke-Command -ComputerName $CmpList -ScriptBlock { $a }

#Make persistent using a PSSession Variable
$MySession = New-PSSession -ComputerName $CmpList
Get-PSSession
Invoke-Command -Session $MySession -ScriptBlock { $a=(Dir C:\ -File).Count }
Invoke-Command -Session $MySession -ScriptBlock { $a }

Get-PSSession -ComputerName 'vdipm0040'
Disconnect-PSSession -Session $MySession
Get-PSSession -ComputerName 'vdipm0040'
$MySession
Disconnect-PSSession $MySession
Invoke-Command -Session $MySession -ScriptBlock { $a }
Connect-PSSession $MySession
Invoke-Command -Session $MySession -ScriptBlock { $a }
Get-Command -Noun PSSession
Remove-PSSession $MySession
Get-PSSession

#Implicit remoting
$MySQL = New-PSSession -ComputerName 'sqlpwa20'  -Credential "FVLPROD\UDABZA"
Get-Module -PSSession $MySQL -ListAvailable
Import-Module -PSSession $MySQL -Name ActiveDirectory -Prefix Rem
Get-RemAdGroup -filter *

$MySQL | Remove-PSSession
Get-PSSession
# Implicit remoting will (try to) recreate the session
Get-RemAdUser -Filter *
Get-PSSession




#Postreq: local administrative privileges are needed, remove on a number of VDI desktops
40..50 | % { "VDIPM{0:D4}" -f $_ } | % { Invoke-Command -ComputerName $_ -ScriptBlock { Net localgroup administrators "fvlprod\Domain users" /delete }}
40..50 | % { "VDIPM{0:D4}" -f $_ } | % { Invoke-Command -ComputerName $_ -ScriptBlock { Net localgroup administrators }}

#endregion
