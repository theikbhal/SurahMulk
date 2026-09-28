#!/usr/bin/env python3
"""Fetch Surah Al-Mulk (67) and build Sources/SurahMulk/Resources/mulk.json.

Development time only — the app bundles the result (fully offline reading).

Sources
  * quran.com API v4  -> Uthmani text, per-word English/transliteration, audio paths,
                         ayah translations: 20 Saheeh English, 54 Urdu (Junagarhi),
                         227 Telugu (Maulana Abder-Rahim)
  * alquran.cloud     -> global ayah numbers (Ayah mp3 on cdn.islamic.network)
  * api.qurani.ai     -> per-word morphology: root, affixes, i'rab, sarf (Arabic)
  * cdn.islamic.network / verses.quran.com -> audio URLs (runtime CDN)

Usage: python3 scripts/fetch_data.py
"""
import concurrent.futures as cf
import html
import json
import pathlib
import re
import urllib.request

CHAPTER = 67
SLUG = "mulk"
VERSES_URL = (
    "https://api.quran.com/api/v4/verses/by_chapter/67"
    "?language=en&words=true&word_fields=text_uthmani,translation,transliteration,audio_url"
    "&translations=20,54,227&per_page=50&page=1"
)
ALQURAN_URL = "https://api.alquran.cloud/v1/surah/67"
MORPH_URL = "https://api.qurani.ai/gw/qh/v1/morphology/word/67:{n}:{pos}?include_meaning=true"

OUT = pathlib.Path(__file__).resolve().parent.parent / f"Sources/SurahMulk/Resources/{SLUG}.json"

SKIP_MEANING = ("كل السوابق", "كل اللواحق", "خص")
ARABIC_LETTERS = re.compile(r"[^ء-ي]")


def word_form(text: str) -> str:
    """Canonical word form: alef-wasla normalised, all vowel marks removed."""
    return ARABIC_LETTERS.sub("", text.translate(str.maketrans("ٱ", "ا")))


def get(url: str):
    request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (SurahMulkBuilder)"})
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)


def clean(text: str) -> str:
    text = re.sub(r"<sup[^>]*>.*?</sup>", "", text, flags=re.S)
    text = re.sub(r"<[^>]+>", "", text)
    text = text.replace("‏", "").replace("‎", "")
    return html.unescape(re.sub(r"\s+", " ", text)).strip()


def category(morph: dict, name: str) -> list:
    tags = morph.get("tags_by_category", {}).get(name, [])
    return [t.get("meaning", "") for t in tags]


def keep(tag: str) -> bool:
    if not tag or tag in SKIP_MEANING:
        return False
    if tag.startswith("عدد "):
        return False
    if tag.startswith("العلامة") and "الإعراب" not in tag:
        return False
    return True


def fetch_morph(key: tuple) -> tuple:
    n, pos = key
    try:
        data = get(MORPH_URL.format(n=n, pos=pos)).get("data", {}).get("morphology", {})
    except Exception as exc:  # noqa: BLE001 - morphology is best-effort
        print(f"    morphology failed {n}:{pos}: {exc}")
        return (n, pos), {}
    morph = {
        "root": next((t for t in category(data, "Root") if t not in SKIP_MEANING), ""),
        "pre": [t for t in category(data, "Sawabiq") if keep(t)],
        "suf": [t for t in category(data, "Lawahiq") if keep(t)],
        "irab": [t for t in category(data, "Irab") if keep(t)][:4],
        "sarf": [t for t in category(data, "Sarf") if keep(t)][:4],
        "count": [t for t in category(data, "Aam") if keep(t)][:3],
    }
    return (n, pos), morph


def main():
    verses = get(VERSES_URL)["verses"]
    editions = get(ALQURAN_URL)["data"]["ayahs"]
    if len(verses) != 30:
        raise SystemExit(f"expected 30 ayahs, got {len(verses)}")

    keys, ayahs = [], []
    for index, verse in enumerate(verses):
        words = []
        for word in verse["words"]:
            if word.get("char_type_name") != "word":
                continue
            words.append(word)
            keys.append((verse["verse_number"], len(words)))

        global_number = editions[index]["number"]
        ayahs.append(
            {
                "n": verse["verse_number"],
                "ar": " ".join(w["text_uthmani"].strip() for w in words),
                "en": clean(verse["translations"][0]["text"]),
                "ur": clean(verse["translations"][1]["text"]),
                "tel": clean(verse["translations"][2]["text"]),
                "audio": f"https://cdn.islamic.network/quran/audio/128/ar.alafasy/{global_number}.mp3",
                "words": [
                    {
                        "ar": w["text_uthmani"].strip(),
                        "en": (w.get("translation") or {}).get("text", "").strip(),
                        "tr": (w.get("transliteration") or {}).get("text", "").strip(),
                        "audio": (
                            f"https://verses.quran.com/{w['audio_url']}" if w.get("audio_url") else ""
                        ),
                    }
                    for w in words
                ],
            }
        )

    print(f"==> morphology for {len(keys)} words")
    with cf.ThreadPoolExecutor(max_workers=8) as pool:
        results = dict(pool.map(fetch_morph, keys))
    for ayah in ayahs:
        for position, word in enumerate(ayah["words"], start=1):
            word.update(results.get((ayah["n"], position), {}))

    tokens = sum(len(a["words"]) for a in ayahs)
    forms: dict = {}
    for ayah in ayahs:
        for word in ayah["words"]:
            key = word_form(word["ar"])
            forms[key] = forms.get(key, 0) + 1
    stats = {
        "total": tokens,
        "unique": len(forms),
        "repeated": tokens - len(forms),
        "top": [
            {"form": form, "count": count}
            for form, count in sorted(forms.items(), key=lambda kv: (-kv[1], kv[0]))[:12]
        ],
    }

    payload = {
        "surah": CHAPTER,
        "name": "Al-Mulk",
        "nameArabic": "ٱلْمُلْك",
        "nameMeaning": "The Sovereignty",
        "revelation": "Meccan",
        "totalAyahs": len(ayahs),
        "basmala": "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
        "video": "https://www.youtube.com/watch?v=JwXN2fnc8Uk",
        "web": "https://quran.com/al-mulk",
        "stats": stats,
        "ayahs": ayahs,
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(
        f"wrote {OUT} — {len(ayahs)} ayahs, {stats['total']} word tokens, "
        f"{stats['unique']} unique forms, {OUT.stat().st_size} bytes"
    )


if __name__ == "__main__":
    main()
