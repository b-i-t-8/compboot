# Check for Administrator privileges
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "WARNING: Running without Administrator privileges. Service start operations may fail." -ForegroundColor Yellow
}

# Set up variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptDir "config.yaml"
$logsDir = Join-Path $scriptDir "logs"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logFile = Join-Path $logsDir "log_$timestamp.log"
$statusFile = Join-Path $logsDir "service_status_$timestamp.csv"

# Create logs directory if it doesn't exist
if (-not (Test-Path -Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir
}

# Function to write log messages
function Write-Log {
    param (
        [string]$message
    )
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
    Add-Content -Path $logFile -Value $logMessage
    Write-Host $logMessage
}

# Initialize log file
"Computer Boot Service Monitor - $(Get-Date)" | Out-File -FilePath $logFile
"==================================================" | Add-Content -Path $logFile

# Initialize status data array
$statusData = @()

$summary = @{
    TotalServices = 0
    Running = 0
    Stopped = 0
    NotFound = 0
    Started = 0
}

# Check if config.yaml exists
if (-not (Test-Path -Path $configFile)) {
    Write-Log "ERROR: config.yaml not found!"
    exit 1
}

Write-Log "Reading configuration from $configFile"

# Simple YAML Parser
$config = @{}
$configContent = Get-Content -Path $configFile
foreach ($line in $configContent) {
    if ($line -match "^(.*?):\s*[`"']?(.*?)[`"']?$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $config[$key] = $value
    }
}

$appPath = $config["ApplicationPath"]
$serviceName = $config["ServiceName"]

if ([string]::IsNullOrWhiteSpace($appPath) -or [string]::IsNullOrWhiteSpace($serviceName)) {
    Write-Log "ERROR: ApplicationPath or ServiceName not defined in config.yaml"
    exit 1
}

$isApplicationRunning = $false

# 1. Check Application
$appName = [System.IO.Path]::GetFileName($appPath)
$summary.TotalServices++ # Counting app as a monitored entity
Write-Log "Checking application: $appName ($appPath)"

if (-not (Test-Path -Path $appPath)) {
    Write-Log "  Application executable not found at $appPath"
    $summary.NotFound++
    $statusData += [PSCustomObject]@{
        "Entity Name"  = $appName
        "Type"         = "Application"
        "Status"       = "Not Found"
        "Timestamp"    = (Get-Date -Format 'o')
        "Action Taken" = "Executable not found"
    }
} else {
    # Check if the process is running
    $runningProcess = Get-Process | Where-Object { $_.Path -eq $appPath } | Select-Object -First 1

    if ($runningProcess) {
        Write-Log "  Application $appName is running."
        $isApplicationRunning = $true
        $summary.Running++
        $statusData += [PSCustomObject]@{
            "Entity Name"  = $appName
            "Type"         = "Application"
            "Status"       = "Running"
            "Timestamp"    = (Get-Date -Format 'o')
            "Action Taken" = "None (Application Mode)"
        }
    } else {
        Write-Log "  Application $appName is not running."
        $statusData += [PSCustomObject]@{
            "Entity Name"  = $appName
            "Type"         = "Application"
            "Status"       = "Stopped"
            "Timestamp"    = (Get-Date -Format 'o')
            "Action Taken" = "None"
        }
    }
}

# 2. Check Service (Only if App is NOT running)
if ($isApplicationRunning) {
    Write-Log "An application is running. Skipping service checks to avoid conflicts."
} else {
    $summary.TotalServices++ # Counting service as a monitored entity
    Write-Log "Checking service: $serviceName"
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        if ($service.Status -eq 'Running') {
            Write-Log "  $serviceName is running normally."
            $summary.Running++
            $statusData += [PSCustomObject]@{
                "Entity Name"  = $serviceName
                "Type"         = "Service"
                "Status"       = "Running"
                "Timestamp"    = (Get-Date -Format 'o')
                "Action Taken" = "None"
            }
        } else {
            Write-Log "  $serviceName is not running. Status: $($service.Status)"
            $statusData += [PSCustomObject]@{
                "Entity Name"  = $serviceName
                "Type"         = "Service"
                "Status"       = $service.Status
                "Timestamp"    = (Get-Date -Format 'o')
                "Action Taken" = "Attempting to start"
            }
            
            try {
                Start-Service -Name $serviceName -ErrorAction Stop
                # Wait a moment for the service to start
                Start-Sleep -Seconds 3
                $service.Refresh()
                if ($service.Status -eq 'Running') {
                    Write-Log "  Successfully started $serviceName."
                    $summary.Started++
                    $summary.Running++
                    $statusData += [PSCustomObject]@{
                        "Entity Name"  = $serviceName
                        "Type"         = "Service"
                        "Status"       = "Running"
                        "Timestamp"    = (Get-Date -Format 'o')
                        "Action Taken" = "Started successfully"
                    }
                } else {
                    Write-Log "  Failed to start $serviceName. Current status: $($service.Status)"
                    $summary.Stopped++
                    $statusData += [PSCustomObject]@{
                        "Entity Name"  = $serviceName
                        "Type"         = "Service"
                        "Status"       = $service.Status
                        "Timestamp"    = (Get-Date -Format 'o')
                        "Action Taken" = "Start attempt failed"
                    }
                }
            } catch {
                Write-Log "  Failed to start $serviceName. Error: $_"
                $summary.Stopped++
                $statusData += [PSCustomObject]@{
                    "Entity Name"  = $serviceName
                    "Type"         = "Service"
                    "Status"       = "Failed to start"
                    "Timestamp"    = (Get-Date -Format 'o')
                    "Action Taken" = $_.Exception.Message
                }
            }
        }
    } catch {
        Write-Log "  Service $serviceName not found on this system."
        $summary.NotFound++
        $statusData += [PSCustomObject]@{
            "Entity Name"  = $serviceName
            "Type"         = "Service"
            "Status"       = "Not Found"
            "Timestamp"    = (Get-Date -Format 'o')
            "Action Taken" = "Service does not exist"
        }
    }
}

# Export the status data to a CSV file
$statusData | Export-Csv -Path $statusFile -NoTypeInformation

Write-Log "Service status check completed."
Write-Log ""
Write-Log "=================================================="
Write-Log "SUMMARY REPORT"
Write-Log "=================================================="
Write-Log "Total services processed: $($summary.TotalServices)"
Write-Log "Services running: $($summary.Running)"
Write-Log "Services stopped/failed: $($summary.Stopped)"
Write-Log "Services not found: $($summary.NotFound)"
Write-Log "Services successfully started: $($summary.Started)"
Write-Log "=================================================="
Write-Log "Results saved to: $statusFile"

Write-Host ""
Write-Host "Service monitoring completed!"
Write-Host ""
Write-Host "SUMMARY:"
Write-Host "  Total services: $($summary.TotalServices)"
Write-Host "  Running: $($summary.Running)"
Write-Host "  Stopped/Failed: $($summary.Stopped)"
Write-Host "  Not Found: $($summary.NotFound)"
Write-Host "  Successfully Started: $($summary.Started)"
Write-Host ""
Write-Host "Log file: $logFile"
Write-Host "Status file: $statusFile"
