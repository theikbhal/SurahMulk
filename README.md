# SurahMulk — Surah Al-Mulk reader & habit tracker for macOS

A native Mac app for reading **Surah Al-Mulk (الملك · 30 ayahs)** with translations in
**English, Urdu and Telugu**, a **daily reminder at 7:00 PM**, **streaks with a calendar**,
a **memorise plan (one ayah a month)**, a **word-of-the-day vocabulary tracker**, a
**grammar view**, a **fast-read mode**, the **recitation video** and **quran.com** in-app.

## Features

### Daily
- **Read** — all 30 ayahs in Uthmani script with Saheeh English, transliteration,
  per-ayah audio (al-Afasy) and an adjustable Arabic font size (18–72 pt).
- **Quick Pass** — your **daily minimum**: the **last 3 lines** in big type with one
  **Pass** button that marks the day done.
- **Streaks** — current streak, best streak, days read and a **month calendar** of marks,
  plus the daily reminder picker (**7:00 PM** by default, 4:00 PM / both / off).

### Study
- **Memorise** — **one ayah per month** assigned to a date, status (planned / learning /
  memorised) and an automatic **revision plan at +7, +30 and +90 days**, plus a
  reveal-on-tap drill.
- **Vocabulary** — **333 total occurrences, 224 unique word forms, 109 repeated
  occurrences**, a **word of the day** with its own **assigned date** and a
  **+1 / +7 / +30 revision plan**, a 14-day **track view**, and the full word list.
- **Grammar** — every word with **root, prefixes, suffixes, i‘rāb and ṣarf**, plus a
  root-frequency cloud over the surah.
- **Translations** — Saheeh (English), Junagarhi (Urdu) and Abder-Rahim (Telugu), single
  or **side by side**, all bundled offline.
- **Hadith & Benefits** — the hadith about Surah Al-Mulk (Tirmidhi 2880 and others) and
  seven benefits of keeping it in your day.
- **Fast Read** — steps through all 333 words at **0.25×–4×**; finishing a run marks the
  day read.

### More
- **Video** — Sheikh Sudais recitation of Surah Al-Mulk
  (https://www.youtube.com/watch?v=JwXN2fnc8Uk), in the browser or in an in-app player.
- **Quran.com** — live in-app browser on https://quran.com/al-mulk.
- **Help** — full Q&A in the app, **onboarding** on first launch (replay with `⌘⇧O`).

## Install

```bash
git clone https://github.com/theikbhal/SurahMulk.git
cd SurahMulk
scripts/build_app.sh
```

The script builds the Swift package, assembles `build/SurahMulk.app` (icon, `Info.plist`,
resource bundle), **moves it to `/Applications/SurahMulk.app`** and creates the Desktop
shortcut **`~/Desktop/SurahMulk.app`**.

Build only: `scripts/build_app.sh --build-only` then `open build/SurahMulk.app`.

Requires macOS 14+ and a Swift toolchain (`xcode-select --install`).

## Use

| Action | How |
| --- | --- |
| Mark today read | “Mark today read” in Read, or **Pass** in Quick Pass (`⌘↩`) |
| Change reminder | Streaks → Daily reminder, or the gear icon (7:00 PM default) |
| Jump to an ayah | click its card in Read / Translations / Vocabulary |
| Fast read | Space play/pause, ‹ › step, speed presets 0.25×–4× |
| Replay onboarding | `⌘⇧O` |
| Tabs | sidebar, grouped Daily / Study / More |

## Data & sources

`Sources/SurahMulk/Resources/mulk.json` (30 ayahs, 333 word tokens, 224 unique forms)
is generated at development time:

```bash
python3 scripts/fetch_data.py
```

- Uthmani text, word-by-word English/transliteration — quran.com API v4
- Translations — quran.com `20` Saheeh English · `54` Junagarhi Urdu · `227` Telugu
- Per-word morphology (root, affixes, i‘rāb, ṣarf) — api.qurani.ai
- Ayah audio — `cdn.islamic.network` (Mishary Rashid al-`Afasy, 128 kbps)
- Word pronunciation — `verses.quran.com` word-by-word clips
- Video — YouTube (Sheikh Sudais, IQRA AL-QURAN)

Reading, streaks, plans and settings are **local only**: no account, no analytics.

## Docs

- [docs/help.md](docs/help.md) — in-app help content
- [docs/ONBOARDING.md](docs/ONBOARDING.md) — onboarding pages copy
- [docs/INSTALL.md](docs/INSTALL.md) — install, permissions, uninstall
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) — project layout, data pipeline, release flow

## Uninstall

```bash
rm -rf /Applications/SurahMulk.app ~/Desktop/SurahMulk.app
defaults delete com.ikbhal.surahmulk                 # settings
rm -rf "$HOME/Library/Application Support/SurahMulk" # streaks & plans
```

## License

MIT © 2026 Ikbhal — theikbhal@gmail.com
