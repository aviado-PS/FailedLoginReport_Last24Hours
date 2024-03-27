<#
.SYNOPSIS
Failed Login Attempts Report Generator for Exchange 2016 Server.

.DESCRIPTION
This script is designed to monitor Exchange 2016 mail servers for failed login attempts over the last 24 hours, indicated by Event ID 4625 in the Security event log. It filters events to gather data on attempted account names, failure reasons, and source network addresses for each failed login attempt.

The data is exported to a CSV file, providing an organized report that can be used for security analysis, auditing, or as part of an investigation into unauthorized access attempts. The script checks for the necessary directory's existence, creates it if absent, and handles errors gracefully, ensuring smooth execution and informative output.

.AUTHOR
Aviad Ofek

.NOTES
- Requires Exchange Management PowerShell SnapIn.
- Make sure to run with administrative privileges if necessary.
- Adjust the `$csvDirectoryPath` and `$csvFilePath` variables as needed.

.EXAMPLE
.\FailedLoginReport_Last24Hours.ps1
Runs the script to generate the report of failed login attempts in the last 24 hours and exports it to the specified CSV file.

#>

# Add PS Snapin for Exchange Management
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# Define the path for the CSV file and its directory
$csvDirectoryPath = "C:\temp\data"
$csvFilePath = "$csvDirectoryPath\EV_Report.csv"

# Check if the directory exists, if not, create it
if (-not (Test-Path -Path $csvDirectoryPath)) {
    New-Item -ItemType Directory -Path $csvDirectoryPath
    Write-Host "Created directory at $csvDirectoryPath"
}

# Prepare an array to hold the data
$data = @()

# Define the time range for the last 24 hours
$startTime = (Get-Date).AddHours(-24)
$endTime = Get-Date

# Query Event Viewer for Event ID 4625 from the last 24 hours
$events = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625; StartTime=$startTime; EndTime=$endTime} -ErrorAction SilentlyContinue

if ($events.Count -eq 0) {
    Write-Host "No events found matching criteria within the last 24 hours."
} else {
    Write-Host "$($events.Count) events found from the last 24 hours. Processing..."

    foreach ($event in $events) {
        $eventXml = [xml]$event.ToXml()
        $accountName = $eventXml.Event.EventData.Data | Where-Object {$_.Name -eq 'TargetUserName'} | Select-Object -ExpandProperty '#text'
        $failureReason = $eventXml.Event.EventData.Data | Where-Object {$_.Name -eq 'Status'} | Select-Object -ExpandProperty '#text'
        $sourceNetworkAddress = $eventXml.Event.EventData.Data | Where-Object {$_.Name -eq 'IpAddress'} | Select-Object -ExpandProperty '#text'

        # Check if $accountName looks like an email address
        if ($accountName -match "@") {
            $data += New-Object PSObject -Property @{
                Time = $event.TimeCreated.ToString()
                AccountName = $accountName
                FailureReason = $failureReason
                SourceNetworkAddress = $sourceNetworkAddress
            }
        }
    }

    if ($data.Count -eq 0) {
        Write-Host "No data to export after filtering."
    } else {
        # Export the data to a CSV file
        $data | Export-Csv -Path $csvFilePath -NoTypeInformation -Encoding UTF8
        Write-Host "Report exported to $csvFilePath"
    }
}

