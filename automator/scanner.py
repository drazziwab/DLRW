# automator/scanner.py
import os

class GameScanner:
    def __init__(self, search_paths):
        self.paths = search_paths

    def scan(self):
        games = []
        for base in self.paths:
            if os.path.exists(base):
                for entry in os.listdir(base):
                    full = os.path.join(base, entry)
                    if os.path.isdir(full): games.append(full)
        return games
