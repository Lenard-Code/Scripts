<#
.SYNOPSIS
    Retrieves information about WSL installations on a list of remote hosts.

.DESCRIPTION
    The Get-AllWslThings function checks a list of specified hosts to determine if they have any WSL (Windows Subsystem for Linux) installations.
    It tries to establish a connection to each host and searches for specific WSL-related executables in the Program Files\WindowsApps directory.
    The function outputs the results to a specified file or displays them on the console.

.PARAMETER shost
    A string representing a single host name (not used in the function but reserved for future use).

.PARAMETER shostFile
    A string specifying the path to a file containing a list of host names to be checked.

.PARAMETER OutFile
    A string specifying the path to an output file where the results will be saved. If not provided, results are displayed on the console.

.EXAMPLE
    Get-AllWslThings -shostFile "C:\hosts.txt" -OutFile "C:\wsl_results.txt"

.NOTES
    Author: Lenard
    Date: 2024-10-27 (added to github, not sure when it was made)
#>
 
 function Get-AllWslThings{
    Param(
        [string]$shost,
        [string]$shostFile,
        [string]$OutFile
    )
    $hostList = (Get-Content $shostFile)
    $zwslList = @()
    ForEach($sh in $hostList){
        try{
            $ip=(Test-Connection $sh -count 1 -ErrorAction SilentlyContinue | Select IPV4Address).IPV4Address.IPAddressToString | Out-String
            if($ip -like "10.*"){
                Write-Host "$sh on VPN, checking for WSL..." -ForegroundColor DarkCyan
                try{
                    $rem = (Invoke-Command -ComputerName $sh -ScriptBlock {$list=@();$box=hostname;$seekEXE=("*ubuntu*.exe","*kali*.exe","*fedora*.exe","*opensus*.exe");`
                    ForEach($i in $seekEXE){$file=(Get-ChildItem -Path "C:\Program Files\WindowsApps" $i -Recurse).Name;`
                    if($file){$list += $file}else{}};Return $list})

                    if($rem){
                        $zwslinfo = New-Object PSObject -property @{
                            Hostname = $sh
                            WSL_Found = $rem
                        }
                        $zwslList += $zwslinfo
                    }
                }
                catch{
                    Write-Host "Unable to connect to $sh" -ForegroundColor DarkRed
                }
            }
            else{
                Write-Host "$sh IP is not VPN" -ForegroundColor DarkRed
            }
        }
        catch{
            Write-Host "No response from $sh"
        }
    }
    if($OutFile){
        $zwslList | Select Hostname,WSL_Found | Out-File $OutFile
    }
    else{
        $zwslList | Select Hostname,WSL_Found
    }
}
