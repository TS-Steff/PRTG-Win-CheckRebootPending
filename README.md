# Requirements

Make sure Test-RebootPending is installed (PackageProvider nuget and PSGallery required) in PowerShell x86

https://www.powershellgallery.com/packages/Test-PendingReboot/

    Install-PackageProvider -Name Nuget
    Install-Module -Name PendingReboot
    
# File locations

## On your PRTG-Core Server
    ts-WinCheckRebootPending.ovl  - C:\Program Files (x86)\PRTG Network Monitor\lookups

## On The Probe
    prtg-win-check-reboot.ps1     - C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors