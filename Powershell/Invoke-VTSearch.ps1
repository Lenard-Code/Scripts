<#
    .SYNOPSIS
        Returns the SHA1 hash..
    .DESCRIPTION
        The function uses VirusTotals APIv2 to query the service that returns the SHA1 hash if found. The
        user has the ability to submit a file of hashes to query or submit a single hash. Function has
        the ability to write out findings to text file.
    .PARAMETER hash
        Used for single hash lookup
    .PARAMETER hashFile
        Used for multiple hashes to be queried. File needs to be in CSV format and needs a header labeled as "hash".
    .PARAMETER OutFile
        Used to to set the target location of the outfile.
    .EXAMPLE
        Get-VTShaHash -hash "SOMEHASH"
        Get-VTShaHash -hashFile "C:\Users\SOMEUSER\FILE\Location.csv" -OutFile "C:\Users\SOME\USER\location.txt"
            
        Description
        -----------
        The function uses VirusTotals APIv2 to query the service that returns the SHA1 hash if found. The
        user has the ability to submit a file of hashes to query or submit a single hash. Function has
        the ability to write out findings to text file.
    .NOTES
        FunctionName    : Get-VTShaHash
        Created by      : No one special
        Date Coded      : 09/13/2021 00:00:00
        Modified by     : No one special
        Date Modified   : 10/02/2021 00:00:00
        More info       : NA
#>
function Get-VTShaHash {
    Param(
        [string]$hash,
        [string]$hashFile,
        [string]$OutFile
    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $apiKey = "---apikeyplaceholder"

    function Submit-Hash($hash) {
        $body = @{resource = $hash; apikey = $apikey}
        $result = Invoke-RestMethod -Method GET -Uri 'https://www.virustotal.com/vtapi/v2/file/report' -Body $body
        return $result
    }
    $hashList = @()
    if ($hash) {
        $hashList = $hash
    }
    elseif ($hashFile) {
        Import-CSV $hashFile | ForEach-Object {
            $hashList += $_.hash
        }
    }
    else {
        Write-Host "No or Incorrect Parameter used."
    }
    $hashTotal = $hashList.Count
    $n = 0
    ForEach ($i in $hashList){
        Write-Progress -Activity "Searching Hashes" -Status "Progress:" -PercentComplete ($n/$hashTotal*100)
        if ($hashList.count -ge 4) {
            $sleepTime = 20
        }
        else {
            $sleepTime = 1
        }
        $results = Submit-Hash($i)
        
        if ($OutFile) {
            if ($results.sha1 -eq $null) {
                #Do nothing but keep it moving
            }
            else {
                ($results.sha1) >> $OutFile
            }
        }
        else {
            if ($results.sha1 -eq $null){
                #Do nothing but keep it moving
            }
            else {
                Write-Host "SHA1: " -NoNewline; Write-Host $results.sha1
            }
        }   
        Start-Sleep -seconds $sleepTime
        $n += 1
    }
}