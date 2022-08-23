<#
    .SYNOPSIS
    PRTG Check if Windows has reboot Pending
    
    .DESCRIPTION
    HTTP Push Sensor
    Uses PS Module PendingReboot
    
    .EXAMPLE
    prtg-win-check-reboot.ps1 -Server <SERVERNAME>
    prtg-win-check-reboot.ps1 -Server <SERVERNAME> -username <USERNAME> -password <PASSWORD>
    prtg-win-check-reboot.ps1 -Server <SERVERNAME> -username <COMPUTERNAME>\<USERNAME> -password <PASSWORD>
    
    .NOTES
    ┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
    │ ORIGIN STORY                                                                                │ 
    ├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
    │   DATE        : 2022-08-23                                                                  |
    │   AUTHOR      : TS-Management GmbH, Stefan Müller                                           | 
    │   DESCRIPTION : Checks if Windows needs a reboot by testing                                 |
    |                 ComponentBasedServicing and                                                 |
    |                 WindowsUpdateAutoUpdate                                                     |
    └─────────────────────────────────────────────────────────────────────────────────────────────┘
    
    .Link
    https://ts-man.ch
    https://www.powershellgallery.com/packages/PendingReboot/0.9.0.6
#>

### Possible states 
# 0: No Reboot Pending
# 1: Reboot Pending
# 9: Error


[cmdletbinding()]
param(
    [Parameter(Mandatory=$true)]
        [string]$Server = '',

    [Parameter(Mandatory=$false)]
        [string]$username = '',

    [Parameter(Mandatory=$false)]
        [string]$password = '',

    [Parameter(Mandatory=$false)]
        [switch]$Info = $false
)

# create credentials
if($password){
    [securestring]$password = ConvertTo-SecureString $password -AsPlainText -Force
    [pscredential]$credentials = New-Object System.Management.Automation.PSCredential ($username, $password)
}


#write-host $password -ForegroundColor cyan

# Check if PackageProvider Nuget and Module PendingReboot is installed
<#
if(Get-Module -ListAvailable -Name PendingReboot) {
    if($Info){ write-host "INFO - Module PendingReboot installed!" -ForegroundColor Green }
}else{
    if($Info){ Write-Host "WARN - Module Pending Reboot not Installed!" -ForegroundColor Red }

    if(Get-PackageProvider -Name Nuget){
        if($info){ write-host "INFO - Nuget installed installed" -ForegroundColor Green }        
    }else{
        if($info){ Write-host "WARN - Nuget NOT installed, try to intsall" -ForegroundColor Red }
        Install−PackageProvider −Name Nuget −Force
    }

    Install-Script -name Test-PendingReboot -Force
}
#>

# Run PendingReboot$
if($credentials){
    $ServerResult = Test-PendingReboot -Detailed -ComputerName $Server -SkipPendingFileRenameOperationsCheck -SkipConfigurationManagerClientCheck -Credential $credentials
}else{
    $ServerResult = Test-PendingReboot -Detailed -ComputerName $Server -SkipPendingFileRenameOperationsCheck -SkipConfigurationManagerClientCheck
}

if($ServerResult){ Write-Verbose $ServerResult }

## Verhalten bei zugriff verweigert
if(!$ServerResult){
    # could not connect to host
    if($info){ write-host "ERR  - Clould not get resutls from Server: "$Server -ForegroundColor Red }
    write-host "9:Error connecting to host" 
    

}elseif($ServerResult.IsRebootPending){
    # reboot pending
    if($info){ write-host "INFO - Server Needs a Reboot!" -ForegroundColor DarkYellow }
    write-host "1:Reboot pending"
}else{
    if($info){ write-host "INFO - No Reboot Pending!" -ForegroundColor Green }
    write-host "0:No reboot pending"
}

