# Requirements

Make sure Test-RebootPending is installed (PackageProvider nuget and PSGallery required) in PowerShell x86

https://www.powershellgallery.com/packages/PendingReboot

    Install-PackageProvider -Name Nuget
    Install-Module -Name PendingReboot

# Screenshot
![PRTG Screenshot](/IMG/screenshot.png?raw=true "PRTG Screenshot")
    
# Settings in EXE Skript Sensor
### Parameters
    -Server %host -username %windowsuser -password %windowspassword
        
### Scanning Interval
15 Minutes        
        
# File locations

## On your PRTG-Core Server
    ts-WinCheckRebootPending.ovl  - C:\Program Files (x86)\PRTG Network Monitor\lookups

## On The Probe
    prtg-win-check-reboot.ps1     - C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXE
    
Log Location
    C:\ProgramData\Paessler\PRTG Network Monitor\Logs