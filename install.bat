@echo off
REM Get the directory where this script is located.
set SCRIPT_DIR=%~dp0
set LOG_FILE="%SCRIPT_DIR%sql_install_log.txt"

echo --- Starting SQL Server 2022 Installation at %date% %time% --- > %LOG_FILE%

REM --- Step 1: Mount the ISO file ---
echo Mounting SQL Server ISO... >> %LOG_FILE%
powershell -Command "Mount-DiskImage -ImagePath '%SCRIPT_DIR%SQLServer2022-x64-ENU-Dev.iso'" >> %LOG_FILE% 2>&1

REM --- Step 2: Find the drive letter of the mounted ISO ---
echo Finding drive letter... >> %LOG_FILE%
for /f "tokens=1" %%i in ('powershell -Command "(Get-DiskImage -ImagePath '%SCRIPT_DIR%SQLServer2022-x64-ENU-Dev.iso' | Get-Volume).DriveLetter"') do set ISODRIVE=%%i
echo ISO mounted to drive %ISODRIVE%: >> %LOG_FILE%

IF NOT DEFINED ISODRIVE (
    echo FAILED: Could not determine drive letter for the ISO. >> %LOG_FILE%
    exit /b 1
)

REM --- Step 3: Run the SQL Server Setup ---
echo Starting SQL Server setup... >> %LOG_FILE%
start /wait %ISODRIVE%:\setup.exe /ConfigurationFile="%SCRIPT_DIR%ConfigurationFile.ini" /Q /IAcceptSQLServerLicenseTerms

REM Check the exit code of the installer
IF %ERRORLEVEL% NEQ 0 (
    echo FAILED: SQL Server setup exited with error code %ERRORLEVEL%. >> %LOG_FILE%
) ELSE (
    echo SUCCESS: SQL Server setup completed. >> %LOG_FILE%
)

REM --- Step 4: Dismount the ISO ---
echo Dismounting SQL Server ISO... >> %LOG_FILE%
powershell -Command "Dismount-DiskImage -ImagePath '%SCRIPT_DIR%SQLServer2022-x64-ENU-Dev.iso'" >> %LOG_FILE% 2>&1

echo --- Installation script finished at %date% %time% --- >> %LOG_FILE%

exit /b 0
