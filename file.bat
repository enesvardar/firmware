@echo off
echo === HEX dosyası kopyalanıyor ===

set SOURCE_HEX=D:\github\solar-tracking-system-internal-acc\Objects\solar_tracking_system_internal_acc.hex
set DEST_FOLDER=D:\github\firmware
copy /Y "%SOURCE_HEX%" "%DEST_FOLDER%"
echo HEX dosyası kopyalandı.

echo.
echo === Sürüm bilgisi alınıyor ve formatlanıyor ===

set DEFINES_FILE=D:\github\solar-tracking-system-internal-acc\src\defines.h
set VERSION_FILE=%DEST_FOLDER%\stm32_version_info.txt

REM defines.h içinden APP_VERSION satırını bul, sadece versiyon bilgisini al
for /f "tokens=2,3 delims= " %%A in ('findstr /C:"APP_VERSION" "%DEFINES_FILE%"') do (
    REM %%A = APP_VERSION, %%B = "4.0"
    set "VERSION=%%~B"
)

REM Değeri dışarı almak için call kullan
call echo APP_VERSION %VERSION:"=%> "%VERSION_FILE%"

echo Sürüm bilgisi yazıldı: APP_VERSION %VERSION:"=%
echo.
echo Tüm işlemler tamamlandı.
exit
