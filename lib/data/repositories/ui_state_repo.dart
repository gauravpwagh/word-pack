import 'package:drift/drift.dart';

import '../db/database.dart';

/// The single `UiState` row: tree expansion and selection, explorer viewer
/// mode, tree panel visibility (EXP-9, `docs/UI_UX.md` §1).
class UiStateRepo {
  UiStateRepo(this._db);

  final AppDatabase _db;

  late final _row = _db.select(_db.uiState)..where((s) => s.id.equals(1));

  Stream<UiStateData> watch() => _row.watchSingle();

  Future<UiStateData> get() => _row.getSingle();

  Future<void> _write(UiStateCompanion c) =>
      (_db.update(_db.uiState)..where((s) => s.id.equals(1))).write(c);

  Future<void> setExpanded(Set<String> ids) =>
      _write(UiStateCompanion(expandedNodeIds: Value(ids.toList()..sort())));

  Future<void> setSelected(String? id) =>
      _write(UiStateCompanion(selectedNodeId: Value(id)));

  /// `card` or `list`.
  Future<void> setViewerMode(String mode) =>
      _write(UiStateCompanion(viewerMode: Value(mode)));

  Future<void> setTreePanelOpen(bool open) =>
      _write(UiStateCompanion(treePanelOpen: Value(open)));

  /// One more pass finished with the study buttons off (D-34).
  Future<void> countGestureHintPass() => _db.customUpdate(
    'UPDATE ui_state SET gesture_hint_passes = gesture_hint_passes + 1 '
    'WHERE id = 1',
    updates: {_db.uiState},
  );
}
