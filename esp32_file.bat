@echo off
echo === Copying BIN file ===

set "SOURCE_BIN=D:\github\solar-tracking-system-esp32\.pio\build\esp32-s3-devkitc-1\firmware.bin"
set "DEST_FOLDER=D:\github\firmware"
copy /Y "%SOURCE_BIN%" "%DEST_FOLDER%"
echo BIN file copied.

echo.
echo === Retrieving and writing version information ===

set "DEFINES_FILE=D:\github\solar-tracking-system-esp32\src\main.cpp"
set "VERSION_FILE=%DEST_FOLDER%\esp32_version_info.txt"

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