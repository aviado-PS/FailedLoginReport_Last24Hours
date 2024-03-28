# Failed Login Attempts Report Generator for Exchange 2016

## Overview

This PowerShell script is crafted to assist system administrators in monitoring and analyzing failed login attempts on Exchange 2016 servers. By targeting Event ID 4625 in the Security event log, it provides valuable insights into unauthorized access attempts within the last 24 hours. The extracted data is neatly compiled into a CSV file, making it an indispensable tool for security audits and investigations.

## Features

- **Automated Monitoring**: Automatically scans the Security event log for Event ID 4625, identifying failed login attempts.
- **Comprehensive Reporting**: Gathers details on account names, failure reasons, and source IP addresses for each attempt.
- **Export to CSV**: Outputs the collected data into an organized CSV file, ready for analysis or audit documentation.
- **Customizable Paths**: Allows for easy customization of the destination directory and CSV file path.

## Prerequisites

- Exchange Management PowerShell SnapIn must be installed.
- Administrative privileges are required to run this script effectively.
- Ensure the `$csvDirectoryPath` and `$csvFilePath` variables are adjusted according to your needs.
## Author
This script was authored by [aviado1](https://github.com/aviado1).
## Usage
To generate a report of failed login attempts for the last 24 hours, navigate to the script's directory and execute:

```powershell
.\FailedLoginReport_Last24Hours.ps1
