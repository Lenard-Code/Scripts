# Function to clean DisplayName
function Clean-DisplayName {
    param (
        [string]$name
    )
    # Remove anything in parentheses and version numbers
    $name -replace '\s*\(.*\)', '' -replace '\d+(\.\d+)*', '' -replace '\s+$', ''
}

# Get installed software from the 64-bit registry
$software64 = Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
    Get-ItemProperty |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object { $_.DisplayName -ne $null } |
    ForEach-Object {
        $_.DisplayName = Clean-DisplayName -name $_.DisplayName
        $_
    }

# Get installed software from the 32-bit registry
$software32 = Get-ChildItem -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" |
    Get-ItemProperty |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object { $_.DisplayName -ne $null } |
    ForEach-Object {
        $_.DisplayName = Clean-DisplayName -name $_.DisplayName
        $_
    }

# Combine both lists
$software = $software64 + $software32

# Convert to JSON and save to a file
$software | ConvertTo-Json | Set-Content -Path "C:\Users\Path\Desktop\output_registry.json"
