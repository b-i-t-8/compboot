# CompBoot - Computer Boot Service Monitor

**Version:** 1.0.0

## Overview

Windows batch script that monitors and manages Windows services and applications. Reads services from `services.csv` and applications from `applications.csv`, checks their status, starts stopped services/applications, and generates logs.

## Quick Start

1. Edit `services.csv` with your services:
   ```csv
   "CompassService","AlertonCompassIgnite1","Alerton Compass Kafka","EthuioService","AlertonPointDataService1"
   ```

2. (Optional) Edit `applications.csv` with full paths to executables:
   ```csv
   "C:\Windows\System32\notepad.exe","C:\Path\To\App.exe"
   ```

3. Run as Administrator:
   ```batch
   compboot.bat
   ```

## Files

- `compboot.bat` - Launcher script (elevates permissions)
- `execute.ps1` - Main PowerShell logic
- `services.csv` - List of service names
- `applications.csv` - List of application paths
- `logs/` - Generated logs and CSV reports

## Output

- **Log:** `logs\log_YYYYMMDDHHMMSS.log`
- **CSV:** `logs\service_status_YYYYMMDDHHMMSS.csv`

## Troubleshooting

- **Access Denied:** Run as Administrator
- **Service Not Found:** Check exact service name with `sc query`
- **Application Not Found:** Ensure the full path in `applications.csv` is correct and accessible.
- **CSV Errors:** Use quotes and commas: `"Item1","Item2"`

## License

MIT License

