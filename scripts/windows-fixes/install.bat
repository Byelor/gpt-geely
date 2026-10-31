@echo off
chcp 65001 >nul
setlocal

:: GeelyHelp: фиксы для ГУ Geely EX2.
:: Ставит navfix, pip-fix и выдаёт разрешения приложениям.
:: Запускать двойным кликом из папки архива; adb берётся из этой же папки.

set "P=%~dp0"
set "ADB=%P%adb.exe"

echo.
echo === GeelyHelp: фиксы для ГУ ===
echo.

if exist "%ADB%" goto have_adb
where adb >nul 2>nul
if errorlevel 1 (
    echo [ERROR] adb.exe не найден ни в папке скрипта, ни в PATH.
    pause
    exit /b 1
)
set "ADB=adb"
:have_adb

set /p "IP=Введите IP-адрес ГУ (например 192.168.1.50): "
if "%IP%"=="" (
    echo [ERROR] IP не введён.
    pause
    exit /b 1
)

echo.
echo [1/4] Подключение к %IP%:5555...
"%ADB%" connect %IP%:5555
"%ADB%" wait-for-device
"%ADB%" shell echo ok >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Устройство не отвечает. Проверьте IP и что на ГУ включён adb по Wi-Fi.
    pause
    exit /b 1
)

echo.
echo [2/4] Выдача разрешений приложениям...
"%ADB%" push "%P%grant_perms.sh" /data/local/tmp/grant_perms.sh >nul
"%ADB%" shell "tr -d '\r' < /data/local/tmp/grant_perms.sh > /data/local/tmp/grant_perms_unix.sh"
"%ADB%" shell "sh /data/local/tmp/grant_perms_unix.sh"
"%ADB%" shell "rm -f /data/local/tmp/grant_perms.sh /data/local/tmp/grant_perms_unix.sh"

echo.
echo [3/4] navfix (фикс вылетов навигатора)...
"%ADB%" shell "which su" >nul 2>nul
if errorlevel 1 (
    echo [WARN] su не найден - navfix пропущен.
) else (
    "%ADB%" push "%P%navfix" /data/local/tmp/navfix >nul
    "%ADB%" push "%P%navfix_install.sh" /data/local/tmp/navfix_install.sh >nul
    "%ADB%" shell "tr -d '\r' < /data/local/tmp/navfix_install.sh > /data/local/tmp/navfix_install_unix.sh"
    "%ADB%" shell "chmod 755 /data/local/tmp/navfix_install_unix.sh"
    "%ADB%" shell "su 0 sh /data/local/tmp/navfix_install_unix.sh"
    "%ADB%" shell "rm -f /data/local/tmp/navfix /data/local/tmp/navfix_install.sh /data/local/tmp/navfix_install_unix.sh"
)

echo.
echo [4/4] pip-fix (окно "картинка в картинке")...
"%ADB%" root >nul 2>nul
timeout /t 2 /nobreak >nul
"%ADB%" wait-for-device
"%ADB%" remount >nul 2>nul
"%ADB%" shell "mkdir -p /vendor/overlay/SysuiPipOverlay"
"%ADB%" push "%P%pip-overlay.apk" /vendor/overlay/SysuiPipOverlay/pip-overlay.apk
"%ADB%" shell "chmod 644 /vendor/overlay/SysuiPipOverlay/pip-overlay.apk"

"%ADB%" shell "grep -c com.geely.overlay.systemui.pip /data/system/overlays.xml 2>/dev/null" > "%TEMP%\pip_check.txt" 2>nul
set /p EXISTS=<"%TEMP%\pip_check.txt"
del "%TEMP%\pip_check.txt" >nul 2>nul

if "%EXISTS%"=="0" goto add_pip
if "%EXISTS%"=="" goto add_pip
echo   Запись уже есть в overlays.xml - пропуск.
goto reboot

:add_pip
echo   Добавление записи в overlays.xml...
"%ADB%" shell "cp /data/system/overlays.xml /data/local/tmp/overlays.xml.bak"
"%ADB%" shell "sed 's|</overlays>|    <item packageName=\"com.geely.overlay.systemui.pip\" userId=\"0\" targetPackageName=\"com.android.systemui\" baseCodePath=\"/vendor/overlay/SysuiPipOverlay/pip-overlay.apk\" state=\"3\" isEnabled=\"true\" isStatic=\"false\" priority=\"1\" />\n</overlays>|' /data/system/overlays.xml > /data/local/tmp/overlays_pip.xml"
"%ADB%" shell "cat /data/local/tmp/overlays_pip.xml > /data/system/overlays.xml"
"%ADB%" shell "chmod 660 /data/system/overlays.xml"
"%ADB%" shell "chown system:system /data/system/overlays.xml"
"%ADB%" shell "rm -f /data/local/tmp/overlays_pip.xml"
echo   Бэкап оригинала: /data/local/tmp/overlays.xml.bak

:reboot
echo.
set /p "RB=Перезагрузить ГУ сейчас? [Y/n]: "
if /i "%RB%"=="n" goto done
"%ADB%" reboot

:done
echo.
echo Готово. Фиксы применятся после загрузки ГУ.
pause
