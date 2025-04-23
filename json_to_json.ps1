# Requires -Version 5.0
# Extracts EXE names and paths from gameslist.json to gamelist_small.json
# Only creates gamelist_small.json if it does not already exist

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sourceJsonPath = Join-Path $projectRoot "gameslist.json"
$targetJsonPath = Join-Path $projectRoot "gamelist_small.json"

# Exit if target file already exists
if (Test-Path $targetJsonPath) {
    Write-Host "gamelist_small.json already exists. No changes made."
    exit 0
}

# Validate and load source JSON
if (-Not (Test-Path $sourceJsonPath)) {
    Write-Error "gameslist.json not found at path: $sourceJsonPath"
    exit 1
}

$gamesList = Get-Content $sourceJsonPath -Raw | ConvertFrom-Json

# Extract GameName, ExecutablePath, and OS
$smallList = @()
foreach ($game in $gamesList) {
    foreach ($exe in $game.executables) {
        $exePath = $exe.name -replace "/", "\"
        $smallList += [PSCustomObject]@{
            GameName      = $game.name
            Executable    = Split-Path $exePath -Leaf
            DirectoryHint = Split-Path $exePath -Parent
            OS            = $exe.os
        }
    }
}

# Write new JSON file
$smallList | ConvertTo-Json -Depth 4 | Out-File -Encoding UTF8 -FilePath $targetJsonPath
Write-Host "gamelist_small.json created at: $targetJsonPath"
