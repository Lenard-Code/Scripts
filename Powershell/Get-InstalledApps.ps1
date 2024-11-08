# Function to clean DisplayName
function Clean-DisplayName {
    param (
        [string]$name
    )
    # Remove anything in parentheses and version numbers
    #$name -replace '\s*\(.*\)', '' -replace '\d+(\.\d+)*', '' -replace '\s+$', ''
}

# Debug function to log messages
function Log-Debug {
    param (
        [string]$message
    )
    #Write-Host "DEBUG: $message"
}

# Get installed software from the 64-bit registry
$software64 = Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
    Get-ItemProperty |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object {
        if ($_.DisplayName -ne $null) {
            Log-Debug "Found DisplayName: $($_.DisplayName)"
            $true
        } else {
            Log-Debug "Null DisplayName found"
            $false
        }
    } |
    ForEach-Object {
        $_.DisplayName = Clean-DisplayName -name $_.DisplayName
        $_
    }

# Get installed software from the 32-bit registry
$software32 = Get-ChildItem -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" |
    Get-ItemProperty |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object {
        if ($_.DisplayName -ne $null) {
            Log-Debug "Found DisplayName: $($_.DisplayName)"
            $true
        } else {
            Log-Debug "Null DisplayName found"
            $false
        }
    } |
    ForEach-Object {
        $_.DisplayName = Clean-DisplayName -name $_.DisplayName
        $_
    }

# Combine both lists
$software = $software64 + $software32

# Get the current username
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1]

# Define the output path to the user's desktop
$outputPath = "C:\Users\$currentUser\Desktop\output_registry.json"

# Convert to JSON and save to the user's desktop
$software | ConvertTo-Json | Set-Content -Path $outputPath
