# 👤 Active Directory User Offboarding Tool

![PowerShell](https://img.shields.io/badge/PowerShell-Automation-blue)
![Active Directory](https://img.shields.io/badge/Active%20Directory-Management-green)
![Windows](https://img.shields.io/badge/Windows-Server-lightgrey)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 🚀 Overview

This PowerShell script automates the offboarding process for Active Directory users.

It supports both:

- Single user offboarding  
- Bulk offboarding via CSV  

Designed for IT administrators to standardize and automate user deprovisioning tasks in a secure and consistent way.

---

## 🎯 Key Features

- Supports **single and bulk operations**
- Removes group memberships (except Domain Users)
- Resets password to a secure random value
- Disables the account
- Hides user from the Global Address List (GAL)
- Updates account description with audit information
- Optional OU relocation
- Detailed logging for auditing and troubleshooting

---

## ⚙️ Requirements

- Windows PowerShell 5.1+
- Active Directory PowerShell module
- Appropriate permissions to:
  - Modify users
  - Reset passwords
  - Remove group memberships
  - Move objects

---

## 🔐 Usage

### Single User

```powershell
.\Offboard-ADUsers.ps1 -SamAccountName jsmith
```

### Single User (Move to OU)

```powershell
.\Offboard-ADUsers.ps1 -SamAccountName jsmith -MoveToTargetOU -TargetOU "OU=Disabled Users,DC=contoso,DC=com"
```

### Bulk Users

```powershell
.\Offboard-ADUsers.ps1 -CsvPath .\sample-users.csv
```

### Bulk Users (Move to OU)

```powershell
.\Offboard-ADUsers.ps1 -CsvPath .\sample-users.csv -MoveToTargetOU -TargetOU "OU=Disabled Users,DC=contoso,DC=com"
```

## ▶️ Running the Script

If script execution is restricted on your system, run the following command in PowerShell before executing:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## 📄 CSV Format

```csv
SamAccountName
jsmith
mjones
abrown
```

---

## 📊 What the Script Does

For each user, the script:

- Updates `mailNickname`
- Removes all group memberships except **Domain Users**
- Hides the user from the GAL
- Updates the description with timestamp and operator
- Resets the password to a secure random value
- Disables the account (if not already disabled)
- Optionally moves the account to a target OU

---

## 📋 Example Output

```text
Processing user: jsmith
mailNickname updated
Removed from group: HR-Team
Hidden from GAL
Description updated
Password reset to random value
Account disabled
User kept in current OU
Completed offboarding for jsmith
```
## 📁 Log File

A detailed log file is automatically created for auditing and troubleshooting:

C:\Users\<YourUser>\Desktop\OffboardingLogs\Offboarding_Log_YYYY-MM.txt

---

## ⚠️ Production Safety Notice

This script makes **direct changes to Active Directory user accounts**.

Actions performed include:

- Removing group memberships
- Resetting passwords
- Disabling accounts
- Modifying user attributes
- Optionally moving users to another OU

### Before using in production:

- Test with non-production users first  
- Validate the CSV input file  
- Confirm the target OU path  
- Ensure you have appropriate permissions  
- Review your organization’s offboarding policy  

⚠️ Use with caution — this script is designed for administrative use in controlled environments.

---

## 🛡️ Security Considerations

- Passwords are reset to a **random value**
- Passwords are **not displayed or logged**
- Script is safe to re-run (idempotent behavior)
- Logging provides traceability for actions performed

---

## 👨‍💻 Author

**Eduardo González**  
IT Support | Microsoft 365 | Active Directory | Automation  

---

## ⭐ Support

If you find this useful, consider giving this repo a ⭐

---

## 📄 License

MIT
