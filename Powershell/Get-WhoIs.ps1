<#
.SYNOPSIS
    Retrieves and categorizes WHOIS information for a list of IP addresses from various regional internet registries.

.DESCRIPTION
    The Get-WhoisDB function reads a list of IP addresses from a specified file and queries the WHOIS database for each IP.
    It categorizes the IP addresses based on the regional internet registry (RIR) that they belong to, such as RIPE, APNIC, AFRINIC, LACNIC, JPNIC, KRNIC, TWNIC, IRINN, and ARIN.
    The results are displayed and specific WHOIS querying functions for each RIR are invoked if there are matching IPs.

.PARAMETER IPfile
    A string specifying the path to a file containing a list of IP addresses to be queried.

.EXAMPLE
    Get-WhoisDB -IPfile "C:\path\to\iplist.txt"

.NOTES
    Author: Lenard
    Date: 2024-10-27 (Added to Github, made years ago)
#>
 
 function Get-WhoisDB {
    Param (
        [string]$IPfile
    )
    $UserListofIps = Get-Content $IPFile
    $ripeArr = @(); $apnicArr = @(); $afrinicArr = @(); $lacnicArr = @(); $jpnicArr = @(); $krnicArr = @()
    $twnicArr = @(); $irinnArr = @(); $arinArr = @()

    $baseURL = 'http://whois.arin.net/rest'
    $header = @{"Accept" = "application/xml"}

    if($IPfile) {
        $UserListofIps = Get-Content $IPFile
        ForEach($ip in $UserListofIps) {
            $url = "$baseUrl/ip/$ip"
            $r = Invoke-Restmethod $url -Headers $header -ErrorAction stop
            $DBname = ($r.net.orgRef.name | Out-String)
            if ($DBname -like "RIPE*"){
                $ripeArr += $ip
            }
            elseif ($DBname -like "Asia Pacific Network Information Centre*") {
                $apnicArr += $ip
            }
            elseif ($DBName -like "AFRINIC*") {
                $afrinicArr += $ip
            }
            elseif ($DBName -like "Latin American and Caribbean IP address Regional Registry*") {
                $lacnicArr += $ip
            }
            elseif ($DBName -like "JPNIC*") {
                $jpnicArr += $ip
            }
            elseif ($DBName -like "KRNIC*") {
                $krnicArr += $ip
            }
            elseif ($DBName -like "TWNIC*") {
                $twnicArr += $ip
            }
            elseif ($DBName -like "IRINN*") {
                $irinnArr += $ip
            }
            else {
                $arinArr += $ip
            }
        }
    }
    $allarrCount = @{}
    $allarrCount.Add('RIPE', $ripeArr.count)
    $allarrCount.Add('APNIC', $apnicArr.count)
    $allarrCount.Add('AFRINIC', $afrinicArr.count)
    $allarrCount.Add('LACNIC', $lacnicArr.count)
    $allarrCount.Add('JPNIC', $jpnicArr.count)
    $allarrCount.Add('KRNIC', $krnicArr.count)
    $allarrCount.Add('TWNIC', $twnicArr.count)
    $allarrCount.Add('IRINN', $irinnArr.count)
    $allarrCount.Add('ARIN', $arinArr.count)

    ForEach ($i in $allarrCount.keys) {
        if ($allarrCount.$i -gt 0) {
            Write-Host "Number of $i IPs:" $allarrCount.$i -ForegroundColor Yellow
        }
    }
    
    if($arinArr.count -gt 0) {
        Write-Host "ARIN IPs:" -ForegroundColor Green
        Get-WhoisARIN -IPFile $arinArr #-OutFile C:\Users\cdarnell\Desktop\newListofIps.csv
    }
    if($ripeArr.count -gt 0) {
    Write-Host "RIPE IPs:" -ForegroundColor Green
        Get-WhoisRIPE -IPfile $ripeArr
    }
    if($lacnicArr.count -gt 0) {
        Get-WhoisLACNIC -IPFile $lacnicArr
    }
}


function Get-WhoisARIN {
    Param (
        [string]$IPAddress,
        [string[]]$IPfile,
        [string]$OutFile
    )
    $baseURL = 'http://whois.arin.net/rest'
    $header = @{"Accept" = "application/xml"}
    if($IPfile) {
        $ipl = $IPFile
        $iparray = @()
        ForEach ($ip in $ipl) {
            $url = "$baseUrl/ip/$ip"
            $r = Invoke-Restmethod $url -Headers $header -ErrorAction stop
            Write-Verbose ($r.net | Out-String)
            if ($r.net){
                $handle = $r.net.orgRef.handle
                $obj = New-Object PSObject -Property @{
                    Name = $r.net.name
                    IP = $ip
                    Organization = $r.net.orgRef.name
                    CIDR = ($r.net.netBlocks.netBlock | foreach-object {"$($_.startaddress)/$($_.cidrLength)"}) -join ', '
                    Handle = $r.net.orgRef.handle
                    Additional_Nets = if($r.net.orgRef.handle){"https://whois.arin.net/rest/org/$handle/nets"}else{}
                    Updated = $r.net.updateDate
                    }
                $iparray += $obj
            }
        }
        if($OutFile){
            $iparray | Export-Csv -Path $OutFile -NoTypeInformation
            $iparray | Select IP, Name, Organization, Handle, Additional_Nets, Updated| Format-Table -AutoSize}
        else {
            $iparray | Select IP, Name, Organization, Handle, Additional_Nets, Updated| Format-Table -AutoSize -Wrap
        }
    }
    elseif($IPAddress) {
        $url = "$baseUrl/ip/$IPAddress"
        $r = Invoke-Restmethod $url -Headers $header -ErrorAction stop
        Write-Host ($r.net | Out-String)
        Write-Verbose ($r.net | Out-String)
        $handle = $r.net.orgRef.handle
        $obj = New-Object PSObject -Property @{
            Name = $r.net.name
            IP = $IPAddress
            Organization = $r.net.orgRef.name
            CIDR = ($r.net.netBlocks.netBlock | foreach-object {"$($_.startaddress)/$($_.cidrLength)"}) -join ', '
            Handle = $r.net.orgRef.handle
            Additional_Nets = if($r.net.orgRef.handle){"https://whois.arin.net/rest/org/$handle/nets"}else{}
            Updated = $r.net.updateDate
            }
        $obj | Select IP, Name, Organization, Handle, Additional_Nets, Updated | Format-Table -AutoSize -Wrap
    }
    else {Write-Host "Nope $IPAddress"}
}

function Get-WhoisRIPE {
    Param (
        [string]$IPAddress,
        [string[]]$IPfile
    )
    if($IPfile) {
        $ipl = $IPFile
        $iparray = @()
        ForEach ($ip in $ipl) {
            $Url = "https://rest.db.ripe.net/search.json?query-string=$ip"
            $header = @{"Accept" = "text/xml"}
            $xml = Invoke-RestMethod $Url -Header $headers
            $v = $xml.objects.object | Where-Object {$_.type -eq "inetnum"}
            $z = $v.attributes.attribute
            Write-Verbose ($z | Out-String)
            $obj = New-Object PSObject -Property @{
                IPAddress = $ip
                Range = $z | ? {$_.name -eq "inetnum"} | Select-Object -ExpandProperty value
                Netname = $z | ? {$_.name -eq "netname"} | Select-Object -ExpandProperty value
                Country_Code = $z | ? {$_.name -eq "country"} | Select-Object -ExpandProperty value
                Organization = ($z | ? {$_.name -eq "mnt-by"} | Select-Object -ExpandProperty value) -join ' ,'
                Last_Modified = $z | ? {$_.name -eq "last-modified"} | Select-Object -ExpandProperty value
                }
            $iparray += $obj
        }
        $iparray | Select IPAddress, Country_Code, NetName, Range, Last_Modified, Organization | Format-Table -Autosize -Wrap
    }
    elseif($IPAddress) {
        $Url = "https://rest.db.ripe.net/search.json?query-string=$IPAddress"
        $header = @{"Accept" = "text/xml"}
        $xml = Invoke-RestMethod $Url -Header $headers
        $v = $xml.objects.object | Where-Object {$_.type -eq "inetnum"}
        $z = $v.attributes.attribute
        Write-Verbose ($z | Out-String)
        $obj = New-Object PSObject -Property @{
            IPAddress = $IPAddress
            Range = $z | ? {$_.name -eq "inetnum"} | Select-Object -ExpandProperty value
            Netname = $z | ? {$_.name -eq "netname"} | Select-Object -ExpandProperty value
            Organization = $z | ? {$_.name -eq "mnt-by"} | Select-Object -ExpandProperty value
            Country_Code = $z | ? {$_.name -eq "country"} | Select-Object -ExpandProperty value
            Last_Modified = $z | ? {$_.name -eq "last-modified"} | Select-Object -ExpandProperty value

            }
        $iparray | Select IPAddress, Country_Code, NetName, Range, Last_Modified, Organization | Format-Table -Autosize -Wrap
    }

}
function Get-WhoisAPNIC {
    Param(
        [string[]]$IPfile
    )
    $hashTable = @{}
    ForEach($x in $IPfile) {
        $r = Invoke-RestMethod -Uri "https://wq.apnic.net/query?searchtext=$x" -ErrorAction stop
        $r | % {
            if (($null -ne $_.attributes) -and ($_.objecttype -eq "inetnum")) {
                $_.attributes | Add-Member -MemberType NoteProperty -Name Type -Value $_.objecttype
                #Need to fix this who care $_.attributes
            }
        }
    }
    $hashTable

}
function Get-WhoisAFRINIC{}
function Get-WhoisLACNIC {
    Param (
        [string[]]$IPFile
    )
    Write-Host "LANIC IPs:" -ForegroundColor Green
    ForEach($ip in $IPFile) {
        Write-Host $ip
    }
}
function Get-WhoisJPNIC {}
function Get-WhoisKRNIC {}
function Get-WhoisTWNIC {}
function Get-WhoisIRINN {}
