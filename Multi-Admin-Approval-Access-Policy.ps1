<#
    .SYNOPSIS
       Create Multi-Admin Approval in Microsoft Intune

    .DESCRIPTION
       Create Multi-Admin Approval in Microsoft Intune
       For use with Microsoft Graph PowerShell SDK
 
    .NOTES
        Author: 	Daniel Bradley
        Purpose:	To enable the use to complete the task of creating a mult-admin approval using PowerShell.
        Website:    https://ourcloudnetwork.com/
        LinkedIn:   https://www.linkedin.com/in/danielbradley2/
    #>

$DisplayName = "test2"  #Enter the desired policy name
$Description = "test1"  #Enter the desired policy description
$PolicyType  = "Apps"  #Enter either 'Apps' or 'Scripts'
$ApproversGroup = "Approval Admins" #Enter the exact name of the approvers groups

#Checks for Microsoft Graph
if (Get-Module -ListAvailable -Name Microsoft.Graph.Devices.CorporateManagement) 
{
} else {
        Install-Module -Name Microsoft.Graph.Devices.CorporateManagement -Scope CurrentUser
        Write-Host "Microsoft Graph Authentication Installed"
}

#Imports Module
Import-Module Microsoft.Graph.Devices.CorporateManagement, Microsoft.Graph.Groups

#Select Beta Profile
Select-MgProfile -Name Beta

#Connect to Microsoft Graph
Connect-MgGraph -Scopes DeviceManagementConfiguration.ReadWrite.All, Group.Read.All

#Store Target group
$targetgroup = Get-MgGroup | Where-Object {$_.DisplayName -eq $ApproversGroup}

#Define the URI
$uri = "https://graph.microsoft.com/beta/deviceManagement/operationApprovalPolicies"

#Define policy parameters
$json = 
@{
  "@odata.type" = "#microsoft.graph.operationApprovalPolicy"
  displayName = "$DisplayName"
  description = "$Description"
  policyType = "$PolicyType"
  approverGroupIds = @($targetgroup.id)
 } | ConvertTo-Json

#Create policy
$companyportal = Invoke-MgGraphRequest -Uri $uri -Body $json -Method POST -ContentType "application/json"

