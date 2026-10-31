#!/system/bin/sh
# Установка ViPER4Android (Viper8, без Magisk) на ГУ.
# Запускается как: su 0 sh viper_install.sh
# Логика портирована из geely-toolbox viper_re.ts (Viper8_nomagisk_by_Dmitry).

mount -o remount,rw /vendor 2>/dev/null
mount -o remount,rw /system 2>/dev/null

# --- ветка: vendor или system (и 32/64-бит) ---
if [ -d /vendor/lib/soundfx ]; then
    LIB_DIR=/vendor/lib/soundfx
    SO_CTX=u:object_r:vendor_file:s0
    CFG_XML=/vendor/etc/audio_effects.xml
    CFG_CONF=/vendor/etc/audio_effects.conf
elif [ -d /system/lib64 ]; then
    LIB_DIR=/system/lib64/soundfx
    SO_CTX=u:object_r:system_file:s0
    CFG_XML=/system/etc/audio_effects.xml
    CFG_CONF=/system/etc/audio_effects.conf
else
    LIB_DIR=/system/lib/soundfx
    SO_CTX=u:object_r:system_file:s0
    CFG_XML=/system/etc/audio_effects.xml
    CFG_CONF=/system/etc/audio_effects.conf
fi

echo "Lib dir: $LIB_DIR"

# --- A: драйвер ---
mkdir -p $LIB_DIR
mv -f /data/local/tmp/libv4a_re_armeabi-v7a.so $LIB_DIR/libv4a_re.so
chmod 644 $LIB_DIR/libv4a_re.so
chown root:root $LIB_DIR/libv4a_re.so
chcon $SO_CTX $LIB_DIR/libv4a_re.so 2>/dev/null

# --- B: APK как системное приложение ---
mkdir -p /system/app/ViPER4Android
mv -f /data/local/tmp/viperfx-release.apk /system/app/ViPER4Android/ViPER4Android.apk
chmod 644 /system/app/ViPER4Android/ViPER4Android.apk
chown root:root /system/app/ViPER4Android/ViPER4Android.apk
chmod 755 /system/app/ViPER4Android
chown root:root /system/app/ViPER4Android
chcon u:object_r:system_file:s0 /system/app/ViPER4Android/ViPER4Android.apk 2>/dev/null
chcon u:object_r:system_file:s0 /system/app/ViPER4Android 2>/dev/null

# --- C: регистрация эффекта в аудио-конфиге ---
if [ -f "$CFG_XML" ]; then
    CFG=$CFG_XML
    cp "$CFG" "$CFG.bak" 2>/dev/null
    sed -i "/v4a_standard_re/d" "$CFG"
    sed -i "/v4a_re/d" "$CFG"
    sed -i "/v4a_standard_fx/d" "$CFG"
    sed -i "/v4a_fx/d" "$CFG"
    sed -i "/<libraries>/ a\        <library name=\"v4a_re\" path=\"libv4a_re.so\"/>" "$CFG"
    sed -i "/<effects>/ a\        <effect name=\"v4a_standard_re\" library=\"v4a_re\" uuid=\"90380da3-8536-4744-a6a3-5731970e640f\"/>" "$CFG"
    chmod 644 "$CFG"
    chown root:root "$CFG"
    echo "audio_effects.xml patched."
elif [ -f /data/local/tmp/viper_cfg_new.conf ]; then
    CFG=$CFG_CONF
    mkdir -p "$(dirname "$CFG")"
    [ -f "$CFG" ] && cp "$CFG" "$CFG.bak" 2>/dev/null
    cat /data/local/tmp/viper_cfg_new.conf > "$CFG"
    chmod 644 "$CFG"
    chown root:root "$CFG"
    chcon u:object_r:system_file:s0 "$CFG" 2>/dev/null
    echo "audio_effects.conf patched."
else
    echo "WARN: аудио-конфиг не найден — эффект не зарегистрирован."
fi

mount -o remount,ro /system 2>/dev/null
mount -o remount,ro /vendor 2>/dev/null
echo "ViPER install complete."
