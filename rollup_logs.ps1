# Set up variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logsDir = Join-Path $scriptDir "logs"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$rollupFile = Join-Path $logsDir "rollup_log_$timestamp.csv"

# Get all the service status log files
$logFiles = Get-ChildItem -Path $logsDir -Filter "service_status_*.csv"

if (-not $logFiles) {
    Write-Host "No 'service_status_*.csv' log files found in the logs directory."
    exit
}

Write-Host "Found $($logFiles.Count) log files to process."

# Create an empty array to hold all the log data
$allLogData = @()

# Process each log file
foreach ($file in $logFiles) {
    Write-Host "Processing $($file.Name)..."
    try {
        $csvData = Import-Csv -Path $file.FullName
        if ($null -ne $csvData) {
            $allLogData += $csvData
        }
    } catch {
        Write-Host "  Error processing file $($file.Name): $_"
    }
}

# Sort the data by timestamp
# The 'Timestamp' column is in ISO 8601 format, which can be sorted as a string.
$sortedData = $allLogData | Sort-Object -Property "Timestamp"

# Export the rolled-up data to a new CSV file
$sortedData | Export-Csv -Path $rollupFile -NoTypeInformation

Write-Host ""
Write-Host "Log rollup complete."
Write-Host "All data has been combined, sorted, and saved to:"
Write-Host $rollupFile
