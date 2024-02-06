 <#
.SYNOPSIS
This function is used to grab all items from Graph API that are paginated
.INFO 
Author: Daniel Bradley
LinkedIn: https://www.linkedin.com/in/danielbradley2/
Blog: https://ourcloudnetwork.com
.EXAMPLE
DeployCatalogApps -Apps "7-Zip", "WinSCP"
#>

Function DeployCatalogApps {

    Param(
        $Apps
    )

    Foreach ($CatalogApp in $Apps) {

        #Get the latest version of the catalog app
        $GetUri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileAppCatalogPackages?`$filter=productName eq '$CatalogApp'"
        $RetrievedApp = Invoke-MgGraphRequest -Method GET -Uri $GetUri -OutputType PSObject | Select -ExpandProperty Value
        $SelectedApp = $RetrievedApp[0]
    
        Write-Host "Attempting to deploy catalog app: $($SelectedApp.productName) v:$($SelectedApp.versionName)"
        write-host "Converting to mobile app"

        #Convert the app to catalog package
        $ConUri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/convertMobileAppCatalogPackageToMobileApp(versionId='$($SelectedApp.id)')"
        $MobApp = (Invoke-MgGraphRequest -uri $ConUri -Method GET -OutputType PSObject) | Select-Object * -ExcludeProperty "@odata.context", id, largeIcon, createdDateTime, lastModifiedDateTime, owner, notes, size, minimumSupportedOperatingSystem, minimumFreeDiskSpaceInMB, minimumMemoryInMB, minimumNumberOfProcessors, minimumCpuSpeedInMHz 
        $AppPayload = $MobApp | ConvertTo-Json

        Write-Host "Deploying catalog app: $($SelectedApp.productName) v:$($SelectedApp.versionName)"

        #Deploy the catalog app
        $DeployUri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps"
        Invoke-MgGraphRequest -Method POST -Uri $DeployUri -Body $AppPayload -ContentType "application/json"
        
    }
}
