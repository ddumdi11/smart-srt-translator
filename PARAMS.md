Parameter-Übersicht (smart-srt-translator)
=========================================

Ziel: kompakte Referenz für die wichtigsten Modi, Flags, sinnvolle Defaults und kurze Rezepte. Version 0.1.1.

Modi
-----
- Smart: gruppiert Sätze, übersetzt kontextbezogen, verteilt zurück auf Original‑Timing (Standard).
- Preserve Timing: segmentweise Übersetzung, keine Wortbewegungen über Grenzen; ideal für timing‑kritische Einbettung.
- Basic: einfache Segment‑zu‑Segment‑Übersetzung (nur im CLI‑Modus „basic“; weniger smart).

Provider
--------
- `openai`: Standard im CLI; nutzt `OPENAI_API_KEY` und optional `OPENAI_MODEL`.
- `dummy`: kein Netz, zum Verkabeln/Smoke‑Tests (liefert Quelltext zurück).
- Programmatic: Provider immer explizit setzen (`OpenAITranslator()`), sonst verwendet die API den `DummyTranslator`.

Environment
-----------
- CLI lädt `.env` automatisch (Repo‑Root oder `VidScalerSubtitleAdder/.env`).
- Programmatic: `from smart_srt_translator.env import load_env_vars` aufrufen.
- Wichtige Variablen: `OPENAI_API_KEY`, optional `OPENAI_MODEL`.

Kern‑Flags (CLI `translate`)
----------------------------
- `--mode smart|basic`: wählt Pipeline (Standard: smart).
- `--provider openai|dummy`: wählt Provider (Standard: openai).
- `--wrap-width INT`: Zeilenumbruchbreite (Standard 40; in Preserve‑Timing für DE oft 100–120 sinnvoll).
- `--out PATH`: expliziter Output‑Pfad (sonst `*_translated_smart_<lang>.srt`).

Review & Cleanup
----------------
- Review (an): prüft auf Rest‑EN und bereinigt (ASCII/Stopword‑Heuristik).
  - `--no-review`: Review aus.
  - `--review-ascii FLOAT`: ASCII‑Schwelle (Standard 0.6).
  - `--review-stop FLOAT`: Stopword‑Schwelle (Standard 0.15).
- Strict‑Review (an): wiederholt Review‑Pässe, wenn nötig.
  - `--strict-review` | `--no-strict-review` (Standard: an).
  - `--strict-passes INT`: max. Pässe (Standard 2).

Reflow, Glättung, Balancing
---------------------------
- `--no-smooth`: schaltet Glättung aus (Standard: an).
  - Glättung schützt: Satzzeichen bleiben am vorigen Segment; 1‑Wort‑Heads/Tails werden vermieden; Mikrosegmente (<600 ms oder ≤3 Tokens) werden nicht angerührt.
- `--no-balance`: schaltet Längen‑Balancing aus (Standard: an).
  - `--balance-ratio FLOAT`: Auslöseverhältnis (Standard 1.8).

Preserve Timing
---------------
- `--preserve-timing`: segmentweise Übersetzung ohne Cross‑Boundary‑Reflow.
  - Wrap wird intern auf mindestens ~100 angehoben; Balancing/Glättung wirken nur noch in sicheren Heuristiken.
  - Empfohlen für DE + Einbrennen/Live‑Anzeige.
  - Typisch: `--preserve-timing --wrap-width 120`.

Timing‑Expansion (Prototyp)
---------------------------
- Dehnt Segmentszeiten zur besseren Lesbarkeit (längere Zielsprache wie DE):
  - `--expand-timing`
  - `--expansion-factor FLOAT` (Standard 1.3; DE ≈ 1.3)
  - `--min-seg-dur FLOAT` Mindestdauer je Segment in Sekunden (Standard 2.0)
  - `--reading-wpm INT` Lese‑Geschwindigkeit (Standard 200 WPM)
  - `--min-gap-ms INT` Minimalabstand zwischen Segmenten (Standard 120 ms)
- Wirkt in smart und preserve; erhält Reihenfolge, schiebt Folge‑Segmente nach hinten, hält Minimalpausen ein.

Audio‑Probe (Basis‑API)
-----------------------
- `translate_srt_file(..., probe_mode="off"|"ask"|"auto")`: erzeugt `*.requests.json` und Issues (z. B. zero‑length‑Segmente).
- Finalize: `srt-translate finalize <translated.srt> --requests <req.json> --resolutions <res.json>`.

Ausgaben & Namensschema
-----------------------
- Output‑SRT: `*_translated_smart_<lang>.srt` (kein Overwrite der Quelle).
- Requests‑JSON: `<output>.requests.json` (bei probe ask).
- Finalisierte SRT: `<translated>_final.srt`.

Empfohlene Defaults (hinterlegt)
---------------------------------
- Smart (OpenAI): wrap 40; Review an (0.6/0.15); Strict 2; Smoothing an; Balancing 1.8.
- Preserve Timing (DE/Video): `--preserve-timing --wrap-width 120`.
- Timing‑Expansion (DE/Video): zusätzlich `--expand-timing --expansion-factor 1.3 --min-seg-dur 2.0 --reading-wpm 200`.

Schnelle Rezepte
----------------
- DE, timing‑kritisch (Einbrennen/Live):
  - `srt-translate translate "<in.srt>" en de --preserve-timing --wrap-width 120`
  - Lesbarkeit: `+ --expand-timing --expansion-factor 1.3 --min-seg-dur 2.0`
- DE, qualitätsfokussiert (kürzere Clips):
  - `srt-translate translate "<in.srt>" en de`
- Offline Smoke‑Test:
  - `srt-translate translate "<in.srt>" en de --provider dummy --mode basic`

Troubleshooting
---------------
- Rest‑EN in DE: Review/Strict‑Review anlassen; ggf. Schwellen schärfen (ASCII 0.5 / STOP 0.12).
- 1‑Wort‑Artefakte („der.“, „und.“): Preserve‑Timing oder Wrap‑Breite erhöhen; Smoothing greift nun vorsichtig (Satzzeichen‑sticky, Widow‑Kontrolle).
- Zu kurze Anzeigezeiten: Timing‑Expansion (Faktor 1.3–1.4, min‑seg‑dur 2.0–2.2).
- Zero‑length: wird erkannt und nicht befüllt; optional Audio‑Probe nutzen.
- Programmatic nutzt Dummy ohne Provider: `OpenAITranslator()` explizit setzen + `load_env_vars()`.

Programmatic Beispiele
----------------------
Preserve per Segment:
```
from smart_srt_translator.env import load_env_vars
from smart_srt_translator.providers.openai_provider import OpenAITranslator
from smart_srt_translator import translate_srt_smart

load_env_vars(); prov = OpenAITranslator()
out = translate_srt_smart("in.srt", "en", "de", provider=prov, preserve_timing=True, wrap_width=120)
```

Timing‑Expansion:
```
out = translate_srt_smart(
    "in.srt", "en", "de", provider=prov,
    preserve_timing=True, wrap_width=120,
    expand_timing=True, expansion_factor=1.3, min_segment_duration=2.0, reading_speed_wpm=200
)
```

