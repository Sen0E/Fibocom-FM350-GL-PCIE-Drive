@echo off
:::Auto require administrator to avoid special path limitation
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (

    echo Applying run as administrator

    goto UACPrompt

) else ( goto gotAdmin )

:UACPrompt

    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"

    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"

    exit /B

:gotAdmin

    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )

    pushd "%CD%"

    CD /D "%~dp0"
echo got admin authoright

setlocal enabledelayedexpansion
set batPath=%~dp0%

echo ############check driver is installed before or not ############
cd %~dp0%

if exist %"batPath"%device_exist.log (
	del %"batPath"%device_exist.log 1>>nul 2>>nul
)

if exist %"batPath"%driver_temp.log (
	del %"batPath"%driver_temp.log 1>>nul 2>>nul
)

if exist %"batPath"%device_status.log (
	del %"batPath"%device_status.log 1>>nul 2>>nul
)

devcon64 status "PCI\VEN_14C3&DEV_4D75" | find "matching device" >> %"batPath"%device_exist.log
for /f "tokens=1,2,3,4" %%i in (%"batPath"%device_exist.log) do set ExistDevice=%%i
echo Wwannet Exist: !ExistDevice! >> %"batPath"%MBBLog.txt
echo !ExistDevice!
if "!ExistDevice!" NEQ "1" (	
	echo "Wwannet Device NOT Exist , not install drivers !!!"
		exit
		
)

if exist %"batPath"%device_exist.log (
	del %"batPath"%device_exist.log 1>>nul 2>>nul
)
::HP
devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_8914103C" | find "matching device" >> %"batPath"%device_exist.log

::Generic
devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35001CF8" | find "matching device" >> %"batPath"%device_exist.log
::Lenovo
devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35021CF8" | find "matching device" >> %"batPath"%device_exist.log
devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35031CF8" | find "matching device" >> %"batPath"%device_exist.log
devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35051CF8" | find "matching device" >> %"batPath"%device_exist.log
devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35061CF8" | find "matching device" >> %"batPath"%device_exist.log
devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35071CF8" | find "matching device" >> %"batPath"%device_exist.log

for /f "tokens=1,2,3,4" %%i in (%"batPath"%device_exist.log) do (
	set ExistDevice=%%i
	if "!ExistDevice!" EQU "1" (
		goto break
	)
)
:break
echo Wwannet Exist: !ExistDevice!  >> %"batPath"%MBBLog.txt
if "!ExistDevice!" EQU "1" (
	echo "Wwannet Device Exist, check whether install !!"
	call "FM350_Uninstall.exe" -silent
        timeout /t 2 >> nul
	echo "Drivers have been uninstalled completely !!"
	set /a Installmethod=0
) else (	
	echo "Wwannet Device NOT Exist , install drivers at once !!"
	set /a Installmethod=1
)

if exist %"batPath"%device_exist.log (
	del %"batPath"%device_exist.log 1>>nul 2>>nul
)

::GOTO :EOF
md "C:\Windows\Wwan\Firmware"
echo ############ Install Wwannet Driver ############
:installWwannetDriver
copy "%~dp0FwUpdateDriver"\FwPackage.flz C:\Windows\Wwan\Firmware\
pnputil.exe /add-driver "%~dp0WwanNet"\WwanNet.inf /install > driver_temp.log
if %ERRORLEVEL% EQU 0 (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	echo [STEP  PASS] Install driver [WwanNet] successful !!
	echo. >> install_log.log
	echo "[STEP  PASS] Install driver [WwanNet] successful !!"
) else (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	if !DriverResult! NEQ 0 (
		echo [STEP  PASS] Install driver [WwanNet] successful !!
		echo. >> install_log.log
		echo "[STEP  PASS] Install driver [WwanNet] successful !!"
	) else (
		echo [STEP  FAIL] Install driver [WwanNet] failed !!
		echo. >> install_log.log
		echo "[STEP  FAIL] Install driver [WwanNet] failed !!"
		set /a ERRORFLAG=1
	)
)
echo. >> install_log.log
devcon64 rescan 1>>nul 2>>nul
timeout /t 2 >> nul

echo "[STEP Check] Checking the WwanNet is running or not !!"
set /a waitcounter=0

:waitforWwanNet
if %Installmethod% NEQ 1 (
	devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_8914103C" | find "Driver is" >> device_status.log
    devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35001CF8" | find "Driver is" >> device_status.log
    devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35021CF8" | find "Driver is" >> device_status.log
    devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35031CF8" | find "Driver is" >> device_status.log
    devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35051CF8" | find "Driver is" >> device_status.log
	devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35061CF8" | find "Driver is" >> device_status.log
	devcon64 status "PCI\VEN_14C3&DEV_4D75&SUBSYS_35071CF8" | find "Driver is" >> device_status.log
	for /f "tokens=1,2,3" %%i in (device_status.log) do set DeviceStatus=%%k
	
	echo "DeviceStatus : !DeviceStatus!"
	if "!DeviceStatus!" == "running." (
		call :InstallWwanComDriver
	) else (
		if %waitcounter% LEQ 10 (
			set /a waitcounter=%waitcounter% + 1
			timeout /t 1 >> nul
			call :waitforWwanNet
		) else (
			echo "[ Critical ] **********************************************"
			echo "[ Critical ] WwanNet status is abnormal, please check it !!"
			echo "[ Critical ] **********************************************"
			call :InstallWwanComDriver
		)
	)
) else (
	call :InstallWwanComDriver
)

del device_status.log 1>>nul 2>>nul

GOTO :EOF

:InstallWwanComDriver
pnputil.exe /add-driver "%~dp0WwanNet"\WwanComDriver.inf /install > driver_temp.log
if %ERRORLEVEL% EQU 0 (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	echo [STEP  PASS] Install driver [WwanComDriver] successful !!
	echo. >> install_log.log
	echo "[STEP  PASS] Install driver [WwanComDriver] successful !!"
) else (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	if !DriverResult! NEQ 0 (
		echo [STEP  PASS] Install driver [WwanComDriver] successful !!
		echo. >> install_log.log
		echo "[STEP  PASS] Install driver [WwanComDriver] successful !!"
	) else (
		echo [STEP  FAIL] Install driver [WwanComDriver] failed !!
		echo. >> install_log.log
		echo "[STEP  FAIL] Install driver [WwanComDriver] failed !!"
		set /a ERRORFLAG=1
	)
)
echo. >> install_log.log
devcon64 rescan 1>>nul 2>>nul
timeout /t 2 >> nul



:InstallGNSSDriver
pnputil.exe /add-driver "%~dp0IntelGNSSDriver"\IntelGNSSDriver.inf /install > driver_temp.log
if %ERRORLEVEL% EQU 0 (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	echo [STEP  PASS] Install driver [IntelGNSSDriver] successful !!
	echo. >> install_log.log
	echo "[STEP  PASS] Install driver [IntelGNSSDriver] successful !!"
) else (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	if !DriverResult! NEQ 0 (
		echo [STEP  PASS] Install driver [IntelGNSSDriver] successful !!
		echo. >> install_log.log
		echo "[STEP  PASS] Install driver [IntelGNSSDriver] successful !!"
	) else (
		echo [STEP  FAIL] Install driver [IntelGNSSDriver] failed !!
		echo. >> install_log.log
		echo "[STEP  FAIL] Install driver [IntelGNSSDriver] failed !!"
		set /a ERRORFLAG=1
	)
)
echo. >> install_log.log
devcon64 rescan 1>>nul 2>>nul
timeout /t 2 >> nul


echo "[STEP Check] Checking the GNSSDriver is running or not !!"
set /a waitcounter=0

:waitforGNSS
if %Installmethod% NEQ 1 (
	devcon64 status "PCI\VID_8087&PID_0B5E" | find "Driver is" > device_status.log
	for /f "tokens=1,2,3" %%i in (device_status.log) do set DeviceStatus=%%k
	
	echo "DeviceStatus : !DeviceStatus!"
	if "!DeviceStatus!" == "running." (
		call :InstallFwUpdateDriver
	) else (
		if %waitcounter% LEQ 10 (
			set /a waitcounter=%waitcounter% + 1
			timeout /t 1 >> nul
			call :waitforGNSS
		) else (
			echo "[ Critical ] **********************************************"
			echo "[ Critical ] GNSSDriver status is abnormal, please check it !!"
			echo "[ Critical ] **********************************************"
			call :InstallFwUpdateDriver
		)
	)
) else (
	call :InstallFwUpdateDriver
)

del device_status.log 1>>nul 2>>nul

GOTO :EOF

:InstallFwUpdateDriver
pnputil.exe /add-driver "%~dp0FwUpdateDriver"\FwUpdateDriver.inf /install > driver_temp.log
if %ERRORLEVEL% EQU 0 (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	echo [STEP  PASS] Install driver [FwUpdateDriver] successful !!
	echo. >> install_log.log
	echo "[STEP  PASS] Install driver [FwUpdateDriver] successful !!"
) else (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	if !DriverResult! NEQ 0 (
		echo [STEP  PASS] Install driver [FwUpdateDriver] successful !!
		echo. >> install_log.log
		echo "[STEP  PASS] Install driver [FwUpdateDriver] successful !!"
	) else (
		echo [STEP  FAIL] Install driver [FwUpdateDriver] failed !!
		echo. >> install_log.log
		echo "[STEP  FAIL] Install driver [FwUpdateDriver] failed !!"
		set /a ERRORFLAG=1
	)
)
echo. >> install_log.log
devcon64 rescan 1>>nul 2>>nul
timeout /t 2 >> nul

:InstallFbWwanConfig
pnputil.exe /add-driver "%~dp0FbWwanConfig"\fbwwanConfig.inf /install > driver_temp.log
if %ERRORLEVEL% EQU 0 (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	echo [STEP  PASS] Install driver [FbWwanConfig] successful !!
	echo. >> install_log.log
	echo "[STEP  PASS] Install driver [FbWwanConfig] successful !!"
) else (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	if !DriverResult! NEQ 0 (
		echo [STEP  PASS] Install driver [FbWwanConfig] successful !!
		echo. >> install_log.log
		echo "[STEP  PASS] Install driver [FbWwanConfig] successful !!"
	) else (
		echo [STEP  FAIL] Install driver [FbWwanConfig] failed !!
		echo. >> install_log.log
		echo "[STEP  FAIL] Install driver [FbWwanConfig] failed !!"
		set /a ERRORFLAG=1
	)
)
echo. >> install_log.log
devcon64 rescan 1>>nul 2>>nul
timeout /t 2 >> nul


:InstallFwFlashDriver
pnputil.exe /add-driver "%~dp0FwFlashDriver"\FwFlashDriver.inf /install > driver_temp.log
if %ERRORLEVEL% EQU 0 (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	echo [STEP  PASS] Install driver [FwFlashDriver] successful !!
	echo. >> install_log.log
	echo "[STEP  PASS] Install driver [FwFlashDriver] successful !!"
) else (
	for /f "tokens=*" %%a in ('find /C "up-to-date" ^< "driver_temp.log"') do set DriverResult=%%a
	type driver_temp.log >> install_log.log
	echo "Count the string "up-to-date" [!DriverResult!] !!"
	del driver_temp.log 1>>nul 2>>nul
	if !DriverResult! NEQ 0 (
		echo [STEP  PASS] Install driver [FwFlashDriver] successful !!
		echo. >> install_log.log
		echo "[STEP  PASS] Install driver [FwFlashDriver] successful !!"
	) else (
		echo [STEP  FAIL] Install driver [FwFlashDriver] failed !!
		echo. >> install_log.log
		echo "[STEP  FAIL] Install driver [FwFlashDriver] failed !!"
		set /a ERRORFLAG=1
	)
)
echo. >> install_log.log
devcon64 rescan 1>>nul 2>>nul
timeout /t 2 >> nul

echo "[STEP Check] Checking the FwFlashDriver is running or not !!"
set /a waitcounter=0

:waitforFwFlashDriver
if %Installmethod% NEQ 1 (
	devcon64 status "ACPI\INTC1073" | find "Driver is" > device_status.log
	for /f "tokens=1,2,3" %%i in (device_status.log) do set DeviceStatus=%%k
	
	echo "DeviceStatus : !DeviceStatus!"
	if "!DeviceStatus!" == "running." (
		GOTO :EOF
	) else (
		if %waitcounter% LEQ 10 (
			set /a waitcounter=%waitcounter% + 1
			timeout /t 1 >> nul
			call :waitforFwFlashDriver
		) else (
			echo "[ Critical ] **********************************************"
			echo "[ Critical ] FwFlashDriver status is abnormal, please check it !!"
			echo "[ Critical ] **********************************************"
			GOTO :EOF
		)
	)
) else (
	GOTO :EOF
)
del device_status.log 1>>nul 2>>nul

GOTO :EOF

::pause