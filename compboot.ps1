# Check for Administrator privileges
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires Administrator privileges to start services." -ForegroundColor Red
    Write-Host "Please run PowerShell as an Administrator and try again." -ForegroundColor Red
    if ($Host.Name -eq "ConsoleHost") {
        Read-Host -Prompt "Press Enter to exit"
    }
    exit 1
}

# Set up variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$servicesFile = Join-Path $scriptDir "services.csv"
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

# Check if services.csv exists
if (-not (Test-Path -Path $servicesFile)) {
    Write-Log "ERROR: services.csv not found!"
    exit 1
}

Write-Log "Reading services from $servicesFile"
Write-Log "Checking service status..."

# Read and parse the CSV file
$services = (Get-Content -Path $servicesFile) -split ',' | ForEach-Object { $_.Trim().Trim('"') }

$summary = @{
    TotalServices = 0
    Running = 0
    Stopped = 0
    NotFound = 0
    Started = 0
}

foreach ($serviceName in $services) {
    if (-not [string]::IsNullOrWhiteSpace($serviceName)) {
        $summary.TotalServices++
        Write-Log "Checking service: $serviceName"
        try {
            $service = Get-Service -Name $serviceName -ErrorAction Stop
            if ($service.Status -eq 'Running') {
                Write-Log "  $serviceName is running normally."
                $summary.Running++
                $statusData += [PSCustomObject]@{
                    "Service Name" = $serviceName
                    "Status"       = "Running"
                    "Timestamp"    = (Get-Date -Format 'o')
                    "Action Taken" = "None"
                }
            } else {
                Write-Log "  $serviceName is not running. Status: $($service.Status)"
                $statusData += [PSCustomObject]@{
                    "Service Name" = $serviceName
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
                            "Service Name" = $serviceName
                            "Status"       = "Running"
                            "Timestamp"    = (Get-Date -Format 'o')
                            "Action Taken" = "Started successfully"
                        }
                    } else {
                        Write-Log "  Failed to start $serviceName. Current status: $($service.Status)"
                        $summary.Stopped++
                        $statusData += [PSCustomObject]@{
                            "Service Name" = $serviceName
                            "Status"       = $service.Status
                            "Timestamp"    = (Get-Date -Format 'o')
                            "Action Taken" = "Start attempt failed"
                        }
                    }
                } catch {
                    Write-Log "  Failed to start $serviceName. Error: $_"
                    $summary.Stopped++
                    $statusData += [PSCustomObject]@{
                        "Service Name" = $serviceName
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
                "Service Name" = $serviceName
                "Status"       = "Not Found"
                "Timestamp"    = (Get-Date -Format 'o')
                "Action Taken" = "Service does not exist"
            }
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
