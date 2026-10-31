@echo off
chcp 65001 >nul
setlocal

:: GeelyHelp: ViPER4Android (Viper8, без Magisk) для ГУ Geely EX2.
:: Драйвер libv4a_re.so + APK как системное приложение + регистрация
:: эффекта в audio_effects.xml/.conf. Запускать двойным кликом из папки.
:: Нужен root (su) на ГУ.

set "P=%~dp0"
set "ADB=%P%adb.exe"

echo.
echo === GeelyHelp: ViPER4Android без Magisk ===
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
echo [1/5] Подключение к %IP%:5555...
"%ADB%" connect %IP%:5555
"%ADB%" wait-for-device
"%ADB%" shell echo ok >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Устройство не отвечает. Проверьте IP и что на ГУ включён adb по Wi-Fi.
    pause
    exit /b 1
)

echo.
echo [2/5] Проверка root...
"%ADB%" shell "which su" >nul 2>nul
if errorlevel 1 (
    echo [ERROR] su не найден — без root установить ViPER нельзя.
    pause
    exit /b 1
)

echo.
echo [3/5] Определение аудио-конфига...
"%ADB%" shell "if [ -d /vendor/lib/soundfx ]; then L=/vendor/lib/soundfx; X=/vendor/etc/audio_effects.xml; C=/vendor/etc/audio_effects.conf; elif [ -d /system/lib64 ]; then L=/system/lib64/soundfx; X=/system/etc/audio_effects.xml; C=/system/etc/audio_effects.conf; else L=/system/lib/soundfx; X=/system/etc/audio_effects.xml; C=/system/etc/audio_effects.conf; fi; if [ -f $X ]; then echo xml - $L; elif [ -f $C ]; then echo conf $C $L; else echo none - $L; fi" > "%TEMP%\geely_viper_detect.txt" 2>nul

set "FMT="
set "CFG="
set "LIBDIR="
for /f "usebackq tokens=1,2,3" %%a in ("%TEMP%\geely_viper_detect.txt") do (
    set "FMT=%%a"
    set "CFG=%%b"
    set "LIBDIR=%%c"
)
del "%TEMP%\geely_viper_detect.txt" >nul 2>nul

if /i "%FMT%"=="none" (
    echo [ERROR] На устройстве не найден audio_effects.xml/.conf.
    pause
    exit /b 1
)

if /i "%FMT%"=="conf" (
    echo   Легаси-конфиг %CFG% — правлю на ПК...
    "%ADB%" pull "%CFG%" "%TEMP%\geely_viper_orig.conf" >nul
    powershell -NoProfile -ExecutionPolicy Bypass -File "%P%patch_conf.ps1" -In "%TEMP%\geely_viper_orig.conf" -Out "%P%viper_cfg_new.conf" -LibDir "%LIBDIR%"
    if errorlevel 1 (
        echo [ERROR] Не удалось подготовить %CFG%.
        pause
        exit /b 1
    )
    "%ADB%" push "%P%viper_cfg_new.conf" /data/local/tmp/viper_cfg_new.conf >nul
    del "%P%viper_cfg_new.conf" "%TEMP%\geely_viper_orig.conf" >nul 2>nul
) else (
    echo   audio_effects.xml — правка на устройстве.
)

echo.
echo [4/5] Установка (su)...
"%ADB%" push "%P%libv4a_re_armeabi-v7a.so" /data/local/tmp/ >nul
"%ADB%" push "%P%viperfx-release.apk" /data/local/tmp/ >nul
"%ADB%" push "%P%viper_install.sh" /data/local/tmp/ >nul
"%ADB%" shell "tr -d '\r' < /data/local/tmp/viper_install.sh > /data/local/tmp/viper_install_unix.sh"
"%ADB%" shell "chmod 755 /data/local/tmp/viper_install_unix.sh"
"%ADB%" shell "su 0 sh /data/local/tmp/viper_install_unix.sh"

echo.
echo [5/5] Очистка...
"%ADB%" shell "rm -f /data/local/tmp/libv4a_re_armeabi-v7a.so /data/local/tmp/viperfx-release.apk /data/local/tmp/viper_install.sh /data/local/tmp/viper_install_unix.sh /data/local/tmp/viper_cfg_new.conf"

echo.
echo Готово. Приложение появится после перезагрузки.
echo Бэкап аудио-конфига остался рядом с оригиналом (.bak).
echo.
set /p "RB=Перезагрузить ГУ сейчас? [Y/n]: "
if /i "%RB%"=="n" goto done
"%ADB%" reboot

:done
echo.
echo После загрузки: откройте Viper, включите первую (сиреневую) опцию,
echo в настройках включите «Legacy mode», запустите музыку и проверьте
echo на иконке «чипа», что Enabled: yes.
pause
