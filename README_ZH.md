# 🌐 Fibocom FM350 GL PCIE 驱动解决方案

---

## 🏷️ 项目概述

本解决方案针对Fibocom FM350GL 5G模块在PCIE接口下的驱动稳定性问题进行了优化：

🔹 **核心功能**:
- 🛠 基于驱动 `0.6.200.233` 版本修改
- 🔌 完整开放AT命令COM端口功能
- ⚡ 集成智能连接维护工具
- 🔋 解决低功耗状态驱动掉线问题

> 🚩 **兼容性说明**  
> **固件版本**: `81600.0000.00.29.20.01_CCC62`

---

## 🔬 技术背景

### ⚠️ 已知问题
- 驱动异常断开
- 重启无法恢复，需要手动关机再开机

### 💡 解决方案
通过发送AT命令，避免进入问题低功耗模式。

---

## 📦 安装指南

### ✅ 推荐方案
```bash
1. 获取完整驱动包
2. 使用dims++加载INF配置
3. 完成安装后重启系统
```

### 🔄 其他方案
执行 `Drivers/Install.bat` 安装脚本

---

## 🗂️ 项目结构

```tree
Drivers/                       # 🛠 驱动目录
├── FbWwanConfig/
├── FwFlashDriver/ 
├── FwUpdateDriver/            # ⚠️ 已移除
├── IntelGNSSDriver/
└── WwanNet/

Script/                         # ⚙️ 工具目录
├── Intel5GSolution5000.c
└── Intel 5G Solution 5000.exe
```

---

## 🛠️ 使用指南

### 1. 驱动验证
- 确认设备管理器显示 `Intel 5G Solution 5000`
- 验证COM端口枚举正常

### 2. 连接维护
```powershell
> Intel5GSolution5000.exe
```
💡 建议配置为系统服务自动运行

---

## 🚨 故障排查

### 🔧 驱动问题
1. 检查设备管理器错误代码
2. 使用dims++重新部署
3. 检查固件版本

---

## ⚙️ 高级配置

如需开放其他功能端口，可修改`Drivers/WwanNet/WwanNet.inf`中的注册表值：

```ini
HKR,, WWANFeatureGNSS,    %RegTypeDW%, 1   # 🛰️ 启用GNSS功能
HKR,, WWANFeatureAT,      %RegTypeDW%, 1   # 📟 启用AT命令端口
HKR,, WWANFeatureCD,      %RegTypeDW%, 0   # ⚠️ 禁用CD端口
HKR,, WWANFeatureMDLOG,   %RegTypeDW%, 0   # ⚠️ 禁用MDLOG
HKR,, WWANFeatureSAPLOG,  %RegTypeDW%, 0   # ⚠️ 禁用SAPLOG
HKR,, WWANFeatureADB,     %RegTypeDW%, 0   # ⚠️ 禁用ADB
HKR,, WWANFeatureMETASAP, %RegTypeDW%, 0   # ⚠️ 禁用METASAP
HKR,, WWANFeatureMETAMD,  %RegTypeDW%, 0   # ⚠️ 禁用METAMD
HKR,, WWANFeatureNPT,     %RegTypeDW%, 0   # ⚠️ 禁用NPT
HKR,, WWANFeatureFLASH,   %RegTypeDW%, 0   # ⚠️ 禁用FLASH
HKR,, WWANFeatureNMEA,    %RegTypeDW%, 0   # ⚠️ 禁用NMEA
```

> ⚠️ **重要提示**: 修改后需要重新安装驱动才能使配置生效

---

## 📜 许可协议

[MIT License](LICENSE) © 2025
