# WordPack — Vocabulary Pack Learner (Flutter)

WordPack imports a CSV of words and definitions, splits it into small **packs** (30 words by default), and drills each pack until the learner gets through the whole pack **without peeking**. Once a pack is learned, its words can be organised into a two-level **category → subcategory** taxonomy and tagged by **tone** (positive / negative / neutral) and **traits** (counter-intuitive, multiple meanings) with one-tap quick buttons; tags are shown with colours and icons wherever the word appears. An **explorer tree** lets the user browse wordlists, packs, categories and subcategories and step through the words in any node.

**Platform:** a single **Flutter** app, fully **offline**, data stored on the device in SQLite. Targets: Android and iOS (v1), plus Windows / macOS / Linux desktop from the same code (wide-screen layout with the tree always visible). No server, no account.

This repository contains the **specification** and the app being built from it (progress: [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md); milestones M0 – M6 done on Android). The spec is written so a developer or a coding agent (Claude Code) can build the app without further conversation. All product decisions are in [`docs/DECISIONS.md`](docs/DECISIONS.md).

## Document map

| File | What it answers |
|---|---|
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Confirmed decisions (no open questions) |
| [`docs/REQUIREMENTS.md`](docs/REQUIREMENTS.md) | What the app must do, settings, acceptance criteria |
| [`docs/IMPORT_FORMAT.md`](docs/IMPORT_FORMAT.md) | Accepted CSV layouts, detection, parsing, part-of-speech labels |
| [`docs/LEARNING_LOGIC.md`](docs/LEARNING_LOGIC.md) | Packs, passes, the "no peeking" rule, learned rule, rebuilding packs, review |
| [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) | Drift (SQLite) tables, invariants, derived values, backup format |
| [`docs/UI_UX.md`](docs/UI_UX.md) | Screens, adaptive layout, card, quick tag buttons, colours/icons, shortcuts, gestures |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Flutter packages, project layout, layers, state management |
| [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md) | Milestones and ordered tasks with definitions of done |
| [`docs/TEST_PLAN.md`](docs/TEST_PLAN.md) | Unit, repository, widget and integration tests |
| [`DESIGN_BRIEF.md`](DESIGN_BRIEF.md) | Plain-language brief and deliverables list for the visual designer |
| [`CLAUDE.md`](CLAUDE.md) | Working rules for a coding agent |
| [`flutter-best-practices.md`](flutter-best-practices.md) | General Flutter conventions (structure, widgets, performance, testing, security, CI) the code should follow |
| [`reference/import_parser.py`](reference/import_parser.py) | Verified behaviour oracle for the importer (generates the golden files) |
| [`fixtures/`](fixtures/) | Real sample file (998 words), CSV variants, edge cases, and `expected/` golden outputs |

Read in this order: README → DECISIONS → REQUIREMENTS → LEARNING_LOGIC → DATA_MODEL → UI_UX → ARCHITECTURE → IMPLEMENTATION_PLAN.

## Feature summary

1. **Import** a CSV (or the plain `word - pos. definition` text format) → one new wordlist, with a preview and error report before saving. Parts of speech shown as **noun, verb, adj., adv., pron., prep., conj., interj., …**
2. **Packs**: consecutive words in file order, *N* per pack (setting, default 30); last pack may be shorter.
3. **Learning**: one card at a time, in source order. **Next** = "I knew it"; **Show** = reveal. Any Show makes the pack *Learning* and the whole pack must be repeated; a pass with zero reveals is a clean pass.
4. **Direction**: *Word → Definition* or *Definition → Word*. Which clean passes make a pack *Learned* is a user setting (default: **both directions**).
5. **Categorise and tag** — only for words of **Learned** packs, while reviewing them or in the explorer. No prompts. One category + optional subcategory per word, from dropdowns that suggest all earlier entries (shared across wordlists).
6. **Quick tag buttons**: Positive / Negative / Neutral (pick one) and Counter-intuitive / Multiple meanings (toggles).
7. **Visuals**: tone = coloured left border + tint; traits = icon badges (+ dashed outline for counter-intuitive). Always icon + colour.
8. **Explorer**: tree `Wordlist → Packs / Categories → Subcategories / Tags / Uncategorised`; selecting a node shows its words one at a time.
9. **Settings**: pack size (rebuilds all packs), default direction, learned rule, show part of speech, theme; backup export/import.

## Running (once built)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift + riverpod codegen
flutter run                        # pick a device / emulator / desktop
flutter test                       # unit, repository and widget tests
flutter test integration_test      # end-to-end on a device or desktop
./tool/check.sh                    # milestone gate: l10n, format, analyze, test (Windows: tool\check.ps1)
```

### Android release (Play Store)

Application ID: `io.github.gauravpwagh.wordpack` (D-31). One-time setup: create an upload keystore **outside the repository** and copy `android/key.properties.example` to `android/key.properties` (git-ignored) with its passwords and path. Then:

```bash
flutter build appbundle --release   # build/app/outputs/bundle/release/app-release.aab
```

Raise the `+N` build number in `pubspec.yaml` before every upload. Back up the keystore and its passwords; losing them means asking Play support for an upload-key reset.

Building for Windows needs Developer Mode turned on (Settings → For developers) so Flutter can link plugins.

In the app, tap **Import** and pick `fixtures/definitions.txt` or `fixtures/sample-columns.csv` (copy them to the device first).

## Glossary

| Term | Meaning |
|---|---|
| Wordlist | Everything created by one import. |
| Word | One entry: term, part of speech, definition. |
| Pack | A group of up to *N* consecutive words from one wordlist. |
| Direction | `WD` = show word, recall definition. `DW` = show definition, recall word. |
| Pass | One run through every card of a pack in one direction, in source order. |
| Reveal / peek | Tapping **Show**. |
| Clean pass | A pass completed with zero reveals. |
| Review | Studying a pack that is already Learned; this is where categorising and tagging happen. |
| Tone | Exactly one of positive / negative / neutral, or none. |
| Trait | Zero or more of counter-intuitive, multiple meanings. |
