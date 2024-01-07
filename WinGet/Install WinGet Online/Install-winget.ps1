<#
.SYNOPSIS
Installs WinGet, for use with Intune
.LINK
   https://ourcloudnetwork.com
.NOTES
   Version:        0.1
   Author:         Daniel Bradley
   Creation Date:  Friday, January 5th 2024, 5:18:37 pm
   File: Install-winget.ps1
   Copyright (c) 2024 Your Company

HISTORY:
2024-01-06	Initial releease
2024-01-06	Update Winget uri to include latest release without .Net (15MB, instead of 200MB)
2024-01-06	Updated to latest version, otherwise AutoPilot preprovisioning fails

.INPUTS
<Inputs if any, otherwise state None>
.OUTPUTS
<Outputs if anything is generated>

.COMPONENT
 Required Modules: 

 .EXAMPLE
Deploy with Intune. Package into Win32 app.

.LICENSE
Use this code free of charge at your own risk.
Never deploy code into production if you do not know what it does.
#>

#Create path and define log file
$path= "C:\ProgramData\WinGet"
$LogFile = "InstallLog.txt"
mkdir $path -ErrorAction SilentlyContinue

#Write to log
Function LogWrite
{
   Param ([string]$logstring)
   $date = (Get-Date).tostring("yyyyMMdd-HH:mm")
   Add-content "$path\$Logfile" -value "$date - $logstring"
}

#Check if WinGet is Installed
$Winget = Get-AppxPackage Microsoft.DesktopAppInstaller

#Install WinGet
Start-Transcript -Path "$path\$Logfile" -Append
if ((!$Winget) -or ($winget.version -lt 1.21)){
    LogWrite "WinGet not installed or outdated, downloading latest files"
    Try {
        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile "$path\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Verbose
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile "$path\Microsoft.VCLibs.x64.14.00.Desktop.appx" -Verbose
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile "$path\Microsoft.UI.Xaml.2.7.x64.appx" -Verbose
        Add-AppxProvisionedPackage -online -packagepath $path\Microsoft.VCLibs.x64.14.00.Desktop.appx -SkipLicense -Verbose
        Add-AppxProvisionedPackage -online -packagepath $path\Microsoft.UI.Xaml.2.7.x64.appx -SkipLicense -Verbose
        Add-AppxProvisionedPackage -online -packagepath $path\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -SkipLicense -Verbose
    }
    Catch {
        Write-host "Unable to complete install"
    }
} Else {
    LogWrite "WinGet already installed"
}
Stop-Transcript
