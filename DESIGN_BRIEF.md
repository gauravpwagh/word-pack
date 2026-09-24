# WordPack — Design Brief

> **Status: delivered (24 Sep 2026).** The design is on the canvas [WordPack — app design](https://claude.ai/artifact/692F7FARdZGCMMzrwaiAgb), and its values are in `docs/UI_UX.md` §9. This brief is kept for reference. Where the spec overrode the design, see `docs/DECISIONS.md` D-9 and D-18 – D-22.

## 1. The product in one paragraph

WordPack is a vocabulary app. The user imports a file of words and definitions, and the app splits it into small **packs** of 30 words. The user studies one pack at a time with flashcards. On each card they either tap **Next** ("I knew it") or tap **Show** to peek at the answer. **One peek means the whole pack must be repeated.** A pack is **Learned** only after the user gets through all 30 cards without peeking, in both directions: word → definition and definition → word. Once a pack is learned, the user can sort its words into their own categories and tag each word's feel (positive, negative, neutral) and quirks (counter-intuitive, multiple meanings). An explorer lets them browse everything they've built.

## 2. Who uses it

Adults building vocabulary for exams (GRE/IELTS-style lists), work or reading. They study in short sessions on their phone (commute, breaks) and in longer sessions on a laptop. Their word lists are serious and dense, with definitions like *"impervious to pleas, persuasion, requests, reason."*

## 3. How it should feel

- **Calm and focused.** One card at a time, with nothing competing for attention. It should feel like a quiet study desk, not a game.
- **Honest about progress.** The "no peeking" rule is strict, so the interface should make it clear without being punishing. A peek is simply noted ("this pass won't count"), not shamed.
- **Rewarding at the right moment.** Learning a whole pack is a real achievement and deserves a small celebration. Individual cards don't need one.
- **Personal.** Categories and tags are the user's own way of organising their mind. The tagged views should look rich and satisfying to browse.

## 4. What's fixed and what's yours

**Fixed (product rules; please keep):**
- The screens and their content (§5).
- Show and Next as the two main actions, with Next as the primary one.
- Tone is shown by a **coloured left edge + light background tint** on the card.
- Counter-intuitive and multiple meanings are shown as **small icon badges**, and counter-intuitive also gets a **dashed outline** around the card.
- Tone and traits can combine on one word. Example: negative + counter-intuitive = red edge, red tint, dashed outline and a badge. All combinations must look clear together.
- Colour is **never the only signal**: every tag has an icon too, for colour-blind users.
- The tag buttons and category fields appear **only when reviewing a learned pack** (or browsing it in the explorer). Never show them, hint at them or prompt for them while the user is still learning.
- Light **and** dark themes.
- Touch targets at least 48 × 48 dp; text contrast at least WCAG AA; layouts must survive 200 % text size.

**Yours to decide:**
- Typography, colour palette (including the exact tag colours, as long as each is distinct and meets contrast), icons, spacing, corner radii, card style, motion, empty-state illustrations, app icon and wordmark.
- Layout details within each screen.

The app is built in Flutter with Material 3 components. Designing on top of Material 3 is the cheapest to build, but you're free to restyle it.

## 5. Screens

### Sizes to design
| Frame | Size | Navigation |
|---|---|---|
| Phone | 360 × 780 | Bottom bar: Learn · Explore · Settings. Explorer tree opens as a slide-out drawer. |
| Desktop | 1280 × 800 | Left rail for navigation, **explorer tree always visible** as a side panel (~280 px), main area on the right. |

(A tablet frame is optional; it uses the phone layout in portrait and the desktop layout in landscape.)

### Screen list

| # | Screen | Purpose | Must show |
|---|---|---|---|
| 1 | **Welcome** | First launch, no words yet | Short explanation, a big "Import CSV" action, a note on accepted file formats |
| 2 | **Import preview** | Check the file before saving | Detected format, editable list name, "998 words ready", part-of-speech breakdown (noun 501 · adj. 336 · verb 149 · adv. 12), skipped lines with reasons, "34 packs of 30", first 10 words, Cancel / Import |
| 3 | **Wordlist home** | Starting point for studying | Progress (e.g. 5 of 34 packs learned), a **Continue** button that says what it opens ("Continue · Pack 6 · Word → Definition"), a banner to resume an unfinished pass, a grid of all packs with their status (New / Learning / Learned) |
| 4 | **Learn** | The core flashcard screen | Pack name and word range, direction switch (Word → Definition / Definition → Word), card position (16 / 30), the card, Previous / Show / Next, peek counter, status of the pack in each direction, progress bar |
| 5 | **Review** | Same as Learn, for a learned pack | Everything on Learn, plus a "Review" badge, the **5 quick tag buttons** and the **category + subcategory fields** |
| 6 | **Pass summary** | End of a run through the pack | Three variants (§6) |
| 7 | **Explorer** | Browse any group of words | Breadcrumb (definitions › Categories › Emotions › Anger), word count, card/list switch, one card at a time with previous/next, or a list view |
| 8 | **Explorer tree** | Navigation of everything | Wordlist → Packs (with status icons) / Categories → Subcategories / Tags / Uncategorised, with a count on each row; a search box on top |
| 9 | **Settings** | Preferences | Pack size, default direction, "pack counts as learned after" (both directions / either / one specific), show part of speech, peeks during review demote the pack, theme, manage categories, backup export/import, rename/delete wordlists |
| 10 | **Manage categories** | Tidy up | List of categories and subcategories with rename, merge, delete |

## 6. States to design

**The card**
- Word → Definition, before Show: only the word and its part-of-speech label ("adj.").
- Word → Definition, after Show: the definition appears **without moving anything else**. Reserve the space.
- Definition → Word, before and after Show. The definition is the prompt, so design for long text. The longest in the sample is 204 characters (see §8).
- After a peek: the Show button reads "Shown" and is disabled; the peek counter reads 1 with a gentle note: "This pass won't count — finish it, then repeat the pack."

**Tags on the card** (review mode): no tags · positive · negative · neutral · counter-intuitive only · multiple meanings only · negative + counter-intuitive · positive + multiple meanings · all traits + a tone.

**Quick tag buttons:** all off; one tone on; tone on + both traits on; pressed and focused states. On phones they may wrap onto two rows (tone row, trait row).

**Category fields:** empty; typing with suggestions; no match, showing a `Create "Annoyance"` option; filled; subcategory disabled until a category is chosen.

**Pass summary: three variants**
1. *Clean pass*: "Pack 6 · Word → Definition mastered." → Start Definition → Word / Next pack / Back.
2. *Pack learned!* (the celebration moment) → Next pack / Review this pack / Back.
3. *Finished with peeks*: "4 peeks: accommodate · adverse · airy · alien" → Repeat pack / Switch direction / Back.

(On phones this is a bottom sheet; on desktop a centred panel.)

**Pack status** (grid and tree): New · Learning · Learned. Also show the per-direction status (e.g. Word → Definition ✓, Definition → Word in progress).

**Dialogs:**
- Switch direction mid-pass ("This pass will restart").
- Change pack size ("All packs will be rebuilt… your progress is kept").
- Delete wordlist.
- Delete category.
- Restore backup.

**Empty and edge states:**
- Explorer node with no words.
- "All packs learned 🎉".
- Import with skipped lines.
- Unreadable file.
- Search with no results.

## 7. Interactions to show (a short prototype or annotations is enough)

- Phone: tap the card to Show, swipe left for Next, swipe right for Previous.
- Opening the tree drawer on phone, selecting a category, then stepping through its words.
- Tapping a tone button: the card's edge and tint change instantly. Tapping the same tone again removes it.
- The "pack learned" celebration. Keep it short and subtle, and provide a no-motion version.

## 8. Real content to use

Please design with real words from `fixtures/definitions.txt`, not lorem ipsum:

| Word | POS | Definition | Suggested tags for mockups |
|---|---|---|---|
| acclaim | noun | enthusiastic approval | Positive |
| accuse | verb | blame for, make a claim of wrongdoing or misbehavior against | Negative |
| abbey | noun | a monastery ruled by an abbot | Neutral · Category: Religion › Places |
| airy | adj. | not practical or realizable; speculative | Negative + Counter-intuitive |
| acid | adj. | biting, sarcastic, or scornful | Negative + Multiple meanings |
| zeal | noun | excessive fervor to do something or accomplish some end | Positive + Counter-intuitive |
| vulnerable | adj. | capable of being wounded or hurt | Neutral |

**Stress tests:**
- Longest definition (204 chars): *hybrid — (genetics) an organism that is the offspring of genetically dissimilar parents or stock; especially offspring produced by breeding plants or animals of different varieties or breeds or species*
- Longest word: *characteristic* (14 letters).
- Parts of speech appear as: noun, verb, adj., adv. (and occasionally pron., prep., conj., interj.).

## 9. Deliverables

1. **Figma file** (or similar) with every screen in §5 at phone and desktop size, in light and dark.
2. **All states** in §6.
3. **Component sheet**: word card (all tag combinations), quick tag buttons, category field, tree row (each node type and status), pack tile, part-of-speech chip, peek counter, progress bar, buttons.
4. **Design values table.** The developer copies this straight into the app, so please fill it in exactly. *(Filled in: see `docs/UI_UX.md` §9.)*

| Value | Light | Dark |
|---|---|---|
| Background / surface / surface-variant | | |
| Text primary / secondary | | |
| Primary (buttons, focus) | | |
| Positive — edge / tint / icon | | |
| Negative — edge / tint / icon | | |
| Neutral — edge / icon | | |
| Counter-intuitive — badge colour / badge background / outline | | |
| Multiple meanings — badge colour / badge background | | |
| Pack status — New / Learning / Learned | | |

| Value | Spec |
|---|---|
| Font family (must be free for app use, e.g. Google Fonts) | |
| Type scale: card word, card definition, headings, body, labels, chips | size / weight / line height |
| Spacing scale | e.g. 4 / 8 / 12 / 16 / 24 / 32 |
| Corner radius: card / buttons / chips / sheets | |
| Card edge thickness (tone) | currently 6 px on cards, 4 px on list rows |
| Icons chosen for each tag and node type | name + source |

5. **App icon** (1024 × 1024 master) and wordmark, if in scope.

## 10. Not in this version

Accounts, sync, sharing, streaks, sound, typed answers and spaced repetition are all out of scope. Please don't design for them.

Resetting a pack to New is **not** a feature (D-18): any pack can be studied or reviewed at any time.

## 11. Handback

Send the Figma link and the filled-in values table. The developer will update the app's theme and `docs/UI_UX.md` to match before building the tagging and explorer screens. Until then the app runs with a plain default look, so nothing is blocked.

For deeper detail on any behaviour, see `docs/UI_UX.md` and `docs/REQUIREMENTS.md`. You can skip the code notes in them.
