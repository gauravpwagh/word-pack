# Fixtures

| File | Format | Expected import result |
|---|---|---|
| `definitions.txt` | Plain text, `term - pos. definition` (real sample from the product owner) | 998 words, 0 skipped, 0 duplicates; 501 noun · 336 adj. · 149 verb · 12 adv. → 34 packs at size 30 |
| `sample-excel-dash.csv` | Same lines saved by Excel as a one-column CSV (UTF-8 BOM, CRLF, lines with commas wrapped in quotes) | 60 words, 0 skipped |
| `sample-columns.csv` | Proper CSV with header `word,pos,definition`, POS written as words | 60 words, 0 skipped; 24 noun · 20 adj. · 16 verb |
| `edge-cases.txt` | Hand-made parser edge cases | 9 words, 1 skipped (line 11), 1 duplicate — see `docs/IMPORT_FORMAT.md` §7 |

`expected/<file>.json` holds the exact output the Dart importer must produce (`format`, `words[line, term, pos_raw, pos, definition]`, `skipped`, `duplicates_removed`). Regenerate with `python3 reference/import_parser.py` if the fixtures change.
