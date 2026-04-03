@echo off
set "DEFINES_FILE=D:\github\solar-tracking-system-internal\src\defines.h"
set "FUAR_MODE_VALUE=undefined"

REM FUAR_MODE oku
for /f "tokens=1,2,3" %%A in ('
  findstr /R /C:"^[ ]*#define.*FUAR_MODE" "%DEFINES_FILE%"
') do (
  set "FUAR_MODE_VALUE=%%C"
)

echo FUAR_MODE = %FUAR_MODE_VALUE%

REM -------- POPUP WARNING --------
if /I "%FUAR_MODE_VALUE%"=="true" (
    powershell -NoProfile -Command ^
    "Add-Type -AssemblyName System.Windows.Forms; " ^
    "[System.Windows.Forms.MessageBox]::Show(" ^
    "'FUAR MODE AKTIF!'," ^
    "'UYARI - FUAR MODE'," ^
    "[System.Windows.Forms.MessageBoxButtons]::OK," ^
    "[System.Windows.Forms.MessageBoxIcon]::Warning)"
)

exit /b
