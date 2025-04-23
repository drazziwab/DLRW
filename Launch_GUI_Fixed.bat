@echo off
:: Launch the GUI using Python and preserve CLI arguments
set PY_SCRIPT="C:\Users\Basic User\Desktop\LLM_PROJECTS\DLA\DailyLoginAutomator\run.py"
set ARGS=gui

powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c python %PY_SCRIPT% %ARGS% && pause' -Verb RunAs"
