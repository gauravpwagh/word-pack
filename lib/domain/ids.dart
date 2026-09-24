/// Source of new entity ids (UUID v4 in the app, predictable ids in tests).
abstract interface class IdGenerator {
  String newId();
}
