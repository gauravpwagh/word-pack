# Import format

The user picks a **CSV** file (`.csv`; `.txt` also accepted). Two layouts are supported and detected automatically.

Implement in pure Dart as `lib/domain/importer.dart` + `lib/domain/pos.dart`. `reference/import_parser.py` is a verified behaviour oracle: for every file in `fixtures/`, the Dart importer's output must equal the golden JSON in `fixtures/expected/<file>.json` (fields `format`, `words[line, term, pos_raw, pos, definition]`, `skipped[line, reason]`, `duplicates_removed`).

## 1. Layout A — "dash lines" (the supplied sample)

One entry per line: `term - pos. definition`

```
abbey - n. a monastery ruled by an abbot
absurd - j. inconsistent with reason or logic or common sense
wherever - a. where in the world
```

Facts from `fixtures/definitions.txt` (998 lines): every line has this shape; codes `n.` 501, `j.` 336, `v.` 149, `a.` 12; **42 definitions contain commas**, so these lines must not be split on commas.

The same content saved from Excel as a CSV becomes a one-column CSV: lines that contain a comma are wrapped in double quotes (`"acid - j. biting, sarcastic, or scornful"`), inner quotes are doubled, the file may start with a UTF-8 BOM, use CRLF, and sometimes has trailing empty cells (`abbey - n. …,,`). Layout A handles all of this (`fixtures/sample-excel-dash.csv`).

## 2. Layout B — columns

A normal CSV with 2 or 3 columns:

```
word,pos,definition
abbey,noun,a monastery ruled by an abbot
absurd,adj,"inconsistent with reason, logic or common sense"
```

- Delimiter: comma, semicolon or tab. Detection: for each candidate, count occurrences outside double quotes on each of the first 10 non-blank lines; pick the candidate that has the same non-zero count on the most lines; ties → comma.
- Standard CSV quoting (RFC 4180).
- **Header row optional.** Recognised header names (case-insensitive):
  - term: `word`, `term`
  - part of speech: `pos`, `part of speech`, `part_of_speech`, `type`
  - definition: `definition`, `meaning`, `definitions`
- Without a recognised header: 2 columns = term, definition; 3 columns = term, pos, definition.
- If there is no POS column, a leading code in the definition (`n. …`) is still recognised.

## 3. Format detection

```
non_blank = lines with any non-space character
if ≥ 80 % of non_blank lines contain " - "  → Layout A
else                                        → Layout B
```

Decoding: try strict UTF-8 (`utf8.decode(bytes)` without `allowMalformed`, BOM stripped); on `FormatException`, decode as Windows-1252 (package `enough_convert`). Accept LF, CRLF and CR line endings.

For Layout B use the `csv` package (v8: `CsvDecoder(fieldDelimiter: d, skipEmptyLines: false)`, which handles ``, `
` and `
` and keeps values as strings) so quoted fields with commas and line breaks work. Keeping empty rows keeps row numbers equal to the oracle's.

## 4. Parsing rules

**Layout A, per line:**
1. Strip whitespace, strip trailing commas, and if the line is wrapped in `"…"` remove the quotes and turn `""` into `"`.
2. Blank → ignore silently.
3. Split on the **first** `" - "` (space-hyphen-space). None → skip `NO_SEPARATOR`. Hyphens inside words (`co-op`) are not separators; a later `" - "` stays in the definition.
4. Term = left part, inner whitespace collapsed. Empty → skip `EMPTY_TERM`.
5. Right part: if it starts with `<letters>.` + whitespace **and** the letters are a known POS code (§5), take it as the POS; the rest is the definition. Otherwise there is no POS and the whole right part is the definition (so `nopos - a definition…` keeps "a definition…").
6. Empty definition → skip `EMPTY_DEFINITION`.

**Layout B, per row:** read term / pos / definition from the mapped columns; skip rows that are entirely empty; `EMPTY_TERM` / `EMPTY_DEFINITION` as above; POS value has a trailing dot removed and is lower-cased before lookup.

## 5. Part of speech: codes and display labels

Store the canonical key in `Words.pos` and the original code in `Words.posRaw`. Show the **label** in the UI; the full name is used for tooltips and screen readers.

| Accepted input (case-insensitive, trailing `.` ignored) | Canonical key | UI label | Full name |
|---|---|---|---|
| `n`, `noun` | `noun` | **noun** | noun |
| `v`, `verb` | `verb` | **verb** | verb |
| `j`, `adj`, `adjective` | `adjective` | **adj.** | adjective |
| `a`, `adv`, `r`, `adverb` | `adverb` | **adv.** | adverb |
| `pron`, `pronoun` | `pronoun` | **pron.** | pronoun |
| `prep`, `preposition` | `preposition` | **prep.** | preposition |
| `conj`, `conjunction` | `conjunction` | **conj.** | conjunction |
| `interj`, `int`, `interjection` | `interjection` | **interj.** | interjection |
| `phr`, `phrase` | `phrase` | **phrase** | phrase |
| `idiom` | `idiom` | **idiom** | idiom |
| `abbr`, `abbreviation` | `abbreviation` | **abbr.** | abbreviation |
| anything else (Layout B column only) | `other` | the raw text + `.` | the raw text |

⚠ In this sample, `a.` means **adverb** (`wherever - a. where in the world`) and `j.` means **adjective**. Keep the mapping in one map (`lib/domain/pos.dart`) so it can be changed if another source uses `a` for adjective.

In Layout A, an unknown code before a dot is **not** treated as POS (it stays part of the definition), to avoid mistaking ordinary text for a code.

## 6. Duplicates

| Case | Behaviour |
|---|---|
| Same term + same POS + same definition (case-insensitive, whitespace-normalised) | Keep the first; count as "duplicates removed". |
| Same term, different POS or definition (e.g. `affect` noun / verb) | Keep both as separate words. |

## 7. Expected results for `fixtures/edge-cases.txt`

| Line | Content (abridged) | Result |
|---|---|---|
| 1 | `abbey - n. …` | `abbey`, noun |
| 2 | blank | ignored |
| 3 | `  absurd - j. …, logic …  ` | `absurd`, adj., trimmed, comma kept |
| 4 | `affect - n. …` | `affect`, noun |
| 5 | `affect - v. …` | `affect`, verb (kept) |
| 6 | `co-op - n. …` | term `co-op` |
| 7 | `well-being - n. a contented state - being happy…` | term `well-being`; definition keeps ` - ` |
| 8 | `wholly - a. … ('whole' …)` | adv. |
| 9 | `nopos - a definition …` | no POS; definition `a definition …` |
| 10 | `x. - n. …` | term `x.`, noun |
| 11 | `missing separator line` | skipped, `NO_SEPARATOR` |
| 12 | repeat of line 1 | duplicate removed |

Totals: **9 words, 1 skipped, 1 duplicate**.

## 8. Import report (preview screen)

```
File: definitions.csv   Detected: dash lines (word - pos. definition)
Wordlist name: [definitions            ]
✔ 998 words ready     noun 501 · adj. 336 · verb 149 · adv. 12
⚠ 0 lines skipped     ℹ 0 duplicates removed
→ 34 packs of 30 (last pack 8)
First 10 words: …
[Cancel]  [Import 998 words]
```

Skipped lines are listed as `Line 11: "missing separator line" — no " - " separator found`.

Run `parse` in a background isolate (`Isolate.run`) so large files never block the UI.
