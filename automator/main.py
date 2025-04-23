import os
import sys
import argparse
from .settings_manager import SettingsManager
from .scanner import GameScanner
from .profile_manager import ProfileManager
from .backup_manager import BackupManager
from .automation_engine import AutomationEngine

def ensure_dirs(dirs):
    for d in dirs:
        os.makedirs(d, exist_ok=True)

def setup_logging(log_dir):
    """Ensure log directory exists and configure basic logging."""
    os.makedirs(log_dir, exist_ok=True)
    import logging
    log_path = os.path.join(log_dir, "automator.log")
    logging.basicConfig(
        filename=log_path,
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s"
    )

def main():
    parser = argparse.ArgumentParser(description="DailyLoginAutomator")
    parser.add_argument("--create-profile", "-c", help="Game path to create a new profile")
    parser.add_argument("--run-profile", "-r", help="Profile name to run")
    args = parser.parse_args()

    settings = SettingsManager()
    ensure_dirs([
        settings.get_logs_dir(),
        settings.get_backup_dir(),
        settings.get_profiles_dir()
    ])

    setup_logging(settings.get_logs_dir())

    scanner = GameScanner(settings.get_search_paths())
    profiler = ProfileManager(settings.get_profiles_dir(), settings.get_config_path())
    backup  = BackupManager(settings.get_backup_dir())
    engine  = AutomationEngine()

    if args.create_profile:
        cfg = profiler.create_profile(args.create_profile, backup)
        print(f"Profile created: {cfg}")
        sys.exit(0)
    if args.run_profile:
        profile = profiler.load_profile(args.run_profile)
        engine.run(profile)
        sys.exit(0)

    parser.print_help()
