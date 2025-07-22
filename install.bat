@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

::————————————————————————————
:: Configuration (can be overridden via command‑line)
::————————————————————————————
set "SCRIPT_DIR=%~dp0"
set "ISO_NAME=SQLServer2022-x64-ENU-Dev.iso"
set "CONFIG_NAME=ConfigurationFile.ini"
set "LOG_FILE=%SCRIPT_DIR%sql_install_log.txt"
set "ISO_PATH=%SCRIPT_DIR%%ISO_NAME%"
set "CONFIG_PATH=%SCRIPT_DIR%%CONFIG_NAME%"

::————————————————————————————
:: Functions
::————————————————————————————
:Log
rem %~1 = level (INFO, WARN, ERROR); %~2 = message
for /f "tokens=1-4 delims=/:. " %%a in ("%date% %time%") do set "TS=%%a/%%b/%%c %%d"
echo [!TS!] [%~1] %~2>>"%LOG_FILE%"
exit /b 0

:CheckAdmin
net session >nul 2>&1
if errorlevel 1 (
    call :Log ERROR "This script must be run elevated (as Administrator)."
    echo ERROR: Please re-run as Administrator.
    exit /b 1
)
exit /b 0

:Cleanup
if defined ISODRIVE (
    call :Log INFO "Dismounting ISO from drive !ISODRIVE!."
    powershell -NoProfile -Command "Try { Dismount-DiskImage -ImagePath '%ISO_PATH%' -ErrorAction Stop } Catch { Exit 1 }"
    if errorlevel 1 (
        call :Log WARN "Failed to dismount ISO; you may need to do it manually."
    ) else (
        call :Log INFO "ISO dismounted successfully."
    )
)
exit /b 0

::————————————————————————————
:: Start Logging
::————————————————————————————
>"%LOG_FILE%" echo ------------------------------------------------------------ 
>>"%LOG_FILE%" echo Starting SQL Server 2022 installation: %date% %time%
call :Log INFO "Parameters: ISO='%ISO_PATH%', Config='%CONFIG_PATH%'"

::————————————————————————————
:: 1) Ensure ISO and config exist
::————————————————————————————
if not exist "%ISO_PATH%" (
    call :Log ERROR "ISO not found at '%ISO_PATH%'."
    echo ERROR: ISO file missing.
    exit /b 1
)
if not exist "%CONFIG_PATH%" (
    call :Log ERROR "Configuration file not found at '%CONFIG_PATH%'."
    echo ERROR: Configuration file missing.
    exit /b 1
)
call :Log INFO "Found ISO and configuration file."

::————————————————————————————
:: 2) Elevation check
::————————————————————————————
call :CheckAdmin
if errorlevel 1 exit /b 1
call :Log INFO "Running with elevated privileges."

::————————————————————————————
:: 3) Mount the ISO
::————————————————————————————
call :Log INFO "Mounting ISO..."
powershell -NoProfile -Command "Try { Mount-DiskImage -ImagePath '%ISO_PATH%' -ErrorAction Stop } Catch { Exit 1 }" >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :Log ERROR "Failed to mount ISO."
    goto Cleanup
)
call :Log INFO "ISO mounted."

::————————————————————————————
:: 4) Detect drive letter
::————————————————————————————
for /f "usebackq tokens=1" %%D in (`powershell -NoProfile -Command "(Get-DiskImage -ImagePath '%ISO_PATH%' | Get-Volume).DriveLetter"`) do set "ISODRIVE=%%D"
if not defined ISODRIVE (
    call :Log ERROR "Could not determine ISO drive letter."
    goto Cleanup
)
call :Log INFO "ISO drive letter is !ISODRIVE!:"

::————————————————————————————
:: 5) Install SQL Server
::————————————————————————————
set "SETUP_EXE=!ISODRIVE!:\\setup.exe"
if not exist "!SETUP_EXE!" (
    call :Log ERROR "Setup executable not found at '!SETUP_EXE!'."
    goto Cleanup
)
call :Log INFO "Launching SQL Server setup..."
start "" /wait "!SETUP_EXE!" /ConfigurationFile="%CONFIG_PATH%" /Q /IAcceptSQLServerLicenseTerms >>"%LOG_FILE%" 2>&1

if errorlevel 1 (
    call :Log ERROR "SQL Server setup failed with exit code %ERRORLEVEL%."
    goto Cleanup
) else (
    call :Log INFO "SQL Server setup completed successfully."
)

::————————————————————————————
:: 6) Dismount and finish
::————————————————————————————
call :Cleanup
call :Log INFO "Installation script finished: %date% %time%"
echo Installation completed. See log at "%LOG_FILE%".
ENDLOCAL
exit /b 0
