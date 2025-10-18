# 🌐 Fibocom FM350 GL PCIE Driver Solution

🌐 [中文文档](README_ZH.md)

---

## 🏷️ Project Overview

This solution provides optimized drivers for Fibocom FM350GL 5G module on PCIE interface:

🔹 **Key Features**:
- 🛠 Modified based on driver version `0.6.200.233`
- 🔌 Full AT command COM port functionality
- ⚡ Integrated smart connection maintenance tool
- 🔋 Fixed driver disconnection in low power state

> 🚩 **Compatibility Note**  
> **Firmware Version**: `81600.0000.00.29.20.01_CCC62`

---

## 🔬 Technical Background

### ⚠️ Known Issues
- Driver abnormal disconnection
- Requires manual power cycle to recover after reboot

### 💡 Solution
Avoid problematic low power mode by sending AT commands.

---

## 📦 Installation Guide

### ✅ Recommended Method
```bash
1. Get the complete driver package
2. Use dims++ to load INF configuration
3. Restart system after installation
```

### 🔄 Alternative Method
Run `Drivers/Install.bat` installation script

---

## 🗂️ Project Structure

```tree
Drivers/                       # 🛠 Driver directory
├── FbWwanConfig/
├── FwFlashDriver/ 
├── FwUpdateDriver/            # ⚠️It has been removed
├── IntelGNSSDriver/
└── WwanNet/

Script/                         # ⚙️ Tool directory
├── Intel5GSolution5000.c
└── Intel 5G Solution 5000.exe
```

---

## 🛠️ Usage Guide

### 1. Driver Verification
- Confirm `Intel 5G Solution 5000` appears in Device Manager
- Verify COM port enumeration is normal

### 2. Connection Maintenance
```powershell
> Intel5GSolution5000.exe
```
💡 Recommended to configure as auto-run system service

---

## 🚨 Troubleshooting

### 🔧 Driver Issues
1. Check error code in Device Manager
2. Redeploy using dims++
3. Verify firmware version

---

## ⚙️ Advanced Configuration

To enable additional features, modify registry values in `Drivers/WwanNet/WwanNet.inf`:

```ini
HKR,, WWANFeatureGNSS,    %RegTypeDW%, 1   # 🛰️ Enable GNSS
HKR,, WWANFeatureAT,      %RegTypeDW%, 1   # 📟 Enable AT command port
HKR,, WWANFeatureCD,      %RegTypeDW%, 0   # ⚠️ Disable CD port
HKR,, WWANFeatureMDLOG,   %RegTypeDW%, 0   # ⚠️ Disable MDLOG
HKR,, WWANFeatureSAPLOG,  %RegTypeDW%, 0   # ⚠️ Disable SAPLOG
HKR,, WWANFeatureADB,     %RegTypeDW%, 0   # ⚠️ Disable ADB
HKR,, WWANFeatureMETASAP, %RegTypeDW%, 0   # ⚠️ Disable METASAP
HKR,, WWANFeatureMETAMD,  %RegTypeDW%, 0   # ⚠️ Disable METAMD
HKR,, WWANFeatureNPT,     %RegTypeDW%, 0   # ⚠️ Disable NPT
HKR,, WWANFeatureFLASH,   %RegTypeDW%, 0   # ⚠️ Disable FLASH
HKR,, WWANFeatureNMEA,    %RegTypeDW%, 0   # ⚠️ Disable NMEA
```

> ⚠️ **Important**: Driver reinstallation is required after modification

---

## 📜 License

[MIT License](LICENSE) © 2025
