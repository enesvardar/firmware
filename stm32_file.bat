@echo off
echo === Copying HEX file ===

set SOURCE_HEX=D:\github\solar-tracking-system-internal\Objects\solar_tracking_system_internal_acc.hex
set DEST_FOLDER=D:\github\firmware
copy /Y "%SOURCE_HEX%" "%DEST_FOLDER%"
echo HEX file copied.

echo.
echo === Retrieving and formatting version information ===

set DEFINES_FILE=D:\github\solar-tracking-system-internal\src\defines.h
set VERSION_FILE=%DEST_FOLDER%\stm32_version_info.txt

REM Search for #define APP_VERSION line and get the 3rd token
for /f "tokens=3 delims= " %%A in ('findstr /C:"#define APP_VERSION" "%DEFINES_FILE%"') do (
    set "VERSION=%%~A"
)

REM Use call to expand the variable and write to file
call echo APP_VERSION %VERSION:"=%> "%VERSION_FILE%"

echo Version information written: APP_VERSION %VERSION:"=% 
echo.
echo All operations completed.
exit