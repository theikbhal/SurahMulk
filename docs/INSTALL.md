# Install — Surah Mulk

## Build & install

```bash
git clone https://github.com/theikbhal/SurahMulk.git
cd SurahMulk
scripts/build_app.sh
```

Result:

- `/Applications/SurahMulk.app` — the app
- `~/Desktop/SurahMulk.app` — Desktop shortcut (symlink to the app)

Build only, without installing:

```bash
scripts/build_app.sh --build-only
open build/SurahMulk.app
```

Requirements: macOS 14+, Xcode command line tools (`xcode-select --install`).

## First launch

1. **Onboarding** — four pages (replay any time with `⌘⇧O` or Settings → Replay).
2. **Notification permission** — asked when you finish onboarding. Allow it so the
   **7:00 PM** reminder works.
3. Streaks and plans start on the day you first open the app (`plan start` = today).

## Permissions

| Permission | Why |
| --- | --- |
| Notifications | the daily reminder (7:00 PM by default) |
| Network (optional) | ayah audio, YouTube video, quran.com tab |

Reading, streaks, vocabulary and the memorise plan are fully offline.

If notifications never appear: **System Settings → Notifications → Surah Mulk** → allow
alerts, then toggle the reminder in the app once (Streaks → Daily reminder) to re-schedule.

## Data locations

| What | Where |
| --- | --- |
| Settings (font, reminder, last ayah) | `defaults com.ikbhal.surahmulk` |
| Streaks, calendar, memorise & vocab plans | `~/Library/Application Support/SurahMulk/progress.json` |
| Surah text bundle | `/Applications/SurahMulk.app/Contents/Resources/mulk.json` |

## Update

```bash
cd SurahMulk
git pull
scripts/build_app.sh
```

## Uninstall

```bash
rm -rf /Applications/SurahMulk.app ~/Desktop/SurahMulk.app
defaults delete com.ikbhal.surahmulk
rm -rf "$HOME/Library/Application Support/SurahMulk"
```

Notifications are removed automatically with the app; if one lingers:
**System Settings → Notifications → Surah Mulk**.
