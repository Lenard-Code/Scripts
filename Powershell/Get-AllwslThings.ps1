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