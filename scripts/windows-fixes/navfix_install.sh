#!/system/bin/sh
# Ставит navfix на ГУ (запускается как: su 0 sh navfix_install.sh).
# Копия assets/navfix/install_navfix.sh из heavy-apks-program, mark99i.

mount -o remount,rw /system 2>/dev/null

echo "Copying binary..."
cp -f /data/local/tmp/navfix /system/bin/navfix
chmod 755 /system/bin/navfix
chown root:root /system/bin/navfix

echo "Creating init service..."
echo 'service navfix /system/bin/navfix apply
    class late_start
    user root
    group root
    seclabel u:r:shell:s0
    oneshot' > /system/etc/init/navfix.rc

chmod 644 /system/etc/init/navfix.rc
chown root:root /system/etc/init/navfix.rc
chcon u:object_r:system_file:s0 /system/etc/init/navfix.rc
chcon u:object_r:shell_exec:s0 /system/bin/navfix

mount -o remount,ro /system 2>/dev/null

echo "Installation Complete."
