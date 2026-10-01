# Label Workflow - uninstaller. Removes the app folder, its shortcuts and the Settings > Apps entry.
# Keeps your projects, images and %LOCALAPPDATA%\LabelWorkflow (settings, window layout, nnInteractive tools).
param([switch]$Quiet)
$ErrorActionPreference = "Stop"
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Here = [IO.Path]::GetFullPath($Here).TrimEnd('\')
if (-not (Split-Path -Parent $Here) -or -not (Test-Path -LiteralPath (Join-Path $Here 'launch_app.py')) -or
    -not (Test-Path -LiteralPath (Join-Path $Here 'python\pythonw.exe')) -or
    ((Get-Item -LiteralPath $Here).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'This is not a recognized application folder.' }
$running = Get-Process pythonw, python -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($Here, [StringComparison]::OrdinalIgnoreCase) }
if ($running) { throw "Label Workflow is still running. Close it first (save your work)." }
if (-not $Quiet) {
  Add-Type -AssemblyName System.Windows.Forms
  $answer = [System.Windows.Forms.MessageBox]::Show("Remove Label Workflow from $Here?`n`nYour projects and settings are kept.", "Uninstall Label Workflow", "OKCancel", "Question")
  if ($answer -ne "OK") { exit 1 }
}
foreach ($lnk in @((Join-Path ([Environment]::GetFolderPath("Programs")) "Label Workflow.lnk"), (Join-Path ([Environment]::GetFolderPath("Desktop")) "Label Workflow.lnk"))) {
  if (Test-Path $lnk) {
    $target = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk).TargetPath
    if ($target -and $target.StartsWith($Here, [StringComparison]::OrdinalIgnoreCase)) { Remove-Item $lnk -Force }
  }
}
$key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\LabelWorkflow"
if ((Test-Path $key) -and ((Get-ItemProperty $key).InstallLocation -eq $Here)) { Remove-Item $key -Recurse -Force }
# The folder cannot delete itself while this script runs from it: remove it from a short-lived helper.
$literal = $Here.Replace("'", "''")
$cmd = "Start-Sleep 2; if ((Test-Path -LiteralPath '$literal\launch_app.py') -and (Test-Path -LiteralPath '$literal\python\pythonw.exe')) { Remove-Item -LiteralPath '$literal' -Recurse -Force }"
$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
Start-Process powershell.exe -ArgumentList '-NoProfile', '-EncodedCommand', $encoded -WindowStyle Hidden
if (-not $Quiet) { Write-Host "Label Workflow removed. Your projects and settings were kept." }
