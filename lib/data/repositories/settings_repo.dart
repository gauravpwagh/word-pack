import '../db/database.dart';

/// The single `AppSettings` row (seeded on create).
class SettingsRepo {
  SettingsRepo(this._db);

  final AppDatabase _db;

  Future<AppSetting> get() => _query.getSingle();

  Stream<AppSetting> watch() => _query.watchSingle();

  late final _query = _db.select(_db.appSettings)..where((s) => s.id.equals(1));
}
