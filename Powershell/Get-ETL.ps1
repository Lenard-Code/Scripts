<#
.SYNOPSIS
        Captures traffic for the given IP address on the remote system and creates an ETL file using NETSH trace. This file will be retrieved in order to convert to PCAP for analysis.
.DESCRIPTION
        This function allows NETSH trace to be executed on a remote system which will capture traffic pertaining to the provided IP address.
        After the given time (in seconds) the script will stop the trace and provide an .etl file named as the date (YYYYMMDDhhmmss) when the capture started.
        The function will then retrieve the newly created .etl file and delete it off the host.
.PARAMETER Dest
        FQDN of the target machine.
.PARAMETER IPaddress
        Must use quotes around the address. Provides NETSH the IP address to capture.
.PARAMETER Seconds
        The amount of time to capture.
.EXAMPLE
        Get-ETL -Dest RAN-DOMBOX.domain.corp -IPaddress "1.1.1.1" -Seconds 300
            
        Description
        -----------
        This function allows NETSH trace to be executed on a remote system which will capture traffic pertaining to the provided IP address.
        After the given time (in seconds) the script will stop the trace and provide an .etl file named as the date (YYYYMMDDhhmmss) when the capture started.
        The function will then retrieve the newly created .etl file and delete it off the host.
.NOTES
        FunctionName    : Get-ETL
        Created by      : Lenard
        Date Coded      : 07/20/2021 00:00:00
        Modified by     : No one special
        Date Modified   : 07/20/2021 00:00:00
        More info       : Will need to convert file using etl2pcapng (https://github.com/microsoft/etl2pcapng/releases)
#>
function Get-ETL {
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Dest,
        [Parameter(Mandatory=$true)]
        [string]$IPaddress,
        [Parameter(Mandatory=$true)]
        [string]$Seconds
    )
    $t = (Get-Date).ToString("yyyyMMddhhmmss")
    Invoke-Command -ComputerName $Dest -ScriptBlock {param($arg1,$arg2,$arg3) Write-Host "[+] Starting NETSH  Trace." -ForegroundColor Green ;netsh trace start report=disabled capture=yes IPv4.Address=$arg1 tracefile=C:\temp\$arg3.etl;`
    Start-Sleep -Seconds $arg2;netsh trace stop} -ArgumentList $IPaddress,$Seconds,$t
    #Establishing PS-Session for  remote host
    try {
        Write-Host "[*] Attempting to create PSSession." -ForegroundColor Yellow
        $x = New-PSSession -Computer $Dest -ErrorAction Stop
        Write-Host "[+] PSSession created." -ForegroundColor Green
    }
    catch {
        Write-Host "[-] Error durring PSSession." -ForegroundColor Red
        throw
    }
    #Retrieving ETL file
        try {
        Write-host "[+] Copying ETL file from remote host" -ForegroundColor Green
        Copy-Item -Path "C:\temp\$t.etl" -Destination C:\temp -FromSession $x
        Write-host "[+] ETL copy successful" -ForegroundColor Green
        Invoke-Command -Session $x -ScriptBlock {param($arg1) Remove-Item c:\temp\$arg1.etl} -ArgumentList $t
    }
    catch {
        Write-Host "[-] Unable to copy files." -ForegroundColor Red
    }
    #Closing PSSessions
    Write-Host "[+] Closing created PS Session" -ForegroundColor Green
    $cpss = Get-PSSession | ? {$_.State -eq "Opened"} | Select Name; ForEach ($i in $cpss){Disconnect-PSSession -Name $i.Name | Out-Null}
}