$snip= @'
<#
.SYNOPSIS
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.PARAMETER
   Parameter 1...
.PARAMETER
   Parameter 2...
.NOTES
   Author : 
   Company: Valid
   Date   : 
   Version: 1.0

   Change history:
   Date     Name     Version  Description
                     0.0-0.9  buildversions
                         1.0  Initial version
.LINK
   http://powershell.valid.nl
#>

    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                  SupportsShouldProcess=$True,
                  PositionalBinding=$False,
                  HelpUri = 'http://powershell.valid.nl/',
                  ConfirmImpact='Medium')]
    Param (
    )

'@
New-IseSnippet -Text $snip -Title "Default BvZ ScriptHeader" -Author "Ben van Zanten" -Description "Default script header for Valid" -force


function Initialize-PowerShellTrainingFiles
{
    Write-Host "Copying the Scripts and Presentations for the PowerShell Training to C:\Scripts  from $(Join-Path $PSScriptRoot "Scripts")"
    Copy-Item -Path (Join-Path $PSScriptRoot "Scripts") -Destination C:\ -Recurse -Force
}


function Show-PowerShellTraining_Slides
{
    [CmdletBinding()]
    Param
    (
        # Which Module do you want to see (1-4)?
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet(1,2,3,4)]
        [int]$Module
    )

    foreach ($file in  dir (Join-Path $PSScriptRoot "Slides\PS Intro$($Module)*.pptx"))
    {
        Try {
            Invoke-Item $file.FullName -ErrorAction Stop
        } 
        Catch {
            $PPT = New-Object -ComObject "PowerPoint.Application"
            $ppt.visible = $True
            $ppt.Presentations.Open($file.FullName)
        }

    }
}

function Show-PowerShellTraining_Examples
{
    [CmdletBinding()]
    Param
    (
        # Which Module do you want to see (1-4)?
        [Parameter(Position=0)]
        [ValidateSet(1,2,3,4)]
        [int]$Module=1
    )

    if (!(Test-Path c:\scripts))
    {
        $query = @'
You need to run Initialize-PowerShellTrainingFiles to copy files to c:\scripts before proceeding.
Would you like me to run that for you now?
'@
        if ($PSCmdlet.ShouldContinue($query,'Show-PowerShellTraining_Examples'))
        {
            Initialize-PowerShellTrainingFiles
        }
        else
        {
            Throw @'
You need to run 
    Initialize-PowerShellTrainingFiles 
to copy files to c:\scripts before proceeding.
'@
        }
    }

    $files = @()
    if ($Host.Name -eq 'Windows PowerShell ISE Host')
    {
        foreach ($f in dir "C:\Scripts\Mod$($Module)\*1")
        {
            $files += $f.fullname
        }
        $Script:PST_EXAMPLES = $files
        psedit "C:\Scripts\Mod$($Module)"
    }
    else
    {
        foreach ($f in dir (Join-Path "C:\Scripts\Mod$($Module)\*1"))
        {
                $files += "$($f.FullName)"
        }
        PowerShell_ise.exe -file $($files -join ",")
    }
    Write-host "Use the Clear-PowerShellTraining_Examples cmdlet when done"
}



function Clear-PowerShellTraining_Examples
{
    [CmdletBinding()]
    Param
    (
    )


    if ($Script:PST_EXAMPLES)
    {
        foreach ($file in @($psISE.CurrentPowerShellTab.Files))
        {
            if ($file.fullPath -in $Script:PST_EXAMPLES)
            {
                 $psise.CurrentPowerShellTab.Files.Remove($File) | Out-Null
            }
        }
    }
    $Script:PST_EXAMPLES=$Null
}
