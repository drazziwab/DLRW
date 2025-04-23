# automator/scheduler.py
import schedule, time, logging
from automator.profile_manager import ProfileManager
from automator.backup_manager import BackupManager
from automator.automation_engine import AutomationEngine
from automator.settings_manager import SettingsManager

def run_profile(profile_name):
    settings = SettingsManager()
    backup   = BackupManager(settings.get_backup_dir())
    profiler = ProfileManager(settings.get_profiles_dir(), settings.get_config_path())
    profile  = profiler.load_profile(profile_name)
    backup.backup_settings(profile['settings_path'])
    engine = AutomationEngine()
    engine.run(profile)

def schedule_profile(profile_name, run_time):
    logging.info(f'Scheduling {profile_name} daily at {run_time}')
    schedule.every().day.at(run_time).do(lambda: run_profile(profile_name))
    while True:
        schedule.run_pending()
        time.sleep(30)
