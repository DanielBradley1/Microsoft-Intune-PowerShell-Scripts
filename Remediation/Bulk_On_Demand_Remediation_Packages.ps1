#Connect to Microsoft Graph
Connect-MgGraph -scopes DeviceManagementConfiguration.Read.All, DeviceManagementManagedDevices.Read.All, DeviceManagementManagedDevices.PrivilegedOperations.All
Install-Module Microsoft.Graph.Beta.DeviceManagement -scope CurrentUser -Force
Import-Module Microsoft.Graph.Beta.DeviceManagement


#Get Script package
$ScriptPackageName = "Local Admin Accounts (for LAPS)"
$RemediationPachage = Get-MgBetaDeviceManagementDeviceHealthScript -Filter "DisplayName eq '$ScriptPackageName'" -ExpandProperty assignments

#Evaluate membership
If ($RemediationPachage.Assignments.target.AdditionalProperties.Keys -match "groupId") {
    $switch = "group"
    $assignments = $RemediationPachage.Assignments.target.AdditionalProperties.groupId
} Else {


}

If ($switch -eq "group") {
    $groupmembers = @()
    Foreach ($group in $assignments) {}
        Get-MgBetaGroupMember -GroupId $group

    }
}



https://graph.microsoft.com/beta/deviceManagement/managedDevices('5dcca03d-635c-432f-8534-131ee152cc85')/initiateOnDemandProactiveRemediation


Get-Mg
