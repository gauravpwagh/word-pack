# Notes for the coding agent

You are building WordPack v1 as a **Flutter** app (offline, SQLite via drift) from the specification in this repo. The spec is the source of truth; if code and spec disagree, fix the code or record the question — don't silently diverge.

## How to work
1. Read `README.md`, `docs/DECISIONS.md`, then REQUIREMENTS, LEARNING_LOGIC, DATA_MODEL, UI_UX, ARCHITECTURE.
2. Follow `docs/IMPLEMENTATION_PLAN.md` milestone by milestone; tick checkboxes as you go.
3. Write domain unit tests before the code they test. Put test IDs (U-n, R-n, W-n, I-n) in test descriptions.
4. If the spec doesn't cover something, choose the simplest option, add a row to `docs/DECISIONS.md` marked *Assumed*, and continue.

## Rules
- `lib/domain/**` is pure Dart: no `package:flutter`, no drift, no `DateTime.now()` or random IDs inside — inject `Clock` and `IdGenerator`.
- The importer must reproduce `fixtures/expected/*.json` exactly (behaviour oracle: `reference/import_parser.py`). Copy fixtures into `test/fixtures/` or read them via a relative path.
- Every user action = one service method = one `db.transaction`.
- Pack status is derived (`packStatus`), never stored.
- Tagging/categorising must throw `WordNotLearnedException` unless the word's pack is Learned. Never add a prompt/nudge to categorise.
- Cards are always in source order — never shuffle.
- Tag and status colours only through the `WpColors` theme extension; always icon + colour + `Semantics` label.
- Design values (colours, fonts, spacing, radii, icons, motion) come from `docs/UI_UX.md` §9 — don't invent new ones.
- Fonts are bundled assets; never use `google_fonts` (it downloads at runtime).
- Parts of speech use the labels in `docs/IMPORT_FORMAT.md` §5 (noun, verb, adj., adv., …).
- All UI strings in `lib/l10n/app_en.arb`.
- No network access in the app.
- Before finishing a milestone: `dart format --set-exit-if-changed . && flutter analyze && flutter test` (and `flutter test integration_test` from M3).
- There is no "reset pack" feature (D-18) — don't build one.
