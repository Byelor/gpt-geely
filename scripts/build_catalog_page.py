#!/usr/bin/env python3
"""Собирает служебную страницу каталога APK (s/katalog-*.html).

Источники: ~/.r2-env (доступ к бакету) и манифест geelyProject
(distribution/catalog.json — единственное место, где есть названия,
версии и описания). Размер и наличие файла проверяются по листингу R2,
поэтому «битые» ссылки в страницу не попадают.

Запуск: python3 scripts/build_catalog_page.py
После новых APK — перезапустить и закоммитить s/katalog-*.html.
"""
import argparse
import hashlib
import html
import json
import re
import sys
from pathlib import Path
from urllib.parse import quote

PUBLIC = "https://files.geelyhelp.by"
CATEGORIES = ["приложения", "хаб", "для машины", "виджеты", "утилиты", "мультимедиа", "навигаторы"]
HEADER = """  <header class="header" id="header">
    <div class="container header__inner">
      <a class="logo" href="../index.html" aria-label="Geely Help Minsk — на главную страницу">
        <span class="logo__mark" aria-hidden="true">G</span>
        <span class="logo__text">Geely Help<em> Minsk</em></span>
      </a>
      <nav class="nav" id="nav" aria-label="Основная навигация">
        <a href="../index.html#benefits">Возможности</a>
        <a href="../index.html#compat">Совместимость</a>
        <a href="../index.html#demo">До/после</a>
        <a href="../index.html#safety">Безопасность</a>
        <a href="../index.html#prices">Цены</a>
        <a href="../index.html#contacts">Контакты</a>
        <a href="../index.html#faq">Вопросы</a>
      </nav>
      <a class="btn btn--primary btn--header" href="https://t.me/geelyhelpoff" target="_blank" rel="noopener">Записаться</a>
      <button class="burger" type="button" aria-expanded="false" aria-controls="nav" aria-label="Открыть меню">
        <span class="burger__box" aria-hidden="true"><i></i><i></i></span>
      </button>
    </div>
  </header>"""
FOOTER = """  <footer class="footer">
    <div class="container">
      <div class="footer__bottom">
        <p>© <span id="year">2026</span> Geely Help Minsk · Минск</p>
        <p>Каталог приложений</p>
      </div>
    </div>
  </footer>

  <script src="../script.js" defer></script>"""


def read_env(path: Path) -> dict:
    """~/.r2-env — не POSIX-sh (кириллица в значениях), парсим построчно."""
    env = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        m = re.match(r'(?:export\s+)?([A-Z0-9_]+)\s*=\s*"?(.*?)"?\s*$', line.strip())
        if m:
            env[m.group(1)] = m.group(2)
    return env


def list_bucket(env: dict) -> dict:
    import boto3
    from botocore.config import Config

    s3 = boto3.client(
        "s3",
        endpoint_url=f"https://{env['R2_ACCOUNT_ID']}.r2.cloudflarestorage.com",
        aws_access_key_id=env["R2_ACCESS_KEY_ID"],
        aws_secret_access_key=env["R2_SECRET_ACCESS_KEY"],
        region_name="auto",
        config=Config(signature_version="s3v4"),
    )
    objects = {}
    for page in s3.get_paginator("list_objects_v2").paginate(Bucket=env["R2_BUCKET"]):
        for obj in page.get("Contents", []):
            objects[obj["Key"]] = obj["Size"]
    return objects


def resolve_key(app: dict, objects: dict) -> str | None:
    """Манифест → реальный ключ в R2. Часть записей ссылается на старые
    имена com.geelyhelp.*, в бакете лежат com.geelyhub.*."""
    key = app["file"] if app["file"].startswith("catalog/") else "catalog/" + app["file"]
    # последний кандидат — файл в корне бакета (voiceshort.apk, GeelyHelpVoice-*.apk:
    # их раздаёт app.html, дублировать под catalog/ не нужно)
    for candidate in (key, key.replace("com.geelyhelp.", "com.geelyhub."), app["file"]):
        if candidate in objects:
            return candidate
    return None


def human_size(size: int) -> str:
    return f"{size / 1048576:.1f} МБ".replace(".", ",") if size >= 1048576 else f"{size / 1024:.0f} КБ"


def card(app: dict, key: str, size: int, objects: dict) -> str:
    label = html.escape(app["label"])
    icon_key = key[:-4] + ".png"
    icon = ""
    if icon_key in objects:
        icon = f'<img src="{PUBLIC}/{quote(icon_key)}" alt="" loading="lazy" onerror="this.remove()">'
    letter = html.escape(next((c for c in app["label"] if c.isalnum()), "#").upper())
    meta = " · ".join(x for x in (app.get("version"), human_size(size)) if x)
    return f"""        <article class="apps-card">
          <span class="apps-card__ic" data-l="{letter}" aria-hidden="true">{icon}</span>
          <h3 class="apps-card__name">{label}</h3>
          <p class="apps-card__meta">{html.escape(meta)}</p>
          <p class="apps-card__desc">{html.escape(app.get("description", ""))}</p>
          <a class="btn btn--primary apps-card__btn" href="{PUBLIC}/{quote(key)}" download>Скачать APK</a>
        </article>"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path,
                        default=Path.home() / "vscodeProjects/geelyProject/distribution/catalog.json")
    parser.add_argument("--out", type=Path,
                        default=Path(__file__).resolve().parent.parent / "s/katalog-7f3m9p.html")
    parser.add_argument("--force", action="store_true", help="перезаписать правки, сделанные руками")
    args = parser.parse_args()

    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    objects = list_bucket(read_env(Path.home() / ".r2-env"))

    groups, skipped, no_icon = {}, [], 0
    for app in manifest["apps"]:
        category = app.get("category")
        if category == "central-exauto" or not app.get("file"):
            continue
        if category not in CATEGORIES:
            skipped.append(f"{app['label']} (категория «{category}»)")
            continue
        key = resolve_key(app, objects)
        if not key:
            skipped.append(f"{app['label']} (файла нет в R2)")
            continue
        groups.setdefault(category, []).append(card(app, key, objects[key], objects))
        no_icon += (key[:-4] + ".png") not in objects

    sections = []
    for category in CATEGORIES:
        if category not in groups:
            continue
        cards = "\n".join(groups[category])
        sections.append(f"""    <section class="apps-sec">
      <div class="container">
        <h2 class="apps-sec__h">{html.escape(category.capitalize())} <span class="apps-sec__n">{len(groups[category])}</span></h2>
        <div class="apps-grid">
{cards}
        </div>
      </div>
    </section>""")

    total = sum(len(v) for v in groups.values())
    page = f"""<!DOCTYPE html>
<html lang="ru">
<!-- Служебная страница для клиентов. Генерируется scripts/build_catalog_page.py
     из манифеста geelyProject; правки руками переживут сборку: без --force
     генератор откажется перезаписывать изменённый файл. -->
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <meta name="robots" content="noindex,nofollow"/>
  <title>Каталог приложений — Geely EX2</title>
  <meta name="color-scheme" content="light dark"/>
  <link rel="icon" href="../img/icon.png"/>
  <link rel="stylesheet" href="../styles.css"/>
  <script>document.documentElement.classList.add('js');</script>
</head>
<body>
  <a class="skip-link" href="#main">Перейти к содержимому</a>

{HEADER}

  <main id="main">
    <section class="apps-head">
      <div class="container">
        <h1>Приложения для Geely EX2</h1>
        <p class="apps-head__lead">Скачайте APK и откройте файл на экране автомобиля. Если приложение
        уже установлено — сначала обновите каталог на ГУ.</p>
      </div>
    </section>

{chr(10).join(sections)}
  </main>

{FOOTER}
</body>
</html>
"""
    args.out.parent.mkdir(parents=True, exist_ok=True)
    # Страница правится руками (порядок, тексты) — без --force не затираем
    # изменения, сделанные после последней сборки.
    guard = args.out.with_name(args.out.name + ".sha256")
    if args.out.exists() and not args.force:
        last = guard.read_text().strip() if guard.exists() else None
        if last != hashlib.sha256(args.out.read_bytes()).hexdigest():
            sys.exit(f"{args.out} изменён после последней сборки — не перезаписываю.\n"
                     f"Сохрани правки или запусти с --force (они будут потеряны).")
    args.out.write_text(page, encoding="utf-8")
    guard.write_text(hashlib.sha256(page.encode()).hexdigest() + "\n")
    print(f"готово: {total} приложений, {len(groups)} категорий, без иконки {no_icon} → {args.out}")
    for item in skipped:
        print(f"  пропущено: {item}")


if __name__ == "__main__":
    main()
