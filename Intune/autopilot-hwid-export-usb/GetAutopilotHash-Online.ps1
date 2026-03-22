<#
.SYNOPSIS
    Collects the Windows Autopilot hardware hash and saves it to a CSV file on the USB drive.

.DESCRIPTION
    This script is intended to be run from a USB drive during Windows OOBE or from a Windows session.
    It automatically detects the location of the script, creates an HWID.csv file in that same folder,
    and exports the device Autopilot hardware hash to it.

    If HWID.csv does not already exist, the script creates it with the proper CSV header.
    If HWID.csv already exists, the script appends the new device entry without duplicating the header row.

.NOTES
    Requirements:
    - Internet connection
    - PowerShell execution allowed for the current process
    - Access to PowerShell Gallery
    - The Get-WindowsAutopilotInfo script will be installed automatically if missing

    Output:
    - HWID.csv in the same folder where this script is stored

.AUTHOR
    Eduardo González
#>

# Force PowerShell to use TLS 1.2 when connecting to PowerShell Gallery.
# This helps prevent connection issues when downloading required components.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Detect the folder where this script is running from.
# This allows the script to save the output CSV to the same USB drive
# regardless of whether the drive letter is D:, E:, F:, etc.
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define the final output file on the USB drive.
# HWID.csv will store one or more Autopilot hardware hashes.
$USBPath = Join-Path $ScriptRoot 'HWID.csv'

# Define a temporary file path in the local Windows TEMP folder.
# The hardware hash is first generated here before being moved or appended to the USB CSV file.
$TempPath = "$env:TEMP\TempHWID.csv"

# Set the execution policy only for the current PowerShell process.
# This avoids making permanent changes to the device.
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned

# Install the NuGet package provider if required.
# This is needed to download scripts from the PowerShell Gallery.
Install-PackageProvider -Name NuGet -Force | Out-Null

# Download and install Microsoft's Get-WindowsAutopilotInfo script.
# This script is used to collect the device hardware hash for Autopilot registration.
Install-Script -Name Get-WindowsAutopilotInfo -Force

# Generate the device Autopilot hardware hash and save it to a temporary CSV file.
Get-WindowsAutopilotInfo -OutputFile $TempPath

# If HWID.csv does not already exist on the USB drive,
# move the temporary CSV file there as the main output file.
# This keeps the original header row.
if (-not (Test-Path $USBPath)) {
    Move-Item -Path $TempPath -Destination $USBPath
} else {
    # If HWID.csv already exists, append only the data rows.
    # Skip the first row because it contains the CSV header.
    Get-Content $TempPath | Select-Object -Skip 1 | Add-Content $USBPath

    # Remove the temporary file after appending its content.
    Remove-Item $TempPath
}

# Display a confirmation message showing where the CSV file was saved.
Write-Host "Autopilot hardware hash exported/appended to $USBPath"