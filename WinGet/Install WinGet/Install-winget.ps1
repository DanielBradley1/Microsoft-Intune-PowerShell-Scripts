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
Date      	          By	Comments
----------	          ---	----------------------------------------------------------
2024-01-06-08-27-am	 DB	    Initial release

.INPUTS
<Inputs if any, otherwise state None>
.OUTPUTS
<Outputs if anything is generated>

.COMPONENT
 Required Modules: 

.LICENSE
Use this code free of charge at your own risk.
Never deploy code into production if you do not know what it does.
 
.EXAMPLE
Deploy with Intune. Package into Win32 app.

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
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop
        LogWrite "WinGet successfully installed"
    }
    Catch {
        LogWrite $_
        LogWrite "Unable to install with Add-AppxPackage"
        Try {
            LogWrite "Downloading WinGet and its dependencies..."
            Start-Transcript -Path "$path\$Logfile" -Append
            Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile "$path\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Verbose
            Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile "$path\Microsoft.VCLibs.x64.14.00.Desktop.appx" -Verbose
            Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile "$path\Microsoft.UI.Xaml.2.7.x64.appx" -Verbose
            Add-AppxPackage $path\Microsoft.VCLibs.x64.14.00.Desktop.appx -Verbose
            Add-AppxPackage $path\Microsoft.UI.Xaml.2.7.x64.appx -Verbose
            Add-AppxPackage $path\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -Verbose
            Stop-Transcript
        }
        Catch {
            Write-host "Unable to complete offline installer"
        }
    }
} Else {
    LogWrite "WinGet already installed"
}
