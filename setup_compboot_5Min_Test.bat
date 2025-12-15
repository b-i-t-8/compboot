@echo off
rem Create the task to run every 5 minutes for testing
schtasks /create /tn "Compass Boot Workaround (5 Min Test)" /tr "c:\compboot\compboot.bat" /sc minute /mo 5 /rl HIGHEST /ru SYSTEM /f

echo.
echo Task "Compass Boot Workaround (5 Min Test)" has been created to run every 5 minutes.
pause
