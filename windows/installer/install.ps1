# Label Workflow - Windows installer (per user, no administrator rights).
#
#   Double-click "Install Label Workflow.cmd", or:
#   powershell -ExecutionPolicy Bypass -File install.ps1 [-Destination <folder>] [-NoShortcuts] [-NoRegister] [-Quiet]
#
# Installs the self-contained app (own Python, PyTorch CUDA 12.6 / CPU fallback) to
#   %LOCALAPPDATA%\Programs\Label Workflow
# adds Start menu + desktop shortcuts and an entry in Settings > Apps (uninstall there or via uninstall.ps1).
# Your projects, images and %LOCALAPPDATA%\LabelWorkflow (settings, window layout, nnInteractive) are never touched.
param(
  [string]$Destination = (Join-Path $env:LOCALAPPDATA "Programs\Label Workflow"),
  [switch]$NoShortcuts, [switch]$NoRegister, [switch]$Quiet
)
$ErrorActionPreference = "Stop"
function Get-LtpFileHash {
  param([Alias('LiteralPath')][string]$Path, [string]$Algorithm='SHA256')
  if ($Algorithm -ne 'SHA256') { throw 'Only SHA256 is supported.' }
  $stream = [IO.File]::OpenRead($Path); $hasher = [Security.Cryptography.SHA256]::Create()
  try { [pscustomobject]@{Hash=([BitConverter]::ToString($hasher.ComputeHash($stream))).Replace('-','')} }
  finally { $stream.Dispose(); $hasher.Dispose() }
}
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Destination = [IO.Path]::GetFullPath($Destination).TrimEnd('\')
$Parent = Split-Path -Parent $Destination
if (-not $Parent) { throw 'Choose an application subfolder, not a drive root.' }
function Assert-Child($Path, $Root, [switch]$PathOnly) {
  $p = [IO.Path]::GetFullPath($Path)
  $r = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
  if (-not $p.StartsWith($r, [StringComparison]::OrdinalIgnoreCase)) { throw "Unsafe path: $p is outside $r" }
  if ($PathOnly) { return }
  $check = $p
  while ($check.Length -ge $r.Length) {
    if ((Test-Path -LiteralPath $check) -and ((Get-Item -LiteralPath $check).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "Linked paths are not supported: $check" }
    $check = Split-Path -Parent $check
  }
}
Assert-Child $Destination $Parent
$Archive = Join-Path $Here "LabelWorkflow-app.zip"
$Version = (Get-Content (Join-Path $Here "VERSION.txt") -ErrorAction SilentlyContinue | Select-Object -First 1)
if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw 'Missing or invalid installer version.' }
$ReleaseTag = "v$Version"
$tagFile = Join-Path $Here 'RELEASE_TAG.txt'
if (Test-Path -LiteralPath $tagFile) { $ReleaseTag = (Get-Content -LiteralPath $tagFile | Select-Object -First 1).Trim() }
if ($ReleaseTag -notmatch ('^v' + [regex]::Escape($Version) + '(?:-[A-Za-z0-9][A-Za-z0-9.-]*)?$')) { throw 'Invalid installer release tag.' }
function Say($m) { if (-not $Quiet) { Write-Host $m } }

$Joined = $null
if (-not (Test-Path $Archive)) {
  # Download missing fixed-name parts, pinned to this installer's release and hashes.
  $manifest = @{}
  foreach ($line in Get-Content -LiteralPath (Join-Path $Here 'SHA256SUMS.txt')) {
    if ($line -match '^([0-9a-fA-F]{64})\s+\*?(LTP-windows-x64-app\.part\d+)$') { $manifest[$Matches[2]] = $Matches[1].ToUpper() }
  }
  if (-not $manifest.Count) { throw 'Application parts are missing from the checksum manifest.' }
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  foreach ($name in ($manifest.Keys | Sort-Object { [int]($_ -replace '.*part','') })) {
    $partPath = Join-Path $Here $name
    if (-not (Test-Path -LiteralPath $partPath)) {
      $partial = $partPath + '.' + [guid]::NewGuid().ToString('N') + '.partial'
      Say "Downloading $name (this may take several minutes)..."
      Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/sciencehunt/LabelTrainPredict/releases/download/$ReleaseTag/$name" -OutFile $partial
      if ((Get-LtpFileHash -LiteralPath $partial -Algorithm SHA256).Hash -ne $manifest[$name]) { throw "Download failed verification: $partial" }
      Move-Item -LiteralPath $partial -Destination $partPath
    }
  }
  # GitHub release files must be < 2 GB, so the app archive may come as ...-app.part1, .part2, ... next to this script.
  $parts = Get-ChildItem $Here -Filter "LTP-windows-x64-app.part*" | Where-Object { $_.Name -match '\.part(\d+)$' -and $manifest.ContainsKey($_.Name) } |
           Sort-Object { [int]([regex]::Match($_.Name, '\.part(\d+)$').Groups[1].Value) }
  if (-not $parts) { throw "The app archive is missing: put LabelWorkflow-app.zip, or all ...-app.partN files, next to install.ps1." }
  $sumsFile = Join-Path $Here "SHA256SUMS.txt"
  if (-not (Test-Path $sumsFile)) { throw "SHA256SUMS.txt is missing next to install.ps1; the downloaded parts cannot be verified." }
  $sums = @{}
  foreach ($line in Get-Content $sumsFile) { if ($line -match '^([0-9a-fA-F]{64})\s+\*?(.+)$') { $sums[$Matches[2].Trim()] = $Matches[1].ToUpper() } }
  foreach ($part in $parts) {
    Say ("  Checking {0}" -f $part.Name)
    if (-not $sums.ContainsKey($part.Name)) { throw "$($part.Name) is not listed in SHA256SUMS.txt." }
    if ((Get-LtpFileHash $part.FullName -Algorithm SHA256).Hash -ne $sums[$part.Name]) { throw "$($part.Name) is damaged or incomplete (checksum mismatch). Download it again." }
  }
  $expected = ($parts | ForEach-Object { $_.Name -replace '\.part\d+$', '.zip' } | Select-Object -First 1)
  if (-not $sums.ContainsKey($expected)) { throw 'Joined archive checksum missing.' }
  $Joined = Join-Path $Parent ('.ltp-' + [guid]::NewGuid().ToString('N') + '.download.zip')
  Assert-Child $Joined $Parent
  New-Item -ItemType Directory -Force (Split-Path $Joined -Parent) | Out-Null
  Say "  Joining $($parts.Count) parts"
  $out = [IO.File]::Create($Joined)
  try { foreach ($part in $parts) { $in = [IO.File]::OpenRead($part.FullName); try { $in.CopyTo($out, 16MB) } finally { $in.Close() } } }
  finally { $out.Close() }
  if ($sums.ContainsKey($expected) -and (Get-LtpFileHash $Joined -Algorithm SHA256).Hash -ne $sums[$expected]) {
    Remove-Item $Joined -Force; throw "The joined archive does not match SHA256SUMS.txt ($expected)."
  }
  $Archive = $Joined
}
# The optional unsplit archive must pass the same manifest check as joined parts.
$archiveHash = $null
foreach ($line in Get-Content -LiteralPath (Join-Path $Here 'SHA256SUMS.txt')) {
  if ($line -match '^([0-9a-fA-F]{64})\s+\*?LTP-windows-x64-app\.zip$') { $archiveHash = $Matches[1].ToUpper() }
}
if (-not $archiveHash -or (Get-LtpFileHash -LiteralPath $Archive -Algorithm SHA256).Hash -ne $archiveHash) { throw 'Application archive checksum mismatch.' }
$need = [Math]::Max(15GB, (Get-Item $Archive).Length * 5)
$drive = New-Object IO.DriveInfo([IO.Path]::GetPathRoot([IO.Path]::GetFullPath($Destination)))
if ($drive.AvailableFreeSpace -lt $need) { throw ("Not enough disk space: about {0:N1} GB needed on {1}, {2:N1} GB free." -f ($need/1GB), $drive.Name, ($drive.AvailableFreeSpace/1GB)) }

$running = Get-Process pythonw, python -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($Destination+'\', [StringComparison]::OrdinalIgnoreCase) }
if ($running) { throw "Label Workflow is running from $Destination. Close it (save your work), then run the installer again." }

Say "Installing Label Workflow $Version to $Destination"
$staging = Join-Path $Parent ('.ltp-' + [guid]::NewGuid().ToString('N') + '.installing')
Assert-Child $staging $Parent
New-Item -ItemType Directory -Force $staging | Out-Null
Say "  Unpacking (about 5.5 GB; this takes a few minutes)..."
$tar = Join-Path $env:SystemRoot "System32\tar.exe"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($Archive)
try { foreach ($entry in $zip.Entries) { Assert-Child (Join-Path $staging $entry.FullName) $staging -PathOnly } } finally { $zip.Dispose() }
if (Test-Path $tar) { & $tar -xf $Archive -C $staging; if ($LASTEXITCODE) { throw "Unpacking failed (tar exit $LASTEXITCODE)." } }
else { Expand-Archive -Path $Archive -DestinationPath $staging -Force }
$app = Get-ChildItem $staging -Directory | Where-Object { Test-Path (Join-Path $_.FullName "python\pythonw.exe") } | Select-Object -First 1 -ExpandProperty FullName
if (-not $app) { throw "The archive does not contain an app folder with python\pythonw.exe." }

# Replace an older version only after the new one is fully unpacked (the old one is kept until then).
Assert-Child $app $staging
if (Test-Path -LiteralPath $Destination) {
  if (-not (Test-Path -LiteralPath (Join-Path $Destination 'launch_app.py'))) { throw 'The destination is not a recognized LTP installation. Choose another folder.' }
  $backup = $Destination + '.backup-' + [guid]::NewGuid().ToString('N')
  Assert-Child $Destination $Parent; Assert-Child $backup $Parent
  Move-Item -LiteralPath $Destination -Destination $backup
  Say "  Previous application preserved at $backup"
}
Move-Item -LiteralPath $app -Destination $Destination
Assert-Child $staging $Parent
Remove-Item -LiteralPath $staging -Recurse -Force
if ($Joined -and (Test-Path -LiteralPath $Joined)) { Assert-Child $Joined $Parent; Remove-Item -LiteralPath $Joined -Force }
Copy-Item (Join-Path $Here "uninstall.ps1") (Join-Path $Destination "uninstall.ps1") -Force
Set-Content -Path (Join-Path $Destination "VERSION.txt") -Value $Version -Encoding ASCII

Say "  Checking the installed Python"
$py = Join-Path $Destination "python\python.exe"
# Two app layouts: launch_app.py + src\ (the app code runs from src\), or the package installed in python\Lib\site-packages.
$launcher = Join-Path $Destination "launch_app.py"
$useLauncher = Test-Path $launcher
$savedPythonPath = $env:PYTHONPATH
$env:PYTHONPATH = if ($useLauncher) { Join-Path $Destination "src" } else { "" }
$check = & $py -B -c "import napari_label_workflow, torch, napari; print(napari_label_workflow.__file__); print('torch', torch.__version__, 'cuda', torch.cuda.is_available())" 2>&1
$env:PYTHONPATH = $savedPythonPath
if ($LASTEXITCODE) { throw "The installed app did not start its Python correctly:`n$check" }
Say ("    " + ($check -join "`n    "))

$target = Join-Path $Destination "python\pythonw.exe"; $icon = Join-Path $Destination "icon.ico"
if (-not $NoShortcuts) {
  $shell = New-Object -ComObject WScript.Shell
  $places = @((Join-Path ([Environment]::GetFolderPath("Programs")) "Label Workflow.lnk"), (Join-Path ([Environment]::GetFolderPath("Desktop")) "Label Workflow.lnk"))
  foreach ($lnk in $places) {
    $s = $shell.CreateShortcut($lnk); $s.TargetPath = $target
    $s.Arguments = if ($useLauncher) { "-B `"$launcher`"" } else { "-m napari_label_workflow" }
    $s.WorkingDirectory = $Destination; $s.IconLocation = $icon; $s.Description = "Label Workflow $Version"; $s.Save()
  }
  Say "  Shortcuts: Start menu and desktop"
}
if (-not $NoRegister) {
  $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\LabelWorkflow"
  New-Item -Path $key -Force | Out-Null
  $size = [int]((Get-ChildItem $Destination -Recurse -File | Measure-Object Length -Sum).Sum / 1KB)
  $un = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $Destination 'uninstall.ps1')`""
  foreach ($p in @{DisplayName="Label Workflow"; DisplayVersion=$Version; Publisher="Label Workflow"; InstallLocation=$Destination;
                   DisplayIcon=$icon; UninstallString=$un; QuietUninstallString="$un -Quiet"; NoModify=1; NoRepair=1; EstimatedSize=$size}.GetEnumerator()) {
    $type = if ($p.Value -is [int]) { "DWord" } else { "String" }
    New-ItemProperty -Path $key -Name $p.Key -Value $p.Value -PropertyType $type -Force | Out-Null
  }
  Say "  Registered in Settings > Apps (uninstall from there)"
}
Say "Done. Start Label Workflow from the Start menu or the desktop shortcut."
