@Echo off
dir "%~dpn0.ps1"
PowerShell -NoProfile -NonInteractive -ExecutionPolicy ByPass -File "%~dpn0.ps1"
pause
