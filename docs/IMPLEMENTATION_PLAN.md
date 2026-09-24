# Implementation plan (Flutter)

Build milestone by milestone; each ends with a working, tested app on the Android emulator (D-23; desktop runs deferred).

## M0 — Scaffold (½ day)
- [x] `flutter create --platforms=android,ios,windows,macos,linux wordpack`; packages from `ARCHITECTURE.md` §1; lints.
- [x] `ProviderScope`, `MaterialApp.router`, light/dark themes from `UI_UX.md` §9 (`ColorScheme` + `WpColors` theme extension, bundled Literata + Atkinson Hyperlegible Next fonts).
- [x] Adaptive shell (bottom bar / rail / rail + tree panel) with placeholder screens and routes.
- [x] l10n set up with `app_en.arb`.
- [x] Check script: `tool/check.sh` / `tool/check.ps1` (`flutter gen-l10n`, `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`).

**DoD:** app runs on an Android emulator and desktop; check script passes.
*Status 2026-09-24:* check script passes (14 tests); integration smoke test passes on the Android emulator (Pixel 9, API 35). Desktop runs deferred (D-23).

## M1 — Domain core (1.5 days)
- [x] `domain/models.dart`, `pos.dart` (IMPORT_FORMAT §5).
- [x] `domain/importer.dart` — matches `fixtures/expected/*.json` exactly for all four fixtures.
- [x] `domain/packing.dart` — `chunk`, `packsForImport`, `rebuildPacks`, `deriveMastery`.
- [x] `domain/learning.dart` — `PassState`, reducer, events, `packStatus`, `continueTarget`.
- [x] `domain/categories.dart`, `tags.dart`.
- [x] Unit tests U-1 … U-26.

**DoD:** `flutter test test/domain` green; 100 % line coverage on `lib/domain` (`flutter test --coverage`).
*Status 2026-09-24:* done — 53 domain tests (U-1 … U-26 plus edge cases), 370/370 lines covered; all four fixtures match their golden files.

## M2 — Database + import (1.5 days)
- [x] Drift tables, database, seeding, migration strategy, schema dump.
- [x] Repositories + `ImportService`.
- [x] Welcome screen, file picking, preview screen (parse in isolate), wordlist home with pack chips.

**DoD:** every fixture imports with the numbers in `fixtures/README.md`; data survives app restart; tests R-1 … R-4 green.
*Status 2026-09-24:* done — R-1 … R-4 plus rollback test, 15 widget tests (import flow, errors, cancel, resume banner, list switching), I-1 and a reopen-the-database test on the emulator; checked by hand on the emulator with the system file picker and a force-stop/relaunch. 90 host tests in total.

## M3 — Learning (2 days)
- [x] `LearningService` + providers.
- [x] `WordCard`, learn screen: Show / Next / Previous, direction toggle + confirm, progress, peek counter, summary sheet.
- [x] Continue button, resume banner.
- [x] Swipe gestures, keyboard shortcuts, haptics.

**DoD:** W-1 … W-3 and I-2 … I-5 green; the worked example in `LEARNING_LOGIC.md` §2 reproduced by service test R-6.
*Status 2026-09-24:* done — R-5, R-6 and 7 more service tests; W-1 … W-3 plus 12 learn-screen widget tests (summary variants, Next pack, Repeat, Previous, swipe, keyboard, I-4/I-5 flows, accessibility guidelines); I-1 … I-5 pass on the emulator. 115 host tests. Checked by hand on the emulator.

## M4 — Review, tags, categories (1.5 days)
- [x] `TaggingService`, `CategoryService` (learned-only rule, find-or-create, case-insensitive).
- [x] `QuickTagBar`, `CategoryRow` with autocomplete + create option.
- [x] Tag visuals on card and rows (border, tint, badges, dashed outline) in both themes.
- [x] Review mode on the learn screen; shortcuts 1–5, C.

**DoD:** W-4 … W-6, I-6 … I-8 green; TalkBack/VoiceOver reads tag badges.
*Status 2026-09-24:* done — R-7, R-8 (9 service tests); W-4 … W-6 with all nine tag combinations in light and dark (25 widget tests); I-6 … I-8 plus keyboard and accessibility-guideline tests on the host; I-6 … I-8 pass on the emulator. Semantics tests check the card is announced as "word, POS, tags". 154 host tests, 8 emulator tests. Checked by hand on the emulator.

## M5 — Explorer (1.5 days)
- [x] `TreeService` streams; flattened tree view with expand/collapse, counts, status icons; state saved in `UiState`.
- [x] Explorer screen: `PageView` card mode + list mode; ordering rules; tagging for learned words.
- [x] Drawer on narrow layouts; search (P1); Tags branch (P1).

**DoD:** I-9, I-10 green; tree counts update live after tagging.
*Status 2026-09-24:* done — tree model (100 % covered) and R-11 (8 service tests: counts, `(no subcategory)`, tag counts, live updates, ordering, search); 9 explorer widget tests (drawer, I-9, live counts, learned-only tagging, list mode, search, keyboard, accessibility); I-9 and I-10 pass on the emulator. 176 host tests, 10 emulator tests. Checked by hand on the emulator.

## M6 — Settings, backup, polish (1.5 days)
- [x] Settings screen; pack-size rebuild with preview dialog; learned-rule setting; theme.
- [x] Manage categories (rename/merge/delete); rename/delete wordlist.
- [x] Backup export (share sheet / save dialog) and restore.
- [ ] Desktop drag-and-drop import (P1) — deferred with desktop runs (D-23).
- [x] Shortcut help overlay; empty and error states; app icon and name.

**DoD:** full test suite green on Android and one desktop OS; manual accessibility pass (TalkBack, 200 % text, keyboard-only on desktop).
*Status 2026-09-24:* done on Android — R-9, R-10, R-12, R-13 and category-management service tests; 13 settings/categories widget tests; a 200 % text walkthrough of every main screen with no overflow; I-11 on the emulator. 206 host tests and 11 emulator tests pass; checked by hand on the emulator (settings, launcher icon). Screen-reader behaviour is covered by semantics and accessibility-guideline tests, not yet by a hands-on TalkBack session. Desktop runs and the keyboard-only desktop pass are deferred (D-23).

**Estimate:** ~10 developer-days.

## After v1
"Open with WordPack" share intent · spaced repetition using recorded stats · multiple categories per word · typed-answer quiz · optional cloud sync.
