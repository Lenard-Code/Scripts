#Function produces output of connections on the local host and the responsible process

function Get-ProcessConnection {

    $a = Get-NetTcpConnection | Select-Object -Property LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess, @{'Name' = 'ProcessName';'Expression' = {(Get-Process -Id $_.OwningProcess).Name}}
    $OutFilePath = ".\process_connections.json"
    $a | ConvertTo-Json -depth 100 | Set-Content $outFilePath
}

Get-ProcessConnection