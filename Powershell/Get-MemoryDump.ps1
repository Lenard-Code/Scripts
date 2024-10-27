<#
.SYNOPSIS
    Collects a memory dump from a remote host using the RamCapture tool.

.DESCRIPTION
    The Get-MemoryDump function establishes a PowerShell session with a specified remote host to perform a memory dump.
    It copies the RamCapture tool to the remote host, decompresses it, runs the capture, compresses the dump, and retrieves the compressed file.
    It also cleans up the temporary files and closes the PowerShell session.

.PARAMETER RemoteHost
    A string representing the name or IP address of the remote host.

.PARAMETER UserName
    A string representing the username under which the compressed memory dump file will be saved on the local machine.

.PARAMETER RamCapPath
    A string specifying the path to the RamCapture tool zip file on the local machine.

.EXAMPLE
    Get-MemoryDump -RemoteHost "192.168.1.10" -UserName "JohnDoe" -RamCapPath "C:\Tools\RamCapture.zip"

.NOTES
    Author: Lenard
    Date: 2024-10-27 (Added to github, was made a long time ago)
#>
 
 function Get-MemoryDump {
    Param (
        [Parameter(Mandatory=$True)]
        [string]$RemoteHost,
        [string]$UserName,
        [string]$RamCapPath
    )

    try {
        Write-Host "[*] Creating PSSession." -ForegroundColor Yellow
        $x = New-PSSession -Computer $RemoteHost -ErrorAction Stop
    }
    catch {
        Write-Host "[-] Error durring PSSession." -ForegroundColor Red
        throw
    }

    #Copying RamCapture tool to remote host
    try {
        Write-host "[+] Copying RamCapture to remote host." -ForegroundColor Green
        Copy-Item -Path $RamCapPath -Destination C:\temp -ToSession $x
        Write-Host "[+] RamCapture tool copied to remote host." -ForegroundColor Green
    }
    catch {
        Write-Host "[-] Unable to copy RamCapture tool to remote host." -ForegroundColor Red
    }

    #Decompressing RamCapture on the remote host
    Invoke-Command -ComputerName $RemoteHost -ScriptBlock {try{Write-Host "[+] Attemping to decompress RamCapture Archive." -ForegroundColor Green;Expand-Archive -LiteralPath C:\temp\RamCapture.zip -DestinationPath C:\temp\;`
    Write-Host "[+] RamCapture Archive decompressed." -ForegroundColor Green}catch{Write-Host "[-] Error during decompressing RamCapture archive" -ForegroundColor Red}}

    #Running RamCapture on remote host for collection
    Invoke-Command -ComputerName $RemoteHost -ScriptBlock {$hst=hostname;$bitSys=[System.Environment]::Is64BitOperatingSystem;cd "C:\temp";New-Item -Path . -ItemType "directory" -Name "RamCapture_Collect" | Out-Null;`
    if($bitSys -eq $True){Write-Host "[+] Running RamCapture." -ForegroundColor Green;cd C:\temp\RamCapture\x64;Start-Process .\RamCapture64.exe -Argument "C:\temp\RamCapture_Collect\$hst.mem" -Wait -NoNewWindow | Out-Null;Write-Host "[+] Memory capture complete." -ForegroundColor Green}`
    else{Write-Host "[+] Running RamCapture." -ForegroundColor Green;cd C:\temp\RamCapture\x86;.\RamCapture.exe "C:\temp\RamCapture_Collect\$hst.mem" | Out-Null}}

    #Check if 7zip module is installed, install if needed, compress memory file
    Invoke-Command -ComputerName $RemoteHost -ScriptBlock {$hst=hostname;$file="C:\temp\RamCapture_Collect\$hst.mem";if(Get-Module -ListAvailable -Name 7Zip4Powershell)`
    {Write-Host "[+] 7Zip4Powershell Module exists, moving on." -ForegroundColor Green}else{Write-Host "[*] 7Zip4Powershell module not found, attempting to install." -ForegroundColor Yellow;`
    try{Install-Module -Name 7Zip4Powershell -RequiredVersion 2.0.0 -Confirm:$false -Force;Write-Host "[+] 7Zip4Powershell module has been installed." -ForegroundColor Green}`
    catch{Write-host "[-] Error" -ForegroundColor Red;throw}};Write-Host "[*] Compressing memory file to Zip." -ForegroundColor Yellow;`
    try{Compress-7zip -Path "C:\temp\RamCapture_Collect\$hst.mem" -ArchiveFileName "C:\temp\RamCapture_Collect\$hst.zip" -Format Zip -CompressionLevel Normal;Write-Host "[+] Compression Complete." -ForegroundColor Green;Remove-Item –Path "C:\temp\RamCapture_Collect\$hst.mem" -Force}`
    catch{Write-Host "[-] Error in compression." -ForegroundColor Red}}

    #Retrieving RamCapture Memory image **Change $userName to your specific username to eliminate having to use -Username flag in the command
    try {
        Write-host "[+] Copying compressed memory dump file from remote host" -ForegroundColor Green
        Copy-Item -Recurse -Path C:\temp\RamCapture_Collect -Destination C:\Users\$UserName\Desktop -FromSession $x
        Write-host "[+] Copying memory dump successful" -ForegroundColor Green
    }
    catch {
        Write-Host "[-] Unable to copy files." -ForegroundColor Red
    }

    #Removing 7zip Module & Created RamCapture files on remote host
    Invoke-Command -ComputerName $RemoteHost -ScriptBlock {try{Write-Host "[+] Removing RamCapture related files from remote host." -ForegroundColor Green;`
    Remove-Item –Path C:\temp\RamCapture –Recurse -Force;Remove-Item –Path C:\temp\RamCapture_Collect –Recurse -Force; Remove-Item –Path C:\temp\RamCapture.zip –Recurse -Force;`
    Write-Host "[+] RamCapture related files removed." -ForegroundColor Green}catch{Write-Host "[-] Error in attempting to remove RamCapture files." -ForegroundColor Red}`
    if (Get-Module -ListAvailable -Name 7Zip4Powershell){try {Write-Host "[*] 7Zip4Powershell module found, attempting to remove." -ForegroundColor Yellow;Uninstall-Module -Name 7Zip4Powershell;`
    Write-host "[+] 7Zip4Powershell module Removed." -ForegroundColor Green}catch{Write-host "[-] Error removing module." -ForegroundColor Red}}else{Write-Host "[*] 7Zip4Powershell module not found, uninstall not needed." -ForegroundColor Yellow}}

    Write-Host "[+] Closing created PS Session's" -ForegroundColor Green
    $cpss = Get-PSSession | ? {$_.State -eq "Opened"} | Select Name; ForEach ($i in $cpss){Disconnect-PSSession -Name $i.Name | Out-Null}

}
