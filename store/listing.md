# Play Store listing — WordPack

Everything to paste into Play Console. Limits are Play's; counts are checked.

## App details

| Field | Value |
|---|---|
| App name (≤ 30) | `WordPack: Vocabulary Packs` (26) |
| Package | `io.github.gauravpwagh.wordpack` |
| Default language | English (United States) – en-US |
| App or game | App |
| Free or paid | Free |
| Category | Education |
| Tags (pick up to 5 in Console) | Vocabulary, Flashcards, Language learning, Study, Test prep |
| Contact email | vijwagh31@gmail.com (shown publicly on the listing — change it here and in `privacy-policy.md` if you prefer another address) |
| Website | https://github.com/gauravpwagh/word-pack (optional) |
| Privacy policy URL | the published `store/privacy-policy.md` — see [Hosting the privacy policy](#hosting-the-privacy-policy) |

## Short description (≤ 80)

```
Learn vocabulary from your own word lists, one small pack at a time.
```
(68 characters)

## Full description (≤ 4000)

```
WordPack turns your own word list into small, manageable packs and drills each pack until you know it — without peeking.

IMPORT YOUR OWN WORDS
• Pick a CSV file with word, part of speech and definition columns, or a plain list in the form “abbey - n. a monastery ruled by an abbot”.
• See a preview before saving: how many words were found, which lines were skipped and why, and how many packs you’ll get.
• Parts of speech are shown clearly: noun, verb, adj., adv. and more.

LEARN ONE PACK AT A TIME
• Words are split into packs of 30 in file order (you choose the size, from 5 to 100).
• One card at a time: tap Next if you knew it, Show if you need to peek.
• Any peek means the pack gets repeated. A pack is learned only after a clean pass — no reveals.
• Practise Word → Definition, Definition → Word, or both. You decide which clean passes make a pack count as learned.
• Pick up exactly where you left off.

ORGANISE WHAT YOU’VE LEARNED
• Once a pack is learned, sort its words into your own categories and subcategories.
• One-tap tags: Positive, Negative or Neutral tone, plus Counter-intuitive and Multiple meanings.
• Tags show up everywhere as colours and icons, so tricky words stand out.

EXPLORE
• Browse a tree of wordlists, packs, categories and tags, with live counts.
• Step through any group as cards, or scan it as a list.
• Search every word and definition.

PRIVATE AND OFFLINE
• No account, no ads, no tracking.
• The app has no internet permission: your words never leave your device.
• Export a backup file to move everything to another device.

Also: light and dark themes, large-text support, screen-reader labels, swipe gestures and keyboard shortcuts.
```
(≈ 1,650 characters)

## Graphics

| Asset | File | Play requirement |
|---|---|---|
| App icon | `store/icon-512.png` | 512 × 512 PNG, ≤ 1 MB |
| Feature graphic | `store/feature-graphic.png` | 1024 × 500, 24-bit PNG or JPEG, no alpha |
| Phone screenshots | `store/screenshots/01…08` | 2–8 images, 1080 × 2160 (2:1), 24-bit PNG |

Screenshot order (upload in this order):

1. `01-learn.png` — a card revealed mid-pass, peek counter
2. `02-review-tags.png` — reviewing a learned pack: tone, category, quick tag buttons
3. `03-packs.png` — wordlist home: progress, Continue, pack grid
4. `04-explore-card.png` — explorer card with both trait badges and dashed outline
5. `05-list.png` — list mode with tone colours
6. `06-tree.png` — the word tree with categories and tags
7. `07-dark.png` — dark theme
8. `08-import.png` — import preview

Tablet screenshots are optional; add them later if you want the listing to appear in tablet-specific surfaces.

Regenerating: `flutter test tool/render_store_art_test.dart` renders the icon and feature graphic (the feature graphic comes out with an alpha channel; convert it to 24-bit before uploading). Screenshots come from the emulator with the demo data built by `flutter test tool/store_seed_test.dart` (restore `build/store/wordpack-store-demo.json` from Settings › Restore backup), display set to 1080 × 2160 (`adb shell wm size 1080x2160`) and the System UI demo mode for a clean status bar.

## App content (Policy › App content)

| Section | Answer |
|---|---|
| Privacy policy | URL above |
| Ads | No, the app does not contain ads |
| App access | All functionality is available without special access (no login) |
| Content rating | Questionnaire category **Reference, News, or Educational**; answer No to every content question → expected rating: Everyone / PEGI 3 |
| Target audience | 13+ (or 18+). Choosing under-13 age groups pulls in the Families policy; avoid unless you intend it |
| News app | No |
| COVID-19 contact tracing | No |
| Data safety | See below |
| Government app | No |
| Financial features | None |
| Health | No |

### Data safety

- Does your app collect or share any of the required user data types? **No.**
  (Words, tags and progress are stored only on the device; Google's definition of “collected” means sent off the device. The release build has no INTERNET permission.)
- Is all of the user data collected by your app encrypted in transit? — not asked once you answer No.
- Do you provide a way for users to request that their data is deleted? — not asked; users delete data by deleting wordlists or uninstalling.

The resulting label reads: “No data collected · No data shared with third parties”.

## Release notes (v1.0.0, build 1)

```
<en-US>
First release: import your word list, learn it in small packs, tag and categorise what you’ve learned, and explore it all offline.
</en-US>
```

## Hosting the privacy policy

Play needs a public, non-PDF web page. Any of these works:

1. **Repository file** — if the GitHub repo is public, use
   `https://github.com/gauravpwagh/word-pack/blob/main/store/privacy-policy.md`.
2. **GitHub Pages** — Settings › Pages › Deploy from branch `main`, folder `/ (root)`; the page is then at
   `https://gauravpwagh.github.io/word-pack/store/privacy-policy` (public repo required on free plans).
3. A private repo: publish the policy as a GitHub Gist or on any site you own.
