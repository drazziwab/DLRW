#Requires -RunAsAdministrator
# Steam Manifest Scanner - Full Script

# --- Auto Elevation Check ---
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process -FilePath "powershell" -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# --- Unblock Script Automatically (if blocked) ---
$scriptFile = $MyInvocation.MyCommand.Path
if ((Get-Item $scriptFile).Attributes -band [System.IO.FileAttributes]::Blocked) {
    Unblock-File -Path $scriptFile
}

# --- Define Excluded Folders ---
$excludedDirs = @(
    "Windows", "Program Files", "Program Files (x86)", "ProgramData",
    "AppData", "System Volume Information", "$Recycle.Bin", "Recovery",
    "MSOCache", "Users\Default", "Users\Public"
)

function Get-ValidDrives {
    Get-PSDrive -PSProvider FileSystem | Where-Object { Test-Path $_.Root } | Select-Object -ExpandProperty Root
}

function Is-ExcludedPath {
    param($path)
    foreach ($excluded in $excludedDirs) {
        if ($path -like "*\$excluded*") { return $true }
    }
    return $false
}

function Extract-ManifestLines {
    param($filePath)
    $lines = Get-Content -Path $filePath
    if ($lines.Count -ge 6) {
        return [PSCustomObject]@{
            GameName   = $lines[5].Trim()
            Line3      = $lines[2].Trim()
            Line5      = $lines[4].Trim()
            Manifest   = $filePath
        }
    }
    return $null
}

# --- Output File ---
$outputFile = "$PSScriptRoot\steam_manifest_results.txt"
if (Test-Path $outputFile) { Remove-Item $outputFile -Force }
New-Item -Path $outputFile -ItemType File -Force | Out-Null

# --- Begin Scan ---
Write-Host "Starting Steam manifest scan..."
$allDrives = Get-ValidDrives
$foundCount = 0

foreach ($drive in $allDrives) {
    Write-Host "Scanning $drive ..."

    try {
        $paths = Get-ChildItem -Path $drive -Recurse -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -like "*SteamLibrary\steamapps*" -and -not (Is-ExcludedPath $_.FullName) }

        foreach ($dir in $paths) {
            $manifests = Get-ChildItem -Path $dir.FullName -Filter "appmanifest*" -File -ErrorAction SilentlyContinue
            foreach ($file in $manifests) {
                $data = Extract-ManifestLines -filePath $file.FullName
                if ($data) {
                    $foundCount++
                    $log = "[$foundCount] Game: $($data.GameName) | $($data.Line3) | $($data.Line5) | $($data.Manifest)"
                    Write-Host $log
                    Add-Content -Path $outputFile -Value $log
                }
            }
        }
    } catch {
        Write-Host ("Error scanning {0}: {1}" -f $drive, $_)
    }
}

Write-Host "Scan Complete. $foundCount appmanifest files processed."
Write-Host "Output saved to: $outputFile"

# --- Set Full Permissions on Output ---
$acl = Get-Acl -Path $outputFile
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","Allow")
$acl.SetAccessRule($rule)
Set-Acl -Path $outputFile -AclObject $acl
