import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../data/repositories/settings_repo.dart';
import '../domain/clock.dart';
import '../domain/ids.dart';
import '../domain/models.dart';
import '../domain/packing.dart';

class InvalidPackSizeException implements Exception {
  const InvalidPackSizeException(this.size);

  final int size;

  @override
  String toString() => 'InvalidPackSizeException($size)';
}

/// What a pack-size change will do, for the confirmation dialog.
class PackSizePreview {
  const PackSizePreview({
    required this.size,
    required this.wordlists,
    required this.openPasses,
  });

  final int size;

  /// Per wordlist: name, packs now, packs after.
  final List<({String name, int before, int after})> wordlists;

  /// Passes in progress that will be discarded.
  final int openPasses;
}

/// Settings (`docs/REQUIREMENTS.md` §6). Every change is one transaction;
/// the learned rule is re-evaluated on read, so changing it writes nothing
/// else (pack status is derived).
class SettingsService {
  SettingsService({
    required AppDatabase db,
    required Clock clock,
    required IdGenerator ids,
  }) : _db = db,
       _clock = clock,
       _ids = ids,
       _settings = SettingsRepo(db);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final SettingsRepo _settings;

  Future<void> _write(AppSettingsCompanion c) => _db.transaction(
    () => (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(c),
  );

  Future<void> setDefaultDirection(Direction d) =>
      _write(AppSettingsCompanion(defaultDirection: Value(d)));

  Future<void> setLearnedRule(LearnedRule r) =>
      _write(AppSettingsCompanion(learnedRule: Value(r)));

  Future<void> setShowPos(bool v) =>
      _write(AppSettingsCompanion(showPos: Value(v)));

  Future<void> setDemoteOnReveal(bool v) =>
      _write(AppSettingsCompanion(demoteOnReveal: Value(v)));

  /// `light`, `dark` or `system`.
  Future<void> setTheme(String theme) {
    if (!const {'light', 'dark', 'system'}.contains(theme)) {
      throw ArgumentError.value(theme, 'theme');
    }
    return _write(AppSettingsCompanion(theme: Value(theme)));
  }

  static void _checkSize(int size) {
    if (size < minPackSize || size > maxPackSize) {
      throw InvalidPackSizeException(size);
    }
  }

  Future<PackSizePreview> previewPackSizeChange(int size) async {
    _checkSize(size);
    final lists = await (_db.select(
      _db.wordlists,
    )..orderBy([(w) => OrderingTerm.asc(w.name)])).get();
    final packs = await _db.select(_db.packs).get();
    final open = await _db.select(_db.passSessions).get();
    return PackSizePreview(
      size: size,
      wordlists: [
        for (final l in lists)
          (
            name: l.name,
            before: packs.where((p) => p.wordlistId == l.id).length,
            after: (l.wordCount + size - 1) ~/ size,
          ),
      ],
      openPasses: open.length,
    );
  }

  /// Rebuilds every pack of every wordlist with [size] words
  /// (`docs/LEARNING_LOGIC.md` §6): open passes are discarded, pack mastery
  /// is derived from the words' own progress, tags and categories are
  /// untouched. One transaction.
  Future<void> applyPackSizeChange(int size) async {
    _checkSize(size);
    await _db.transaction(() async {
      final now = _clock.now();
      final rule = (await _settings.get()).learnedRule;
      await _db.delete(_db.passSessions).go();

      for (final list in await _db.select(_db.wordlists).get()) {
        final words =
            await (_db.select(_db.words)
                  ..where((w) => w.wordlistId.equals(list.id))
                  ..orderBy([(w) => OrderingTerm.asc(w.position)]))
                .get();
        final plans = rebuildPacks(
          words: [
            for (final w in words)
              WordProgress(
                wordId: w.id,
                masteredWd: w.masteredWd,
                masteredDw: w.masteredDw,
                revealCountWd: w.revealCountWd,
                revealCountDw: w.revealCountDw,
              ),
          ],
          size: size,
          rule: rule,
          now: now,
        );

        // Old packs step aside (numbers must stay unique per wordlist),
        // words move to the new packs, then the old packs go.
        final old = await (_db.select(
          _db.packs,
        )..where((p) => p.wordlistId.equals(list.id))).get();
        for (final p in old) {
          await (_db.update(_db.packs)..where((x) => x.id.equals(p.id))).write(
            PacksCompanion(number: Value(-p.number)),
          );
        }
        for (final plan in plans) {
          final packId = _ids.newId();
          await _db
              .into(_db.packs)
              .insert(
                PacksCompanion.insert(
                  id: packId,
                  wordlistId: list.id,
                  number: plan.number,
                  masteryWd: plan.progress.wd,
                  masteryDw: plan.progress.dw,
                  masteredAtWd: Value(
                    plan.progress.wd == Mastery.mastered ? now : null,
                  ),
                  masteredAtDw: Value(
                    plan.progress.dw == Mastery.mastered ? now : null,
                  ),
                  learnedAt: Value(plan.learnedAt),
                  createdAt: now,
                ),
              );
          await (_db.update(_db.words)..where((w) => w.id.isIn(plan.wordIds)))
              .write(WordsCompanion(packId: Value(packId)));
        }
        await (_db.delete(
          _db.packs,
        )..where((p) => p.id.isIn([for (final p in old) p.id]))).go();
      }

      await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
        AppSettingsCompanion(packSize: Value(size)),
      );
    });
  }
}
