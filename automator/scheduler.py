import os
import schedule
import time
from .main import run_profile

def schedule_profile(profile_name, run_time: str):
    """Schedules the given profile to run daily at HH:MM (24h)."""
    hour, minute = map(int, run_time.split(":"))
    schedule.clear()
    schedule.every().day.at(f"{hour:02d}:{minute:02d}").do(run_profile, profile_name)
    print(f"Scheduled \'{profile_name}\' daily at {hour:02d}:{minute:02d}")
    try:
        while True:
            schedule.run_pending()
            time.sleep(30)
    except KeyboardInterrupt:
        print("Scheduler stopped.")

def run_profile(profile_name):
    """Launches one-off run via the engine."""
    from .settings_manager import SettingsManager
    from .backup_manager import BackupManager
    from .profile_manager import ProfileManager
    from .automation_engine import AutomationEngine

    settings = SettingsManager()
    for d in (settings.get_logs_dir(), settings.get_backup_dir(), settings.get_profiles_dir()):
        os.makedirs(d, exist_ok=True)

    backup   = BackupManager(settings.get_backup_dir())
    profiler = ProfileManager(settings.get_profiles_dir(), settings.get_config_path())
    profile  = profiler.load_profile(profile_name)
    engine   = AutomationEngine()
    engine.run(profile)
