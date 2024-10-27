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