/// Source of the current time. Domain code never calls `DateTime.now()`; the
/// app injects a system clock and tests inject a fixed one.
abstract interface class Clock {
  /// The current time in UTC.
  DateTime now();
}
