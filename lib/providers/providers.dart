import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/repositories/category_repo.dart';
import '../data/repositories/pack_repo.dart';
import '../data/repositories/pass_repo.dart';
import '../data/repositories/settings_repo.dart';
import '../data/repositories/ui_state_repo.dart';
import '../data/repositories/word_repo.dart';
import '../data/repositories/wordlist_repo.dart';
import '../data/system.dart';
import '../domain/clock.dart';
import '../domain/ids.dart';
import '../domain/importer.dart';
import '../domain/tree.dart';
import '../services/backup_files.dart';
import '../services/backup_service.dart';
import '../services/category_service.dart';
import '../services/file_picking.dart';
import '../services/import_service.dart';
import '../services/learning_service.dart';
import '../services/settings_service.dart';
import '../services/tagging_service.dart';
import '../services/tree_service.dart';
import '../services/wordlist_service.dart';

// Infrastructure. Tests override [databaseProvider] with an in-memory
// database, [clockProvider]/[idsProvider] with predictable ones and
// [importFilePickerProvider] with a fake picker.

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final idsProvider = Provider<IdGenerator>((ref) => UuidIdGenerator());

final importFilePickerProvider = Provider<ImportFilePicker>(
  (ref) => const SystemImportFilePicker(),
);

final backupFilesProvider = Provider<BackupFiles>(
  (ref) => const SystemBackupFiles(),
);

// Repositories and services.

final wordlistRepoProvider = Provider(
  (ref) => WordlistRepo(ref.watch(databaseProvider)),
);
final wordRepoProvider = Provider(
  (ref) => WordRepo(ref.watch(databaseProvider)),
);
final packRepoProvider = Provider(
  (ref) => PackRepo(ref.watch(databaseProvider)),
);
final passRepoProvider = Provider(
  (ref) => PassRepo(ref.watch(databaseProvider)),
);
final settingsRepoProvider = Provider(
  (ref) => SettingsRepo(ref.watch(databaseProvider)),
);

final importServiceProvider = Provider(
  (ref) => ImportService(
    db: ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idsProvider),
  ),
);

final learningServiceProvider = Provider(
  (ref) => LearningService(
    db: ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idsProvider),
  ),
);

final taggingServiceProvider = Provider(
  (ref) => TaggingService(
    db: ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idsProvider),
  ),
);

final categoryRepoProvider = Provider(
  (ref) => CategoryRepo(ref.watch(databaseProvider)),
);

final wordlistServiceProvider = Provider(
  (ref) => WordlistService(ref.watch(databaseProvider)),
);

// Streams for screens.

final wordlistsProvider = StreamProvider<List<Wordlist>>(
  (ref) => ref.watch(wordlistRepoProvider).watchAll(),
);

final wordlistProvider = StreamProvider.family<Wordlist?, String>(
  (ref, id) => ref.watch(wordlistRepoProvider).watch(id),
);

final packRowsProvider = StreamProvider.family<List<PackRow>, String>(
  (ref, wordlistId) => ref.watch(packRepoProvider).watchRows(wordlistId),
);

final openPassesProvider = StreamProvider.family<List<PassSession>, String>(
  (ref, wordlistId) => ref.watch(passRepoProvider).watchForWordlist(wordlistId),
);

final settingsProvider = StreamProvider<AppSetting>(
  (ref) => ref.watch(settingsRepoProvider).watch(),
);

// Import flow: the picked file, then its parsed preview.

class ImportDraftController extends Notifier<PickedFile?> {
  @override
  PickedFile? build() => null;

  void set(PickedFile file) => state = file;

  void clear() => state = null;
}

final importDraftProvider =
    NotifierProvider<ImportDraftController, PickedFile?>(
      ImportDraftController.new,
    );

/// The preview of the picked file, parsed in a background isolate.
/// Not retried on error: a bad file stays bad.
final importPreviewProvider = FutureProvider<ImportReport?>((ref) {
  final draft = ref.watch(importDraftProvider);
  if (draft == null) return null;
  return ref.read(importServiceProvider).preview(draft.bytes);
}, retry: (_, _) => null);

// Explorer.

final treeServiceProvider = Provider(
  (ref) => TreeService(ref.watch(databaseProvider)),
);

final uiStateRepoProvider = Provider(
  (ref) => UiStateRepo(ref.watch(databaseProvider)),
);

final uiStateProvider = StreamProvider<UiStateData>(
  (ref) => ref.watch(uiStateRepoProvider).watch(),
);

/// The explorer tree, updated live.
final treeProvider = StreamProvider<List<TreeNode>>(
  (ref) => ref.watch(treeServiceProvider).watchTree(),
);

/// The words behind a tree node, updated live.
final nodeWordsProvider = StreamProvider.family<List<Word>, String>(
  (ref, nodeId) => ref.watch(treeServiceProvider).watchWords(nodeId),
);

/// Packs that are Learned now: their words can be tagged in the explorer.
final learnedPackIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(treeServiceProvider).watchLearnedPackIds(),
);

final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepoProvider).watchAll(),
);

// Settings, categories, backup.

final settingsServiceProvider = Provider(
  (ref) => SettingsService(
    db: ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idsProvider),
  ),
);

final categoryServiceProvider = Provider(
  (ref) => CategoryService(ref.watch(databaseProvider)),
);

final categoryUsageProvider = StreamProvider<List<CategoryUsage>>(
  (ref) => ref.watch(categoryServiceProvider).watchUsage(),
);

final backupServiceProvider = Provider(
  (ref) => BackupService(
    db: ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);
