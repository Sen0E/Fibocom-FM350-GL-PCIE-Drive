# 📡 Fibocom FM350 GL 5G模块驱动解决方案

## 🚀 项目介绍

本解决方案针对Fibocom FM350 GL 5G模块在某些笔记本电脑上存在的驱动掉线问题，提供了完整的修复方案：

- 🛠️ 基于官网驱动修改，开放了AT端口功能
- 💻 使用C语言编写了维护脚本，可持续保持模块运行状态
- 🔌 解决了驱动异常断开和无法自动恢复的问题

## 🔍 技术细节

### 📋 设备信息
- 🔹 **设备ID**: PCI\VEN_14C3&amp;DEV_4D75
- 🔹 **驱动版本**: 0.6.200.330
- 🔹 **测试固件版本**: 81600.0000.00.29.20.01_CC C62

### 🗂️ 项目结构
```
Drivers/
├── WwanNet.inf                # 驱动配置文件
├── WwanNet.sys                # 驱动核心文件
└── ...

Script/
├── 5G Solution 5000 COM AT.exe # AT维护工具
├── 5G-Solution-5000-COM-AT.c  # AT工具源代码
└── build.bat                  # 构建脚本
```

## 使用指南

### 安装步骤
1. 卸载系统中现有的FM350 GL驱动
2. 使用[Dism++](https://github.com/Chuyu-Team/Dism-Multi-language)工具安装Drivers/目录下的驱动
3. 重启系统完成驱动安装
4. 运行`Script/5G Solution 5000 COM AT.exe`
5. 将AT工具设置为开机自启动

## 高级配置

如需开放其他功能端口，可修改`Drivers/WwanNet.inf`中的以下注册表值：

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

> ⚠️ 修改后需要重新安装驱动才能使配置生效

## 自行编译

如需修改AT工具，可按以下步骤编译：

1. 确保已安装C语言编译环境
2. 源代码位于`Script/5G-Solution-5000-COM-AT.c`
3. 运行`Script/build.bat`进行编译

## 许可协议

[MIT License](LICENSE) © 2025
