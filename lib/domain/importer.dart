/// Word-list importer (`docs/IMPORT_FORMAT.md`). Pure Dart so it can run in a
/// background isolate: `Isolate.run(() => parseImport(bytes))`.
///
/// Behaviour oracle: `reference/import_parser.py`. For every file in
/// `fixtures/`, [ImportReport.toJson] must equal `fixtures/expected/<file>.json`.
library;

import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:enough_convert/windows.dart';

import 'pos.dart';

enum ImportFormat {
  /// `term - pos. definition`, one per line (Layout A).
  dash,

  /// Ordinary CSV with 2 or 3 columns (Layout B).
  columns,
}

enum SkipReason {
  noSeparator('NO_SEPARATOR'),
  emptyTerm('EMPTY_TERM'),
  emptyDefinition('EMPTY_DEFINITION');

  const SkipReason(this.code);

  /// Code used in the golden files.
  final String code;
}

/// A file that is neither valid UTF-8 nor valid Windows-1252.
class UnreadableFileException implements Exception {
  const UnreadableFileException();

  @override
  String toString() => 'UnreadableFileException';
}

class ImportedWord {
  const ImportedWord({
    required this.line,
    required this.term,
    required this.posRaw,
    required this.pos,
    required this.definition,
  });

  /// 1-based line (Layout A) or CSV row (Layout B) in the source file.
  final int line;
  final String term;

  /// The code as written (lower-cased, trailing dots removed), or null.
  final String? posRaw;

  /// Canonical key from `pos.dart`, [otherPos], or null.
  final String? pos;
  final String definition;

  Map<String, Object?> toJson() => {
    'line': line,
    'term': term,
    'pos_raw': posRaw,
    'pos': pos,
    'definition': definition,
  };
}

class SkippedLine {
  const SkippedLine({
    required this.line,
    required this.reason,
    required this.text,
  });

  final int line;
  final SkipReason reason;

  /// The line as it appeared, for the preview's skipped-lines list.
  final String text;

  Map<String, Object?> toJson() => {'line': line, 'reason': reason.code};
}

class ImportReport {
  const ImportReport({
    required this.format,
    required this.words,
    required this.skipped,
    required this.duplicatesRemoved,
  });

  final ImportFormat format;
  final List<ImportedWord> words;
  final List<SkippedLine> skipped;
  final int duplicatesRemoved;

  /// Words per canonical part-of-speech key (words without one are left out),
  /// most frequent first.
  Map<String, int> get posCounts {
    final counts = <String, int>{};
    for (final w in words) {
      if (w.pos case final pos?) counts[pos] = (counts[pos] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  Map<String, Object?> toJson() => {
    'format': format.name,
    'words': [for (final w in words) w.toJson()],
    'skipped': [for (final s in skipped) s.toJson()],
    'duplicates_removed': duplicatesRemoved,
  };
}

/// Parses an import file. Never throws on content (bad lines are reported in
/// [ImportReport.skipped]); throws [UnreadableFileException] when the bytes
/// cannot be decoded.
ImportReport parseImport(List<int> bytes) {
  final text = decodeImportBytes(bytes);
  final lines = _splitLines(text);
  final nonBlank = lines.where((l) => l.trim().isNotEmpty).toList();
  final dashLines = nonBlank.where((l) => l.contains(' - ')).length;

  final ImportFormat format;
  final _Parsed parsed;
  if (nonBlank.isNotEmpty && dashLines / nonBlank.length >= 0.8) {
    format = ImportFormat.dash;
    parsed = _parseDash(lines);
  } else {
    format = ImportFormat.columns;
    parsed = _parseColumns(text, nonBlank);
  }

  final seen = <String>{};
  final words = <ImportedWord>[];
  var duplicates = 0;
  for (final w in parsed.words) {
    final key = [
      w.term.toLowerCase(),
      w.pos ?? '',
      _collapse(w.definition.toLowerCase()),
    ].join('\u0000');
    if (!seen.add(key)) {
      duplicates++;
      continue;
    }
    words.add(w);
  }

  return ImportReport(
    format: format,
    words: words,
    skipped: parsed.skipped,
    duplicatesRemoved: duplicates,
  );
}

/// Strict UTF-8 (BOM removed), falling back to Windows-1252.
String decodeImportBytes(List<int> bytes) {
  try {
    final text = utf8.decode(bytes);
    return text.startsWith('﻿') ? text.substring(1) : text;
  } on FormatException {
    // Five bytes are undefined in Windows-1252; the codec would let them
    // through, the oracle (Python cp1252) rejects them.
    if (bytes.any(_undefinedIn1252.contains)) {
      throw const UnreadableFileException();
    }
    return const Windows1252Codec().decode(bytes);
  }
}

const _undefinedIn1252 = {0x81, 0x8D, 0x8F, 0x90, 0x9D};

class _Parsed {
  final words = <ImportedWord>[];
  final skipped = <SkippedLine>[];
}

final _lineBreak = RegExp(r'\r\n|\r|\n');
final _whitespace = RegExp(r'\s+');
final _trailingCommas = RegExp(r',+$');
final _posPrefix = RegExp(r'^([A-Za-z]{1,12})\.\s+(.*)$');

List<String> _splitLines(String text) {
  final lines = text.split(_lineBreak);
  if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
  return lines;
}

String _collapse(String s) => s.trim().split(_whitespace).join(' ');

/// A leading known POS code (`n. …`) split off the definition.
(String?, String) _splitPos(String rest) {
  final m = _posPrefix.firstMatch(rest);
  if (m != null && isKnownPosCode(m[1]!)) {
    return (m[1]!.toLowerCase(), m[2]!.trim());
  }
  return (null, rest);
}

/// Layout A line clean-up: trim, drop trailing commas (Excel's empty cells),
/// and unwrap `"…"` with doubled inner quotes.
String _unquoteLine(String raw) {
  var l = raw.trim().replaceFirst(_trailingCommas, '').trim();
  if (l.length >= 2 && l.startsWith('"') && l.endsWith('"')) {
    l = l.substring(1, l.length - 1).replaceAll('""', '"');
  }
  return l.trim();
}

_Parsed _parseDash(List<String> lines) {
  final out = _Parsed();
  for (var n = 1; n <= lines.length; n++) {
    final raw = lines[n - 1];
    final l = _unquoteLine(raw);
    if (l.isEmpty) continue;
    final i = l.indexOf(' - ');
    if (i <= 0) {
      out.skipped.add(
        SkippedLine(line: n, reason: SkipReason.noSeparator, text: raw),
      );
      continue;
    }
    // [l] is trimmed, so text always follows the separator: the definition
    // cannot be empty here, and a line ending in " -" has no separator at all.
    final term = _collapse(l.substring(0, i));
    final (posRaw, definition) = _splitPos(l.substring(i + 3).trim());
    out.words.add(
      ImportedWord(
        line: n,
        term: term,
        posRaw: posRaw,
        pos: posRaw == null ? null : canonicalPos(posRaw),
        definition: definition,
      ),
    );
  }
  return out;
}

const _delimiters = [',', ';', '\t'];

/// For each candidate, count its occurrences outside double quotes on the
/// first 10 non-blank lines; pick the one with the same non-zero count on the
/// most lines. Ties go to the earlier candidate (comma first).
String detectDelimiter(List<String> nonBlankLines) {
  final sample = nonBlankLines.take(10).toList();
  var best = ',';
  var bestScore = 0;
  for (final d in _delimiters) {
    final tally = <int, int>{};
    for (final line in sample) {
      var count = 0;
      var quoted = false;
      for (final ch in line.split('')) {
        if (ch == '"') {
          quoted = !quoted;
        } else if (ch == d && !quoted) {
          count++;
        }
      }
      if (count > 0) tally[count] = (tally[count] ?? 0) + 1;
    }
    final score = tally.values.fold(0, (a, b) => a > b ? a : b);
    if (score > bestScore) {
      best = d;
      bestScore = score;
    }
  }
  return best;
}

const _headerNames = {
  'term': ['term', 'word'],
  'pos': ['pos', 'part of speech', 'part_of_speech', 'type'],
  'definition': ['definition', 'meaning', 'definitions'],
};

_Parsed _parseColumns(String text, List<String> nonBlank) {
  final out = _Parsed();
  final delimiter = detectDelimiter(nonBlank);
  final rows = [
    for (final r in CsvDecoder(
      fieldDelimiter: delimiter,
      skipEmptyLines: false,
    ).convert(text))
      [for (final c in r) '$c'],
  ];

  var idx = <String, int>{};
  if (rows.isNotEmpty) {
    final header = [for (final c in rows.first) c.trim().toLowerCase()];
    for (final MapEntry(key: k, value: aliases) in _headerNames.entries) {
      for (var j = 0; j < header.length; j++) {
        if (aliases.contains(header[j])) idx[k] = j;
      }
    }
  }
  final hasHeader = idx.containsKey('term') && idx.containsKey('definition');
  final start = hasHeader ? 1 : 0;
  if (!hasHeader) {
    final width = rows.fold(0, (w, r) => r.length > w ? r.length : w);
    idx = width == 2
        ? {'term': 0, 'definition': 1}
        : {'term': 0, 'pos': 1, 'definition': 2};
  }

  for (var r = start; r < rows.length; r++) {
    final row = rows[r];
    final n = r + 1;
    if (row.every((c) => c.trim().isEmpty)) continue;
    String cell(String k) {
      final j = idx[k];
      return j != null && j < row.length ? row[j].trim() : '';
    }

    final rawText = row.join(delimiter);
    final term = _collapse(cell('term'));
    var definition = cell('definition');
    final posCell = cell('pos').replaceFirst(RegExp(r'\.+$'), '').toLowerCase();
    String? posRaw = posCell.isEmpty ? null : posCell;
    if (term.isEmpty) {
      out.skipped.add(
        SkippedLine(line: n, reason: SkipReason.emptyTerm, text: rawText),
      );
      continue;
    }
    if (definition.isEmpty) {
      out.skipped.add(
        SkippedLine(line: n, reason: SkipReason.emptyDefinition, text: rawText),
      );
      continue;
    }
    if (posRaw == null) (posRaw, definition) = _splitPos(definition);
    out.words.add(
      ImportedWord(
        line: n,
        term: term,
        posRaw: posRaw,
        pos: posRaw == null ? null : canonicalPos(posRaw),
        definition: definition,
      ),
    );
  }
  return out;
}
