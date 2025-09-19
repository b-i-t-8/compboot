# CompBoot - Computer Boot Service Monitor

**Version:** 0.1.4

## Overview

Windows batch script that monitors and manages Windows services. Reads services from CSV file, checks status, starts stopped services, and generates logs.

## Quick Start

1. Edit `services.csv` with your services:
   ```csv
   "CompassService","AlertonCompassIgnite1","Alerton Compass Kafka","EthuioService","AlertonPointDataService1"
   ```

2. Run as Administrator:
   ```batch
   compboot.bat
   ```

## Files

- `compboot.bat` - Main script
- `services.csv` - Service list
- `logs/` - Generated logs and CSV reports

## Output

- **Log:** `logs\log_YYYYMMDDHHMMSS.log`
- **CSV:** `logs\service_status_YYYYMMDDHHMMSS.csv`

## Troubleshooting

- **Access Denied:** Run as Administrator
- **Service Not Found:** Check exact service name with `sc query`
- **CSV Errors:** Use quotes and commas: `"Service1","Service2"`

## License

MIT License

