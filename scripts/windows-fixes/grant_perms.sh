#!/system/bin/sh
# Выдаёт все runtime-разрешения всем установленным пользовательским
# приложениям. Не на всех пакетах pm grant сработает — ошибки глушим:
# для несуществующего пакета или неразрешимого права это нормально.

PERMS=$(pm list permissions -g -d | sed -n 's/.*permission:\(android\.permission\.[A-Za-z_]*\).*/\1/p')

for p in $(pm list packages -3 | cut -d: -f2); do
    for perm in $PERMS; do
        pm grant "$p" "$perm" 2>/dev/null
    done
done

echo "Permissions done."
