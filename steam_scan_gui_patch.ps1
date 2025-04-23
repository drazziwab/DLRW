# unblock_and_allow_scripts.ps1

# Define log path
$LogFile = "$env:USERPROFILE\\script_unlock_log.txt"
"[$(Get-Date)] Starting script unlock process..." | Out-File -Append $LogFile

# Request elevation if needed
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    "[$(Get-Date)] Not running as admin, re-launching..." | Out-File -Append $LogFile
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 1. Set execution policy for current user
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    "[$(Get-Date)] ExecutionPolicy set to RemoteSigned for CurrentUser." | Out-File -Append $LogFile
} catch {
    "[$(Get-Date)] Failed to set execution policy: $_" | Out-File -Append $LogFile
}

# 2. Set execution policy for local machine (fallback)
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    "[$(Get-Date)] ExecutionPolicy set to RemoteSigned for LocalMachine." | Out-File -Append $LogFile
} catch {
    "[$(Get-Date)] Failed to set LocalMachine policy (probably not admin): $_" | Out-File -Append $LogFile
}

# 3. Unblock all .ps1 files in known script folders
$TargetDirs = @(
    "$env:USERPROFILE\\Desktop\\LLM_PROJECTS\\pshell_scripts",
    "$env:USERPROFILE\\Desktop\\LLM_PROJECTS\\DLA\\DailyLoginAutomator"
)

foreach ($dir in $TargetDirs) {
    if (Test-Path $dir) {
        $ps1Files = Get-ChildItem -Path $dir -Recurse -Filter *.ps1 -ErrorAction SilentlyContinue
        foreach ($file in $ps1Files) {
            try {
                Unblock-File -Path $file.FullName
                "[$(Get-Date)] Unblocked: $($file.FullName)" | Out-File -Append $LogFile
            } catch {
                "[$(Get-Date)] Failed to unblock: $($file.FullName) — $_" | Out-File -Append $LogFile
            }
        }
    } else {
        "[$(Get-Date)] Target directory not found: $dir" | Out-File -Append $LogFile
    }
}

"[$(Get-Date)] Script unlock process completed." | Out-File -Append $LogFile
Write-Output "✅ Scripts unlocked, execution policy set. Check log at $LogFile"

# Requires -Version 5.0

$ErrorActionPreference = "Stop"
$projectRoot = "C:\Users\Basic User\Desktop\LLM_PROJECTS\DLA\DailyLoginAutomator"
$scannerFile = Join-Path $projectRoot "automator\scanner.py"
$outputCsv = Join-Path $projectRoot "steam_games.csv"
$guiFile = Join-Path $projectRoot "automator\gui.py"

$scanButtonPatch = @'
def scan_steam_games_only():
    import os, csv, re
    from pathlib import Path
    from tkinter import messagebox

    steam_data = []
    drives = [f"{chr(c)}:\\" for c in range(65, 91) if os.path.exists(f"{chr(c)}:\\")]

    for drive in drives:
        steam_path = Path(drive) / "SteamLibrary" / "steamapps"
        if not steam_path.exists():
            continue
        acf_files = list(steam_path.glob("*.acf"))
        if not acf_files:
            continue
        for acf in acf_files:
            try:
                with open(acf, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                appid_match = re.search(r'"appid"\s+"(\d+)"', content)
                name_match = re.search(r'"name"\s+"([^"]+)"', content)
                path_match = re.search(r'"LauncherPath"\s+"([^"]+)"', content)
                if appid_match and name_match and path_match:
                    appid = appid_match.group(1)
                    name = name_match.group(1)
                    launcher = path_match.group(1)
                    full_command = f'{launcher} -applaunch {appid}'
                    steam_data.append([name, full_command])
            except Exception:
                continue

    if steam_data:
        with open(r"{0}", "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["name", "LauncherPathNow"])
            writer.writerows(steam_data)
        messagebox.showinfo("Scan Complete", f"Found {len(steam_data)} games.")
    else:
        messagebox.showwarning("Scan Complete", "No Steam games found.")
'@ -f $outputCsv

$scanPatchPath = Join-Path $projectRoot "automator\scan_steam_patch.py"
Set-Content -Path $scanPatchPath -Value $scanButtonPatch -Encoding UTF8

(gc $guiFile) -replace 'def scan_games\(\):.*?Log_output.insert\("1\.0", "Log viewer placeholder\\\.n"\)', 'def scan_games():\n    import subprocess\n    subprocess.run(["python", "automator/scan_steam_patch.py"], check=True)\n    Log_output.insert("1.0", "Scan triggered.\\n")' |
    Set-Content -Path $guiFile -Encoding UTF8

$dirs = @("docs", "tests") | ForEach-Object { Join-Path $projectRoot $_ }
foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory | Out-Null
    }
}

$readmeContent = @'
# DailyLoginAutomator

## Overview
Automates daily login rewards and scheduled launch of games.

## Installation
```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

## Usage
```bash
python run.py --create-profile MyGame
python run.py --run-profile MyGame
python run.py --schedule MyGame 09:00
```

## Features
- OCR-based automation
- Game profile management
- Scheduler integration
'@
Set-Content -Path (Join-Path $projectRoot "README.md") -Value $readmeContent -Encoding UTF8

$licenseText = @'
MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
'@
Set-Content -Path (Join-Path $projectRoot "LICENSE") -Value $licenseText -Encoding UTF8

$archDoc = @'
# Architecture

## Module Flow
- GUI âž” Profile Manager âž” Automation Engine
- Scheduler âž” CLI trigger âž” Profile Execution

## Files
- automator/
- configs/
- profiles/
- backups/
'@
Set-Content -Path (Join-Path $projectRoot "docs\architecture.md") -Value $archDoc -Encoding UTF8

$profileSchema = @'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "name": { "type": "string" },
    "exe_path": { "type": "string" },
    "launch_delay": { "type": "number" },
    "actions": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "type": { "type": "string" },
          "value": { "type": "string" }
        },
        "required": ["type", "value"]
      }
    }
  },
  "required": ["name", "exe_path", "launch_delay"]
}
'@
Set-Content -Path (Join-Path $projectRoot "docs\profile_schema.json") -Value $profileSchema -Encoding UTF8

$testProfileManager = @'
import pytest
from automator.profile_manager import create_profile, load_profile

def test_profile_roundtrip(tmp_path):
    path = tmp_path / "test_profile.json"
    profile_data = {
        "name": "TestGame",
        "exe_path": "C:\\Games\\test.exe",
        "launch_delay": 5,
        "actions": [{"type": "click", "value": "100,200"}]
    }
    create_profile(path, profile_data)
    loaded = load_profile(path)
    assert loaded["name"] == "TestGame"
'@
Set-Content -Path (Join-Path $projectRoot "tests\test_profile_manager.py") -Value $testProfileManager -Encoding UTF8

$workflowPath = Join-Path $projectRoot ".github\workflows"
New-Item -ItemType Directory -Path $workflowPath -Force | Out-Null
$workflowFile = Join-Path $workflowPath "python-app.yml"
$workflowContent = @'
name: Python application

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: "3.11"
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest
    - name: Run tests
      run: |
        pytest
'@
Set-Content -Path $workflowFile -Value $workflowContent -Encoding UTF8

Write-Host "âœ… All project scaffolding, patching, and GUI integration completed."
