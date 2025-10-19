# 📡 Fibocom FM350 GL 5G Module Driver Solution

## 🚀 Project Overview

This solution provides a complete fix for the driver disconnection issue of Fibocom FM350 GL 5G module on some laptops:

- 🛠️ Modified from official driver with AT port functionality enabled
- 💻 Maintenance script written in C to keep the module running
- 🔌 Solved driver abnormal disconnection and auto-recovery issues

## 🔍 Technical Details

### 📋 Device Information
- 🔹 **Device ID**: PCI\VEN_14C3&amp;DEV_4D75
- 🔹 **Driver Version**: 0.6.200.330
- 🔹 **Tested Firmware Version**: 81600.0000.00.29.20.01_CC C62

### 🗂️ Project Structure
```
Drivers/
├── WwanNet.inf                # Driver configuration
├── WwanNet.sys                # Driver core file
└── ...

Script/
├── 5G Solution 5000 COM AT.exe # AT maintenance tool
├── 5G-Solution-5000-COM-AT.c  # AT tool source code
└── build.bat                  # Build script
```

## Usage Guide

### Installation Steps
1. Uninstall existing FM350 GL driver
2. Use [Dism++](https://github.com/Chuyu-Team/Dism-Multi-language) to install drivers from Drivers/ directory
3. Reboot system to complete installation
4. Run `Script/5G Solution 5000 COM AT.exe`
5. Set AT tool to auto-start on boot

## Advanced Configuration

To enable additional features, modify these registry values in `Drivers/WwanNet.inf`:

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

> ⚠️ Driver reinstallation is required after modification

## Build from Source

To modify AT tool, follow these steps:

1. Ensure C compiler environment is installed
2. Source code is in `Script/5G-Solution-5000-COM-AT.c`
3. Run `Script/build.bat` to compile

## License

[MIT License](LICENSE) © 2025
