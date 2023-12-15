#Connect to Microsoft Graph
Connect-MgGraph -scopes DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, DeviceManagementManagedDevices.PrivilegedOperations.All

Install-Module Microsoft.Graph.Beta.DeviceManagement -scope CurrentUser -Force
Import-Module Microsoft.Graph.Beta.DeviceManagement

#Get Script package
$ScriptPackageName = "Local Admin Accounts (for LAPS)"
$RemediationPachage = Get-MgBetaDeviceManagementDeviceHealthScript -Filter "DisplayName eq '$ScriptPackageName'"

#Create request body
$body = @{
    "ScriptPolicyId" = "78c339b9-bc38-49f6-81a9-cab9bffe18ed"
} | ConvertTo-Json

#Store target devices
$TargetDevices = Get-MgBetaDeviceManagementManagedDevice -filter "OwnerType eq 'Company'"

#Loop through each device
Foreach ($device in $TargetDevices){
    Write-Host "Initiating remediation package $ScriptPackageName for $($Device.DeviceName)" -ForegroundColor Cyan
    $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$($device.id)')/initiateOnDemandProactiveRemediation"
    Invoke-MgGraphRequest -Uri $uri -Method POST -Body $body -ContentType  "application/json"
}
