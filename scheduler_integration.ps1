
# Requires -Version 5.0

$projectRoot = "C:\Users\Basic User\Desktop\LLM_PROJECTS\DLA\DailyLoginAutomator"
$runFile = Join-Path $projectRoot "run.py"
$schedulerFile = Join-Path $projectRoot "automator\scheduler_launcher.py"

# Patch run.py with --schedule argument
$runPatch = @'
import typer
from automator.gui import GUI
from automator.profile_manager import load_profile
from automator.automation_engine import run_automation
import schedule, time
from datetime import datetime

app = typer.Typer()

@app.command()
def gui():
    GUI()

@app.command()
def run_profile(name: str):
    profile = load_profile(name)
    run_automation(profile)

@app.command()
def schedule(name: str, time_str: str):
    def task():
        typer.echo(f"Running scheduled profile: {name} at {datetime.now()}")
        run_profile(name)
    schedule.every().day.at(time_str).do(task)
    typer.echo(f"Scheduled {name} at {time_str}. Press CTRL+C to exit.")
    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == "__main__":
    app()
'@
Set-Content -Path $runFile -Value $runPatch -Encoding UTF8

# Create separate scheduler_launcher.py if needed for background launching via Task Scheduler
$schedulerScript = @'
import sys
from automator.profile_manager import load_profile
from automator.automation_engine import run_automation

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: scheduler_launcher.py <profile_name>")
        sys.exit(1)
    profile_name = sys.argv[1]
    profile = load_profile(profile_name)
    run_automation(profile)
'@
Set-Content -Path $schedulerFile -Value $schedulerScript -Encoding UTF8

Write-Host "✅ Scheduler integration patched into run.py and scheduler_launcher.py created."
