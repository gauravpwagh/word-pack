import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/domain/importer.dart';
import 'package:wordpack/domain/pos.dart';

/// Fixtures are read in place (tests run from the project root).
List<int> fixture(String name) => File('fixtures/$name').readAsBytesSync();

Object? golden(String name) =>
    jsonDecode(File('fixtures/expected/$name.json').readAsStringSync());

ImportReport parseText(String text) => parseImport(utf8.encode(text));

void main() {
  group('importer goldens', () {
    test('U-1 definitions.txt matches the golden file', () {
      final report = parseImport(fixture('definitions.txt'));
      expect(report.toJson(), golden('definitions.txt'));
      expect(report.format, ImportFormat.dash);
      expect(report.words, hasLength(998));
      expect(report.posCounts, {
        'noun': 501,
        'adjective': 336,
        'verb': 149,
        'adverb': 12,
      });
    });

    test('U-2 edge-cases.txt matches the golden file', () {
      final report = parseImport(fixture('edge-cases.txt'));
      expect(report.toJson(), golden('edge-cases.txt'));
      expect(report.words, hasLength(9));
      expect(report.skipped.single.line, 11);
      expect(report.skipped.single.reason, SkipReason.noSeparator);
      expect(report.skipped.single.text, 'missing separator line');
      expect(report.duplicatesRemoved, 1);
    });

    test('U-3 sample-excel-dash.csv (BOM, CRLF, quoted lines)', () {
      final report = parseImport(fixture('sample-excel-dash.csv'));
      expect(report.toJson(), golden('sample-excel-dash.csv'));
      expect(report.words, hasLength(60));
      final acid = report.words.firstWhere((w) => w.term == 'acid');
      expect(acid.definition, 'biting, sarcastic, or scornful');
      expect(report.words.first.term, 'abbey');
      expect(report.words.any((w) => w.definition.contains('"')), isFalse);
    });

    test('U-4 sample-columns.csv matches the golden file', () {
      final report = parseImport(fixture('sample-columns.csv'));
      expect(report.toJson(), golden('sample-columns.csv'));
      expect(report.format, ImportFormat.columns);
      expect(report.posCounts, {'noun': 24, 'adjective': 20, 'verb': 16});
    });
  });

  group('importer rules', () {
    test('U-5 columns CSV without header, 2 columns', () {
      final report = parseText(
        'abbey,n. a monastery ruled by an abbot\n'
        'absurd,"inconsistent with reason, logic"\n',
      );
      expect(report.format, ImportFormat.columns);
      expect(report.words.map((w) => w.toJson()), [
        {
          'line': 1,
          'term': 'abbey',
          'pos_raw': 'n',
          'pos': 'noun',
          'definition': 'a monastery ruled by an abbot',
        },
        {
          'line': 2,
          'term': 'absurd',
          'pos_raw': null,
          'pos': null,
          'definition': 'inconsistent with reason, logic',
        },
      ]);
    });

    test('U-5 columns CSV without header, 3 columns', () {
      final report = parseText('abbey,Noun.,a monastery\nabide,v,dwell\n');
      expect(report.words.first.posRaw, 'noun');
      expect(report.words.first.pos, 'noun');
      expect(report.words.last.pos, 'verb');
    });

    test('U-6 semicolon- and tab-delimited CSV parse like comma', () {
      for (final d in [';', '\t']) {
        final report = parseText(
          'word${d}pos${d}definition\n'
          'abbey${d}noun${d}a monastery, ruled by an abbot\n'
          'abide${d}verb${d}dwell\n',
        );
        expect(report.words, hasLength(2), reason: 'delimiter "$d"');
        expect(report.words.first.definition, 'a monastery, ruled by an abbot');
        expect(report.words.last.pos, 'verb');
      }
    });

    test('U-6 delimiter detection ignores quoted delimiters; ties → comma', () {
      expect(detectDelimiter(['a;"b;c";d', 'e;f;g']), ';');
      expect(detectDelimiter(['a,b;c', 'd,e;f']), ',');
      expect(detectDelimiter(['no delimiters here']), ',');
    });

    test('U-7 Windows-1252 bytes are decoded', () {
      final bytes = [
        ...latin1.encode('caf'),
        0xE9,
        ...latin1.encode(' - n. a small restaurant\n'),
      ];
      final report = parseImport(bytes);
      expect(report.words.single.term, 'café');
    });

    test('U-7 bytes invalid in UTF-8 and Windows-1252 are unreadable', () {
      expect(
        () => parseImport([0xC3, 0x28, 0x81]),
        throwsA(isA<UnreadableFileException>()),
      );
      expect(
        const UnreadableFileException().toString(),
        'UnreadableFileException',
      );
    });

    test('a UTF-8 BOM is removed when decoding', () {
      expect(decodeImportBytes([0xEF, 0xBB, 0xBF, 0x61]), 'a');
      expect(decodeImportBytes(utf8.encode('FEFF')), 'FEFF');
    });

    test('U-8 only the first " - " separates term and definition', () {
      final report = parseText('well-being - n. a state - being happy\n');
      expect(report.words.single.term, 'well-being');
      expect(report.words.single.definition, 'a state - being happy');
    });

    test('U-9 no POS code keeps the whole definition', () {
      final report = parseText('nopos - a definition with no code\n');
      expect(report.words.single.pos, isNull);
      expect(report.words.single.definition, 'a definition with no code');
    });

    test('U-9 unknown code before a dot stays in the definition', () {
      final report = parseText('etc - misc. things and more\n');
      expect(report.words.single.pos, isNull);
      expect(report.words.single.definition, 'misc. things and more');
    });

    test('U-10 POS labels and full names', () {
      expect(posLabel(canonicalPos('j'), 'j'), 'adj.');
      expect(posLabel(canonicalPos('a'), 'a'), 'adv.');
      expect(posLabel(canonicalPos('n'), 'n'), 'noun');
      expect(posLabel(canonicalPos('prep'), 'prep'), 'prep.');
      expect(canonicalPos('det'), otherPos);
      expect(posLabel(otherPos, 'det'), 'det.');
      expect(posLabel(null, null), isNull);
      expect(posFullName('adjective', 'j'), 'adjective');
      expect(posFullName(otherPos, 'det'), 'det');
      expect(posFullName(null, null), isNull);
    });

    test('unknown POS column value is kept as "other"', () {
      final report = parseText('word,pos,definition\nthe,det,a determiner\n');
      expect(report.words.single.pos, otherPos);
      expect(report.words.single.posRaw, 'det');
    });

    test('empty definitions and terms are skipped with a reason', () {
      // Trimmed, "abbey - " has no " - " left (same as the oracle).
      final dash = parseText('abbey - \nabide - v. dwell\nabout -  \n');
      expect(dash.skipped.map((s) => s.toJson()), [
        {'line': 1, 'reason': 'NO_SEPARATOR'},
        {'line': 3, 'reason': 'NO_SEPARATOR'},
      ]);

      final cols = parseText(
        'word,pos,definition\n,noun,no term\nabbey,noun,\n,,\nabide,verb,dwell\n',
      );
      expect(cols.skipped.map((s) => s.toJson()), [
        {'line': 2, 'reason': 'EMPTY_TERM'},
        {'line': 3, 'reason': 'EMPTY_DEFINITION'},
      ]);
      expect(cols.skipped.first.text, ',noun,no term');
      expect(cols.words.single.term, 'abide');
    });

    test('a line starting with " - " has no term', () {
      final report = parseText(' - n. orphan\nabbey - n. a monastery\n');
      expect(report.skipped.single.reason, SkipReason.noSeparator);
    });

    test('empty file gives an empty columns report', () {
      final report = parseImport(<int>[]);
      expect(report.format, ImportFormat.columns);
      expect(report.words, isEmpty);
      expect(report.posCounts, isEmpty);
    });

    test('CR-only line endings are accepted', () {
      final report = parseText('abbey - n. a monastery\rabide - v. dwell\r');
      expect(report.words.map((w) => w.line), [1, 2]);
    });
  });
}
