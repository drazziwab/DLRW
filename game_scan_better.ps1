# Requires -Version 5.0
# Full Game Scan Script - Called by GUI "Scan for Games" button
# Creates or edits scanned_games_log.json and scan_output.log in project root

$ErrorActionPreference = "Stop"

# Target project root
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$gamesListPath = Join-Path $projectRoot "gameslist.json"
$logPath = Join-Path $projectRoot "scanned_games_log.json"
$outputLog = Join-Path $projectRoot "scan_output.log"

# Ensure output files exist or are created
if (-Not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType File -Force | Out-Null
}
if (-Not (Test-Path $outputLog)) {
    New-Item -Path $outputLog -ItemType File -Force | Out-Null
}

# Load game definitions
if (-Not (Test-Path $gamesListPath)) {
    Add-Content $outputLog "ERROR: gameslist.json not found at $gamesListPath"
    exit 1
}
$gamesList = Get-Content $gamesListPath -Raw | ConvertFrom-Json

# Define folders to exclude from scanning unless explicitly listed
$excludedDirs = @(
    "$env:SystemRoot", "$env:ProgramFiles", "$env:ProgramFiles (x86)",
    "$env:ProgramData", "$env:APPDATA", "$env:LOCALAPPDATA",
    "$env:USERPROFILE\AppData", "$env:USERPROFILE\Default", "$env:USERPROFILE\Public"
)

# Extract and normalize allowed paths from gameslist.json
$allowedDirs = @()
foreach ($game in $gamesList) {
    foreach ($exe in $game.executables) {
        $exePath = $exe.name -replace "/", "\"
        if ($exePath -match "^[a-zA-Z]:\\") {
            $base = Split-Path $exePath -Parent
            if ($base -and -not ($allowedDirs -contains $base)) {
                $allowedDirs += $base
            }
        }
    }
}

# Function: should this folder be scanned?
function ShouldScanDir($dir) {
    foreach ($excluded in $excludedDirs) {
        if ($dir -like "$excluded*") {
            foreach ($allowed in $allowedDirs) {
                if ($dir -like "$allowed*") {
                    return $true
                }
            }
            return $false
        }
    }
    return $true
}

# Sanitize a path to avoid illegal characters
function SanitizePath($path) {
    return $path -replace '[<>:"|?*]', ''
}

# Main scan logic
function Scan-ForGames {
    $results = @()
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -gt 0 -and $_.DisplayRoot -eq $null }

    foreach ($drive in $drives) {
        $root = $drive.Root
        Add-Content $outputLog "Scanning drive $root..."

        Get-ChildItem -Path $root -Recurse -Directory -ErrorAction SilentlyContinue |
        ForEach-Object {
            $folder = SanitizePath $_.FullName
            if (ShouldScanDir $folder) {
                foreach ($game in $gamesList) {
                    foreach ($exe in $game.executables) {
                        $exeName = Split-Path $exe.name -Leaf
                        $candidatePath = Join-Path $folder $exeName
                        $candidatePath = SanitizePath $candidatePath
                        if ([System.IO.File]::Exists($candidatePath)) {
                            $results += [PSCustomObject]@{
                                GameName = $game.name
                                ExecutablePath = $candidatePath
                            }
                        }
                    }
                }
            }
        }
    }

    return $results
}

# Run and write results
try {
    $foundGames = Scan-ForGames

    if ($foundGames.Count -gt 0) {
        $foundGames | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 -Path $logPath
        Add-Content $outputLog "Scan completed. Found $($foundGames.Count) games. Results saved to scanned_games_log.json"
    } else {
        Set-Content -Path $logPath -Value "[]" -Encoding UTF8
        Add-Content $outputLog "Scan completed. No games found."
    }
} catch {
    Add-Content $outputLog "ERROR: $($_.Exception.Message)"
    Set-Content -Path $logPath -Value "[]" -Encoding UTF8
}
