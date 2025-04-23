# automator/main.py
\"\"\"Main entry point with Scheduler and OCR\"\"\"
import logging, argparse, os
from automator.settings_manager import SettingsManager
from automator.scanner import GameScanner
from automator.profile_manager import ProfileManager
from automator.backup_manager import BackupManager
from automator.automation_engine import AutomationEngine
from automator.scheduler import schedule_profile

def setup_logging(log_dir):
    os.makedirs(log_dir, exist_ok=True)
    log_path = os.path.join(log_dir, 'automator.log')
    logging.basicConfig(filename=log_path, level=logging.INFO,
                        format='%(asctime)s [%(levelname)s] %(message)s')
    logging.getLogger().addHandler(logging.StreamHandler())

def main():
    parser = argparse.ArgumentParser(description='DailyLoginAutomator')
    parser.add_argument('--list-games', action='store_true', help='List detected games')
    parser.add_argument('--create-profile', metavar='GAME', help='Create profile for GAME')
    parser.add_argument('--run-profile', metavar='PROFILE', help='Run automation for PROFILE')
    parser.add_argument('--schedule-profile', nargs=2, metavar=('PROFILE','HH:MM'),
                        help='Schedule daily run for PROFILE at time')
    args = parser.parse_args()

    settings = SettingsManager()
    setup_logging(settings.get_logs_dir())

    scanner = GameScanner(settings.get_search_paths())
    profiler = ProfileManager(settings.get_profiles_dir(), settings.get_config_path())
    backup  = BackupManager(settings.get_backup_dir())
    engine  = AutomationEngine()

    if args.list_games:
        for g in scanner.scan(): print(g)
    elif args.create_profile:
        game = args.create_profile
        if game in scanner.scan():
            cfg = profiler.create_profile(game, backup)
            logging.info(f"Profile created: {cfg}")
        else:
            logging.error(f"Game not found: {game}")
    elif args.run_profile:
        profile = profiler.load_profile(args.run_profile)
        backup.backup_settings(profile['settings_path'])
        engine.run(profile)
    elif args.schedule_profile:
        profile_name, run_time = args.schedule_profile
        schedule_profile(profile_name, run_time)
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
