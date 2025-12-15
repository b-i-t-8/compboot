# CompBoot - Computer Boot Service Monitor

**Version:** 1.1.0

## Overview

Windows batch/PowerShell solution that monitors and manages a specific application and its corresponding Windows service. It implements "XOR" logic to ensure the software is running in one form or another:

1.  **Check Application:** If the application executable is running, the script logs it and **exits** (does not touch the service).
2.  **Check Service:** If the application is **not** running, the script checks the Windows Service. If the service is stopped, it attempts to start it.

This prevents conflicts where both the desktop application and the background service might try to run simultaneously.

## Quick Start

1.  Edit `config.yaml` to define your target application and service:
    ```yaml
    ApplicationPath: "C:\Alerton\Compass\2.0\System\bactalk.exe"
    ServiceName: "CompassService"
    ```

2.  Run as Administrator:
    ```batch
    compboot.bat
    ```

## Files

-   `compboot.bat` - Launcher script (elevates permissions)
-   `execute.ps1` - Main PowerShell logic
-   `config.yaml` - Configuration file
-   `logs/` - Generated logs and CSV reports

## Output

-   **Log:** `logs\log_YYYYMMDDHHMMSS.log`
-   **CSV:** `logs\service_status_YYYYMMDDHHMMSS.csv`

## Troubleshooting

-   **Access Denied:** Run as Administrator
-   **Service Not Found:** Check exact service name with `sc query`
-   **Application Not Found:** Ensure the full path in `config.yaml` is correct and accessible.
-   **YAML Errors:** Ensure `Key: "Value"` format is preserved.

## License

MIT License

