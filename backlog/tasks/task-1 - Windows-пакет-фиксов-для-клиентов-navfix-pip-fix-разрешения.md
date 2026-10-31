---
id: TASK-1
title: 'Windows-пакет фиксов для клиентов: navfix + pip-fix + разрешения'
status: Done
assignee: []
created_date: '2026-10-20 21:36'
labels: []
dependencies: []
ordinal: 1000
---



## Description

Один ZIP для Windows на странице каталога: клиент распаковывает и запускает
`install.bat` в папке. Скрипт спрашивает IP ГУ, подключается по adb, выдаёт
runtime-разрешения всем установленным приложениям, ставит navfix и pip-fix,
предлагает перезагрузку.

## Plan

- [x] Собрать `scripts/windows-fixes/`: install.bat, adb.exe + DLL (platform-tools
      Windows), navfix, pip-overlay.apk, navfix_install.sh, grant_perms.sh.
- [x] Собрать `geely-fixes.zip` (плоско, без вложенных папок).
- [x] Залить в R2: `catalog/scripts/geely-fixes.zip` (4 415 263 байт, sha256 452f8cd3…5ef1, отдаётся 200).
- [x] Секция «Скрипт для Windows» внизу `s/katalog-7f3m9p.html` с кнопкой скачивания.

План: `~/.claude/plans/windows-fixes-bundle.md`.

## Notes

- Оригиналы, с которых снята логика: `~/Desktop/newapp/heavy-apks-program/assets/
  {navfix/install_navfix.bat,pip-fix/install.bat}`, бинарники оттуда же.
- В install.bat добавлен бэкап `overlays.xml` в `/data/local/tmp` (в оригинале нет).
- Проверено статически: CRLF у .bat, LF у .sh, navfix — ELF aarch64, pip-overlay — APK.
- Страница не тронута, ZIP не собран — ждём отмашки владельца.
