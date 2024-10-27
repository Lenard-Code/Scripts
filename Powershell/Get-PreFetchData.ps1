<#
.SYNOPSIS
        Retrieves targeted file location within Prefetch folder.
.DESCRIPTION
        This function creates a PS Session to copy the executable PECmd.exe to the remote host. Then
        executes to look for the desired targeted file by name (SearchFile variable). Created CSV's are saved
        to remote disk and parsed to identify the path of the executable. After execution is complete all files
        are then removed and PS Sessions closed.
.PARAMETER Dest
        FQDN of the target machine.
.PARAMETER PECmdPath
        Path to local copy of PECmd.
.PARAMETER SearchFile
        String to search for (program name *no spaces*).
.PARAMETER Ext
        Used to search CSV to locate the path of executable (can be changed if looking for specific file that was touched by the program (Ex. DLL, txt, etc).
.EXAMPLE
        Get-PrefetchData -Dest DEN-516160L.us.nelnet.biz -PECmdPath "C:\tmp\PECmd.exe" -SearchFile "vmware" -Ext "exe"
.EXAMPLE (Hardcoded path to PECmd.exe)
        Get-Prefetch -Dest DEN-516160L.us.nelnet.biz -SearchFile "vmware" -Ext "exe"
            
        Description
        -----------
        This function creates a PS Session to copy the executable PECmd.exe to the remote host. Then
        executes to look for the desired targeted file by name (SearchFile variable). Created CSV's are saved
        to remote disk and parsed to identify the path of the executable. After execution is complete all files
        are then removed and PS Sessions closed.
.NOTES
        FunctionName    : Get-Prefetch
        Created by      : Lenard
        Date Coded      : 03/24/2021 00:00:00
        Modified by     : No one special
        Date Modified   : 03/25/2021 00:00:00
        More info       : Pre-Req: PECmd.exe (.NET4 ver) will need to be downloaded from https://ericzimmerman.github.io/
#>
function Get-PreFetchData {
    Param (
        [string]$Dest,
        [string]$PECmdPath,
        [string]$SearchFile,
        [string]$Ext
    )
    #Change $PECmdPath to path file is located if you dont want to manually set it each time
    #$PECmdPath = C:\SOME-PLACE\PECmd.exe

    $a = Get-FileHash $PECmdPath -Algorithm SHa1 | Select Hash
    $a = $a.Hash
    if ($a -eq "CF40E1D89B3C6F4B2D2C4848C2D6E657C0F70214") {
        Write-Host "[+] Hash is good, moving on" -ForegroundColor Green
    }
    else {
        Write-Host "[-] Hash does not match, exiting" -ForegroundColor Red
        throw
    }

    $SearchFile = $SearchFile.ToUpper()
    $Ext = $Ext.ToUpper()
    try {
        $x = New-PSSession -Computer $Dest -ErrorAction Stop
    }
    catch {
        Write-Host "[-] Error durring PSSession. Is the dest on VPN?" -ForegroundColor Red
        throw
    }
    Copy-Item -Path $PECmdPath -Destination C:\PECmd.exe -ToSession $x

    #Change $PECmdPath to path file is located if you dont want to manually set it each time
    #$PECmdPath = C:\SOME-PLACE\PECmd.exe

    #To see output from PECmd remove "| Out-Null".
    Invoke-Command -ComputerName $Dest -ArgumentList $SearchFile -ScriptBlock {param($SearchFile);cd C:\Windows\Prefetch;$n = dir |? {$_.Name -like "*$SearchFile*"} |
        Select Name;cd C:\; ForEach ($pff in $n) {$x=$pff.Name;.\PECmd.exe -f C:\Windows\Prefetch\$x  --csv "C:\" --csvf $x-Results.csv | Out-Null}; Start-Sleep -s 3}
    Invoke-Command -ComputerName $Dest -ArgumentList $Ext -ScriptBlock {param($Ext);cd C:\; $p = dir | ? {$_.Name -like "*results.csv"};ForEach ($t in $p){$t=$t.Name;`
    $csv = Import-CSV C:\$t; foreach ($i in $csv) {$n = $i.filesloaded -split ","; $a = $a + $n};$list=@(); foreach ($x in $a){if($x.EndsWith("$Ext")){$list=$list+$x}}}`
    $newlist=$list | Select -Unique;if($newList.Count -gt 0){ForEach($j in $newlist){Write-Host "[+] File found in:$j" -Foregroundcolor Green}}else{Write-Host "[-] No items found with selected variables" -ForegroundColor Red}}

    #Clean up PSSessions & Written Files
    Invoke-Command -Computer $Dest -ScriptBlock {cd C:\;try{Remove-Item PECmd.exe; Write-Host "[+] PECmd.exe has been deleted from remote system" -Foregroundcolor Green}`
    catch{Write-Host "[-] An Error has occured removing PECmd from remote system`n`n" -ForegroundColor Red};cd C:\;try{$f=dir | ? {$_.Name -like "*results.csv" -or $_.Name -like "*results_timeline.csv"};`
    ForEach ($i in $f){Remove-Item $i.Name};Write-Host "[+] CSV Files have been removed" -ForegroundColor Green}catch{Write-Host "[-] Error attempting to remove CSV files" -Foreground Red}}
    
    Write-Host "[+] Closing created PS Session's" -ForegroundColor Green
    $o = Get-PSSession | ? {$_.State -eq "Opened"} | Select Name; ForEach ($i in $o){Disconnect-PSSession -Name $i.Name | Out-Null}
}