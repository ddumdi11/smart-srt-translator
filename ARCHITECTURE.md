Architecture Notes
==================

Goals
-----
- Provide a standalone, embeddable module focused on SRT→SRT translation.
- Keep a clean provider abstraction (OpenAI first; more can be added later).
- Offer an optional audio probe flow to request and consume segment-level clarifications.

Modules
-------
- `smart_srt_translator/api.py`: Public API (`translate_srt_file`).
- `smart_srt_translator/models.py`: Dataclasses for segments, issues, requests, options, results.
- `smart_srt_translator/providers/`: Provider interfaces + implementations (dummy, openai).
- `smart_srt_translator/srt_utils.py`: Parse/format SRT.
- `smart_srt_translator/io_json.py`: JSON I/O for audio probe requests/resolutions.
- `smart_srt_translator/cli.py`: Minimal CLI with `translate` and future `finalize`.

Audio Probe Interface
---------------------
- Modes: `off`, `ask`, `auto`.
- `ask`: API returns `pending_requests` and writes requests JSON next to output; caller can provide resolutions later.
- `auto`: planned to rely on a `TranscriberProvider` and `audio_source` to auto-transcribe time windows.

Roadmap
-------
- Port “smart translation” batching, sentence grouping, and timing-aware reflow from the existing app.
- Implement `finalize` to apply `resolutions.json` and update SRT output.
- Add caching & retries; expand provider prompts; optional Pydantic schemas.

Integration
-----------
- GUI app can invoke the package programmatically or via CLI.
- Naming convention: outputs `*_translated_<lang>.srt` without overwriting inputs.

