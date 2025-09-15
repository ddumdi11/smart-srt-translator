Publishing to (Test)PyPI
========================

This package uses PEP 621 metadata in `pyproject.toml` and a console script `srt-translate`.

Prerequisites
-------------
- Python 3.11
- Create a venv first (choose one):
  - Windows: `py -m venv .venv` or `python -m venv .venv`
  - macOS/Linux: `python3 -m venv .venv`
  - Activate: PowerShell `.venv\\Scripts\\Activate.ps1`, CMD `.venv\\Scripts\\activate.bat`, bash/zsh `source .venv/bin/activate`
- Build tools (inside venv): `python -m pip install build twine`

Build
-----
1. Clean old artifacts (recommended):
   - Windows PowerShell: `./clean.ps1` (or dry-run: `./clean.ps1 -DryRun`)
2. Build sdist + wheel:
   - `python -m build`
3. Verify metadata:
   - `twine check dist/*`

Upload to TestPyPI
------------------
1. Create an account on https://test.pypi.org/ and generate a token.
2. Upload:
   - `twine upload --repository testpypi dist/*`
3. Install from TestPyPI in a clean venv:
   - Windows PowerShell:
     - `py -m venv .venv && .venv\Scripts\Activate.ps1` (or `python -m venv .venv`)
     - `python -m pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple smart-srt-translator[openai]`

Upload to PyPI
--------------
1. Ensure version in `pyproject.toml` is bumped (e.g., 0.1.1).
2. Upload:
   - `twine upload dist/*`

Notes
-----
- The CLI auto-loads `.env` from the project root to find `OPENAI_API_KEY` and `OPENAI_MODEL`.
- Optional dependency group `openai` provides the OpenAI client: `pip install smart-srt-translator[openai]`.
- The package has no required dependencies by default; providers are pluggable.
