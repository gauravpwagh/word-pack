# Requirements

Priority: **P0** = required for v1, **P1** = should ship in v1 if time allows, **P2** = later.
IDs are referenced from `TEST_PLAN.md` and `IMPLEMENTATION_PLAN.md`.

## 1. Import

| ID | Pri | Requirement |
|---|---|---|
| IMP-1 | P0 | User picks a `.csv` file (also accept `.txt`) with the system file picker. Desktop: drag-and-drop onto the window (P1). Android/iOS: "Open with WordPack" from other apps (P2). Max 5 MB. |
| IMP-2 | P0 | The file is parsed per `IMPORT_FORMAT.md` (format auto-detected). Nothing is saved until the user confirms. |
| IMP-3 | P0 | Preview shows: detected format, editable wordlist name (default = file name without extension), number of valid words, part-of-speech breakdown with display labels (noun, verb, adj., adv., …), first 10 words, skipped lines with line number and reason, number of duplicates removed, number of packs that will be created. |
| IMP-4 | P0 | Confirming creates **one** new wordlist with all valid words in file order and generates its packs with the current pack size. |
| IMP-5 | P0 | Importing 1,000 words (parse + save) takes under 2 s on a mid-range phone; parsing runs in a background isolate so the UI never freezes. |
| IMP-6 | P1 | Rename and delete a wordlist (delete asks for confirmation; removes its words, packs, open passes; categories remain). |

**Acceptance:** `fixtures/definitions.txt` → 998 words, 34 packs (33 × 30 + 1 × 8), 0 skipped. Other fixtures: see `fixtures/README.md`.

## 2. Parts of speech

| ID | Pri | Requirement |
|---|---|---|
| POS-1 | P0 | Every word shows its part of speech with a clear label: noun, verb, adj., adv., pron., prep., conj., interj., phrase, idiom, abbr. (full name in tooltip / screen-reader text, e.g. "adjective"). |
| POS-2 | P0 | Unrecognised codes are shown as written, followed by a dot (e.g. `det.`). Missing POS shows nothing. |
| POS-3 | P1 | Setting to hide part of speech on the card. |

## 3. Learning mode

| ID | Pri | Requirement |
|---|---|---|
| LRN-1 | P0 | User starts learning from a wordlist (**Continue** picks the next pack per `LEARNING_LOGIC.md` §7) or from any specific pack. |
| LRN-2 | P0 | One card at a time, **in source order**, showing only the prompt side (word in WD, definition in DW). |
| LRN-3 | P0 | Actions: **Next** (move on without revealing) and **Show** (reveal the answer on the same card). After Show, the only forward action is Next. |
| LRN-4 | P0 | Any Show during a pass marks the pack **Learning** and fails the pass; the whole pack must be repeated. |
| LRN-5 | P0 | End of pass shows a summary: clean or not, number of peeks, the peeked words. Buttons: *Repeat pack*, *Switch direction*, *Next pack*, *Back to wordlist*. **No categorise prompt.** |
| LRN-6 | P0 | A clean pass masters that pack in that direction. When the learned rule (setting) is satisfied, the pack and its words become **Learned**. |
| LRN-7 | P0 | Direction toggle (Word → Definition / Definition → Word) on the learning screen. Switching mid-pass asks for confirmation and restarts the pass. |
| LRN-8 | P0 | Progress: `card 7 / 30`, direction, the pack's status in each direction, peeks this pass. |
| LRN-9 | P0 | Pass progress is saved to the database after every action; closing or killing the app and reopening resumes at the same card with the same reveal state. |
| LRN-10 | P1 | **Previous** button to look at earlier cards of the current pass; doing so never adds or removes peeks. |
| LRN-11 | P0 | Studying a Learned pack is **Review**. Review works exactly like learning, and additionally shows the category controls on each card (see §4). The quick tag buttons are shown in both. |

Full rules: `LEARNING_LOGIC.md`.

## 4. Categorising and tagging

| ID | Pri | Requirement |
|---|---|---|
| CAT-1 | P0 | Categorising is available **only for words whose pack is Learned**, in **Review** and in the **Explorer** viewer. For other words the category controls are not shown (existing categories are still displayed). The app never prompts the user to categorise. Tone and traits are not restricted (TAG-1, D-32). |
| CAT-2 | P0 | Each word has at most one category and, optionally, one subcategory under it. |
| CAT-3 | P0 | Category input is a combobox: typing filters existing categories; if no exact match, the last option is `Create "<text>"`. Subcategory works the same, limited to the chosen category's subcategories, and is disabled until a category is chosen. |
| CAT-4 | P0 | Names are trimmed and inner whitespace collapsed; matching is case-insensitive (`Law` = `law`; the first spelling entered is kept). |
| CAT-5 | P0 | Clearing the category clears the subcategory. |
| CAT-6 | P0 | Categories are shared across all wordlists. |
| CAT-7 | P1 | Manage categories: rename, merge, delete (affected words lose the category/subcategory). |
| TAG-1 | P0 | **Quick buttons** on the card for **every word**, while learning, reviewing and in the explorer (D-32): `Positive`, `Negative`, `Neutral`, `Counter-intuitive`, `Multiple meanings`. One tap applies/removes; changes save immediately; tagging is never a peek. |
| TAG-2 | P0 | Tone is single-choice: tapping another tone replaces it, tapping the active tone clears it. Traits toggle independently and combine with any tone. |
| TAG-3 | P0 | Tags are displayed wherever the word appears (learning/review card, explorer card, list rows) using the visual spec in `UI_UX.md` §5. Colour is never the only signal. |
| TAG-4 | P1 | Keyboard shortcuts 1–5 for the quick buttons, `C` to focus the category box. |

## 5. Explorer

| ID | Pri | Requirement |
|---|---|---|
| EXP-1 | P0 | Tree panel always visible on wide windows (≥ 840 logical px: tablets in landscape, desktop); on phones it is one tap away in a drawer. |
| EXP-2 | P0 | Per wordlist: `Packs` (each pack with status icon), `Categories` (category → subcategories, plus `(no subcategory)` when needed), `Uncategorised`. Each node shows a word count. |
| EXP-3 | P0 | Selecting a node shows its words **one at a time** with Previous / Next, `n / total`, tap to reveal. Selecting a category shows all its words including subcategories. |
| EXP-4 | P0 | Explorer never changes learning status. |
| EXP-5 | P0 | The explorer card shows the quick tag buttons for every word, and the category controls for words of Learned packs (CAT-1). |
| EXP-6 | P1 | List view of the same words. |
| EXP-7 | P1 | `Tags` node: Positive / Negative / Neutral / Counter-intuitive / Multiple meanings / Untagged. |
| EXP-8 | P1 | Search box filters words by term or definition. |
| EXP-9 | P1 | Remember expanded nodes and last selection. |
| EXP-10 | P1 | "Study this pack" action on pack nodes. |

## 6. Settings

| Setting | Default | Values | Effect |
|---|---|---|---|
| Pack size | 30 | 5 – 100 | Rebuilds **all** packs after confirmation (`LEARNING_LOGIC.md` §6) |
| Default direction | Word → Definition | WD, DW | |
| Pack counts as Learned after | Clean pass in both directions | both, either, WD only, DW only | Re-evaluated instantly for all packs |
| Show part of speech | On | on/off | |
| Peek during review demotes the pack | Off | on/off | |
| Theme | System | light, dark, system | |

## 7. Data

| ID | Pri | Requirement |
|---|---|---|
| DAT-1 | P0 | Data stored on the device in SQLite (drift); survives restarts and app updates (schema migrations). |
| DAT-2 | P1 | Export a full backup as a JSON file (system share sheet / save dialog); import a backup (replaces everything, with confirmation). This is also how data moves between devices. |

## 8. Non-functional

- Fully offline; the app makes no network requests.
- Android 8+ and iOS 15+; desktop builds for Windows, macOS, Linux. Phone portrait from 360 logical px wide up to desktop windows.
- Accessibility: screen-reader labels (`Semantics`) for all icon-only elements, text scaling up to 200 % without clipping, 48 × 48 dp touch targets, contrast AA, full keyboard use on desktop.
- Any learning action (Show/Next) updates the screen in < 100 ms.
- All UI strings in ARB files (`lib/l10n/app_en.arb`) for later translation.
