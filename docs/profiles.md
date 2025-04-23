# Profile Schema

Each profile JSON in `profiles/` follows:
```json
{
  "game_path": "C:/path/to/game.exe",
  "settings_path": "C:/path/to/config.ini",
  "launch_delay": 60,
  "actions": [
    { "type": "click", "x": 960, "y": 540 },
    { "type": "press", "key": "enter" }
  ]
}
```
