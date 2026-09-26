# UI / UX

Material 3, light and dark themes, adaptive to window width. Routing with `go_router`.

**Visual design:** the designer's canvas [WordPack — app design](https://claude.ai/artifact/692F7FARdZGCMMzrwaiAgb) has every screen (phone and desktop, light and dark), the component sheet, all states, clickable prototypes of Learn / Review / Explorer, and the app icon. The values to build with are copied into §9. The canvas decides *how things look*; this document decides *what they do*. Where the canvas and this spec disagree, `DECISIONS.md` D-9 and D-19 – D-22 settle it.

## 1. Adaptive layout

| Width (logical px) | Layout |
|---|---|
| < 600 (phones) | Bottom `NavigationBar`: **Learn · Explore · Settings**. Explorer tree opens as a `Drawer` (☰ in the app bar); the app bar shows the selected node as a breadcrumb. Import via the wordlist home's `+` action. |
| 600 – 839 (small tablets, portrait) | `NavigationRail` on the left; tree in a drawer. |
| ≥ 840 (tablet landscape, desktop) | `NavigationRail` + **permanent tree panel** (280 px, draggable divider 220–420 px, collapsible; state saved in `UiState`) + main area. |

```
≥ 840
┌────┬──────────────────────┬───────────────────────────────────────────┐
│ 📖 │ 🔍 Search words      │                                           │
│Learn│ ▾ 📚 definitions  998│                                           │
│    │   ▾ Packs   5/34 ✓   │          MAIN AREA                        │
│ 🌳 │     ✓ Pack 1         │   (learning card, explorer viewer,        │
│Expl.│     ◐ Pack 2         │    import preview, settings…)             │
│    │     ○ Pack 3         │                                           │
│ ⬆  │   ▾ Categories       │                                           │
│Imp.│     ▾ Emotions    12 │                                           │
│    │         Anger      4 │                                           │
│ ⚙  │         (none)     3 │                                           │
│    │   ▸ Tags             │                                           │
│    │     Uncategorised 979│                                           │
└────┴──────────────────────┴───────────────────────────────────────────┘
```

## 2. Screens and routes

| Screen | Route | Contents |
|---|---|---|
| Welcome | `/` (no wordlists) | Two-line explanation, big **Import CSV** button (desktop: also a drop zone), short description of accepted formats. |
| Import preview | `/import` | Report from `IMPORT_FORMAT.md` §8, editable name field, Cancel / Import. Shows a progress indicator while parsing in the isolate. |
| Wordlist home | `/lists/:id` | Progress (packs learned / total), **Continue** button (label says what it opens, e.g. "Continue · Pack 4 · Word → Definition"), resume banner if a pass is open, grid of pack chips with status. |
| Learn / Review | `/learn/:packId?dir=wd` | Card (§3), direction toggle, progress, summary at the end. |
| Explorer | `/explore/:nodeId` | Card viewer or list (§4). |
| Settings | `/settings` | Settings from REQUIREMENTS §6, Manage categories, Backup, Wordlists (rename/delete). |

## 3. Learning / review card

```
 Pack 1 · abbey – advent        [Word → Def | Def → Word]     16 / 30
 ─────────────────────────────────────────────────────────────────────
 ┃ ⟲                                                                │
 ┃                         accommodate                              │
 ┃                            (verb)                                │
 ┃                    Emotions › Gratitude                          │
 ┃  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  │
 ┃        provide with something desired or needed   (after Show)   │
 ─────────────────────────────────────────────────────────────────────
  [👍 Positive] [👎 Negative] [— Neutral]          (every word, D-32)
  [⇋ Counter-intuitive] [≡ Multiple meanings]
 ─── review only (pack is Learned) ──────────────────────────────────
  Category [ Emotions        ▾ ]   Subcategory [ Gratitude       ▾ ]
 ─────────────────────────────────────────────────────────────────────
  [‹ Prev]              [ Show ]                     [ Next › ]
 ─────────────────────────────────────────────────────────────────────
  WD ✓ mastered   DW ◐ learning     Peeks this pass: 1   ▓▓▓▓▓▓▓▓░░░░░░ 16/30
```

- Widget: `WordCard(word, direction, revealed, variant: learn | review | browse)` — one widget used everywhere.
- Cards always follow source order.
- Part of speech label from `IMPORT_FORMAT.md` §5 (**noun, verb, adj., adv.** …) in a small `Chip`; `Semantics(label: 'adjective')` / `Tooltip` with the full name.
- The answer's space is reserved before Show (measure it with `TextPainter`, or `Visibility(maintainSize: true)`), so revealing never moves the buttons. The answer fades in (§9 Motion). The card has a minimum height of 240 and grows with the text size.
- **Next** = `FilledButton` (primary); **Show** = `FilledButton.tonal`, becomes "Shown" (`onPressed: null`) after use. Both are 56 high.
- Tags are drawn on the card only through `WpColors`. A word's existing tags are **shown in every mode**, including Learn, even when its pack isn't Learned (possible after a pack-size rebuild or a review demotion). The quick tag buttons are shown for every word (D-32); what is hidden outside Review/Explorer-of-learned-words is the **category** controls (D-9).
- When peeks > 0: subtle text "This pass won't count — finish it, then repeat the pack."
- DW: the definition is the prompt (larger, start-aligned if long; scrollable if very long); the word is the answer.
- **Review mode** (pack Learned): a *Review* badge in the app bar, and the quick tag buttons + category row below the card. Using them is not a peek and never reveals the answer. In learning mode (pack not Learned) these controls are **not built at all** and there is no hint or prompt about them.
- Phones: card fills the width; the bottom action bar (Prev / Show / Next) sits in a `SafeArea` above the navigation bar; the review controls scroll with the card.

### Pass summary (bottom sheet on phones, dialog-sized panel on wide screens)

```
 ✓ Clean pass — Pack 1 · Word → Definition mastered.
   [Start Definition → Word]   [Next pack]   [Back to wordlist]

 ✓ Pack 1 learned!                                   (when the learned rule is met)
   [Next pack]   [Review this pack]   [Back to wordlist]

 Pass finished with 4 peeks: accommodate · adverse · airy · alien
   [Repeat pack]   [Switch direction]   [Back to wordlist]
```

No categorise button or prompt anywhere (D-9). Celebration animation is skipped when `MediaQuery.disableAnimations` is true. Light haptic (`HapticFeedback.lightImpact`) on Next, medium on pack learned (mobile only).

## 4. Explorer viewer

- App bar: breadcrumb (`definitions › Categories › Emotions › Anger`), count, `SegmentedButton` Card | List, which side shows first (Word / Definition).
- Card mode: `WordCard` in *browse* variant inside a `PageView` (swipe between words); tap card or Space reveals; no peek counter; no status changes. For Learned words the quick tag buttons and category row are shown (same as review).
- List mode: `ListView.builder` rows with term · pos and the badges on the first line and the **whole definition** wrapped below it — never cut; rows grow to fit (D-33). Tag visuals as on cards (§5); one screen-reader item per row. Tapping opens card mode at that word.
- Order: source order for pack nodes; alphabetical for category, tag, uncategorised and search nodes.
- Empty node: "No words here yet."

## 5. Visual language for tone and traits

Colour + icon + label always together. Icons are Material Symbols Rounded, bundled as static subset fonts and used through `WpIcons` (D-21); names below are the Material Symbols names (`WpIcons` uses camelCase). Colour values are in §9.

| Tag | Card | List row | Icon (`Symbols.`) |
|---|---|---|---|
| Positive | 6 px **left edge** + background tint + tone badge | 4 px left edge | `sentiment_satisfied` |
| Negative | 6 px left edge + tint + tone badge | 4 px left edge | `sentiment_dissatisfied` |
| Neutral | 6 px left edge, **no tint** + tone badge | 4 px left edge | `sentiment_neutral` |
| Counter-intuitive | icon badge + **2 px dashed** card outline (dash 6 / gap 4, replaces the 1 px border) | badge + 2 px dashed outline inset 4 px | `psychology_alt` |
| Multiple meanings | icon badge | badge | `alt_route` |

- Tone owns edge + tint (+ its badge: a 1.5 px ring in the tone colour on surface); traits own badges (+ the dashed outline). They combine freely.
- The edge is painted **inside** the card, so it never shifts content.
- Badges sit **top-right** of the card in the order tone · counter-intuitive · multiple meanings; 32 × 32 (28 on list rows), radius 10, icon 20.
- Implement colours as a `ThemeExtension<WpColors>` in `lib/ui/theme/wp_colors.dart` with light and dark instances (tone, trait and pack-status colours); widgets read `Theme.of(context).extension<WpColors>()!`. Never hard-code colours in widgets.
- Dashed outline: a small `CustomPainter` (`DashedBorderPainter`) wrapping the card.
- Badges on cards/rows are icon-only with `Tooltip` + `Semantics(label: 'Counter-intuitive')`; quick buttons show icon + text.
- The term's text colour never changes (contrast guaranteed).

### Quick tag buttons

- Five toggle buttons with icon + text, each with `Semantics(toggled: …)`. Tones are mutually exclusive (tap the active one to clear); traits toggle independently. (`SegmentedButton<Tone>` with `emptySelectionAllowed: true` + two `FilterChip`s is an acceptable implementation.)
- Min touch target 48 × 48 dp; on phones tone (3) and traits (2) are on separate rows; at 200 % text they wrap to up to 5 rows.
- Each tap calls `TaggingService.setTone / toggleTrait` immediately; UI updates from the drift stream; errors show a `SnackBar` and the stream restores the true state.

### Category row

- Two comboboxes built with `Autocomplete<CategoryOption>` (or `DropdownMenu(enableFilter: true, requestFocusOnTap: true)`): typing filters case-insensitively; if no exact match the last option is `Create "…"`.
- Subcategory disabled until a category is chosen; lists only that category's subcategories. On phones the suggestion menu opens upwards.
- Saves on selection; small "Saved ✓" indicator; a clear (×) button on each field.

## 6. Dialogs

- **Switch direction mid-pass**: "Switch to Definition → Word? This pass will restart." [Cancel] [Switch]
- **Change pack size**: "All packs in 2 wordlists will be rebuilt with 20 words each (definitions: 34 → 50 packs). Word progress is kept; 1 pass in progress will be discarded." [Cancel] [Rebuild packs] — numbers from `SettingsService.previewPackSizeChange()`.
- **Delete wordlist / category / restore backup**: name the item and what will be affected.

## 7. Input: gestures and keyboard

Touch: tap card = Show (learn) / reveal (explorer); swipe left = Next; swipe right = Previous; long-press a word row = open it in card view.

Keyboard (desktop and hardware keyboards; `Shortcuts` + `Actions` widgets):

| Key | Learn / review | Explorer |
|---|---|---|
| Space / Enter | Show | Reveal / hide |
| → or N | Next | Next |
| ← or P | Previous | Previous |
| D | Toggle direction (confirm mid-pass) | Toggle side |
| 1 / 2 / 3 | Positive / Negative / Neutral | same |
| 4 / 5 | Counter-intuitive / Multiple meanings | same |
| C | Focus category field* | same* |
| Ctrl/⌘ + F | Focus search | Focus search |
| Esc | Close dialog/drawer, leave field | same |
| ? | Shortcut help | same |

\* only for Learned words (review, explorer). Shortcuts are ignored while a text field has focus.

## 8. Tree

- Implement as a flattened `ListView.builder` of visible nodes (fast for thousands of nodes) — no tree package needed.
- Icons (`Symbols.`): wordlist `menu_book`; packs group `stacks`; pack learned `check_circle` (filled, `statusLearned`) / learning `clock_loader_40` (`statusLearning`) / new `radio_button_unchecked` (`statusNew`); category `folder` / `folder_open`; subcategory `label`; tags group `sell`; uncategorised `label_off`; tag nodes use the tag icons and colours.
- Rows are 44 high with a pointer, 48 on touch.
- Counts right-aligned, muted. Packs header shows `learned / total`.
- Desktop keyboard: ↑ ↓ move, → expand, ← collapse, Enter select (when the tree has focus). `Semantics` with expanded/collapsed state.
- Node ids: `wl:<id>`, `wl:<id>:packs`, `pack:<id>`, `wl:<id>:cats`, `cat:<wlId>:<catId>`, `sub:<wlId>:<subId>`, `nosub:<wlId>:<catId>`, `wl:<id>:uncat`, `wl:<id>:tags`, `tag:<wlId>:<positive|negative|neutral|counterIntuitive|multipleMeanings|untagged>`, `search:<query>`.
- The tree is built from drift `watch()` streams, so it updates live after tagging, categorising or completing a pass.

## 9. Design values (from the design canvas)

Copied from the canvas's *Handoff — design values* board. Both themes were checked by the designer for WCAG AA.

### Colours

| Value | Light | Dark | Flutter |
|---|---|---|---|
| Background | `#F5F2EA` | `#141311` | `WpColors.background` |
| Surface | `#FFFDF8` | `#1E1C19` | `colorScheme.surface` |
| Surface variant | `#EDE8DD` | `#292723` | `WpColors.surfaceVariant` |
| Surface 3 | `#E3DDD0` | `#34312C` | `colorScheme.surfaceContainerHighest` |
| Text primary | `#1E1C18` | `#EEE9DF` | `colorScheme.onSurface` |
| Text secondary | `#57524A` | `#BDB6A9` | `colorScheme.onSurfaceVariant` |
| Text tertiary | `#6B655A` | `#A39C90` | `WpColors.textTertiary` |
| Primary / on primary | `#2F4A8A` / `#FFFFFF` | `#A8BDF4` / `#13203F` | `colorScheme.primary` / `onPrimary` |
| Tonal bg / on tonal | `#E2E8F5` / `#233A6E` | `#27314A` / `#D0DBFA` | `colorScheme.primaryContainer` / `onPrimaryContainer` |
| Divider | `#E0D9CB` | `#38352F` | `colorScheme.outlineVariant` |
| Control border | `#8F877A` | `#7A7468` | `colorScheme.outline` |
| Positive edge + icon / tint | `#2B7A4B` / `#E9F3EB` | `#7CCB98` / `#1A2920` | `WpColors.positive` / `positiveTint` |
| Negative edge + icon / tint | `#B3372A` / `#FBEAE6` | `#F29481` / `#36201C` | `WpColors.negative` / `negativeTint` |
| Neutral edge + icon (no tint) | `#6B655A` | `#ABA497` | `WpColors.neutral` |
| Counter-intuitive badge / badge bg / outline | `#6240C0` / `#EEE8FA` / `#7654CF` | `#C5B2F8` / `#2C2545` / `#A68DEC` | `WpColors.counter` / `counterBg` / `counterOutline` |
| Multiple meanings badge / badge bg | `#875500` / `#F9EDD3` | `#EDC36D` / `#382C13` | `WpColors.multi` / `multiBg` |
| Pack status New | `#6B655A` | `#ABA497` | `WpColors.statusNew` |
| Pack status Learning / bg | `#9E5200` / `#FAEEDF` | `#F2AE55` / `#35291A` | `WpColors.statusLearning` / `statusLearningBg` |
| Pack status Learned / bg | `#1F6B45` / `#E5F0E8` | `#7CCB98` / `#1C2A21` | `WpColors.statusLearned` / `statusLearnedBg` |

### Typography

Fonts: **Literata** (words and definitions) and **Atkinson Hyperlegible Next** (UI), both SIL OFL, **bundled** in `assets/fonts/` (D-20). Fallbacks: Georgia / system sans. Sizes in sp; they scale with the system text size and layouts are tested at 200 %.

| Role | Family / weight | Size / line height |
|---|---|---|
| Card word | Literata 600 | 34 / 1.15, −0.01em (desktop 44) |
| Card definition (answer) | Literata 400 | 20 / 1.45 |
| Card definition (prompt, DW) | Literata 400 | 22 / 1.42; over 140 chars → 19 / 1.45 |
| Display (celebration, big numbers) | Literata 600 | 28–34 / 1.15 |
| Part-of-speech chip | Literata italic 400 | 14 / 1.0 |
| Headline (screen title) | Atkinson Hyperlegible Next 700 | 22 / 1.25 |
| Title (app bar, section) | Atkinson Hyperlegible Next 700 | 18 / 1.25 |
| Body | Atkinson Hyperlegible Next 400 | 16 / 1.5 |
| Body small / supporting | Atkinson Hyperlegible Next 400 | 14 / 1.45 (13 for sub-labels) |
| Labels and buttons | Atkinson Hyperlegible Next 600 | 15 / 1.2 (large buttons 16–17) |
| Chips (tag buttons, status) | Atkinson Hyperlegible Next 600 | 13–14 / 1.2 |
| Eyebrow | Atkinson Hyperlegible Next 700 | 12 / 1.3, +0.08em, uppercase |

### Spacing, shape, elevation

| Value | Spec |
|---|---|
| Spacing scale | 4 · 8 · 12 · 16 · 24 · 32 · 48. Phone side gutter 16; desktop content padding 28–32 |
| Corner radius | card 20 · buttons 14 (large 16, Continue 18) · tag buttons and fields 12 · chips 8 · pack tiles 14 · bottom sheet 28 (top corners) · dialog 24 · badges 10 |
| Tone edge | 6 px on cards, 4 px on list rows, painted inset |
| Elevation | cards: `0 1 2` at 8 % + `0 8 24` at 8 % (light); dark uses surface steps with shadows at 35 %. Sheets and dialogs: `0 12 40` |
| Touch targets | every control ≥ 48 × 48 dp; primary study actions 56 high |
| Contrast | all text pairs ≥ 4.5:1 in both themes; control borders ≥ 3:1 |
| 200 % text | Learn/Review body is a scroll view; card min height 240 and grows; the Continue label may wrap to two lines |

### Other icons (`Symbols.`)

Show/peek `visibility` · `visibility_off`; nav Learn `school`, Explore `account_tree`, Settings `settings`; Import `upload_file`; Review badge `edit_note`; clean pass `task_alt`; unfinished pass `history`. Weight 400, optical size 24, fill 0; the active state uses the filled font (`WpIcons.filled`). Tag and tree icons: §5 and §8.

### Motion

| Moment | Motion | With `MediaQuery.disableAnimations` |
|---|---|---|
| Show | answer fades in, 160 ms ease-out; its space is already reserved | instant |
| Next / Previous | card slides 24 px + fades, 180 ms; swipe follows the finger, commits at 60 px or a fling | 120 ms crossfade |
| Tone / trait tap | edge, tint, outline and badge change instantly (≤ 100 ms colour tween) | same |
| Pass summary | bottom sheet rises in 240 ms (phone); panel fades + scales from 0.98 (desktop) | fade only |
| Pack learned | 30 ticks draw around a seal (one per word, 16 ms stagger) → disc → check draws → text rises; ~1.2 s, once | static seal, text appears |

### App icon

1024 × 1024 master on the canvas's Handoff page (*App icon* board). Export the platform sizes from it with `flutter_launcher_icons` (dev dependency).
