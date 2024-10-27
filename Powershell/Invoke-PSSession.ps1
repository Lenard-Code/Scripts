function Invoke-PSSession {
    Param(
        [string]$RHost,
        [string]$RHostFile
    )
    if($RHost){
        try{
            $option = New-PSSessionOption -nomachineprofile
            New-PSSession -ComputerName $RHost -Name $RHost -SessionOption $option -ErrorAction:SilentlyContinue | Out-Null
            $statCheck = (Get-PSSession -Name $RHost | Select State)
            if($statCheck.State -eq "Opened"){
                $id = (Get-PSSession -Name $RHost | ? {$_.State -eq "Opened"} | Select Id).Id
                Write-Host "[+] PS Session established on $RHost with ID $id" -ForegroundColor Green
            }
            else {
                Write-Host "[-] PS Session not established on $RHost" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "[-] Error in establishing connection on $RHost" -ForegroundColor Red
        }
    }

    if($RHostFile){
        $destList = Get-Content $RHostFile
        ForEach ($dest in $destList){
            try {
                $option = New-PSSessionOption -nomachineprofile
                New-PSSession -ComputerName $dest -Name $dest -SessionOption $option -ErrorAction:SilentlyContinue | Out-Null
                $statCheck = Get-PSSession -Name $dest | Select State
                if($statCheck.State -eq "Opened"){
                    Write-Host "[+] PS Session established on $dest" -ForegroundColor Green
                }
                else {
                    Write-Host "[-] PS Session not established on $dest" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "[-] Error in establishing connection on $dest" -ForegroundColor Red
            }
        }
    }
}