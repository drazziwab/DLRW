# DailyLoginAutomator

Automates daily login reward collection across multiple games.

## Installation
```powershell
pip install -r requirements.txt
```

## Usage
- Create profile: `python run.py --create-profile "C:/Path/To/Game.exe"`
- Run profile:   `python run.py --run-profile MyGame`
- Schedule:      `python run.py --schedule MyGame 09:00`

See [docs](docs/) for details.
