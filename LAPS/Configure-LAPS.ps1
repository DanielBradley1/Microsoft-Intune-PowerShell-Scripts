<#
.SYNOPSIS
   This script will automatically enable Entra LAPS, create the LAPS account protection policy and upload a remediation
   Script to create the LAPS user.
.LINK
   https://ourcloudnetwork.com
   https://www.linkedin.com/in/danielbradley2/
   https://twitter.com/DanielatOCN
.NOTES
   Version:        0.1
   Author:         Daniel Bradley
   Creation Date:  Saturday, January 20th 2024, 11:40:42 am
   File: Configure-LAPS.ps1
   Copyright (c) 2024 our cloud network ltd

HISTORY:

.INPUTS
   Declare the $accountname variable
.OUTPUTS
<Outputs if anything is generated>

.LICENSE
Use this code free of charge at your own risk.
Never deploy code into production if you do not know what it does.
#>

#############################
## Declare these variables ##
#############################
$accountname = "Local-Admin"

#############################
## Module prequisite check ##
#############################
Write-host "Checking if Microsoft.Graph.Authentication module is installed"
$MgMod = Get-Module -ListAvailable -Name Microsoft.Graph.Authentication
If (!$MgMod){
    Write-host "Microsoft.Graph.Authentication module is not installed. Installing now..."
    try {
        $ProgressPreference = "SilentlyContinue"
        Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force -ErrorAction stop
        Import-Module Microsoft.Graph.Authentication
        Write-host "Microsoft.Graph.Authentication module installed" -ForegroundColor Green
    }
    catch {
        Write-host "Unable to install required modules"
        Write-host $_ -ForegroundColor Yellow
    }
} Else {
    Import-Module Microsoft.Graph.Authentication
    Write-host "Microsoft.Graph.Authentication module is already installed" -ForegroundColor Green
}

################################
## Connect to Microsoft Graph ##
################################
Connect-MgGraph -scope Policy.ReadWrite.DeviceConfiguration, DeviceManagementConfiguration.ReadWrite.All -NoWelcome
$context = Get-MgContext
If (Get-MgContext) {
    Write-host "Connected to Microsoft Graph with the following scopes:" -ForegroundColor cyan
    $context.scopes
    Write-host "`n"
} Else {
    Write-host "Connection to Microsoft Graph failed" -ForegroundColor Yellow
    break
}

#######################
## Enable Entra LAPS ##
#######################
Write-host "Checking LAPS in Microsoft Entra" -ForegroundColor Cyan
$Uri = "https://graph.microsoft.com/beta/policies/deviceRegistrationPolicy"
$DevicePolicy = Invoke-MgGraphRequest -Uri $Uri -Method GET -OutputType PSObject -ContentType "application/json"
If (($DevicePolicy.localAdminPassword).isEnabled -eq $False) {
    Write-Host "Enabling LAPS..." -ForegroundColor Green
    $DevicePolicy.localAdminPassword.isEnabled = $true
    $Body = $DevicePolicy | ConvertTo-Json
    Invoke-MgGraphRequest -Method PUT -Uri $uri -Body $body -ContentType "application/json" | Out-Null
} Else {
    Write-Host "LAPS is already enabled" -ForegroundColor green
}

########################
## Create LAPS policy ##
########################
## Create Account Protection Profile for LAPS
## Backup: Microsoft Entra
## Password age: 7 days
## Password length: Not configured (default 14 days)
## Account name: $accountname
## Complexity level: 4
## Post auth: Reset password
## Post auth delay: 1 hour
Write-host "Checking for existing LAPS configuration policies" -ForegroundColor Cyan
$ConfigCheckUri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies?`$filter=templateReference/TemplateDisplayName%20eq%20%27Local%20admin%20password%20solution%20(Windows%20LAPS)%27"
$CurrentConfigPolicy = Invoke-MgGraphRequest -Uri $ConfigCheckUri -Method GET -OutputType PSObject -ContentType "application/json" | Select -ExpandProperty Value
If (!$CurrentConfigPolicy) {
    Write-host "No existing Windows LAPS policies detected..." -ForegroundColor green
    Write-host "Creating Windows LAPS policy with the following settings:" -ForegroundColor Cyan
    Write-host "Policy Name      :    Windows LAPS" -ForegroundColor Green
    Write-host "Backup location  :    Microsoft Entra" -ForegroundColor Green
    Write-host "Password age     :    7 days" -ForegroundColor Green
    Write-host "Password length  :    Not configured (default 14 days)" -ForegroundColor Green
    Write-host "Account name     :    $accountname" -ForegroundColor Green
    Write-host "Complexity level :    4" -ForegroundColor Green
    Write-host "Post auth action :    Reset password" -ForegroundColor Green
    Write-host "Post auth delay  :    1 hour" -ForegroundColor Green

$ConfigUri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
$configbody = @"
{
  "name": "Windows LAPS",
  "description": "created by ourcloudnetwork.com",
  "platforms": "windows10",
  "technologies": "mdm",
  "roleScopeTagIds": [
    "0"
  ],
  "settings": [
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_laps_policies_backupdirectory",
        "choiceSettingValue": {
          "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue",
          "value": "device_vendor_msft_laps_policies_backupdirectory_1",
          "children": [
            {
              "@odata.type": "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance",
              "settingDefinitionId": "device_vendor_msft_laps_policies_passwordagedays_aad",
              "simpleSettingValue": {
                "@odata.type": "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue",
                "value": 7
              }
            }
          ],
          "settingValueTemplateReference": {
            "settingValueTemplateId": "4d90f03d-e14c-43c4-86da-681da96a2f92"
          }
        },
        "settingInstanceTemplateReference": {
          "settingInstanceTemplateId": "a3270f64-e493-499d-8900-90290f61ed8a"
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance",
        "settingDefinitionId": "device_vendor_msft_laps_policies_administratoraccountname",
        "simpleSettingValue": {
          "@odata.type": "#microsoft.graph.deviceManagementConfigurationStringSettingValue",
          "value": "$accountname",
          "settingValueTemplateReference": {
            "settingValueTemplateId": "992c7fce-f9e4-46ab-ac11-e167398859ea"
          }
        },
        "settingInstanceTemplateReference": {
          "settingInstanceTemplateId": "d3d7d492-0019-4f56-96f8-1967f7deabeb"
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_laps_policies_passwordcomplexity",
        "choiceSettingValue": {
          "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue",
          "value": "device_vendor_msft_laps_policies_passwordcomplexity_4",
          "children": [],
          "settingValueTemplateReference": {
            "settingValueTemplateId": "aa883ab5-625e-4e3b-b830-a37a4bb8ce01"
          }
        },
        "settingInstanceTemplateReference": {
          "settingInstanceTemplateId": "8a7459e8-1d1c-458a-8906-7b27d216de52"
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_laps_policies_postauthenticationactions",
        "choiceSettingValue": {
          "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue",
          "value": "device_vendor_msft_laps_policies_postauthenticationactions_1",
          "children": [],
          "settingValueTemplateReference": {
            "settingValueTemplateId": "68ff4f78-baa8-4b32-bf3d-5ad5566d8142"
          }
        },
        "settingInstanceTemplateReference": {
          "settingInstanceTemplateId": "d9282eb1-d187-42ae-b366-7081f32dcfff"
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance",
        "settingDefinitionId": "device_vendor_msft_laps_policies_postauthenticationresetdelay",
        "simpleSettingValue": {
          "@odata.type": "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue",
          "value": 1,
          "settingValueTemplateReference": {
            "settingValueTemplateId": "0deb6aee-8dac-40c4-a9dd-c3718e5c1d52"
          }
        },
        "settingInstanceTemplateReference": {
          "settingInstanceTemplateId": "a9e21166-4055-4042-9372-efaf3ef41868"
        }
      }
    }
  ],
  "templateReference": {
    "templateId": "adc46e5a-f4aa-4ff6-aeff-4f27bc525796_1"
  }
}
"@
    Invoke-MgGraphRequest -Method POST -Uri $ConfigUri -Body $configbody -ContentType "application/json" | Out-Null
} Else {
    Write-Host "Existing LAPS policy detected, please review. To proceed, delete existing configuration and re-run the script" -ForegroundColor yellow
    $CurrentConfigPolicy
    break
}

##############################################
## Create LAPS user with Remediation Script ##
##############################################
Write-host "Creating remediation package for LAPS user" -ForegroundColor Cyan

## Convert Remediation Script to Base64
$Remediationscript = @'
<#
Written by Daniel Bradley
https://ourcloudnetwork.com/
https://www.linkedin.com/in/danielbradley2/
#>

#Add system.web assembly
Add-Type -AssemblyName 'System.Web'
 
#Check if user exisis
$Userexist = (Get-LocalUser).Name -Contains ">Placeholder<"
if (!$userexist) {
    $password = [System.Web.Security.Membership]::GeneratePassword(20,5)
    $Securepassword = ConvertTo-SecureString $Password -AsPlainText -force
    $params = @{
        Name        = ">Placeholder<"
        Password    = $Securepassword
    }
    New-LocalUser @params
}

# Add the account to the Administrators group
Add-LocalGroupMember -Group "Administrators" -Member ">Placeholder<"
'@
$Remediationscript = $Remediationscript -replace ">Placeholder<", "$accountname"
$Remed_byte_array = [System.Text.Encoding]::ASCII.GetBytes($Remediationscript)
$RemediationBase64 = [System.Convert]::ToBase64String($Remed_byte_array)

## Convert Detection Script to Base64
$Detectionscript = @'
<#
Written by Daniel Bradley
https://ourcloudnetwork.com/
https://www.linkedin.com/in/danielbradley2/
#>

#Check if user exists
$Userexist = (Get-LocalUser).Name -Contains ">Placeholder<"
if ($userexist) { 
  Write-Host ">Placeholder< exists" 
} 
Else {
  Write-Host ">Placeholder< does not Exists"
  Exit 1
}

#Check if user is a local admin
$localadmins = ([ADSI]"WinNT://./Administrators").psbase.Invoke('Members') | % {
 ([ADSI]$_).InvokeGet('AdsPath')
}

if ($localadmins -like "*>Placeholder<*") {
    Write-Host ">Placeholder< is a member of local admins"
    exit 0     
} else {
    Write-Host ">Placeholder< is NOT a member of local admins"
    exit 1
}
'@
$Detectionscript = $Detectionscript -replace ">Placeholder<", "$accountname"
$Detect_byte_array = [System.Text.Encoding]::ASCII.GetBytes($Detectionscript)
$DetectionBase64 = [System.Convert]::ToBase64String($Detect_byte_array)

#Define URI for remdiation scripts
$ScriptURI = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"

#Define remdiation package configuration
$scriptbody = @"
{
  "displayName": "Windows LAPS User",
  "description": "Checks for account \"LocalAdmin\". If it doesn't exist, it will create it a random password and add it to the local administrators group.",
  "publisher": "ourcloudnetwork.com",
  "runAs32Bit": false,
  "runAsAccount": "system",
  "enforceSignatureCheck": false,
  "detectionScriptContent": "$DetectionBase64",
  "remediationScriptContent": "$RemediationBase64",
  "roleScopeTagIds": [
    "0"
  ]
}
"@

#Create remediation package
Try {
    Invoke-MgGraphRequest -Method POST -Uri $ScriptURI -Body $scriptbody -ContentType "application/json" | Out-Null -ErrorAction Stop
    Write-host "Remediation package created" -ForegroundColor Green
}
Catch {
    Write-host "Unable to create Remediation package" -ForegroundColor Yellow
    Write-host $_ -ForegroundColor Yellow
}

##############
# Disconnect #
##############
Write-host "Disconnecting from Microsoft Graph" -ForegroundColor Cyan
Disconnect-MgGraph