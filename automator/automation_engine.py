import pyautogui, pytesseract, subprocess, time

class AutomationEngine:
    """Launches game executable and performs automated login reward actions."""
    def __init__(self):
        self.pyautogui = pyautogui
        self.pytesseract = pytesseract
        self.subprocess = subprocess
        self.time = time

    def run(self, profile):
        """Launch game and perform reward sequence."""
        exe = profile.get("game_path")
        try:
            proc = self.subprocess.Popen(exe)
        except Exception as e:
            raise RuntimeError(f"Failed to launch game: {e}")
        self.time.sleep(profile.get("launch_delay", 60))
        self._perform_actions(profile)
        proc.terminate()

    def _perform_actions(self, profile):
        """Generic reward click: focus window and press Enter."""
        w, h = self.pyautogui.size()
        self.pyautogui.click(w//2, h//2)
        self.time.sleep(2)
        self.pyautogui.press("enter")
        self.time.sleep(5)
