$apps = (Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") |  Get-ItemProperty | Where {$_.DisplayName -match "Microsoft 365 "}
if ($apps) {
    Write-host "M365 Apps Detected"
	Exit 0
   }else{
    Write-host "M365 Apps not Detected"
    Exit 1
}