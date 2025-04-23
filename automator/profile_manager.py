# automator/profile_manager.py
import os, json

class ProfileManager:
    def __init__(self, profiles_dir, config_path):
        self.profiles_dir = profiles_dir
        os.makedirs(self.profiles_dir, exist_ok=True)

    def create_profile(self, game_path, backup_manager):
        profile = {'game_path': game_path, 'settings_path': self._find_settings(game_path)}
        name = os.path.basename(game_path)
        file = os.path.join(self.profiles_dir, f'{name}.json')
        json.dump(profile, open(file, 'w'), indent=2)
        return file

    def load_profile(self, profile_name):
        path = os.path.join(self.profiles_dir, profile_name if profile_name.endswith('.json') else f'{profile_name}.json')
        return json.load(open(path))

    def _find_settings(self, game_path):
        for root, _, files in os.walk(game_path):
            for f in files:
                if f.lower().endswith(('.ini','.cfg','.json')): return os.path.join(root, f)
        return ''
