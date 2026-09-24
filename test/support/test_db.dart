import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/domain/clock.dart';
import 'package:wordpack/domain/ids.dart';

/// Host tests on Windows use the SQLite that ships with Windows; on Android
/// the app bundles its own through sqlite3_flutter_libs.
void useHostSqlite() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  if (Platform.isWindows) {
    open.overrideFor(
      OperatingSystem.windows,
      () => DynamicLibrary.open('winsqlite3.dll'),
    );
  }
}

AppDatabase memoryDb() {
  useHostSqlite();
  return AppDatabase(NativeDatabase.memory());
}

AppDatabase fileDb(File file) {
  useHostSqlite();
  return AppDatabase(NativeDatabase(file));
}

class FixedClock implements Clock {
  FixedClock([DateTime? at]) : at = at ?? DateTime.utc(2026, 9, 24, 10);

  DateTime at;

  @override
  DateTime now() => at;
}

/// `id-1`, `id-2`, …; set [failAfter] to throw once that many ids were made.
class SeqIds implements IdGenerator {
  SeqIds({this.failAfter});

  final int? failAfter;
  var _n = 0;

  @override
  String newId() {
    _n++;
    if (failAfter != null && _n > failAfter!) {
      throw StateError('id generator failed');
    }
    return 'id-$_n';
  }
}
