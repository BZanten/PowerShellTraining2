
#
#  PS Intro 2
#
# PowerShell Introduction training
# Demonstration script
#
# Ben van Zanten
# Mar 2015

# Security
Get-ExecutionPolicy -List | Format-Table -AutoSize
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

#
# Show different Objects
#
Get-Process -name lsass
Get-Service -name bits

#Wildcards are allowed
Get-Process ccm*
Get-Service ccm*

#
# Objects can be examined using Get-Member (GM) cmdlet
#
Get-Process -name lsass | Get-Member
Get-Service -name bits  | GM

# Let op de verschillende onderdelen van de output
#    TypeName: System.Diagnostics.Process
#    Method
#    Property

# Show only the methods
Get-Process -name lsass | Get-Member -MemberType Method
# Show only the properties  (AliasProperty, NoteProperty, Property, ScriptProperty)
Get-Process -name lsass | Get-Member -MemberType Properties
Get-Process -Name lsass | Get-Member -MemberType Property

# CmdLets in the pipeline expect a special type of object
#   -InputObject <Process[]>
Get-Help Stop-Process -Detailed
Get-Help Stop-Process -Parameter input*

Notepad.exe
Get-Process -Name notepad
Get-Process -Name notepad | gm
Get-Process -Name notepad | Stop-Process -Confirm

# So you cannot (should not) place an object on the pipeline that is not the expected object type for the next cmdlet
Get-Service BITS | Stop-Process

Get-Service Bits
Get-Service Bits | Stop-Service -Confirm

# Other (generic) CmdLets that are designed with different kind of objects, expect an [object], can be any object
help Sort-Object
help Select-Object
help ForEach-Object

#####################################################################################################################

#
# Pipeline wordt vaak gebruikt voor interactieve sessies
#
# Proces met meer dan 500 handles
Get-Process | Where { $_.Handles -gt 500 } | Sort Threads | Format-Table -Property Handles,name,workingset,threads
# 10 processen met de meeste geheugengebruik
Get-Process | Sort WorkingSet | Select-Object -Last 10 | Format-Table

# Select object -first of -last laat het originele object intact
Get-Process | Sort WorkingSet | Select-Object -Last 10 | Get-Member
# Select object alleen bepaalde properties genereert een nieuw type object
Get-Process | Select-Object -Property Name,WorkingSet,ID
Get-Process | Select-Object -Property Name,WorkingSet,ID | Get-Member

# Grouping objects
Get-Process | group Company -NoElement | sort Count,Name -Descending
# Sorteren : Desc op count,   Asc op Name
Get-Process | group Company -NoElement | sort Count,@{Expr='Name';Desc=$false} -Descending

# Measure objects
Dir C:\Windows -File | Measure Length -Sum -Average
Dir C:\Windows -Recurse -File -Ea SilentlyContinue | Measure Length -Sum -Average -min -max


# Pipeline performance.  Filter zo vroeg mogelijk in de pipeline
$S1 = { Get-WmiObject -Class Win32_Group | where Domain -eq $env:COMPUTERNAME }
$S2 = { Get-WmiObject -Query "Select * from Win32_Group where domain='$Env:ComputerName'" }
Measure-Command -Expression $S1
Measure-Command -Expression $S2


###############################################################################################

# Special operators [ ] Index operator
$a = 1,2,3
$a[0]
$a[-1]

(Get-Hotfix | Sort InstalledOn)[-1]
Get-Hotfix | Sort InstalledOn | Select-Object -Last 1


#  -f  Format operator
"{0} tekst {1}, {2}" -f  1,"hello",[math]::pi
"{0} tekst {1,-10}, {2:N}" -f  1,"hello",[math]::pi

"User{0:D4}" -f 1
2..20 | % { "User{0:D4}"-f $_ }
Get-Date
Get-Date -Format "dd-MM-yyyy"Get-Date -Format "dd-MM-yyyy HH:mm:ss"# :: Static member operators[datetime]::Now[datetime]::Now | Get-Member[math]::pi[string]::IsNullOrEmpty($a)
