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

HISTORY:

.INPUTS
<Inputs if any, otherwise state None>
.OUTPUTS
<Outputs if anything is generated>

.COMPONENT
 Required Modules: 
 
.EXAMPLE
<Example goes here. Repeat this attribute for more than one example>

.LICENSE
Use this code free of charge at your own risk.
Never deploy code into production if you do not know what it does.
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

#Download latest setup and install
try {
    LogWrite "Downloading latest setup file.."
    Start-Transcript -Path "$path\$Logfile" -Append
    Invoke-WebRequest -uri "https://officecdn.microsoft.com/pr/wsus/setup.exe" -OutFile "$filepath\setup\setup.exe" -Verbose
    Stop-Transcript
    try {
        $setup = "$filepath\setup\" + "setup.exe"
        $configuration = $psscriptroot + "\configuration.xml"
        Start-Process $setup -ArgumentList "/configure $($psscriptroot)\configuration.xml" -Wait -PassThru -ErrorAction Stop | Tee-Object "$filepath\$Logfile" -Append
        LogWrite "Microsoft 365 apps successfully installed"
        }
        catch {
            LogWrite $_
        }
} 
catch {
    LogWrite "Failed to download office setup.exe. See next line for error..."
    LogWrite $_
}

<#Clean up
If (Test-path -Path "$filepath\setup"){
    try {
        Remove-item -path "$filepath\setup" -Recurse
    }
    catch {
        LogWrite $_
    }
}
#>