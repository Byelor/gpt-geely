(function () {
  'use strict';

  var d = document;
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------- Header: glass + shrink on scroll ---------- */
  var header = d.getElementById('header');
  function onScroll() {
    header.classList.toggle('is-scrolled', window.scrollY > 8);
  }
  onScroll();
  window.addEventListener('scroll', onScroll, { passive: true });

  /* ---------- Mobile menu ---------- */
  var burger = d.querySelector('.burger');
  if (burger) {
    burger.addEventListener('click', function () {
      var open = d.body.classList.toggle('nav-open');
      burger.setAttribute('aria-expanded', open ? 'true' : 'false');
      burger.setAttribute('aria-label', open ? 'Закрыть меню' : 'Открыть меню');
    });
    d.querySelectorAll('.nav a').forEach(function (a) {
      a.addEventListener('click', function () {
        d.body.classList.remove('nav-open');
        burger.setAttribute('aria-expanded', 'false');
      });
    });
  }

  /* ---------- Reveal on scroll (stagger via --i) ---------- */
  d.querySelectorAll('[data-stagger]').forEach(function (group) {
    group.querySelectorAll('.reveal').forEach(function (el, i) {
      el.style.setProperty('--i', i);
    });
  });

  var revealEls = Array.prototype.slice.call(d.querySelectorAll('.reveal'));

  if (reduceMotion || !('IntersectionObserver' in window)) {
    revealEls.forEach(function (el) {
      el.classList.add('is-visible', 'is-drawn');
    });
  } else {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        var el = entry.target;
        el.classList.add('is-visible');
        if (el.hasAttribute('data-draw')) el.classList.add('is-drawn');
        io.unobserve(el);
        el.addEventListener('transitionend', function handler(e) {
          if (e.target !== el) return;
          el.classList.remove('reveal', 'is-visible');
          el.classList.add('is-shown');
          el.removeEventListener('transitionend', handler);
        });
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });
    revealEls.forEach(function (el) { io.observe(el); });
  }

  /* ---------- Hero parallax (desktop only, no reduced motion) ---------- */
  var parallaxEl = d.querySelector('[data-parallax]');
  var desktopMQ = window.matchMedia('(min-width: 1024px)');
  var parallaxOn = false;
  var ticking = false;

  function applyParallax() {
    var y = window.scrollY;
    if (y < window.innerHeight * 1.2) {
      parallaxEl.style.transform = 'translateY(' + y * 0.22 + 'px)';
    }
    ticking = false;
  }
  function enableParallax() {
    if (parallaxOn) return;
    parallaxOn = true;
    window.addEventListener('scroll', function () {
      if (!ticking) {
        window.requestAnimationFrame(applyParallax);
        ticking = true;
      }
    }, { passive: true });
  }
  if (parallaxEl && !reduceMotion) {
    var syncParallax = function () {
      if (desktopMQ.matches) {
        enableParallax();
      } else {
        parallaxOn = false;
        parallaxEl.style.transform = '';
      }
    };
    syncParallax();
    if (desktopMQ.addEventListener) desktopMQ.addEventListener('change', syncParallax);
  }

  /* ---------- FAQ accordion: one open at a time ---------- */
  var faqItems = Array.prototype.slice.call(d.querySelectorAll('.faq__item'));
  faqItems.forEach(function (item) {
    var btn = item.querySelector('.faq__q');
    btn.addEventListener('click', function () {
      var wasOpen = item.classList.contains('is-open');
      faqItems.forEach(function (i) {
        i.classList.remove('is-open');
        i.querySelector('.faq__q').setAttribute('aria-expanded', 'false');
      });
      if (!wasOpen) {
        item.classList.add('is-open');
        btn.setAttribute('aria-expanded', 'true');
      }
    });
  });

  /* ---------- Before / After slider ---------- */
  var ba = d.querySelector('.ba');
  if (ba) {
    var range = ba.querySelector('.ba__range');
    var after = ba.querySelector('.ba__after');
    var setPos = function (v) {
      ba.style.setProperty('--pos', v + '%');
      after.style.clipPath = 'inset(0 0 0 ' + v + '%)';
      range.setAttribute('aria-valuetext', v + '%');
    };
    range.addEventListener('input', function () { setPos(range.value); });
    setPos(range.value);
  }

  /* ---------- Footer year ---------- */
  var year = d.getElementById('year');
  if (year) year.textContent = new Date().getFullYear();
})();
