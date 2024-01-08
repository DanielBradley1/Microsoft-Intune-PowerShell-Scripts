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
2024-01-08	Added optional commands

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
$TestPath = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.21.3482.0_x64__8wekyb3d8bbwe\AppxSignature.p7x"
$Winget = Test-path $TestPath -PathType Leaf

#Install WinGet
if (!$Winget){
    LogWrite "WinGet not installed, attempting install with Add-AppxPackage"
    Try {
        LogWrite "Downloading WinGet and its dependencies..."
        Start-Transcript -Path "$path\$Logfile" -Append
        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile "$path\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Verbose
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile "$path\Microsoft.VCLibs.x64.14.00.Desktop.appx" -Verbose
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile "$path\Microsoft.UI.Xaml.2.7.x64.appx" -Verbose
        Add-AppxProvisionedPackage -online -packagepath $path\Microsoft.VCLibs.x64.14.00.Desktop.appx -SkipLicense -Verbose
        Add-AppxProvisionedPackage -online -packagepath $path\Microsoft.UI.Xaml.2.7.x64.appx -SkipLicense -Verbose
        Add-AppxProvisionedPackage -online -packagepath $path\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -SkipLicense -Verbose
        Stop-Transcript
    }
    Catch {
        Write-host "Unable to complete offline installer"
    }
} Else {
    LogWrite "WinGet already installed"
}

<# 

#### Optional deploy additional applications #####

#### Additoinal looping function can be added here for multiple apps ####

cd "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.21.3482.0_x64__8wekyb3d8bbwe\"
LogWrite "location set to $((Get-Location).Path)"
.\Winget install Google.Chrome --accept-package-agreements --accept-source-agreements | Tee-Object "$path\$Logfile" -Append

#>