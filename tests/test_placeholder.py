import pytest
from automator.settings_manager import SettingsManager

def test_settings_load():
    sm = SettingsManager()
    assert hasattr(sm, 'get_search_paths')
