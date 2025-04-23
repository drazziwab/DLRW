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
        with open(r"C:\Users\Basic User\Desktop\LLM_PROJECTS\DLA\DailyLoginAutomator\steam_games.csv", "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["name", "LauncherPathNow"])
            writer.writerows(steam_data)
        messagebox.showinfo("Scan Complete", f"Found {len(steam_data)} games.")
    else:
        messagebox.showwarning("Scan Complete", "No Steam games found.")
