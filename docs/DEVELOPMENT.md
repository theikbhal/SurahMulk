# Development — Surah Mulk

## Layout

```
SurahMulk/
├── Package.swift                 Swift package: executable target, .macOS(.v14)
├── Sources/SurahMulk/
│   ├── SurahMulkApp.swift        @main, AppDelegate, onboarding overlay, ⌘⇧O
│   ├── AppState.swift            tabs, font size, reminder, last-read ayah
│   ├── SurahStore.swift          loads mulk.json (app bundle copies)
│   ├── Models.swift              Ayah / Word / SurahData / Hadith / Benefit
│   ├── VocabularyIndex.swift     333 tokens → 224 forms, occurrences
│   ├── ProgressStore.swift       streaks, calendar, memorise & vocab plans
│   ├── ReminderManager.swift     UNUserNotificationCenter, 4 PM / 7 PM / both
│   ├── AyahAudio.swift           shared AVPlayer for ayah clips
│   ├── Content.swift             hadith + benefits (curated copy)
│   └── UI/                       RootView, Read, QuickPass, Streaks, Memorise,
│                                 Vocab, Grammar, Translations, Learn, FastRead,
│                                 Video, QuranWeb, Settings, Help, Onboarding
├── scripts/
│   ├── fetch_data.py             builds mulk.json (quran.com + qurani.ai)
│   ├── make_icon.swift           generates Resources/AppIcon.png
│   └── build_app.sh              build → /Applications → Desktop shortcut
├── Resources/AppIcon.png         generated icon
└── docs/                         help, onboarding, install, this file
```

## Data pipeline

```bash
python3 scripts/fetch_data.py
```

1. quran.com API v4 — `verses/by_chapter/67` with Uthmani words, word English and
   transliteration, and translations `20` (Saheeh), `54` (Junagarhi Urdu), `227`
   (Telugu).
2. alquran.cloud — global ayah numbers for the al-Afasy mp3 URLs.
3. api.qurani.ai — per-word morphology (`Root`, `Sawabiq` prefixes, `Lawahiq`
   suffixes, `Irab`, `Sarf`, `Aam`), fetched with 8 threads.
4. Stats — token/unique/repeated counts using the canonical form (alef-wasla → alef,
   vowel marks stripped): **333 / 224 / 109**.

The JSON is committed, so a normal build never touches the network.

## Build & run

```bash
swift build                      # debug binary
scripts/build_app.sh --build-only
scripts/build_app.sh             # release + install + Desktop shortcut
open /Applications/SurahMulk.app
```

> Running the raw `.build/debug/SurahMulk` binary outside an app bundle cannot register
> notifications (`bundleProxyForCurrentProcess is nil`) — always test through
> `build_app.sh`.

### Resource loading rule

`SurahStore.load()` only looks **inside the app bundle**
(`Contents/Resources/mulk.json` → `SurahMulk_SurahMulk.bundle`). It must never fall back
to a `.build/...` path: reaching into `~/Desktop` from an installed app triggers a
macOS TCC consent prompt that blocks the main thread at launch.

## State storage

| Store | File | Contents |
| --- | --- | --- |
| `ProgressStore` | `~/Library/Application Support/SurahMulk/progress.json` | `dailyDone`, `memorise`, `vocab`, `planStart` |
| `AppState` | `defaults com.ikbhal.surahmulk` | `reader.arabicSize`, `reader.reminder`, `reader.lastAyah`, `onboarding.*` |

Plan rules:

- **Memorise** — ayah *n* is assigned to the first day of month *planStart + (n − 1)*;
  memorised on = today; revisions at +7 / +30 / +90 days.
- **Vocabulary** — the word for a day is `daysSince(planStart) % 224`; status
  `new / learning / known`; revisions at +1 / +7 / +30 days.

## Release flow

1. `python3 scripts/fetch_data.py` (only if sources changed)
2. Bump `VERSION` in `scripts/build_app.sh`
3. `scripts/build_app.sh`
4. Update `README.md` / `docs/*`
5. `git add -A && git commit && git push`

## AppTracker

The app is registered in AppTracker (`~/Library/Application Support/AppTracker/apps.json`)
with `bundlePath: /Applications/SurahMulk.app`.
