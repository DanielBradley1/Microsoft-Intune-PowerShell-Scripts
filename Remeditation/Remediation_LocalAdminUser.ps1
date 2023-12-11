# The name of the account
$accountName = 'localadmin'
$accountFullName = 'localadmin'
$accountComment = 'Local Administrator Account'
 
# Set up some Event Log stuff
$sourceName = "$($MyInvocation.MyCommand.Name).ps1"
New-EventLog -LogName Application -Source "$sourceName" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
 
# If the account already exists, exit
if ((Get-WmiObject Win32_UserAccount -filter "domain = '$Env:COMPUTERNAME' and Name = '$accountName'") -ne $null) { 
    Write-EventLog -LogName Application -Source $sourceName -EntryType Information -EventId 1 -Message "$accountName already exists" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    exit
}
 
# Create the account
cmd.exe /c "net user $accountName `"$([guid]::NewGuid().guid)`" /add /y /comment:`"$accountComment`" /fullname:`"$accountFullName`""
# Add the account to the Administrators group
cmd.exe /c "net localgroup Administrators $accountName /add"
 
# Try and write an event to the Event Log
Write-EventLog -LogName Application -Source $sourceName -EntryType Information -EventId 2 -Message "Created local administrator account: $accountName" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
