<#
.SYNOPSIS
<Overview of script>
.LINK
   https://ourcloudnetwork.com
.NOTES
   Version:        0.1
   Author:         Daniel Bradley
   Creation Date:  Monday, January 8th 2024, 11:47:41 am
   File: Install-M365.ps1
   Copyright (c) 2024 Your Company
.OUTPUTS
Log files to "C:\Windows\Temp\m365"
#>

#Create path and define log file
$LogFile = "InstallLog-M365.txt"
$filepath = "$env:SystemRoot" + "\temp\m365\"
mkdir "$filepath\setup" -ErrorAction SilentlyContinue | Out-Null

#Write to log
Function LogWrite
{
   Param ([string]$logstring)
   $date = (Get-Date).tostring("yyyyMMdd-HH:mm")
   Add-content "$filepath\$LogFile" -value "$date - $logstring"
}

#Download latest setup and uninstall
try {
    LogWrite "Downloading latest setup file.."
    Start-Transcript -Path "$filepath\$Logfile" -Append
    Invoke-WebRequest -uri "https://officecdn.microsoft.com/pr/wsus/setup.exe" -OutFile "$filepath\setup\setup.exe" -Verbose
    Stop-Transcript
    try {
        $setup = "$filepath\setup\" + "setup.exe"
        Start-Process $setup -ArgumentList "/configure $($psscriptroot)\uninstall.xml" -Wait -PassThru -ErrorAction Stop | Tee-Object "$filepath\$Logfile" -Append
        LogWrite "Microsoft 365 apps successfully removed"
        }
        catch {
            LogWrite $_
        }
} 
catch {
    LogWrite "Failed to download office setup.exe. See next line for error..."
    LogWrite $_
}