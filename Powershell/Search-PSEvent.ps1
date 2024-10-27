#Code provided by Ben Ten during course in 2021?
 
 function Search-PSEvent {
    Param(
        [datetime]$Start,
        [datetime]$End,
        [string]$Search="*",
        [string]$ComputerName=$null
    )
    Search-Event -LogName "Microsoft-Windows-PowerShell/Operational" -EventID 4104 -Start $Start -End $End -Search $Search
}

function Search-Process {
    Param(
        [datetime]$Start,
        [datetime]$End,
        [string]$Search="*",
        [string]$ComputerName=$null
    )
    Search-Event -LogName "Security" -EventID 4688 -Start $Start -End $End -Search $Search
}

function Search-Event {
    Param(
        [string]$LogName,
        [int]$EventID,
        [datetime]$Start,
        [datetime]$End,
        [string]$Search="*",
        [string]$ComputerName=$null
    )

    $filter = @{
        LogName=$LogName;
        ID=$EventID;
        StartTime=$Start;
        EndTime=$End;
    }
    try {
        if($ComputerName) {
            $events = Get-WinEvent -FilterHashtable $filter -ComputerName $ComputerName -ErrorAction Stop | ? { $_.Message -like "*$Search*" }
        }
        else {
            $events = Get-WinEvent -FilterHashtable $filter -ErrorAction Stop | ? { $_.Message -like "*$Search*" }
        }
        if($events) {
            $xmlevents = $events | % { [xml]$_.ToXml() }
            $xmlevents | % {
                $xmldata = $_.Event.EventData.Data
                $rtn = New-Object PSObject
                $timestamp = $_.Event.System.TimeCreated.SystemTime
                $datetime = ([DateTime]$timestamp).ToUniversalTime()
                $datetime_local = [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($datetime, 'Eastern Standard Time')
                $rtn | Add-Member -Type NoteProperty -Name "Timestamp" -Value $datetime_local
                $xmldata | % {
                    $name = $_.Name
                    $value = $_."#text"
                    $rtn | Add-Member -Type NoteProperty -Name $name -Value $value
                }
                $rtn
            }
        }
        else {
            Write-Warning "No events found using that search criteria."
        }        
    }
    catch {
        Write-Warning "No events found using that search criteria."
    }
}

function Search-PSObfuscation {
    Param(
        [datetime]$Start,
        [datetime]$End
    )
    $chars = @("+", ",", "'", "%", "^")
    $events = Search-PSEvent -Start $Start -End $End
    $events | % {
        $sbt_carr = $_.ScriptBlockText.ToCharArray()
        $obfs = $sbt_carr | ? { $_ -in $chars }
        $obfs_cnt = $obfs.count
        $perc = ($obfs_cnt / $sbt_carr.Count)  * 100
        if($perc -ge 15 -and $obfs_cnt -le 1000) {
            $rtn = New-Object PSObject
            $rtn | Add-Member -Type NoteProperty -Name "Timestamp" -Value $($_.Timestamp)
            $rtn | Add-Member -Type NoteProperty -Name "ScriptBlockText" -Value $($_.ScriptBlockText)
            $rtn | Add-Member -Type NoteProperty -Name "Obfuscations" -Value $($obfs -join "")
            $rtn | Add-Member -Type NoteProperty -Name "Count" -Value $($obfs.Count)
            $rtn | Add-Member -Type NoteProperty -Name "%" -Value $perc
            $rtn
        }        
    }
}
