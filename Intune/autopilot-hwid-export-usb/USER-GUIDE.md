

## 📤 Import into Microsoft Intune

After collecting the hardware hashes, upload the CSV file into Intune:

1. Open **Microsoft Intune admin center**
2. Navigate to:
   - Devices  
   - Windows  
   - Windows enrollment  
   - Windows Autopilot devices  

3. Click **Import**

4. Select your file:

HWID.csv

---

## 🖼️ Intune Import Walkthrough

### Navigate to Autopilot Devices

### Import CSV File

---

## 📊 Output Example

Device Serial Number,Windows Product ID,Hardware Hash
ABC12345,,<HASH>
XYZ67890,,<HASH>

---

## 🔄 Multi-Device Workflow

- Device 1 → creates file  
- Device 2 → appends  
- Device 3 → appends  

✔ One clean CSV  
✔ Ready for bulk import  

---

## 🛡️ Notes

- Execution policy is temporary (process only)
- No permanent system changes
- Script auto-detects USB drive location

---

## 📌 Requirements

- Internet connection
- USB drive
- Windows 10/11 device
- PowerShell access (Shift + F10)

---

## 👨‍💻 Author

**Eduardo González**  
IT Support | Microsoft 365 | Intune | Endpoint Management  

---

## ⭐ Support

If you found this useful, consider giving this repo a ⭐

---

## 📄 License

MIT
