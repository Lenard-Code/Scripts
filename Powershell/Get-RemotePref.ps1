<#
    .SYNOPSIS
        Retrieves Preference files for Chromium based browsers (Currently: Edge, Chrome)
    .DESCRIPTION
        This script is to be used on remote systems while using an elevated PS consoleThe script will 
        check for various Preference files. Then will out any sites that are allowed to send Notifications.
        If no output is listed under the found Preference json files. That means no sites are actively allowed to
        send notifications.

        SentinelOne Usage:
        function Get-SentEdgPref { Param([string]$user); $json = Get-Content -Raw -Path "C:\Users\$($user)\AppData\Local\Microsoft\Edge\User Data\Default\Preferences" | ConvertFrom-Json;$Notif = $json.profile.content_settings.exceptions.notifications;Write-Host "`n"$filePath"`n"$Notif"`n"}
        function Get-SentChrmPref { Param([string]$user); $json = Get-Content -Raw -Path "C:\Users\$($user)\AppData\Local\Google\Chrome\User Data\Default\Preferences" | ConvertFrom-Json;$Notif = $json.profile.content_settings.exceptions.notifications;Write-Host "`n"$filePath"`n"$Notif"`n"}


    .PARAMETER ComputerName
        Need to use the FQDN of the target system.
    .EXAMPLE
        PS Console
            Invoke-Command -ComputerName COMPUTERNAME.us.nelnet.biz -FilePath "C:\Users\USERNAME\Location-To-Script\Get-RemotePref.ps1"

        S1 Console:
            Copy/Paste desired function (Get-SentEdgPerf or Get-ChrmPref) to console
                - function Get-SentEdgPref { Param([string]$user); $json = Get-Content -Raw -Path "C:\Users\$($user)\AppData\Local\Microsoft\Edge\User Data\Default\Preferences" | ConvertFrom-Json;$Notif = $json.profile.content_settings.exceptions.notifications;Write-Host "`n"$filePath"`n"$Notif"`n"}
                Get-SentEdgPref -User username
            
        Description
        -----------
        This script is to be used on remote systems while using an elevated PS console. The script will 
        check for various Preference files. Then will out any sites that are allowed to send Notifications
    .NOTES
        ScriptName      : Get-RemotePref
        Created by      : Lenard
        Date Coded      : 02/03/2022 00:00:00
        Modified by     : No one special
        Date Modified   : 02/03/2022 00:00:00
        More info       : NA
#>
$usrList = @()
$usrCheck = Get-ChildItem -Path 'C:\Users\' -Directory | select Name

ForEach ($usr in $usrCheck) {
    $u = Test-Path -Path "C:\Users\$($usr.Name)\AppData\Local\Microsoft\Edge\User Data\Default\Preferences"
    $c = Test-Path -Path "C:\Users\$($usr.Name)\AppData\Local\Google\Chrome\User Data\Default\Preferences"
    if ($u -eq "True") {
        $k = "C:\Users\$($usr.Name)\Documents\Pref_Folder"
        Write-Host "Edge Pref file found for $($usr.Name)" -ForegroundColor Green
        if (Test-Path -Path $k) {
            #Write-Host "Folder exists at: $k"
        } else {
            New-Item -Path "c:\Users\$($usr.Name)\Documents\Pref_Folder" -ItemType "directory" | Out-Null
            #Write-Host "Folder created at: $k"
        }
        Get-Content "C:\Users\$($usr.Name)\AppData\Local\Microsoft\Edge\User Data\Default\Preferences" | Out-File "$k\Pref_Edge.json"
    } else {
        Write-Host "No Edge pref file found for $($usr.Name)" -ForegroundColor Red
    }

    if ($c -eq "True") {
        $k = "C:\Users\$($usr.Name)\Documents\Pref_Folder"
        Write-Host "Chrome Pref file found for $($usr.Name)" -ForegroundColor Green
        if (Test-Path -Path $k) {
            #Write-Host "Folder exists at: $k"
        } else {
            New-Item -Path "c:\Users\$($usr.Name)\Documents\Pref_Folder" -ItemType "directory" | Out-Null
            #Write-Host "Folder created at: $k"
        }
        Get-Content "C:\Users\$($usr.Name)\AppData\Local\Google\Chrome\User Data\Default\Preferences" | Out-File "$k\Pref_Chrom.json"
    } else {
        Write-Host "No Chrom pref file found for $($usr.Name)" -ForegroundColor Red
    }
}

function Get-PrefNotifications {
    ForEach ($usr in $usrCheck) {
        $prefFiles = Get-ChildItem -Path "C:\Users\$($usr.Name)\Documents\Pref_Folder" -Filter *.json -Recurse | %{$_.FullName}
        ForEach ($filePath in $prefFiles) {
            $json = Get-Content -Raw -Path $filePath | ConvertFrom-Json
            $Notif = $json.profile.content_settings.exceptions.notifications
            Write-Host "`n"$filePath"`n"$Notif"`n"
        }
        Remove-Item -Force -Recurse -Path "C:\Users\$($usr.Name)\Documents\Pref_Folder" -ErrorAction SilentlyContinue
    }
}

Get-PrefNotifications