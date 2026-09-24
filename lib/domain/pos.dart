/// Parts of speech: accepted codes, canonical keys, UI labels and full names
/// (`docs/IMPORT_FORMAT.md` §5). Keep every mapping in this file.
library;

/// Accepted input code (lower-case, no trailing dot) → canonical key.
///
/// In the sample file `a` means adverb and `j` adjective.
const Map<String, String> posCodes = {
  'n': 'noun',
  'noun': 'noun',
  'v': 'verb',
  'verb': 'verb',
  'j': 'adjective',
  'adj': 'adjective',
  'adjective': 'adjective',
  'a': 'adverb',
  'adv': 'adverb',
  'r': 'adverb',
  'adverb': 'adverb',
  'pron': 'pronoun',
  'pronoun': 'pronoun',
  'prep': 'preposition',
  'preposition': 'preposition',
  'conj': 'conjunction',
  'conjunction': 'conjunction',
  'interj': 'interjection',
  'int': 'interjection',
  'interjection': 'interjection',
  'phr': 'phrase',
  'phrase': 'phrase',
  'idiom': 'idiom',
  'abbr': 'abbreviation',
  'abbreviation': 'abbreviation',
};

/// Key for codes that are not in [posCodes] (only possible from a POS column).
const String otherPos = 'other';

const Map<String, String> _labels = {
  'noun': 'noun',
  'verb': 'verb',
  'adjective': 'adj.',
  'adverb': 'adv.',
  'pronoun': 'pron.',
  'preposition': 'prep.',
  'conjunction': 'conj.',
  'interjection': 'interj.',
  'phrase': 'phrase',
  'idiom': 'idiom',
  'abbreviation': 'abbr.',
};

/// Whether [code] (any case) is a known part-of-speech code.
bool isKnownPosCode(String code) => posCodes.containsKey(code.toLowerCase());

/// Canonical key for a raw code: a known key, or [otherPos].
String canonicalPos(String rawCode) =>
    posCodes[rawCode.toLowerCase()] ?? otherPos;

/// Short label shown in the UI: `noun`, `adj.`, …; unknown codes are shown as
/// written plus a dot (`det.`). Null when the word has no part of speech.
String? posLabel(String? key, String? raw) {
  if (key == null) return null;
  return _labels[key] ?? '$raw.';
}

/// Full name for tooltips and screen readers (`adjective`); for unknown codes
/// the raw text.
String? posFullName(String? key, String? raw) {
  if (key == null) return null;
  return _labels.containsKey(key) ? key : raw;
}
