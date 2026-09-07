/* ============================================================================
   GEELY HELP MINSK — скрипты страницы
   ----------------------------------------------------------------------------
   СОДЕРЖАНИЕ (быстрый поиск по слову «БЛОК»):

     БЛОК 1  CONFIG — настройки страницы, которые можно менять
     БЛОК 2  Шапка: уплотнение и «стекло» при прокрутке
     БЛОК 3  Мобильное меню (бургер)
     БЛОК 4  Появление блоков при прокрутке (.reveal)
     БЛОК 5  Параллакс картинки в hero
     БЛОК 6  Аккордеон FAQ
     БЛОК 7  Слайдер «До / После»
     БЛОК 8  Год в футере

   Как пользоваться:
   • Каждая функция — самостоятельный блок. Чтобы отключить фичу, уберите
     её вызов из списка «ЗАПУСК» в конце файла — остальное не сломается.
   • Как разметить HTML для анимаций — см. комментарий к БЛОКУ 4
     и README.md (раздел «Классы-анимации»).
   ========================================================================== */

'use strict';

/* ----------------------------------------------------------------------------
   БЛОК 1. CONFIG — общие настройки страницы
   -------------------------------------------------------------------------- */
const CONFIG = {
  // Насколько сильно картинка в hero «отстаёт» от прокрутки (0.22 = 22% скорости).
  // Поставьте 0, чтобы полностью выключить параллакс.
  parallaxSpeed: 0.22,

  // Параллакс включается только на экранах шире этого значения (px):
  // на телефонах эффект не нужен и лишь тратит батарею.
  parallaxMinWidth: 1024,

  // Через сколько пикселей прокрутки шапка сжимается и становится стеклянной.
  headerScrollTrigger: 8,
};

// Пользователь попросил систему «уменьшить движение» — учитывается в БЛОКАХ 4 и 5.
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

/* ----------------------------------------------------------------------------
   БЛОК 2. ШАПКА
   Вешает класс .is-scrolled на <header> — дальше работает CSS
   (styles.css, РАЗДЕЛ 4): уменьшение высоты + размытый полупрозрачный фон.
   -------------------------------------------------------------------------- */
function initHeader() {
  const header = document.getElementById('header');
  if (!header) return;

  const onScroll = () => {
    header.classList.toggle('is-scrolled', window.scrollY > CONFIG.headerScrollTrigger);
  };

  onScroll(); // начальное состояние (если страница открыта не с самого верха)
  window.addEventListener('scroll', onScroll, { passive: true });
}

/* ----------------------------------------------------------------------------
   БЛОК 3. МОБИЛЬНОЕ МЕНЮ
   Кнопка .burger переключает класс nav-open на <body> — показ/скрытие панели
   делает CSS (styles.css, РАЗДЕЛ 4). aria-expanded сообщает скринридерам
   об открытом меню.
   -------------------------------------------------------------------------- */
function initMobileMenu() {
  const burger = document.querySelector('.burger');
  if (!burger) return;

  const close = () => {
    document.body.classList.remove('nav-open');
    burger.setAttribute('aria-expanded', 'false');
  };

  burger.addEventListener('click', () => {
    const open = document.body.classList.toggle('nav-open');
    burger.setAttribute('aria-expanded', String(open));
    burger.setAttribute('aria-label', open ? 'Закрыть меню' : 'Открыть меню');
  });

  // Клик по любому пункту меню закрывает его (иначе панель висит над текстом)
  document.querySelectorAll('.nav a').forEach((link) => {
    link.addEventListener('click', close);
  });
}

/* ----------------------------------------------------------------------------
   БЛОК 4. ПОЯВЛЕНИЕ БЛОКОВ ПРИ ПРОКРУТКЕ

   Как пользоваться в HTML:
     <div class="reveal">…</div>                  — плавное появление
     <div data-stagger> … .reveal-дети … </div>   — дети появляются по очереди
     <div data-stagger data-draw> … </div>        — + «дорисовка» линии (шаги)

   Механика: IntersectionObserver добавляет класс .is-visible, CSS плавно
   показывает элемент (styles.css, РАЗДЕЛ 18). Задержка очереди — переменная
   --reveal-stagger в РАЗДЕЛЕ 1 styles.css. После анимации служебные классы
   снимаются, чтобы hover-эффекты карточек не тормозили transition-delay.
   -------------------------------------------------------------------------- */
function initReveal() {
  // Проставляем каждому .reveal внутри группы порядковый номер (--i):
  // из него CSS считает задержку появления.
  document.querySelectorAll('[data-stagger]').forEach((group) => {
    group.querySelectorAll('.reveal').forEach((el, index) => {
      el.style.setProperty('--i', index);
    });
  });

  const elements = Array.from(document.querySelectorAll('.reveal'));

  // Фолбэк: без анимаций всё видно сразу
  if (prefersReducedMotion || !('IntersectionObserver' in window)) {
    elements.forEach((el) => el.classList.add('is-visible', 'is-drawn'));
    return;
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      const el = entry.target;
      el.classList.add('is-visible');
      if (el.hasAttribute('data-draw')) el.classList.add('is-drawn');
      observer.unobserve(el); // показали один раз — дальше не следим

      el.addEventListener('transitionend', function handler(event) {
        if (event.target !== el) return;
        el.classList.remove('reveal', 'is-visible');
        el.classList.add('is-shown');
        el.removeEventListener('transitionend', handler);
      });
    });
  }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });

  elements.forEach((el) => observer.observe(el));
}

/* ----------------------------------------------------------------------------
   БЛОК 5. ПАРАЛЛАКС В HERO
   Картинка сдвигается вниз медленнее прокрутки (CONFIG.parallaxSpeed).
   Включается только на широких экранах и уважает prefers-reduced-motion.
   -------------------------------------------------------------------------- */
function initParallax() {
  const el = document.querySelector('[data-parallax]');
  if (!el || prefersReducedMotion || CONFIG.parallaxSpeed <= 0) return;

  const desktop = window.matchMedia(`(min-width: ${CONFIG.parallaxMinWidth}px)`);
  let listening = false;
  let ticking = false; // троттлинг: не чаще одного расчёта на кадр

  const update = () => {
    const y = window.scrollY;
    if (y < window.innerHeight * 1.2) {
      el.style.transform = `translateY(${y * CONFIG.parallaxSpeed}px)`;
    }
    ticking = false;
  };

  const onScroll = () => {
    if (!ticking) {
      window.requestAnimationFrame(update);
      ticking = true;
    }
  };

  // Включаем/выключаем обработчик при изменении ширины окна
  const sync = () => {
    if (desktop.matches && !listening) {
      window.addEventListener('scroll', onScroll, { passive: true });
      listening = true;
    } else if (!desktop.matches && listening) {
      window.removeEventListener('scroll', onScroll);
      listening = false;
      el.style.transform = '';
    }
  };

  sync();
  desktop.addEventListener('change', sync);
}

/* ----------------------------------------------------------------------------
   БЛОК 6. АККОРДЕОН FAQ
   Открыт один вопрос за раз. Открытие — класс .is-open на .faq__item,
   плавность делает CSS через grid-template-rows (styles.css, РАЗДЕЛ 15).
   -------------------------------------------------------------------------- */
function initFaq() {
  const items = Array.from(document.querySelectorAll('.faq__item'));

  items.forEach((item) => {
    const button = item.querySelector('.faq__q');
    if (!button) return;

    button.addEventListener('click', () => {
      const wasOpen = item.classList.contains('is-open');

      // Сначала закрываем все…
      items.forEach((other) => {
        other.classList.remove('is-open');
        const btn = other.querySelector('.faq__q');
        if (btn) btn.setAttribute('aria-expanded', 'false');
      });

      // …и открываем выбранный, если он был закрыт (повторный клик = закрыть)
      if (!wasOpen) {
        item.classList.add('is-open');
        button.setAttribute('aria-expanded', 'true');
      }
    });
  });
}

/* ----------------------------------------------------------------------------
   БЛОК 7. СЛАЙДЕР «ДО / ПОСЛЕ»
   Левая половина (.ba__before) — фото штатного экрана,
   правая (.ba__after) — фото настроенного.
   Позицию двигает невидимый <input class="ba__range">: он даёт управление
   с клавиатуры (стрелки) и тачем «из коробки». Визуальная линия (.ba__handle)
   и обрезка правой картинки синхронизируются через CSS-переменную --pos
   (styles.css, РАЗДЕЛ 11).
   -------------------------------------------------------------------------- */
function initBeforeAfter() {
  const ba = document.querySelector('.ba');
  if (!ba) return;

  const range = ba.querySelector('.ba__range');
  const afterPane = ba.querySelector('.ba__after');
  if (!range || !afterPane) return;

  const setPosition = (value) => {
    ba.style.setProperty('--pos', `${value}%`);
    afterPane.style.clipPath = `inset(0 0 0 ${value}%)`;
    range.setAttribute('aria-valuetext', `${value}%`);
  };

  range.addEventListener('input', () => setPosition(range.value));
  setPosition(range.value); // начальное положение берётся из value инпута
}

/* ----------------------------------------------------------------------------
   БЛОК 8. ГОД В ФУТЕРЕ — чтобы копирайт не устаревал
   -------------------------------------------------------------------------- */
function initFooterYear() {
  const year = document.getElementById('year');
  if (year) year.textContent = new Date().getFullYear();
}

/* ============================================================================
   ЗАПУСК. Уберите строку — и соответствующая фича отключится.
   ========================================================================== */
initHeader();
initMobileMenu();
initReveal();
initParallax();
initFaq();
initBeforeAfter();
initFooterYear();

