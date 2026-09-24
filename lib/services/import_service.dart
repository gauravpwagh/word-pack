import 'dart:isolate';

import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../data/repositories/pack_repo.dart';
import '../data/repositories/settings_repo.dart';
import '../data/repositories/word_repo.dart';
import '../data/repositories/wordlist_repo.dart';
import '../domain/clock.dart';
import '../domain/ids.dart';
import '../domain/importer.dart';
import '../domain/models.dart';
import '../domain/packing.dart';
import 'exceptions.dart';

/// Import: parse and preview a file, then save it as one new wordlist
/// (`docs/REQUIREMENTS.md` IMP-1 … IMP-5).
class ImportService {
  ImportService({
    required AppDatabase db,
    required Clock clock,
    required IdGenerator ids,
    ImportParser parser = parseInIsolate,
  }) : _db = db,
       _parse = parser,
       _clock = clock,
       _ids = ids,
       _wordlists = WordlistRepo(db),
       _words = WordRepo(db),
       _packs = PackRepo(db),
       _settings = SettingsRepo(db);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final ImportParser _parse;
  final WordlistRepo _wordlists;
  final WordRepo _words;
  final PackRepo _packs;
  final SettingsRepo _settings;

  static const int maxBytes = 5 * 1024 * 1024;

  /// Parses [bytes] in a background isolate. Nothing is saved.
  Future<ImportReport> preview(Uint8List bytes) async {
    checkSize(bytes.length);
    final ImportReport report;
    try {
      report = await _parse(bytes);
    } on UnreadableFileException {
      throw const ImportException(ImportError.unreadable);
    }
    if (report.words.isEmpty) {
      throw const ImportException(ImportError.noWordsFound);
    }
    return report;
  }

  /// Throws [ImportError.tooLarge] for files over [maxBytes]; call it with the
  /// file's length before reading it.
  static void checkSize(int length) {
    if (length > maxBytes) throw const ImportException(ImportError.tooLarge);
  }

  /// Saves [report] as a new wordlist with packs of the current pack size, in
  /// one transaction. Returns the wordlist id.
  Future<String> commit(
    ImportReport report, {
    required String name,
    required String sourceFilename,
  }) {
    if (report.words.isEmpty) {
      throw const ImportException(ImportError.noWordsFound);
    }
    return _db.transaction(() async {
      final now = _clock.now();
      final settings = await _settings.get();
      final wordlistId = _ids.newId();
      final wordIds = [for (final _ in report.words) _ids.newId()];
      final plans = packsForImport(wordIds, settings.packSize);

      await _wordlists.insert(
        WordlistsCompanion.insert(
          id: wordlistId,
          name: wordlistName(name, sourceFilename),
          sourceFilename: sourceFilename,
          sourceFormat: report.format.name,
          wordCount: report.words.length,
          importedAt: now,
        ),
      );

      final packOf = <String, String>{};
      final packRows = <PacksCompanion>[];
      for (final plan in plans) {
        final packId = _ids.newId();
        for (final w in plan.wordIds) {
          packOf[w] = packId;
        }
        packRows.add(
          PacksCompanion.insert(
            id: packId,
            wordlistId: wordlistId,
            number: plan.number,
            masteryWd: Mastery.unseen,
            masteryDw: Mastery.unseen,
            createdAt: now,
          ),
        );
      }
      await _packs.insertAll(packRows);

      await _words.insertAll([
        for (final (i, w) in report.words.indexed)
          WordsCompanion.insert(
            id: wordIds[i],
            wordlistId: wordlistId,
            position: i,
            term: w.term,
            pos: Value(w.pos),
            posRaw: Value(w.posRaw),
            definition: w.definition,
            packId: packOf[wordIds[i]]!,
            updatedAt: now,
          ),
      ]);
      return wordlistId;
    });
  }
}

/// Runs the importer; the app parses in a background isolate so large files
/// never block the UI (IMP-5), widget tests parse inline.
typedef ImportParser = Future<ImportReport> Function(Uint8List bytes);

Future<ImportReport> parseInIsolate(Uint8List bytes) =>
    Isolate.run(() => parseImport(bytes));

Future<ImportReport> parseInline(Uint8List bytes) async => parseImport(bytes);

/// The wordlist name to store: [name] trimmed (max 200 characters), or the
/// file name without its extension when empty.
String wordlistName(String name, String sourceFilename) {
  var n = name.trim();
  if (n.isEmpty) n = defaultWordlistName(sourceFilename);
  if (n.isEmpty) n = 'Wordlist';
  return n.length > 200 ? n.substring(0, 200) : n;
}

/// `definitions.csv` → `definitions`.
String defaultWordlistName(String filename) {
  final base = filename.split(RegExp(r'[/\\]')).last;
  final dot = base.lastIndexOf('.');
  return (dot > 0 ? base.substring(0, dot) : base).trim();
}
