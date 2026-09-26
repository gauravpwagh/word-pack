import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../domain/clock.dart';

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// Summary of a backup file, for the restore confirmation.
class BackupInfo {
  const BackupInfo({
    required this.exportedAt,
    required this.wordlists,
    required this.words,
  });

  final DateTime exportedAt;
  final int wordlists;
  final int words;
}

/// Full backup as one JSON file (`docs/DATA_MODEL.md` §6, DAT-2). Restore
/// replaces everything in one transaction.
class BackupService {
  BackupService({required AppDatabase db, required Clock clock})
    : _db = db,
      _clock = clock;

  final AppDatabase _db;
  final Clock _clock;

  static const app = 'wordpack';

  /// Times as ISO-8601 strings, read back in UTC.
  static const _json = ValueSerializer.defaults(
    serializeDateTimeValuesAsString: true,
  );
  static const schemaVersion = 1;

  /// `wordpack-backup-2026-09-24.json`
  String fileName() {
    final d = _clock.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'wordpack-backup-${d.year}-${two(d.month)}-${two(d.day)}.json';
  }

  Future<String> export() => _db.transaction(() async {
    List<Map<String, dynamic>> rows<T extends DataClass>(List<T> items) => [
      for (final i in items) i.toJson(serializer: _json),
    ];
    final settings = await (_db.select(
      _db.appSettings,
    )..where((s) => s.id.equals(1))).getSingle();
    return const JsonEncoder.withIndent(' ').convert({
      'app': app,
      'schemaVersion': schemaVersion,
      'exportedAt': _clock.now().toIso8601String(),
      'settings': settings.toJson(serializer: _json),
      'categories': rows(await _db.select(_db.categories).get()),
      'wordlists': rows(await _db.select(_db.wordlists).get()),
      'packs': rows(await _db.select(_db.packs).get()),
      'words': rows(await _db.select(_db.words).get()),
      'passSessions': rows(await _db.select(_db.passSessions).get()),
    });
  });

  Map<String, dynamic> _decode(String json) {
    final Object? data;
    try {
      data = jsonDecode(json);
    } on FormatException {
      throw const BackupFormatException('not JSON');
    }
    if (data is! Map<String, dynamic> || data['app'] != app) {
      throw const BackupFormatException('not a WordPack backup');
    }
    if (data['schemaVersion'] != schemaVersion) {
      throw BackupFormatException(
        'unsupported schema version ${data['schemaVersion']}',
      );
    }
    return data;
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> data, String key) {
    final v = data[key];
    if (v is! List) throw BackupFormatException('missing "$key"');
    return v.cast<Map<String, dynamic>>();
  }

  /// Checks a file and summarises it, without changing anything.
  BackupInfo inspect(String json) {
    final data = _decode(json);
    return BackupInfo(
      exportedAt: DateTime.parse(data['exportedAt'] as String),
      wordlists: _list(data, 'wordlists').length,
      words: _list(data, 'words').length,
    );
  }

  /// Replaces all data with the backup's. Nothing changes if the file is
  /// invalid.
  Future<void> restore(String json) async {
    final data = _decode(json);
    try {
      final categories =
          [
            for (final j in _list(data, 'categories'))
              Category.fromJson(j, serializer: _json),
          ]..sort(
            (a, b) =>
                (a.parentId == null ? 0 : 1) - (b.parentId == null ? 0 : 1),
          );
      final wordlists = [
        for (final j in _list(data, 'wordlists'))
          Wordlist.fromJson(j, serializer: _json),
      ];
      final packs = [
        for (final j in _list(data, 'packs'))
          Pack.fromJson(j, serializer: _json),
      ];
      final words = [
        for (final j in _list(data, 'words'))
          Word.fromJson(j, serializer: _json),
      ];
      final passes = [
        for (final j in _list(data, 'passSessions'))
          PassSession.fromJson({
            ...j,
            // JSON lists decode as List<dynamic>.
            'revealed': (j['revealed'] as List<Object?>).cast<String>(),
          }, serializer: _json),
      ];
      final settings = AppSetting.fromJson({
        // Settings added after the first backup format default when a
        // backup does not have them.
        'studyButtons': true,
        ...data['settings'] as Map<String, dynamic>,
      }, serializer: _json);

      await _db.transaction(() async {
        await _db.delete(_db.passSessions).go();
        await _db.delete(_db.wordlists).go(); // words, packs cascade
        await _db.delete(_db.categories).go();
        await _db.batch((b) {
          b.insertAll(_db.categories, categories);
          b.insertAll(_db.wordlists, wordlists);
          b.insertAll(_db.packs, packs);
          b.insertAll(_db.words, words);
          b.insertAll(_db.passSessions, passes);
          b.replace(_db.appSettings, settings.copyWith(id: 1));
        });
        await (_db.update(_db.uiState)..where((s) => s.id.equals(1))).write(
          const UiStateCompanion(
            expandedNodeIds: Value([]),
            selectedNodeId: Value(null),
          ),
        );
      });
    } on BackupFormatException {
      rethrow;
    } on TypeError catch (e) {
      throw BackupFormatException('malformed: $e');
    }
  }
}
