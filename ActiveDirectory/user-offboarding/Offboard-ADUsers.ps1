<#
.SYNOPSIS
    Offboards one or more Active Directory users.

.DESCRIPTION
    This script performs a standard offboarding workflow for either:
    - a single Active Directory user
    - multiple users from a CSV file

    Actions performed:
    - Updates mailNickname
    - Removes group memberships except Domain Users
    - Hides the user from the GAL
    - Updates the description
    - Resets password to a random value
    - Disables the account (if not already disabled)
    - Optionally moves the account to a target OU

.PARAMETER SamAccountName
    The SamAccountName of a single user.

.PARAMETER CsvPath
    Path to CSV file with SamAccountName column.

.PARAMETER TargetOU
    OU to move users if -MoveToTargetOU is used.

.PARAMETER MoveToTargetOU
    Switch to move user(s) to TargetOU.

.PARAMETER LogFolder
    Folder for log output.
    
    C:\Users\<YourUser>\Desktop\OffboardingLogs\Offboarding_Log_YYYY-MM.txt

.EXAMPLE
    .\Offboard-ADUsers.ps1 -SamAccountName jsmith

    .\Offboard-ADUsers.ps1 -SamAccountName jsmith -MoveToTargetOU -TargetOU "OU=Disabled Users,DC=contoso,DC=com"

.EXAMPLE
    .\Offboard-ADUsers.ps1 -CsvPath .\users.csv

    .\Offboard-ADUsers.ps1 -CsvPath .\sample-users.csv -MoveToTargetOU -TargetOU "OU=Disabled Users,DC=contoso,DC=com"
#>

[CmdletBinding(DefaultParameterSetName = 'Single')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
    [string]$SamAccountName,

    [Parameter(Mandatory = $true, ParameterSetName = 'Bulk')]
    [string]$CsvPath,

    [string]$TargetOU,
    [switch]$MoveToTargetOU,
    [string]$LogFolder = "$env:USERPROFILE\Desktop\OffboardingLogs"
)

Import-Module ActiveDirectory -ErrorAction Stop

if ($MoveToTargetOU -and [string]::IsNullOrWhiteSpace($TargetOU)) {
    throw "TargetOU must be provided when using -MoveToTargetOU."
}

if (-not (Test-Path $LogFolder)) {
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
}

$month = Get-Date -Format "yyyy-MM"
$logFile = Join-Path $LogFolder "Offboarding_Log_$month.txt"
$currentUser = "$env:USERDOMAIN\$env:USERNAME"

function Write-Log {
    param([string]$Message)

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$time  $Message"
    Add-Content -Path $logFile -Value $line
    Write-Host $Message
}

function New-RandomPassword {
    param([int]$Length = 24)

    $upper   = "ABCDEFGHJKLMNPQRSTUVWXYZ".ToCharArray()
    $lower   = "abcdefghijkmnopqrstuvwxyz".ToCharArray()
    $digits  = "23456789".ToCharArray()
    $special = "!@#$%^&*_-+=".ToCharArray()

    $all = $upper + $lower + $digits + $special
    $chars = New-Object System.Collections.Generic.List[char]

    # Ensure complexity
    $chars.Add(($upper | Get-Random))
    $chars.Add(($lower | Get-Random))
    $chars.Add(($digits | Get-Random))
    $chars.Add(($special | Get-Random))

    for ($i = $chars.Count; $i -lt $Length; $i++) {
        $chars.Add(($all | Get-Random))
    }

    return -join ($chars | Sort-Object { Get-Random })
}

function Invoke-UserOffboarding {
    param([string]$Sam)

    if ([string]::IsNullOrWhiteSpace($Sam)) {
        Write-Log "Skipped blank value"
        return
    }

    $Sam = $Sam.Trim()
    Write-Log ""
    Write-Log "Processing user: $Sam"

    try {
        $adUser = Get-ADUser -Identity $Sam -Properties DistinguishedName, Enabled -ErrorAction Stop
    }
    catch {
        Write-Log "ERROR: User '$Sam' not found"
        return
    }

    try {
        Set-ADUser -Identity $Sam -Replace @{ mailNickname = $Sam }
        Write-Log "mailNickname updated"
    }
    catch {
        Write-Log "ERROR updating mailNickname: $($_.Exception.Message)"
    }

    try {
        $groups = Get-ADPrincipalGroupMembership -Identity $Sam

        foreach ($group in $groups) {
            if ($group.Name -eq "Domain Users") {
                Write-Log "Skipped Domain Users"
                continue
            }

            try {
                Remove-ADGroupMember -Identity $group -Members $Sam -Confirm:$false -ErrorAction Stop
                Write-Log "Removed from group: $($group.Name)"
            }
            catch {
                Write-Log "ERROR removing from group $($group.Name): $($_.Exception.Message)"
            }
        }
    }
    catch {
        Write-Log "ERROR retrieving groups: $($_.Exception.Message)"
    }

    try {
        Set-ADUser -Identity $Sam -Replace @{ msExchHideFromAddressLists = $true }
        Write-Log "Hidden from GAL"
    }
    catch {
        Write-Log "ERROR hiding from GAL: $($_.Exception.Message)"
    }

    try {
        $desc = "Offboarded $(Get-Date -Format 'yyyy-MM-dd HH:mm') by $currentUser"
        Set-ADUser -Identity $Sam -Description $desc
        Write-Log "Description updated"
    }
    catch {
        Write-Log "ERROR updating description: $($_.Exception.Message)"
    }

    try {
        $newPassword = New-RandomPassword
        $securePwd = ConvertTo-SecureString $newPassword -AsPlainText -Force
        Set-ADAccountPassword -Identity $Sam -Reset -NewPassword $securePwd -ErrorAction Stop
        Write-Log "Password reset to random value"
    }
    catch {
        Write-Log "ERROR resetting password: $($_.Exception.Message)"
    }

    try {
        if ($adUser.Enabled) {
            Disable-ADAccount -Identity $Sam -ErrorAction Stop
            Write-Log "Account disabled"
        }
        else {
            Write-Log "Account already disabled"
        }
    }
    catch {
        Write-Log "ERROR disabling account: $($_.Exception.Message)"
    }

    if ($MoveToTargetOU) {
        try {
            Move-ADObject -Identity $adUser.DistinguishedName -TargetPath $TargetOU -ErrorAction Stop
            Write-Log "Moved to OU: $TargetOU"
        }
        catch {
            Write-Log "ERROR moving user: $($_.Exception.Message)"
        }
    }
    else {
        Write-Log "User kept in current OU"
    }

    Write-Log "Completed offboarding for $Sam"
    Write-Log "---------------------------------------"
}

Write-Log ""
Write-Log "===== OFFBOARDING SESSION STARTED by $currentUser ====="
Write-Log "Log file: $logFile"

if ($PSCmdlet.ParameterSetName -eq 'Single') {
    Invoke-UserOffboarding -Sam $SamAccountName
}

if ($PSCmdlet.ParameterSetName -eq 'Bulk') {
    if (-not (Test-Path $CsvPath)) {
        throw "CSV not found: $CsvPath"
    }

    Import-Csv $CsvPath | ForEach-Object {
        Invoke-UserOffboarding -Sam $_.SamAccountName
    }
}

Write-Log "===== OFFBOARDING SESSION COMPLETED ====="
Write-Log ""
