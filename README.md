# CompBoot - Computer Boot Service Monitor

**Version:** 1.0.0  
**Release Date:** September 11, 2025  
**Author:** CompBoot Development Team

## Overview

CompBoot is a Windows batch script that monitors and manages Windows services during system startup or on-demand. It reads a list of services from a CSV file, checks their status, attempts to start stopped services, and generates detailed logs and status reports.

## Features

- 🔍 **Service Status Monitoring** - Checks if services exist and their current state
- 🚀 **Automatic Service Starting** - Attempts to start stopped services
- 📊 **Detailed Logging** - Creates both human-readable logs and structured CSV reports
- 📁 **Dynamic Service List** - Supports any number of services via CSV configuration
- ⏰ **Timestamped Reports** - All logs include precise timestamps for tracking
- 🛡️ **Error Handling** - Gracefully handles missing services and failed operations

## File Structure

```
compboot/
├── compboot.bat          # Main executable script
├── services.csv          # Service configuration file
├── setup_compboot.bat    # Setup helper script (if needed)
├── logs/                 # Generated log files directory
│   ├── log_YYYYMMDDHHMMSS.log           # Detailed activity logs
│   └── service_status_YYYYMMDDHHMMSS.csv # CSV status reports
└── README.md             # This documentation
```

## Installation & Setup

### Prerequisites

- Windows 10/11 or Windows Server 2016+
- PowerShell or Command Prompt
- Administrator privileges (recommended for service management)

### Quick Setup

1. **Download/Clone** the compboot directory to your desired location
2. **Configure Services** - Edit `services.csv` with your desired services
3. **Run** - Execute `compboot.bat`

### Detailed Setup Steps

#### Step 1: Configure Services

Edit the `services.csv` file to include the services you want to monitor:

```csv
"Spooler","BITS","Themes","AudioSrv","YourCustomService1","YourCustomService2"
```

**Service Name Format:**
- Use exact Windows service names (case-sensitive)
- Enclose each service name in quotes
- Separate multiple services with commas
- No spaces after commas (unless part of service name)

#### Step 2: Set Permissions (Recommended)

For full functionality, run as Administrator:

1. Right-click on Command Prompt or PowerShell
2. Select "Run as Administrator"
3. Navigate to the compboot directory
4. Execute `compboot.bat`

#### Step 3: Run CompBoot

```batch
cd C:\path\to\compboot
compboot.bat
```

## Usage

### Basic Execution

```batch
compboot.bat
```

### Output Files

Each run generates two timestamped files:

1. **Log File** (`logs\log_YYYYMMDDHHMMSS.log`)
   - Human-readable detailed log
   - Service discovery and status information
   - Start/stop attempt results
   - Error messages and troubleshooting info

2. **Status CSV** (`logs\service_status_YYYYMMDDHHMMSS.csv`)
   - Structured data for analysis
   - Columns: Service Name, Status, Timestamp, Action Taken
   - Import into Excel or other tools for reporting

### Example Output

**Console Output:**
```
Service monitoring completed!
Log file: C:\compboot\logs\log_20250911080027.log
Status file: C:\compboot\logs\service_status_20250911080027.csv
```

**CSV Status Report:**
```csv
Service Name,Status,Timestamp,Action Taken
Spooler,Running,Thu 09/11/2025 8:00:27.86,None
BITS,STOPPED,Thu 09/11/2025 8:00:27.99,Attempting to start
AudioSrv,Running,Thu 09/11/2025 8:00:28.26,None
MyCustomService,Not Found,Thu 09/11/2025 8:00:28.39,Service does not exist
```

## Configuration

### Services.csv Format

The `services.csv` file supports any number of services in a single line:

```csv
"Service1","Service2","Service3","ServiceN"
```

### Common Windows Services

Here are some commonly monitored Windows services:

| Service Name | Description | Typical Status |
|-------------|-------------|----------------|
| `Spooler` | Print Spooler | Running |
| `BITS` | Background Intelligent Transfer | Stopped |
| `Themes` | Windows Themes | Running |
| `AudioSrv` | Windows Audio | Running |
| `EventLog` | Windows Event Log | Running |
| `Dhcp` | DHCP Client | Running |
| `Dnscache` | DNS Client | Running |

## Troubleshooting

### Common Issues

**"Access Denied" when starting services:**
- Solution: Run as Administrator
- Some services require elevated privileges

**Services not found:**
- Verify service names are correct (case-sensitive)
- Use `sc query` to list available services
- Check if service is installed on the system

**CSV parsing errors:**
- Ensure proper quote formatting in `services.csv`
- No line breaks within the CSV file
- Use commas only as delimiters

### Debug Steps

1. **Check Service Names:**
   ```batch
   sc query type= service state= all
   ```

2. **Test Individual Service:**
   ```batch
   sc query "ServiceName"
   ```

3. **View Recent Logs:**
   ```batch
   type logs\log_*.log
   ```

## Version History

### v1.0.0 (September 11, 2025)
- Initial release
- Dynamic CSV parsing for unlimited services
- Comprehensive logging and status reporting
- Service existence checking and automatic starting
- Error handling for missing services and failed operations

## Advanced Usage

### Scheduling CompBoot

To run CompBoot automatically at system startup:

1. **Task Scheduler Method:**
   - Open Task Scheduler
   - Create Basic Task
   - Set trigger to "At startup"
   - Set action to run `compboot.bat`
   - Configure to run with highest privileges

2. **Startup Folder Method:**
   - Create shortcut to `compboot.bat`
   - Place in: `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`

### Integration with Other Tools

CompBoot CSV output can be integrated with:
- Excel for reporting and analysis
- PowerBI for dashboards
- SIEM systems for monitoring
- Custom scripts for automated responses

## Support

For issues, questions, or contributions:
- Check the troubleshooting section above
- Review log files for detailed error information
- Ensure services.csv format is correct

## License

This project is released under the MIT License. Feel free to modify and distribute according to your needs.

---

**CompBoot v1.0.0** - Keeping your services running, one boot at a time! 🚀
