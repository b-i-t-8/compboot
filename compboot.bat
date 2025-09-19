@echo off
setlocal

:: Get the directory of the current script
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT_PATH=%SCRIPT_DIR%execute.ps1"

echo Attempting to run execute.ps1 with administrator privileges...
powershell -Command "Start-Process -FilePath 'powershell.exe' -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PS_SCRIPT_PATH%""' -Verb RunAs"

endlocal
