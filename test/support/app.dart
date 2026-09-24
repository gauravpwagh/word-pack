import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/app/app.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/providers/providers.dart';
import 'package:wordpack/services/backup_files.dart';
import 'package:wordpack/services/file_picking.dart';
import 'package:wordpack/services/import_service.dart';

import 'test_db.dart';

/// Returns the queued files one per pick; null (cancel) when empty.
class FakeFilePicker implements ImportFilePicker {
  final queue = <PickedFile>[];
  var picks = 0;

  void add(String name, List<int> bytes) =>
      queue.add(PickedFile(name: name, bytes: Uint8List.fromList(bytes)));

  void addFixture(String name) =>
      add(name, File('fixtures/$name').readAsBytesSync());

  @override
  Future<PickedFile?> pick() async {
    picks++;
    return queue.isEmpty ? null : queue.removeAt(0);
  }
}

/// Keeps saved backups in memory; [open] returns [toOpen].
class FakeBackupFiles implements BackupFiles {
  final saved = <String, String>{};
  String? toOpen;

  @override
  Future<bool> save(String fileName, String content) async {
    saved[fileName] = content;
    return true;
  }

  @override
  Future<String?> open() async => toOpen;
}

class TestApp {
  TestApp._(this.db, this.picker, this.backups);

  final AppDatabase db;
  final FakeFilePicker picker;
  final FakeBackupFiles backups;
}

/// A widget test of the whole app on an in-memory database with a fake file
/// picker and inline parsing, at [size] logical pixels. The app is unmounted
/// and the database closed at the end of the body, before Flutter checks for
/// pending timers (drift closes stream queries on a zero-length timer).
void testApp(
  String description,
  Future<void> Function(WidgetTester tester, TestApp app) body, {
  Size size = const Size(360, 780),
  bool semantics = false,
}) {
  testWidgets(description, semanticsEnabled: semantics, (tester) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final database = memoryDb();
    final picker = FakeFilePicker();
    final backups = FakeBackupFiles();
    final clock = FixedClock();
    final ids = SeqIds();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(clock),
          idsProvider.overrideWithValue(ids),
          importFilePickerProvider.overrideWithValue(picker),
          backupFilesProvider.overrideWithValue(backups),
          importServiceProvider.overrideWithValue(
            ImportService(
              db: database,
              clock: clock,
              ids: ids,
              parser: parseInline,
            ),
          ),
        ],
        child: const WordPackApp(),
      ),
    );
    await tester.pumpAndSettle();
    try {
      await body(tester, TestApp._(database, picker, backups));
    } finally {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
      await database.close();
    }
  });
}
