@echo off
rem Create the task to run at startup
schtasks /create /tn "Compass Boot Workaround (on start)" /tr "c:\compboot\compboot.bat" /sc onstart /rl HIGHEST /f

rem Create the task to run daily at midnight
schtasks /create /tn "Compass Boot Workaround (daily)" /tr "c:\compboot\compboot.bat" /sc daily /st 00:00 /rl HIGHEST /f

echo.
echo Tasks have been created to run at startup and daily at midnight.
pause
