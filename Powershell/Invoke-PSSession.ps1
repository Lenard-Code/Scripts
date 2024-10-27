<#
.SYNOPSIS
    Establishes PowerShell sessions with remote hosts.

.DESCRIPTION
    The Invoke-PSSession function attempts to create PowerShell sessions with one or multiple remote hosts.
    It takes either a single hostname or a file containing a list of hostnames and tries to establish a session with each.
    The function outputs the status of each connection attempt.

.PARAMETER RHost
    A string representing the name or IP address of a single remote host.

.PARAMETER RHostFile
    A string specifying the path to a file containing a list of remote hostnames or IP addresses.

.EXAMPLE
    Invoke-PSSession -RHost "192.168.1.10"

.EXAMPLE
    Invoke-PSSession -RHostFile "C:\path\to\hosts.txt"

.NOTES
    Author: Lenard
    Date: 2024-10-27 (Added to github)
#>

﻿function Invoke-PSSession {
    Param(
        [string]$RHost,
        [string]$RHostFile
    )
    if($RHost){
        try{
            $option = New-PSSessionOption -nomachineprofile
            New-PSSession -ComputerName $RHost -Name $RHost -SessionOption $option -ErrorAction:SilentlyContinue | Out-Null
            $statCheck = (Get-PSSession -Name $RHost | Select State)
            if($statCheck.State -eq "Opened"){
                $id = (Get-PSSession -Name $RHost | ? {$_.State -eq "Opened"} | Select Id).Id
                Write-Host "[+] PS Session established on $RHost with ID $id" -ForegroundColor Green
            }
            else {
                Write-Host "[-] PS Session not established on $RHost" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "[-] Error in establishing connection on $RHost" -ForegroundColor Red
        }
    }

    if($RHostFile){
        $destList = Get-Content $RHostFile
        ForEach ($dest in $destList){
            try {
                $option = New-PSSessionOption -nomachineprofile
                New-PSSession -ComputerName $dest -Name $dest -SessionOption $option -ErrorAction:SilentlyContinue | Out-Null
                $statCheck = Get-PSSession -Name $dest | Select State
                if($statCheck.State -eq "Opened"){
                    Write-Host "[+] PS Session established on $dest" -ForegroundColor Green
                }
                else {
                    Write-Host "[-] PS Session not established on $dest" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "[-] Error in establishing connection on $dest" -ForegroundColor Red
            }
        }
    }
}
