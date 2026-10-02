param([string]$Destination = (Join-Path $env:LOCALAPPDATA 'Programs\LTP Windows 0.2.10 alpha.1'), [switch]$NoShortcut)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$ltpHere = Split-Path -Parent $MyInvocation.MyCommand.Path
$ltpManifest = Get-Content -LiteralPath (Join-Path $ltpHere 'download-manifest.json') -Raw | ConvertFrom-Json
$ltpDestination = [IO.Path]::GetFullPath($Destination).TrimEnd('\')
if (Test-Path -LiteralPath $ltpDestination) { throw 'Destination already exists. Choose a new folder; existing installations are never replaced.' }
$ltpParent = Split-Path -Parent $ltpDestination
if (-not $ltpParent) { throw 'Choose an application subfolder, not a drive root.' }
$ltpAncestor = $ltpParent
while ($ltpAncestor) {
    if ((Test-Path -LiteralPath $ltpAncestor) -and ((Get-Item -LiteralPath $ltpAncestor).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Installation through linked directories is not supported.' }
    $ltpAncestor = Split-Path -Parent $ltpAncestor
}
if ($ltpManifest.tag -ne 'v0.2.10-alpha.1') { throw 'Unexpected release manifest.' }
$ltpDrive = New-Object IO.DriveInfo([IO.Path]::GetPathRoot($ltpDestination))
if ($ltpDrive.AvailableFreeSpace -lt 30GB) { throw 'Allow 30 GB of free disk space for download and extraction.' }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
foreach ($ltpPart in $ltpManifest.parts) {
    if ($ltpPart.name -notmatch '^LTP-windows-x64-app\.part[1-9][0-9]*$' -or $ltpPart.sha256 -notmatch '^[a-f0-9]{64}$') { throw 'Invalid download manifest.' }
    $ltpPath = Join-Path $ltpHere $ltpPart.name
    if (-not (Test-Path -LiteralPath $ltpPath)) {
        Write-Host "Downloading $($ltpPart.name)..."
        $ltpPartial = $ltpPath + '.' + [guid]::NewGuid().ToString('N') + '.partial'
        Invoke-WebRequest -UseBasicParsing -Uri ('https://github.com/sciencehunt/LabelTrainPredict/releases/download/v0.2.10-alpha.1/' + $ltpPart.name) -OutFile $ltpPartial
        if ((Get-FileHash -LiteralPath $ltpPartial -Algorithm SHA256).Hash.ToLowerInvariant() -ne $ltpPart.sha256) { throw 'Download checksum mismatch. No application was installed.' }
        Move-Item -LiteralPath $ltpPartial -Destination $ltpPath
    }
    if ((Get-FileHash -LiteralPath $ltpPath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $ltpPart.sha256) { throw "Checksum mismatch: $($ltpPart.name)" }
}
$ltpArchive = Join-Path $ltpHere ('ltp-' + [guid]::NewGuid().ToString('N') + '.zip')
Write-Host 'Joining and verifying the application archive...'
$ltpOutput = [IO.File]::Create($ltpArchive)
try {
    foreach ($ltpPart in $ltpManifest.parts) {
        $ltpInput = [IO.File]::OpenRead((Join-Path $ltpHere $ltpPart.name))
        try { $ltpInput.CopyTo($ltpOutput, 8MB) } finally { $ltpInput.Dispose() }
    }
} finally { $ltpOutput.Dispose() }
if ((Get-FileHash -LiteralPath $ltpArchive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $ltpManifest.archive_sha256) { throw 'Archive checksum mismatch.' }
New-Item -ItemType Directory -Path $ltpDestination | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
$ltpZip = [IO.Compression.ZipFile]::OpenRead($ltpArchive)
try {
    foreach ($ltpEntry in $ltpZip.Entries) {
        $ltpResolved = [IO.Path]::GetFullPath((Join-Path $ltpDestination $ltpEntry.FullName))
        if (-not $ltpResolved.StartsWith($ltpDestination + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe archive member.' }
    }
} finally { $ltpZip.Dispose() }
Write-Host 'Extracting LTP and its included GPU runtimes...'
[IO.Compression.ZipFile]::ExtractToDirectory($ltpArchive, $ltpDestination)
$ltpPython = Join-Path $ltpDestination 'python\python.exe'
& $ltpPython -B (Join-Path $ltpDestination 'verify_runtime.py')
if ($LASTEXITCODE -ne 0) { throw 'Runtime check failed. Keep Smart App Control enabled and report the error with your Windows version.' }
if (-not $NoShortcut) {
    $ltpShell = New-Object -ComObject WScript.Shell
    $ltpShortcut = $ltpShell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) 'LTP Windows 0.2.10 alpha.1.lnk'))
    $ltpShortcut.TargetPath = Join-Path $ltpDestination 'python\pythonw.exe'
    $ltpShortcut.Arguments = '-B "' + (Join-Path $ltpDestination 'launch_ltp.py') + '"'
    $ltpShortcut.WorkingDirectory = $ltpDestination
    $ltpShortcut.Save()
}
Write-Host "LTP alpha is ready in $ltpDestination. Open Launch LTP.cmd."
Write-Host 'The downloaded parts and joined archive are retained; you may delete them after testing.'
