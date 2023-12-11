#The name of the account
$AccountName = 'ohglocaladmin'

#Check if user exisis
$Userexist = (Get-LocalUser).Name -Contains $AccountName
if ($userexist) { 
  Write-Host "$AccountName exist" 
} 
Else {
  Write-Host "$AccountName does not Exists"
  Exit 1
}

#Check if user is a local admin
$localadmins = ([ADSI]"WinNT://./Administrators").psbase.Invoke('Members') | % {
 ([ADSI]$_).InvokeGet('AdsPath')
}

if ($localadmins -like "*ohglocaladmin*") {
    Write-Host "ohglocaladmin is a member of local admins"
    exit 0     
} else {
    Write-Host "ohglocaladmin is NOT a member of local admins"
    exit 1
}