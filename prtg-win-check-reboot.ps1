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
    https://www.powershellgallery.com/packages/PendingReboot
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

# Check if 64Bit Environment
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    # Source: https://stackoverflow.com/a/38981021
    #write-warning "Y'arg Matey, we're off to 64-bit land....."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
    exit $lastexitcode
}

#Check if Module is installed
if(Get-Module -Name PendingReboot){
    ## all ok
}else{
    Write-host "8: PendingReboot Module not installed"
    exit
}

#import Module
Import-Module -Name PendingReboot

# create credentials
if($password){
    [securestring]$password = ConvertTo-SecureString $password -AsPlainText -Force
    [pscredential]$credentials = New-Object System.Management.Automation.PSCredential ($username, $password)
}


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

