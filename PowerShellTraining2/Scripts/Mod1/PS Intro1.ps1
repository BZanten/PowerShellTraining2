
#
#  PS Intro 1
#
# PowerShell Introduction training
# Demonstration script
#
# Ben van Zanten
# Mar 2015


#
# Show Native PowerShell support for different filesystems through PowerShell providers
#

# Filesystem
Dir C:\Temp

# Registry (default: only HKLM and HKCU )         (IF getting access denied error: run this ISE elevated!)
Dir HKLM:\Software\Microsoft\Windows\CurrentVersion\Setup

# Certificates
Dir Cert:\LocalMachine\My

# WMI
Get-WmiObject Win32_Volume

Get-WmiObject Win32_Volume | Format-Table -Property Caption,DriveLetter,DriveType,Label,Capacity,FreeSpace   -AutoSize

#
# .NET Framework support
# Windows Form  (OpenFile dialog)
#
[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
$OpenFile = New-Object System.Windows.Forms.OpenFileDialog
$OpenFile.Filter = "log files (*.log)|*.log|All files (*.*)|*.*"
if ($OpenFile.ShowDialog() -eq "OK" ) { Get-Content $OpenFile.FileName }

#
# .NET Framework support #2
#  Download a file without additional utilities
#
$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

$source = "http://icons.iconarchive.com/icons/google/chrome/256/Google-Chrome-icon.png"
$destination = "C:\Temp\Google-Chrome-icon.png"
If (!(Test-Path C:\Temp)) { MD C:\Temp }

$wc = New-Object System.Net.WebClient
$wc.Proxy = $proxy
$wc.DownloadFile($source, $destination)
Dir $destination
Start-Process -FilePath $destination

#
# .NET Framework support #3
#  Example building a Windows form from PowerShell
#   Source:http://blogs.technet.com/b/stephap/archive/2012/04/23/building-forms-with-powershell-part-1-the-form.aspx

Add-Type -AssemblyName System.Windows.Forms 
$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Mooi plaatje he?"
 
$Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$Form.Icon = $Icon
 
$Image = [system.drawing.image]::FromFile("$($Env:SystemRoot)\Web\Wallpaper\Theme1\img4.jpg")
$Form.BackgroundImage = $Image
$Form.BackgroundImageLayout = "None"
    # None, Tile, Center, Stretch, Zoom
$Form.Width = 100
$Form.Height = 200
$Font = New-Object System.Drawing.Font("Times New Roman",24,[System.Drawing.FontStyle]::Italic)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
$Form.Font = $Font
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "This is a picture $($Env:SystemRoot)\Web\Wallpaper\Theme1\img4.jpg "
$Label.BackColor = "Transparent"
$Label.ForeColor = [System.Drawing.Color]::Azure
$Label.AutoSize = $True
$Form.Controls.Add($Label)
$Form.ShowDialog() 


#
# Get Drivers using .NET
# use Out-GridView for GUI output !
#
Function Get-DeviceDriverService { Param([string]$computer="localhost")
 Add-Type -AssemblyName System.ServiceProcess
 [System.ServiceProcess.ServiceController]::GetDevices($computer)
} 

Get-DeviceDriverService -computer "Localhost" | 
  Select-Object -Property name, displayname, servicetype, status, 
    DependentServices, ServicesDependOn |
      Out-GridView -Title "Device Driver Services"



Get-CimInstance -ClassName win32_volume


#
# COM support
#  Start Microsoft Office Excel, create a new document and fill it with local drive info
#
# Voer regel - voor - regel uit. mbv F8
#
$Excel = New-Object -ComObject "Excel.Application"
$Excel.Visible=$True
$Workbook = $Excel.Workbooks.Add()
$diskSpacewksht= $workbook.Worksheets.Item(1)
$diskSpacewksht.Name = 'DriveSpace'
$diskSpacewksht.Cells.Item(1,1) = 'Caption'
$diskSpacewksht.Cells.Item(1,2) = 'DriveLetter'
$diskSpacewksht.Cells.Item(1,3) = 'Label'
$diskSpacewksht.Cells.Item(1,4) = 'Size(GB)'
$diskSpacewksht.Cells.Item(1,5) = 'FreeSpace(GB)'
$row = 2
Get-CimInstance -ClassName Win32_Volume | ForEach {
    $diskSpacewksht.Cells.Item($row,1) = $_.Caption
    $diskSpacewksht.Cells.Item($row,2) = $_.DriveLetter
    $diskSpacewksht.Cells.Item($row,3) = $_.Label
    $diskSpacewksht.Cells.Item($row,4) = ($_.Capacity /1GB)
    $diskSpacewksht.Cells.Item($row,5) = ($_.FreeSpace /1GB)
    $row++
}
$usedRange = $diskSpacewksht.UsedRange						
$usedRange.EntireColumn.AutoFit() | Out-Null
$Excel.DisplayAlerts = $False
$workbook.SaveAs("C:\temp\DiskSpace.xlsx")
$Excel.Quit()

#
#  Connect to Sharepoint Online, and review the sharepoint sites:
#
# 2.Install the SharePoint Online Management Shell from http://go.microsoft.com/fwlink/p/?LinkId=255251
# 3.Click Start>All Programs>SharePoint Online Management Shell.
Import-Module "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell"
Get-Module
Get-Command -Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url https://moebiussyndroom-admin.sharepoint.com -credential "Ben.van.zanten@moebiussyndroom.nl"
Get-SPOSite
Get-SPODeletedSite
Get-SPOWebTemplate
