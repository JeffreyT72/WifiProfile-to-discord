# WifiProfile-to-discord
- Author: JeffreyT72
- Version: 2.0
- Target: Windows (Powershell 5.1+)
- Category: exfiltration
- Attackmode: HID then OFF

## Description
Insert Raspberry Pi Pico to target Windows pc and exfiltrate wifi profile (SSID and password). Then send the file via discord webhook.

## Features
* Reasonably stealthy - powershell script runs in the background
* Fairly quick        - one line of command on Pico-Ducky

## Setup
1. Follow https://github.com/dbisu/pico-ducky to install Pico-Ducky
2. Download wifi-profile-to-discord.ps1
3. Create a discord webhook and replace the webhook link inside the powershell script
4. Upload the edited powershell script to dropbox and copy the share link
5. Download payload.dd
6. Replace the dropbox share link inside payload.dd
7. Upload payload.dd to Pico-Ducky

## Possible Issues
* Fixed - No output if target pc missing or disabled wifi adapter.

## Disclaimer
* Payloads from this repository are provided for educational purposes only.
* As with any script, you are advised to proceed with caution.

## Credits
* https://github.com/I-Am-Jakoby/PowerShell-for-Hackers
* https://github.com/hak5/usbrubberducky-payloads/tree/bf2dfb7c17d0661624bb418c9576cc9fc51f8832/payloads/library/credentials/Browser-Passwords-Dropbox-Exfiltration
