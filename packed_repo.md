This file is a merged representation of the entire codebase, combined into a single document by Repomix.
The content has been processed where comments have been removed, empty lines have been removed, content has been compressed (code blocks are separated by ⋮---- delimiter).

# File Summary

## Purpose
This file contains a packed representation of the entire repository's contents.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Code comments have been removed from supported file types
- Empty lines have been removed from all files
- Content has been compressed - code blocks are separated by ⋮---- delimiter
- Files are sorted by Git change count (files with more changes are at the bottom)

## Additional Info

# Directory Structure
```
.gitignore
automator/automation_engine.py
automator/backup_manager.py
automator/main.py
automator/profile_manager.py
automator/scanner.py
automator/scheduler.py
automator/settings_manager.py
backups/.gitkeep
configs/default_settings.json
pack_repo.ps1
profiles/.gitkeep
requirements.txt
run.py
```

# Files

## File: pack_repo.ps1
```powershell
# pack_repo.ps1 (fixed version)
# PowerShell script to run Repomix and pack the current folder automatically

# Add global npm bin folder to PATH (if not already added)
$NpmBinPath = "$env:APPDATA\npm"
if (-not ($env:Path -split ";" | Where-Object { $_ -eq $NpmBinPath })) {
    $env:Path += ";$NpmBinPath"
}

# Ensure the script is run from the directory you want to pack
$CurrentDir = Get-Location
$OutputFile = "$($CurrentDir.Path)\packed_repo.md"

# Confirm repomix is available
try {
    repomix --version | Out-Null
} catch {
    Write-Error "❌ Repomix is not installed or not found even after PATH fix. Please reinstall with 'npm install -g repomix'."
    exit
}

# Run repomix with desired options
Write-Output "🚀 Packing repository from: $CurrentDir"
repomix -o "$OutputFile" --compress --remove-comments --remove-empty-lines --style markdown

# Confirm output
if (Test-Path $OutputFile) {
    Write-Output "✅ Repository packed successfully: $OutputFile"
} else {
    Write-Error "❌ Failed to create output file."
}
```

## File: .gitignore
```
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*.pyo

# Virtual environments
env/
venv/

# IDEs and OS
.vscode/
.idea/
.DS_Store
```

## File: automator/automation_engine.py
```python
class AutomationEngine
⋮----
def __init__(self): pass
def run(self, profile)
⋮----
exe = profile.get('game_path')
⋮----
def _perform_actions(self, profile)
⋮----
screenshot = pyautogui.screenshot()
text = pytesseract.image_to_string(screenshot)
```

## File: automator/backup_manager.py
```python
class BackupManager
⋮----
def __init__(self, backup_dir)
def backup_settings(self, settings_path)
⋮----
ts = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
name = os.path.basename(settings_path)
dest = os.path.join(self.backup_dir, f'{name}.{ts}.bak')
```

## File: automator/main.py
```python
def setup_logging(log_dir)
⋮----
log_path = os.path.join(log_dir, 'automator.log')
⋮----
def main()
⋮----
parser = argparse.ArgumentParser(description='DailyLoginAutomator')
⋮----
args = parser.parse_args()
settings = SettingsManager()
⋮----
scanner = GameScanner(settings.get_search_paths())
profiler = ProfileManager(settings.get_profiles_dir(), settings.get_config_path())
backup  = BackupManager(settings.get_backup_dir())
engine  = AutomationEngine()
⋮----
game = args.create_profile
⋮----
cfg = profiler.create_profile(game, backup)
⋮----
profile = profiler.load_profile(args.run_profile)
```

## File: automator/profile_manager.py
```python
class ProfileManager
⋮----
def __init__(self, profiles_dir, config_path)
def create_profile(self, game_path, backup_manager)
⋮----
profile = {'game_path': game_path, 'settings_path': self._find_settings(game_path)}
name = os.path.basename(game_path)
file = os.path.join(self.profiles_dir, f'{name}.json')
⋮----
def load_profile(self, profile_name)
⋮----
path = os.path.join(self.profiles_dir, profile_name if profile_name.endswith('.json') else f'{profile_name}.json')
⋮----
def _find_settings(self, game_path)
```

## File: automator/scanner.py
```python
class GameScanner
⋮----
def __init__(self, search_paths)
def scan(self)
⋮----
games = []
⋮----
full = os.path.join(base, entry)
```

## File: automator/scheduler.py
```python
def run_profile(profile_name)
⋮----
settings = SettingsManager()
backup   = BackupManager(settings.get_backup_dir())
profiler = ProfileManager(settings.get_profiles_dir(), settings.get_config_path())
profile  = profiler.load_profile(profile_name)
⋮----
engine = AutomationEngine()
⋮----
def schedule_profile(profile_name, run_time)
```

## File: automator/settings_manager.py
```python
class SettingsManager
⋮----
def __init__(self)
⋮----
base = os.path.dirname(os.path.dirname(__file__))
⋮----
def _load(self)
⋮----
data = json.load(open(self.config_file))
⋮----
def get_search_paths(self): return self.search_paths
def get_backup_dir(self):    return self.backup_dir
def get_profiles_dir(self):  return self.profiles_dir
def get_logs_dir(self):      return self.logs_dir
def get_config_path(self):   return self.config_path
```

## File: backups/.gitkeep
```

```

## File: configs/default_settings.json
```json
{
  "search_paths": ["C:\\Program Files","C:\\Program Files (x86)","D:\\Games"],
  "backup_dir": "backups",
  "profiles_dir": "profiles",
  "logs_dir": "logs"
}
```

## File: profiles/.gitkeep
```

```

## File: requirements.txt
```
pyautogui
pillow
schedule
pytesseract
```

## File: run.py
```python

```
