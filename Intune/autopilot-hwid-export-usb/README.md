# 🔧 Windows Autopilot HWID Export Tool (USB + OOBE)

![PowerShell](https://img.shields.io/badge/PowerShell-Ready-blue)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-green)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-purple)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 🚀 Overview

A simple and efficient solution to collect **Windows Autopilot hardware hashes (HWID)** directly from the **Out-of-Box Experience (OOBE)** using a USB drive.

Designed for IT professionals who need a fast and repeatable method to prepare devices for **Microsoft Intune Autopilot deployment**.

---

## 🎯 Key Features

- Works directly from OOBE (Shift + F10)
- No need to complete Windows setup
- Automatically installs the required Microsoft script
- Creates or appends to a single CSV file
- Prevents duplicate headers
- USB-based portable workflow
- Supports multi-device collection

---

## 🧠 How It Works

The script uses Microsoft’s official:

Get-WindowsAutopilotInfo.ps1

To:
1. Collect device hardware hash
2. Save it temporarily
3. Create or append to `HWID.csv`
4. Store it on the USB drive

---

## ⚡ Quick Start

1. Copy the files to a USB drive  
2. Boot the device to the **Windows OOBE screen**  
3. Press **Shift + F10** to open Command Prompt  
4. Navigate to the USB drive (example: `E:`)  
5. Run:

GetHash.bat

6. Wait for the script to complete  

7. The file will be created:

HWID.csv

8. Repeat the process for each device - All hardware hashes will be appended to the same file  

9. Upload the file to Intune: Devices → Windows → Windows enrollment → Windows Autopilot devices → Import

---

For a detailed walkthrough, see 👉 USER-GUIDE.md