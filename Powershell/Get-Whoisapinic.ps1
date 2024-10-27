<#
.SYNOPSIS
    Retrieves and displays WHOIS information for a list of IP addresses from the APNIC database.

.DESCRIPTION
    The Get-WhoisAPNIC function takes a list of IP addresses and queries the APNIC WHOIS database for each address.
    It collects relevant information such as IP range, description, network name, country, and last modified date.
    The results are formatted and displayed in a table format.

.PARAMETER IPfile
    An array of strings specifying the list of IP addresses to be queried.

.EXAMPLE
    Get-WhoisAPNIC -IPfile @("192.168.1.1", "203.0.113.0")

.NOTES
    Author: Lenard
    Date: 2024-10-27 (Added to GitHub)
#>
 
 function Get-WhoisAPNIC {
    Param(
        [string[]]$IPfile
    )
    $newapnicWhois = @{}
    ForEach($i in $IPfile) {
        $r = Invoke-RestMethod -Uri "https://wq.apnic.net/query?searchtext=$i" -ErrorAction stop
        #Write-Host ($r.attributes | Out-String)
        Write-Verbose ($r.attributes | Out-String)
        $key = "IP"
        $value = $i
        $newapnicWhois.add($key, $value)
        if($r.attributes) {
            ForEach($i in $r.attributes){
                if($i.name -eq $null -or $i.values -eq $null){
                    Continue
                }
                else {
                    $key = $i.name.trim('{}')
                    $value = $i.values.trim('{}')
                    $value = $value.replace(" - ",'-')
                    if ($newapnicWhois.ContainsKey($key)) {
                        Continue
                    }
                    else {
                        $newapnicWhois.add($key, $value)
                    }
                }
            }
        }
    }
    $newapnicWhois | ForEach {[PSCustomObject]$_} | Select IP,inetnum, descr, netname, country, last-modified | Format-Table -AutoSize -Wrap
}
