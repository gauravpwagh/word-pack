/// Typed service errors; the UI turns each into a localised message.
library;

export '../domain/categories.dart'
    show InvalidCategoryNameException, InvalidSubcategoryException;

enum ImportError {
  /// Larger than [ImportService.maxBytes] (IMP-1).
  tooLarge,

  /// Neither UTF-8 nor Windows-1252.
  unreadable,

  /// Parsed, but not a single valid word (`NO_WORDS_FOUND`).
  noWordsFound,
}

class ImportException implements Exception {
  const ImportException(this.error);

  final ImportError error;

  @override
  String toString() => 'ImportException(${error.name})';
}

class WordlistNotFoundException implements Exception {
  const WordlistNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'WordlistNotFoundException($id)';
}

/// Categorising a word whose pack is not Learned (D-9).
class WordNotLearnedException implements Exception {
  const WordNotLearnedException(this.wordId);

  final String wordId;

  @override
  String toString() => 'WordNotLearnedException($wordId)';
}

class WordNotFoundException implements Exception {
  const WordNotFoundException(this.wordId);

  final String wordId;

  @override
  String toString() => 'WordNotFoundException($wordId)';
}
