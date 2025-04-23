# Requires -Version 5.0
# Generates a refined gamelist_small.json for win32 only
# Filters executables so scan only occurs in explicitly listed directories
# Also generates excluded_dirs.json based on system paths not used in gameslist

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sourceJsonPath = Join-Path $projectRoot "gameslist.json"
$targetJsonPath = Join-Path $projectRoot "gamelist_small.json"
$excludeListPath = Join-Path $projectRoot "excluded_dirs.json"

# Exit if files already exist
if ((Test-Path $targetJsonPath) -and (Test-Path $excludeListPath)) {
    Write-Host "gamelist_small.json and excluded_dirs.json already exist. No changes made."
    exit 0
}

# Ensure source JSON is present
if (-Not (Test-Path $sourceJsonPath)) {
    Write-Error "Missing gameslist.json at $sourceJsonPath"
    exit 1
}

$gamesList = Get-Content $sourceJsonPath -Raw | ConvertFrom-Json

$finalList = @()
$allowedDirs = @()

foreach ($game in $gamesList) {
    foreach ($exe in $game.executables) {
        if ($exe.os -ne "win32") { continue }

        $exePath = $exe.name -replace "/", "\"
        $exeName = Split-Path $exePath -Leaf
        $dirHint = Split-Path $exePath -Parent

        if ($dirHint -and -not ($allowedDirs -contains $dirHint)) {
            $allowedDirs += $dirHint
        }

        $finalList += [PSCustomObject]@{
            GameName      = $game.name
            Executable    = $exeName
            DirectoryHint = $dirHint
        }
    }
}

# Write gamelist_small.json if not present
if (-Not (Test-Path $targetJsonPath)) {
    $finalList | ConvertTo-Json -Depth 3 | Out-File -Encoding UTF8 -FilePath $targetJsonPath
    Write-Host "Created gamelist_small.json"
}

# Exclusion logic: standard system folders NOT in allowedDirs
$systemDirs = @(
    "$env:SystemRoot", "$env:ProgramFiles", "$env:ProgramFiles (x86)",
    "$env:ProgramData", "$env:APPDATA", "$env:LOCALAPPDATA",
    "$env:USERPROFILE\AppData", "$env:USERPROFILE\Default", "$env:USERPROFILE\Public"
)

$excludedDirs = @()
foreach ($sys in $systemDirs) {
    $match = $false
    foreach ($inc in $allowedDirs) {
        if ($sys -like "$inc*") {
            $match = $true
            break
        }
    }
    if (-not $match) {
        $excludedDirs += $sys
    }
}

# Write excluded_dirs.json if not present
if (-Not (Test-Path $excludeListPath)) {
    $excludedDirs | ConvertTo-Json -Depth 2 | Out-File -Encoding UTF8 -FilePath $excludeListPath
    Write-Host "Created excluded_dirs.json"
}

# Scan logic (optional to auto-run post extraction)
function SanitizePath($path) {
    return $path -replace '[<>:"|?*]', ''
}

function ScanGamesFromList {
    $scanResults = @()

    $scanList = Get-Content $targetJsonPath | ConvertFrom-Json

    foreach ($entry in $scanList) {
        $dir = SanitizePath (Join-Path $projectRoot $entry.DirectoryHint)
        $exe = $entry.Executable
        $pathToCheck = Join-Path $dir $exe

        if ([System.IO.File]::Exists($pathToCheck)) {
            $scanResults += [PSCustomObject]@{
                GameName       = $entry.GameName
                FoundExecutable = $pathToCheck
            }
        }
    }

    $scanResultsPath = Join-Path $projectRoot "gamelist_found.json"
    $scanResults | ConvertTo-Json -Depth 3 | Out-File -Encoding UTF8 -FilePath $scanResultsPath
    Write-Host "Scan complete. Results saved to gamelist_found.json"
}

# Optional auto-scan trigger
ScanGamesFromList
