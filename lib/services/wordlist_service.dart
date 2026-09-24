import '../data/db/database.dart';
import '../data/repositories/wordlist_repo.dart';
import 'exceptions.dart';
import 'import_service.dart';

/// Rename and delete wordlists (IMP-6).
class WordlistService {
  WordlistService(AppDatabase db) : _db = db, _wordlists = WordlistRepo(db);

  final AppDatabase _db;
  final WordlistRepo _wordlists;

  Future<void> rename(String id, String name) => _db.transaction(() async {
    final list = await _wordlists.get(id);
    if (list == null) throw WordlistNotFoundException(id);
    await _wordlists.rename(id, wordlistName(name, list.sourceFilename));
  });

  /// Removes its words, packs and open passes; categories remain.
  Future<void> delete(String id) => _db.transaction(() async {
    if (await _wordlists.get(id) == null) throw WordlistNotFoundException(id);
    await _wordlists.delete(id);
  });
}
