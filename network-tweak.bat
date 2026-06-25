@echo off
setlocal EnableDelayedExpansion
title Windows 10 Network Tweak Tool
color 0A

:MENU
cls
echo ============================================================
echo         Windows 10 Network Tweak Tool
echo         Run as Administrator for full functionality
echo ============================================================
echo.
echo  [1]  Flush DNS Cache
echo  [2]  Reset TCP/IP Stack
echo  [3]  Reset Winsock
echo  [4]  Release and Renew IP Address
echo  [5]  Disable/Enable Network Adapter
echo  [6]  Set DNS to Google (8.8.8.8 / 8.8.4.4)
echo  [7]  Set DNS to Cloudflare (1.1.1.1 / 1.0.0.1)
echo  [8]  Restore Default DNS (DHCP)
echo  [9]  Optimize TCP/IP Settings (Gaming/Speed)
echo  [10] Disable Windows Auto-Tuning
echo  [11] Enable Windows Auto-Tuning
echo  [12] Disable Large Send Offload (LSO)
echo  [13] Enable QoS Packet Scheduler
echo  [14] Show Current Network Info
echo  [15] Run Network Diagnostics (netsh diag)
echo  [16] Ping Test (Google DNS)
echo  [17] Apply ALL Recommended Tweaks
echo  [0]  Exit
echo.
set /p CHOICE="  Enter option: "

if "%CHOICE%"=="1"  goto FLUSH_DNS
if "%CHOICE%"=="2"  goto RESET_TCPIP
if "%CHOICE%"=="3"  goto RESET_WINSOCK
if "%CHOICE%"=="4"  goto RENEW_IP
if "%CHOICE%"=="5"  goto TOGGLE_ADAPTER
if "%CHOICE%"=="6"  goto DNS_GOOGLE
if "%CHOICE%"=="7"  goto DNS_CLOUDFLARE
if "%CHOICE%"=="8"  goto DNS_DHCP
if "%CHOICE%"=="9"  goto OPTIMIZE_TCPIP
if "%CHOICE%"=="10" goto DISABLE_AUTOTUNING
if "%CHOICE%"=="11" goto ENABLE_AUTOTUNING
if "%CHOICE%"=="12" goto DISABLE_LSO
if "%CHOICE%"=="13" goto ENABLE_QOS
if "%CHOICE%"=="14" goto SHOW_NET_INFO
if "%CHOICE%"=="15" goto NET_DIAG
if "%CHOICE%"=="16" goto PING_TEST
if "%CHOICE%"=="17" goto APPLY_ALL
if "%CHOICE%"=="0"  goto EXIT
echo  Invalid option. Try again.
timeout /t 2 >nul
goto MENU

:: -------------------------------------------------------
:FLUSH_DNS
cls
echo [*] Flushing DNS Cache...
ipconfig /flushdns
echo [*] Registering DNS...
ipconfig /registerdns
echo.
echo Done.
pause
goto MENU

:: -------------------------------------------------------
:RESET_TCPIP
cls
echo [*] Resetting TCP/IP Stack...
netsh int ip reset resetlog.txt
netsh int ipv4 reset
netsh int ipv6 reset
echo.
echo Done. A restart may be required for changes to take full effect.
pause
goto MENU

:: -------------------------------------------------------
:RESET_WINSOCK
cls
echo [*] Resetting Winsock...
netsh winsock reset catalog
echo.
echo Done. A restart is required for changes to take full effect.
pause
goto MENU

:: -------------------------------------------------------
:RENEW_IP
cls
echo [*] Releasing IP Address...
ipconfig /release
echo [*] Renewing IP Address...
ipconfig /renew
echo.
echo Done.
pause
goto MENU

:: -------------------------------------------------------
:TOGGLE_ADAPTER
cls
echo [*] Available Network Adapters:
echo.
netsh interface show interface
echo.
set /p ADAPTER="  Enter adapter name (e.g. Wi-Fi or Ethernet): "
echo.
echo  [1] Disable   [2] Enable
set /p TOGGLE="  Choice: "
if "%TOGGLE%"=="1" (
    netsh interface set interface "%ADAPTER%" admin=disabled
    echo [*] Adapter "%ADAPTER%" disabled.
) else if "%TOGGLE%"=="2" (
    netsh interface set interface "%ADAPTER%" admin=enabled
    echo [*] Adapter "%ADAPTER%" enabled.
) else (
    echo Invalid choice.
)
echo.
pause
goto MENU

:: -------------------------------------------------------
:DNS_GOOGLE
cls
echo [*] Available Network Adapters:
netsh interface show interface
echo.
set /p ADAPTER="  Enter adapter name to update DNS (e.g. Wi-Fi or Ethernet): "
echo [*] Setting primary DNS to 8.8.8.8 (Google)...
netsh interface ipv4 set dns name="%ADAPTER%" static 8.8.8.8 primary
echo [*] Setting secondary DNS to 8.8.4.4...
netsh interface ipv4 add dns name="%ADAPTER%" 8.8.4.4 index=2
echo.
echo Done.
pause
goto MENU

:: -------------------------------------------------------
:DNS_CLOUDFLARE
cls
echo [*] Available Network Adapters:
netsh interface show interface
echo.
set /p ADAPTER="  Enter adapter name to update DNS (e.g. Wi-Fi or Ethernet): "
echo [*] Setting primary DNS to 1.1.1.1 (Cloudflare)...
netsh interface ipv4 set dns name="%ADAPTER%" static 1.1.1.1 primary
echo [*] Setting secondary DNS to 1.0.0.1...
netsh interface ipv4 add dns name="%ADAPTER%" 1.0.0.1 index=2
echo.
echo Done.
pause
goto MENU

:: -------------------------------------------------------
:DNS_DHCP
cls
echo [*] Available Network Adapters:
netsh interface show interface
echo.
set /p ADAPTER="  Enter adapter name to restore DHCP DNS (e.g. Wi-Fi or Ethernet): "
echo [*] Restoring DNS to automatic (DHCP)...
netsh interface ipv4 set dns name="%ADAPTER%" dhcp
echo.
echo Done.
pause
goto MENU

:: -------------------------------------------------------
:OPTIMIZE_TCPIP
cls
echo [*] Applying TCP/IP optimizations for speed and gaming...
echo.
:: Disable Nagle's algorithm (reduces latency for small packets)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1
:: Set TTL to 64
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f >nul 2>&1
:: Increase max connections
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 65534 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 30 /f >nul 2>&1
:: Disable TCP timestamps (slight speed gain)
netsh int tcp set global timestamps=disabled >nul 2>&1
echo [+] TcpAckFrequency    = 1 (low latency)
echo [+] TCPNoDelay         = 1 (disable Nagle)
echo [+] DefaultTTL         = 64
echo [+] MaxUserPort        = 65534
echo [+] TcpTimedWaitDelay  = 30
echo [+] TCP Timestamps     = Disabled
echo.
echo Done. Restart recommended.
pause
goto MENU

:: -------------------------------------------------------
:DISABLE_AUTOTUNING
cls
echo [*] Disabling Windows TCP Auto-Tuning...
netsh int tcp set global autotuninglevel=disabled
echo.
echo Done.
pause
goto MENU

:: -------------------------------------------------------
:ENABLE_AUTOTUNING
cls
echo [*] Enabling Windows TCP Auto-Tuning (normal)...
netsh int tcp set global autotuninglevel=normal
echo.
echo Done.
pause
goto MENU

:: -------------------------------------------------------
:DISABLE_LSO
cls
echo [*] Disabling Large Send Offload (LSO) via registry...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DisableTaskOffload" /t REG_DWORD /d 1 /f
echo.
echo Done. Restart required.
pause
goto MENU

:: -------------------------------------------------------
:ENABLE_QOS
cls
echo [*] Enabling QoS Packet Scheduler via registry...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f
echo [+] QoS bandwidth reservation set to 0%% (full bandwidth available to apps)
echo.
echo Done.
pause
goto MENU

:: -------------------------------------------------------
:SHOW_NET_INFO
cls
echo ============================================================
echo   Current Network Configuration
echo ============================================================
ipconfig /all
echo.
echo ============================================================
echo   Active TCP Connections
echo ============================================================
netstat -an | more
echo.
pause
goto MENU

:: -------------------------------------------------------
:NET_DIAG
cls
echo [*] Running Network Shell Diagnostics...
echo.
netsh diag show all 2>nul
if %errorlevel% neq 0 (
    echo [!] netsh diag is not available on this Windows version.
    echo [*] Running basic connectivity check instead...
    echo.
    ping 8.8.8.8 -n 4
    tracert -d -h 10 8.8.8.8
)
echo.
pause
goto MENU

:: -------------------------------------------------------
:PING_TEST
cls
echo [*] Pinging Google DNS (8.8.8.8)...
ping 8.8.8.8 -n 10
echo.
echo [*] Pinging Cloudflare DNS (1.1.1.1)...
ping 1.1.1.1 -n 10
echo.
pause
goto MENU

:: -------------------------------------------------------
:APPLY_ALL
cls
echo ============================================================
echo   Applying ALL Recommended Network Tweaks
echo ============================================================
echo.
echo [1/6] Flushing DNS...
ipconfig /flushdns >nul
ipconfig /registerdns >nul
echo  Done.

echo [2/6] Resetting TCP/IP Stack...
netsh int ip reset >nul 2>&1
echo  Done.

echo [3/6] Resetting Winsock...
netsh winsock reset >nul 2>&1
echo  Done.

echo [4/6] Applying TCP/IP Registry Tweaks...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 65534 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 30 /f >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
echo  Done.

echo [5/6] Disabling TCP Auto-Tuning...
netsh int tcp set global autotuninglevel=disabled >nul 2>&1
echo  Done.

echo [6/6] Releasing and Renewing IP Address...
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
echo  Done.

echo.
echo ============================================================
echo   All tweaks applied. A RESTART is recommended.
echo ============================================================
echo.
pause
goto MENU

:: -------------------------------------------------------
:EXIT
cls
echo Goodbye!
timeout /t 2 >nul
exit
