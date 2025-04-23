@echo off
:: Elevate privileges and run the PowerShell GUI script
PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
"Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "python \"C:\Users\Basic User\Desktop\LLM_PROJECTS\DLA\DailyLoginAutomator\run.py\" gui"' -Verb RunAs"
