import 'package:uuid/uuid.dart';

import '../domain/clock.dart';
import '../domain/ids.dart';

/// The real clock (UTC).
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

/// UUID v4 ids, so backups from different devices never collide.
class UuidIdGenerator implements IdGenerator {
  UuidIdGenerator();

  final _uuid = const Uuid();

  @override
  String newId() => _uuid.v4();
}
