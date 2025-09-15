Timing & Readability (DE)
=========================

Purpose
-------
This note summarizes how to assess subtitle readability (words/sec) and how to use the new language‑aware preset and timing‑expansion prototype to improve German subtitle display without breaking timing correctness.

Language‑Aware Preset (CLI)
---------------------------
- Flag: `--lang-preset auto|off` (default: `auto`).
- Behavior (smart mode only): when target language starts with `de` and preset is `auto`:
  - Enables `--preserve-timing` (if not already set).
  - Ensures `--wrap-width >= 100`.
  - Enables `--expand-timing` (if not already set) with at least:
    - `--expansion-factor 1.3`
    - `--min-seg-dur 2.0`
    - `--reading-wpm 200`
    - `--min-gap-ms 120`
- Manual overrides still apply (use `--lang-preset off` to opt out).

Preserve‑Timing Mode
--------------------
- `--preserve-timing`: translates per segment, no cross‑boundary reflow.
- Recommended for DE video workflows, especially for burn‑in/live display.
- Typical: `--preserve-timing --wrap-width 120`.

Timing‑Expansion (Prototype)
----------------------------
- `--expand-timing` expands segment durations to improve readability of longer target texts (DE).
- Parameters:
  - `--expansion-factor` (default 1.3) multiplies base durations.
  - `--min-seg-dur` (default 2.0) enforces minimum duration per segment (seconds).
  - `--reading-wpm` (default 200) target reading speed.
  - `--min-gap-ms` (default 120) minimal gap between adjacent segments.
- Works in smart and preserve‑timing; keeps order, shifts later segments forward, respects minimal gaps.

Recommended Commands (from project root)
---------------------------------------
- Example 1 (timing‑critical, DE):
  - `python -m smart_srt_translator.cli translate "Deutsche_Untertitel_Besonderheiten\Beispiel 1\Biosemiotics.srt" en de --preserve-timing --wrap-width 120 --expand-timing`
- Example 2 (longer content, DE):
  - `python -m smart_srt_translator.cli translate "Deutsche_Untertitel_Besonderheiten\Beispiel 2\candace_charlie.srt" en de --preserve-timing --wrap-width 120 --expand-timing`
- Short form (preset auto applies):
  - `python -m smart_srt_translator.cli translate "<input>.srt" en de`

Reading‑Speed Checker (helper)
------------------------------
- Script: `tmp_readspeed.py` (in repo root).
- Usage: `python tmp_readspeed.py <translated.srt> [wps_threshold=3.5] [min_dur=2.0]`
- Flags segments that are too dense (words/sec above threshold) or too short (duration below min).
- Example:
  - `python tmp_readspeed.py Deutsche_Untertitel_Besonderheiten\Beispiel 2\candace_charlie_translated_smart_de.srt 3.0 2.0`

Tune‑Up Suggestions
-------------------
- More expansion: `--expansion-factor 1.35–1.4`, `--min-seg-dur 2.2`.
- Reading speed: try `--reading-wpm 180–220` based on audience and device.
- Wrap width: DE often benefits from `--wrap-width 100–120` in preserve‑timing.

Notes
-----
- Punctuation‑sticky, widow/orphan control, and micro‑segment protection are active in smoothing to avoid 1‑word tails/heads and sentence‑end spillovers.
- Zero‑length/empty segments remain unchanged (detected and not filled).
- TL;DR Presets
----------------
- Short DE clips (<10 min):
  - `--preserve-timing --wrap-width 120` (expansion optional)
- Long DE clips (≥10 min):
  - `--preserve-timing --wrap-width 120 --expand-timing --expansion-factor 1.4 --min-seg-dur 2.4 --reading-wpm 200`
- Language-aware preset is on by default for `de` (smart mode):
  - Enables preserve+expand with safe defaults; add only factor/min‑dur when needed.

