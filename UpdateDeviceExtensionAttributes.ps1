<#
    .DESCRIPTION
        Configure extension attributes for devices in AAD
 
    .NOTES
        Author:   	Daniel Bradley
        Website:    https://ourcloudnetwork.com/
        LinkedIn:   https://www.linkedin.com/in/danielbradley2/
#>

#Import module
Import-Module Microsoft.Graph.Identity.DirectoryManagement

#Select beta profile
Select-MgProfile -Name "beta"

#Connect to Microsoft Graph
Connect-mgGraph -Scopes Device.Read.All, Directory.ReadWrite.All, Directory.AccessAsUser.All

#Store devices
$AzureADJoinedDevices = Get-MgDevice | Where-Object {$_.EnrollmentType -eq "AzureDomainJoined"}

#Loop through devices
ForEach ($device in $AzureADJoinedDevices) {

#Store URI path
$uri = $null
$uri = "https://graph.microsoft.com/beta/devices/" + $device.id

#Define attribute values
$json = @{
      "extensionAttributes" = @{
      "extensionAttribute1" = "Corporate Device"
         }
  } | ConvertTo-Json
  
#Assign attributes
Invoke-MgGraphRequest -Uri $uri -Body $json -Method PATCH -ContentType "application/json"
}
