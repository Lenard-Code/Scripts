function Get-AllTheDnsThings {
    Param(
        [string]$ip,
        [string]$shost,
        [string]$zname,
	[string]$domain
    )

    $hashTableMainHost = @()
    $hashTableMainIp = @()
    $dcList = @((Get-ADDomainController -Filter *).Name)
    
    if($shost){
        ForEach($i in $dcList){
            $a=Get-DnsServerResourceRecord -ComputerName $i -ZoneName $domain | ? {$_.HostName -like "*$shost*"}
            if($a){
                $hashTableHost = New-Object PSObject -property @{
                    Server=$i
                    HostName=$a.Hostname
                    RecordType=$a.RecordType
                    Type=$a.Type
                    Timestamp=$a.Timestamp
                    TimeToLive=$a.TimeToLive
                    RecordData=$a.RecordData.IPv4Address.IPAddressToString
                }
                $hashTableMainHost += $hashTableHost
            }
            else{
                Write-Host "[!] No DNS record for $shost found on $i" -ForeGroundColor Red
            }
       }
       $hashTableMainHost | Select Server,Hostname,RecordData,RecordType,Timestamp,TimeToLive | FT
    }

    if($ip){
        ForEach($i in $dcList){
            $a=(Get-DnsServerResourceRecord -ComputerName $i -ZoneName $domain | ? {$_.RecordData.IPv4Address.IPAddressToString -like "*$ip*"})
            if($a){
                $hashTableIp = New-Object PSObject -property @{
                    Server=$i
                    HostName=$a.Hostname
                    RecordType=$a.RecordType
                    Type=$a.Type
                    Timestamp=$a.Timestamp
                    TimeToLive=$a.TimeToLive
                    RecordData=$a.RecordData.IPv4Address.IPAddressToString
                }
                $hashTableMainIp += $hashTableIp
            }
            else{
                Write-Host "[!] No DNS record for $ip found on $i" -ForeGroundColor Red
            }
       }
       $hashTableMainIp | Select Server,Hostname,RecordData,RecordType,Timestamp,TimeToLive | FT
    }
}
