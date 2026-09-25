// Builds a demo backup for Play Store screenshots: the sample wordlist with
// packs 1–3 learned (real clean passes in both directions) and tagged, and
// pack 4 in progress with a peek. Not part of the test suite:
//   flutter test tool/store_seed_test.dart
// then restore build/store/wordpack-store-demo.json from Settings › Backup.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;

import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/data/system.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/services/backup_service.dart';
import 'package:wordpack/services/import_service.dart';
import 'package:wordpack/services/learning_service.dart';
import 'package:wordpack/services/tagging_service.dart';

import '../test/support/test_db.dart';

const _categories = {
  'Character': {
    'Negative traits': ['arrogant', 'arrogance', 'abusive', 'adamant'],
    'Positive traits': ['ambitious', 'articulate', 'authentic'],
  },
  'People & roles': {
    'Work': ['administrator', 'analyst', 'amateur'],
    'Politics': ['ally', 'advocate'],
  },
  'Places': {
    'Buildings': ['abbey', 'academy', 'altar', 'arcade', 'asylum'],
    'Streets': ['alley'],
  },
  'Law & politics': {
    '': ['accusation', 'accuse', 'allegiance', 'alliance'],
  },
};

const _tones = {
  Tone.positive: [
    'abundant', 'acclaim', 'accurate', 'accessible', 'ambitious', //
    'articulate', 'authentic', 'ally',
  ],
  Tone.negative: [
    'absurd', 'adverse', 'anxious', 'apocalyptic', 'arbitrary', 'austere', //
    'arrogant', 'arrogance', 'abusive', 'accusation', 'aggression',
  ],
  Tone.neutral: ['annual', 'appease', 'analyst', 'academy', 'abbey'],
};

const _traits = {
  Trait.counterIntuitive: ['august', 'airy', 'apt', 'alternate'],
  Trait.multipleMeanings: ['august', 'acid', 'affect', 'assess', 'account'],
};

void main() {
  test('build store demo backup', () async {
    final db = memoryDb();
    const clock = SystemClock();
    final ids = UuidIdGenerator();
    final import = ImportService(
      db: db,
      clock: clock,
      ids: ids,
      parser: parseInline,
    );
    final learning = LearningService(db: db, clock: clock, ids: ids);
    final tagging = TaggingService(db: db, clock: clock, ids: ids);

    final bytes = File('fixtures/definitions.txt').readAsBytesSync();
    final report = await import.preview(Uint8List.fromList(bytes));
    await import.commit(
      report,
      name: 'GRE vocabulary',
      sourceFilename: 'definitions.txt',
    );

    final packs = await (db.select(
      db.packs,
    )..orderBy([(p) => OrderingTerm.asc(p.number)])).get();
    Future<int> size(Pack p) async => (await (db.select(
      db.words,
    )..where((w) => w.packId.equals(p.id))).get()).length;

    for (final pack in packs.take(3)) {
      for (final d in Direction.values) {
        await learning.open(pack.id, d);
        for (var i = 0; i < await size(pack); i++) {
          await learning.next(pack.id, d);
        }
      }
    }
    // Pack 4: part-way through a Word → Definition pass, one peek.
    final p4 = packs[3].id;
    await learning.open(p4, Direction.wd);
    for (var i = 0; i < 12; i++) {
      if (i == 7) await learning.show(p4, Direction.wd);
      await learning.next(p4, Direction.wd);
    }

    Future<String> id(String term) async => (await (db.select(
      db.words,
    )..where((w) => w.term.equals(term))).getSingle()).id;

    for (final MapEntry(key: cat, value: subs) in _categories.entries) {
      for (final MapEntry(key: sub, value: terms) in subs.entries) {
        for (final t in terms) {
          await tagging.assign(
            await id(t),
            category: cat,
            subcategory: sub.isEmpty ? null : sub,
          );
        }
      }
    }
    for (final MapEntry(key: tone, value: terms) in _tones.entries) {
      for (final t in terms) {
        await tagging.setTone(await id(t), tone);
      }
    }
    for (final MapEntry(key: trait, value: terms) in _traits.entries) {
      for (final t in terms) {
        await tagging.toggleTrait(await id(t), trait);
      }
    }

    final json = await BackupService(db: db, clock: clock).export();
    File('build/store/wordpack-store-demo.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(json);
    await db.close();
  });
}
