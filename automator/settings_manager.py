# automator/settings_manager.py
import json, os

class SettingsManager:
    def __init__(self):
        base = os.path.dirname(os.path.dirname(__file__))
        self.config_file = os.path.join(base, 'configs', 'default_settings.json')
        self._load()

    def _load(self):
        data = json.load(open(self.config_file))
        self.search_paths = data.get('search_paths', [])
        self.backup_dir    = os.path.join(os.path.dirname(self.config_file), '..', data.get('backup_dir'))
        self.profiles_dir  = os.path.join(os.path.dirname(self.config_file), '..', data.get('profiles_dir'))
        self.logs_dir      = os.path.join(os.path.dirname(self.config_file), '..', data.get('logs_dir'))
        self.config_path   = self.config_file

    def get_search_paths(self): return self.search_paths
    def get_backup_dir(self):    return self.backup_dir
    def get_profiles_dir(self):  return self.profiles_dir
    def get_logs_dir(self):      return self.logs_dir
    def get_config_path(self):   return self.config_path
