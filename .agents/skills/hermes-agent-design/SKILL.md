---
name: hermes-agent-design
description: >-
  Visual design system of the Hermes Agent website
  (hermes-agent.nousresearch.com) — an electric-blue, halftone-engraving,
  serif+mono aesthetic. Use this skill whenever the user asks to design a page,
  landing page, section, or component "in the style of Hermes Agent", "like the
  Hermes site", or references this specific blue/halftone/mythological-engraving
  look.
---

# Hermes Agent Website Design System

A bold, high-contrast design system built around a single saturated blue,
vintage halftone engravings, and a two-typeface pairing (elegant serif +
technical monospace). Feels like a manifesto/zine crossed with a CLI tool's
marketing site — confident, printed-poster energy rather than soft SaaS
minimalism.

## Color palette

- **Primary/background:** one saturated electric/ultramarine blue, used as
  full-bleed section backgrounds — approx `#2A2AF5` / `#3333FF` range
  (a vivid royal blue, not navy, not purple).
- **Secondary/background:** pure white, used for alternating sections.
- **Text on blue:** white and a lighter/muted blue-white for secondary text
  (e.g. eyebrow labels).
- **Text on white:** the same saturated blue is reused as the text color
  (blue headlines on white background), plus black/dark-gray for body copy.
- **No other hues.** No gradients, no accent colors beyond the one blue —
  monochrome-plus-white is the whole palette. This restraint is the point;
  don't introduce a second accent color.
- Buttons are white rectangles with blue text on blue sections, and
  blue-outlined or blue-text on white sections — always high-contrast,
  never a soft or muted button.

## Typography

Two typefaces only, used for clearly different jobs — never mix their roles:

1. **Display serif** (Times/Georgia/Canela-like, elegant high-contrast
   serif) — for all big headlines and hero statements: page titles like
   "THE AGENT THAT GROWS WITH YOU", section headers like "PERSISTENT
   MEMORY", "TASKS MULTIPLIED", OS names ("Mac OS", "Windows", "Linux"),
   the wordmark "HERMES AGENT". Usually set in full caps at large sizes
   (60–120px for hero), tight leading, sometimes wrapped across 2–3 short
   lines rather than one long line.
2. **Monospace** (JetBrains Mono / IBM Plex Mono style) — for everything
   functional: nav links, eyebrow/kicker labels ("OPEN SOURCE • MIT
   LICENSE", "#1 CONNECT", "MACOS 12+"), button labels, terminal/code
   snippets, body/paragraph copy in feature sections. Almost always
   uppercase and letter-spaced when used as a label.

Never use a third typeface. Never use a soft sans-serif (Inter/Helvetica)
as the dominant voice — that would break the identity.

## Imagery: halftone engravings

The signature visual element: classical/mythological line-engraving
illustrations (a winged Hermes figure, a woman with headphones, portrait
busts) rendered as **blue-and-white halftone dot patterns** — looks like
a duotone risograph print or an old newspaper engraving reprinted in blue
ink. Images are large, often full-bleed or near-full-bleed within their
section, and always monochrome (white/light dots on blue, or blue dots on
white) — never full-color photography.

If generating new imagery: describe it as "vintage line-engraving /
woodcut illustration, halftone dot screen, single-color blue duotone,
mythological or classical figure" rather than using flat icons or stock
photography.

## Layout patterns

- **Full-bleed alternating sections**: blue section → white section →
  blue section, each edge-to-edge, no contained/boxed cards.
- **Numbered feature grid**: 3-column grid where each column has a small
  eyebrow ("#1 CONNECT", "#2 REMEMBER", "#3 SCHEDULE"), a 2-line serif
  headline, a short monospace paragraph, and a halftone illustration
  below it. Repeats for a second row (#4–#6) — 6 features total in two
  rows of three.
- **Scalloped/wave divider**: a row of white scalloped/petal shapes cuts
  into the top of a blue section as a transition device instead of a
  straight edge.
- **Hero**: eyebrow label top-left ("OPEN SOURCE • MIT LICENSE"), large
  serif headline stacked on 2–3 lines, a primary white CTA button, a
  secondary "install via terminal" block with a real copyable command,
  and a large halftone illustration filling the right half of the
  viewport.
- **Nav bar**: monospace, all-caps, wide letter-spacing, evenly spaced
  across the full width (logo/wordmark centered or left, links spread
  out), social icons (Discord/X/GitHub) as small monochrome glyphs.
- **Product/download tiles**: 3-up equal-width tiles (one per OS/platform),
  each with a monospace eyebrow ("MACOS 12+"), a large serif platform
  name, and one white CTA button — halftone texture as the tile
  background.
- **App screenshot embeds**: real product UI screenshots (light-mode
  chat interface) are dropped directly onto the blue background inside a
  simple browser-chrome frame — no heavy device mockup or drop shadow,
  just placed naturally with a thin border.
- **Footer/closing section**: oversized wordmark used as a giant
  watermark-style background text element, with a smaller illustration
  and license/version info layered on top.

## Tone

Confident, terse, technical. Copy reads like manifesto statements
("THE AGENT THAT GROWS WITH YOU") or command output, not marketing
fluff. Short lines, no hedging, no soft CTAs — direct imperatives
("DOWNLOAD DESKTOP APP", "INSTALL VIA TERMINAL").

## When generating code

- Use CSS variables for the one blue and white so it's trivial to
  swap the exact hex later.
- Load a serif (e.g. via Google Fonts: "Libre Caslon Display", "Playfair
  Display", or similar high-contrast serif) and a monospace (e.g.
  "JetBrains Mono", "IBM Plex Mono") — never fall back to system
  sans-serif for headlines or labels.
- Keep all buttons sharp-cornered or minimally rounded rectangles —
  this system does not use pill buttons or heavy rounding.
- Reserve full-color photography for nothing — if a real product
  screenshot is needed, keep it in its native colors but keep every
  other image on the page in the blue halftone treatment.
