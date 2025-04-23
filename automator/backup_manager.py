# automator/backup_manager.py
import os, shutil, datetime, logging

class BackupManager:
    def __init__(self, backup_dir):
        self.backup_dir = backup_dir
        os.makedirs(self.backup_dir, exist_ok=True)

    def backup_settings(self, settings_path):
        if settings_path and os.path.exists(settings_path):
            ts = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
            name = os.path.basename(settings_path)
            dest = os.path.join(self.backup_dir, f'{name}.{ts}.bak')
            shutil.copy2(settings_path, dest)
            logging.info(f'Backed up {settings_path} to {dest}')
            return dest
        logging.warning('No settings to back up.')
        return ''
