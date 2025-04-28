@echo off
setlocal enabledelayedexpansion

:: === Variables ===
set "localUsername=support.admin"
set "localPassword=YourPassword123!"
set "domainUsername=YOURDOMAIN\support.admin"

:: Set log file path (replace with your file server path)
set "logpath=\\YourFileServer\SharedLogs"
set "hostname=%computername%"
for /f "tokens=2 delims==" %%i in ('"wmic os get LocalDateTime /value"') do set datetime=%%i
set "timestamp=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%_%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%"
set "logfile=%logpath%\%hostname%_%timestamp%_log.txt"

:: Write log header
powershell -Command "Add-Content -Path '%logfile%' -Value '==== Start: %date% %time% ====' -Encoding UTF8"

:: === Create local user ===
net user "%localUsername%" "%localPassword%" /add /passwordchg:no >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Add-Content -Path '%logfile%' -Value '[INFO] User already exists or an error occurred while creating.' -Encoding UTF8"
) else (
    powershell -Command "Add-Content -Path '%logfile%' -Value '[OK] Local user created successfully: %localUsername%' -Encoding UTF8"
    
    :: Set Full Name
    wmic useraccount where "Name='%localUsername%' and LocalAccount=True" set FullName="Support Admin" >nul 2>&1
    if %errorlevel% neq 0 (
        powershell -Command "Add-Content -Path '%logfile%' -Value '[ERROR] Failed to set Full Name for user.' -Encoding UTF8"
    ) else (
        powershell -Command "Add-Content -Path '%logfile%' -Value '[OK] Full Name set successfully for user: %localUsername%' -Encoding UTF8"
    )

    :: Set Description
    net user "%localUsername%" /comment:"Created automatically by GPO script." >nul 2>&1
    if %errorlevel% neq 0 (
        powershell -Command "Add-Content -Path '%logfile%' -Value '[ERROR] Failed to set Description for user.' -Encoding UTF8"
    ) else (
        powershell -Command "Add-Content -Path '%logfile%' -Value '[OK] Description set successfully for user: %localUsername%' -Encoding UTF8"
    )
)

:: === Add users to Administrators group ===
net localgroup Administrators "%localUsername%" /add >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Add-Content -Path '%logfile%' -Value '[INFO] Local user is already in Administrators group or an error occurred while adding.' -Encoding UTF8"
) else (
    powershell -Command "Add-Content -Path '%logfile%' -Value '[OK] Local user added to Administrators group: %localUsername%' -Encoding UTF8"
)

net localgroup Administrators "%domainUsername%" /add >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Add-Content -Path '%logfile%' -Value '[INFO] Domain user is already in Administrators group or an error occurred while adding.' -Encoding UTF8"
) else (
    powershell -Command "Add-Content -Path '%logfile%' -Value '[OK] Domain user added to Administrators group: %domainUsername%' -Encoding UTF8"
)

:: === Set password to never expire ===
wmic useraccount where "Name='%localUsername%' and LocalAccount=True" set PasswordExpires=False >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Add-Content -Path '%logfile%' -Value '[ERROR] Failed to set password to never expire.' -Encoding UTF8"
) else (
    powershell -Command "Add-Content -Path '%logfile%' -Value '[OK] Password never expire option set successfully for user: %localUsername%' -Encoding UTF8"
)

:: Write log footer
powershell -Command "Add-Content -Path '%logfile%' -Value '==== End: %date% %time% ====' -Encoding UTF8"

endlocal
exit
