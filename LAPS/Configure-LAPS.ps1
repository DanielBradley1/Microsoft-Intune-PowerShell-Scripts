## Connect to Microsoft Graph

Connect-MgGraph -scope Policy.ReadWrite.DeviceConfiguration

## Enable Entra LAPS
Write-host "Checking LAPS in Microsoft Entra"
$Uri = "https://graph.microsoft.com/beta/policies/deviceRegistrationPolicy"
$DevicePolicy = Invoke-MgGraphRequest -Uri $Uri -Method GET -OutputType PSObject -ContentType "application/json"
If (($DevicePolicy.localAdminPassword).isEnabled -eq $False) {
    Write-Host "Enabling LAPS..." -ForegroundColor Green
    $DevicePolicy.localAdminPassword.isEnabled = $true
    $Body = $DevicePolicy | ConvertTo-Json
    Invoke-MgGraphRequest -Method PUT -Uri $uri -Body $body -ContentType "application/json" | Out-Null
    Write-Host "Done" -ForegroundColor Green
} Else {
    Write-Host "LAPS is already enabled" -ForegroundColor Yellow
}
