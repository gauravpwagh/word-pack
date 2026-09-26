// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WordlistsTable extends Wordlists
    with TableInfo<$WordlistsTable, Wordlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordlistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFilenameMeta = const VerificationMeta(
    'sourceFilename',
  );
  @override
  late final GeneratedColumn<String> sourceFilename = GeneratedColumn<String>(
    'source_filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFormatMeta = const VerificationMeta(
    'sourceFormat',
  );
  @override
  late final GeneratedColumn<String> sourceFormat = GeneratedColumn<String>(
    'source_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sourceFilename,
    sourceFormat,
    wordCount,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wordlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wordlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source_filename')) {
      context.handle(
        _sourceFilenameMeta,
        sourceFilename.isAcceptableOrUnknown(
          data['source_filename']!,
          _sourceFilenameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceFilenameMeta);
    }
    if (data.containsKey('source_format')) {
      context.handle(
        _sourceFormatMeta,
        sourceFormat.isAcceptableOrUnknown(
          data['source_format']!,
          _sourceFormatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceFormatMeta);
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    } else if (isInserting) {
      context.missing(_wordCountMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wordlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wordlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sourceFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_filename'],
      )!,
      sourceFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_format'],
      )!,
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $WordlistsTable createAlias(String alias) {
    return $WordlistsTable(attachedDatabase, alias);
  }
}

class Wordlist extends DataClass implements Insertable<Wordlist> {
  final String id;
  final String name;
  final String sourceFilename;

  /// `dash` | `columns` (ImportFormat.name).
  final String sourceFormat;
  final int wordCount;
  final DateTime importedAt;
  const Wordlist({
    required this.id,
    required this.name,
    required this.sourceFilename,
    required this.sourceFormat,
    required this.wordCount,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['source_filename'] = Variable<String>(sourceFilename);
    map['source_format'] = Variable<String>(sourceFormat);
    map['word_count'] = Variable<int>(wordCount);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  WordlistsCompanion toCompanion(bool nullToAbsent) {
    return WordlistsCompanion(
      id: Value(id),
      name: Value(name),
      sourceFilename: Value(sourceFilename),
      sourceFormat: Value(sourceFormat),
      wordCount: Value(wordCount),
      importedAt: Value(importedAt),
    );
  }

  factory Wordlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wordlist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sourceFilename: serializer.fromJson<String>(json['sourceFilename']),
      sourceFormat: serializer.fromJson<String>(json['sourceFormat']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sourceFilename': serializer.toJson<String>(sourceFilename),
      'sourceFormat': serializer.toJson<String>(sourceFormat),
      'wordCount': serializer.toJson<int>(wordCount),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  Wordlist copyWith({
    String? id,
    String? name,
    String? sourceFilename,
    String? sourceFormat,
    int? wordCount,
    DateTime? importedAt,
  }) => Wordlist(
    id: id ?? this.id,
    name: name ?? this.name,
    sourceFilename: sourceFilename ?? this.sourceFilename,
    sourceFormat: sourceFormat ?? this.sourceFormat,
    wordCount: wordCount ?? this.wordCount,
    importedAt: importedAt ?? this.importedAt,
  );
  Wordlist copyWithCompanion(WordlistsCompanion data) {
    return Wordlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sourceFilename: data.sourceFilename.present
          ? data.sourceFilename.value
          : this.sourceFilename,
      sourceFormat: data.sourceFormat.present
          ? data.sourceFormat.value
          : this.sourceFormat,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wordlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sourceFilename: $sourceFilename, ')
          ..write('sourceFormat: $sourceFormat, ')
          ..write('wordCount: $wordCount, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sourceFilename,
    sourceFormat,
    wordCount,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wordlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.sourceFilename == this.sourceFilename &&
          other.sourceFormat == this.sourceFormat &&
          other.wordCount == this.wordCount &&
          other.importedAt == this.importedAt);
}

class WordlistsCompanion extends UpdateCompanion<Wordlist> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> sourceFilename;
  final Value<String> sourceFormat;
  final Value<int> wordCount;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const WordlistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sourceFilename = const Value.absent(),
    this.sourceFormat = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordlistsCompanion.insert({
    required String id,
    required String name,
    required String sourceFilename,
    required String sourceFormat,
    required int wordCount,
    required DateTime importedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sourceFilename = Value(sourceFilename),
       sourceFormat = Value(sourceFormat),
       wordCount = Value(wordCount),
       importedAt = Value(importedAt);
  static Insertable<Wordlist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sourceFilename,
    Expression<String>? sourceFormat,
    Expression<int>? wordCount,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sourceFilename != null) 'source_filename': sourceFilename,
      if (sourceFormat != null) 'source_format': sourceFormat,
      if (wordCount != null) 'word_count': wordCount,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordlistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? sourceFilename,
    Value<String>? sourceFormat,
    Value<int>? wordCount,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return WordlistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceFilename: sourceFilename ?? this.sourceFilename,
      sourceFormat: sourceFormat ?? this.sourceFormat,
      wordCount: wordCount ?? this.wordCount,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sourceFilename.present) {
      map['source_filename'] = Variable<String>(sourceFilename.value);
    }
    if (sourceFormat.present) {
      map['source_format'] = Variable<String>(sourceFormat.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordlistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sourceFilename: $sourceFilename, ')
          ..write('sourceFormat: $sourceFormat, ')
          ..write('wordCount: $wordCount, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PacksTable extends Packs with TableInfo<$PacksTable, Pack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordlistIdMeta = const VerificationMeta(
    'wordlistId',
  );
  @override
  late final GeneratedColumn<String> wordlistId = GeneratedColumn<String>(
    'wordlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wordlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Mastery, String> masteryWd =
      GeneratedColumn<String>(
        'mastery_wd',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Mastery>($PacksTable.$convertermasteryWd);
  @override
  late final GeneratedColumnWithTypeConverter<Mastery, String> masteryDw =
      GeneratedColumn<String>(
        'mastery_dw',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Mastery>($PacksTable.$convertermasteryDw);
  static const VerificationMeta _passesWdMeta = const VerificationMeta(
    'passesWd',
  );
  @override
  late final GeneratedColumn<int> passesWd = GeneratedColumn<int>(
    'passes_wd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _passesDwMeta = const VerificationMeta(
    'passesDw',
  );
  @override
  late final GeneratedColumn<int> passesDw = GeneratedColumn<int>(
    'passes_dw',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cleanPassesWdMeta = const VerificationMeta(
    'cleanPassesWd',
  );
  @override
  late final GeneratedColumn<int> cleanPassesWd = GeneratedColumn<int>(
    'clean_passes_wd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cleanPassesDwMeta = const VerificationMeta(
    'cleanPassesDw',
  );
  @override
  late final GeneratedColumn<int> cleanPassesDw = GeneratedColumn<int>(
    'clean_passes_dw',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPassAtWdMeta = const VerificationMeta(
    'lastPassAtWd',
  );
  @override
  late final GeneratedColumn<DateTime> lastPassAtWd = GeneratedColumn<DateTime>(
    'last_pass_at_wd',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPassAtDwMeta = const VerificationMeta(
    'lastPassAtDw',
  );
  @override
  late final GeneratedColumn<DateTime> lastPassAtDw = GeneratedColumn<DateTime>(
    'last_pass_at_dw',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _masteredAtWdMeta = const VerificationMeta(
    'masteredAtWd',
  );
  @override
  late final GeneratedColumn<DateTime> masteredAtWd = GeneratedColumn<DateTime>(
    'mastered_at_wd',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _masteredAtDwMeta = const VerificationMeta(
    'masteredAtDw',
  );
  @override
  late final GeneratedColumn<DateTime> masteredAtDw = GeneratedColumn<DateTime>(
    'mastered_at_dw',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Direction?, String>
  lastDirection = GeneratedColumn<String>(
    'last_direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Direction?>($PacksTable.$converterlastDirectionn);
  static const VerificationMeta _learnedAtMeta = const VerificationMeta(
    'learnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> learnedAt = GeneratedColumn<DateTime>(
    'learned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordlistId,
    number,
    masteryWd,
    masteryDw,
    passesWd,
    passesDw,
    cleanPassesWd,
    cleanPassesDw,
    lastPassAtWd,
    lastPassAtDw,
    masteredAtWd,
    masteredAtDw,
    lastDirection,
    learnedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('wordlist_id')) {
      context.handle(
        _wordlistIdMeta,
        wordlistId.isAcceptableOrUnknown(data['wordlist_id']!, _wordlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordlistIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('passes_wd')) {
      context.handle(
        _passesWdMeta,
        passesWd.isAcceptableOrUnknown(data['passes_wd']!, _passesWdMeta),
      );
    }
    if (data.containsKey('passes_dw')) {
      context.handle(
        _passesDwMeta,
        passesDw.isAcceptableOrUnknown(data['passes_dw']!, _passesDwMeta),
      );
    }
    if (data.containsKey('clean_passes_wd')) {
      context.handle(
        _cleanPassesWdMeta,
        cleanPassesWd.isAcceptableOrUnknown(
          data['clean_passes_wd']!,
          _cleanPassesWdMeta,
        ),
      );
    }
    if (data.containsKey('clean_passes_dw')) {
      context.handle(
        _cleanPassesDwMeta,
        cleanPassesDw.isAcceptableOrUnknown(
          data['clean_passes_dw']!,
          _cleanPassesDwMeta,
        ),
      );
    }
    if (data.containsKey('last_pass_at_wd')) {
      context.handle(
        _lastPassAtWdMeta,
        lastPassAtWd.isAcceptableOrUnknown(
          data['last_pass_at_wd']!,
          _lastPassAtWdMeta,
        ),
      );
    }
    if (data.containsKey('last_pass_at_dw')) {
      context.handle(
        _lastPassAtDwMeta,
        lastPassAtDw.isAcceptableOrUnknown(
          data['last_pass_at_dw']!,
          _lastPassAtDwMeta,
        ),
      );
    }
    if (data.containsKey('mastered_at_wd')) {
      context.handle(
        _masteredAtWdMeta,
        masteredAtWd.isAcceptableOrUnknown(
          data['mastered_at_wd']!,
          _masteredAtWdMeta,
        ),
      );
    }
    if (data.containsKey('mastered_at_dw')) {
      context.handle(
        _masteredAtDwMeta,
        masteredAtDw.isAcceptableOrUnknown(
          data['mastered_at_dw']!,
          _masteredAtDwMeta,
        ),
      );
    }
    if (data.containsKey('learned_at')) {
      context.handle(
        _learnedAtMeta,
        learnedAt.isAcceptableOrUnknown(data['learned_at']!, _learnedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {wordlistId, number},
  ];
  @override
  Pack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      wordlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wordlist_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      masteryWd: $PacksTable.$convertermasteryWd.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mastery_wd'],
        )!,
      ),
      masteryDw: $PacksTable.$convertermasteryDw.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mastery_dw'],
        )!,
      ),
      passesWd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passes_wd'],
      )!,
      passesDw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passes_dw'],
      )!,
      cleanPassesWd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clean_passes_wd'],
      )!,
      cleanPassesDw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clean_passes_dw'],
      )!,
      lastPassAtWd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pass_at_wd'],
      ),
      lastPassAtDw: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pass_at_dw'],
      ),
      masteredAtWd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}mastered_at_wd'],
      ),
      masteredAtDw: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}mastered_at_dw'],
      ),
      lastDirection: $PacksTable.$converterlastDirectionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_direction'],
        ),
      ),
      learnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}learned_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PacksTable createAlias(String alias) {
    return $PacksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Mastery, String, String> $convertermasteryWd =
      const EnumNameConverter<Mastery>(Mastery.values);
  static JsonTypeConverter2<Mastery, String, String> $convertermasteryDw =
      const EnumNameConverter<Mastery>(Mastery.values);
  static JsonTypeConverter2<Direction, String, String> $converterlastDirection =
      const EnumNameConverter<Direction>(Direction.values);
  static JsonTypeConverter2<Direction?, String?, String?>
  $converterlastDirectionn = JsonTypeConverter2.asNullable(
    $converterlastDirection,
  );
}

class Pack extends DataClass implements Insertable<Pack> {
  final String id;
  final String wordlistId;

  /// 1-based.
  final int number;
  final Mastery masteryWd;
  final Mastery masteryDw;
  final int passesWd;
  final int passesDw;
  final int cleanPassesWd;
  final int cleanPassesDw;
  final DateTime? lastPassAtWd;
  final DateTime? lastPassAtDw;
  final DateTime? masteredAtWd;
  final DateTime? masteredAtDw;
  final Direction? lastDirection;
  final DateTime? learnedAt;
  final DateTime createdAt;
  const Pack({
    required this.id,
    required this.wordlistId,
    required this.number,
    required this.masteryWd,
    required this.masteryDw,
    required this.passesWd,
    required this.passesDw,
    required this.cleanPassesWd,
    required this.cleanPassesDw,
    this.lastPassAtWd,
    this.lastPassAtDw,
    this.masteredAtWd,
    this.masteredAtDw,
    this.lastDirection,
    this.learnedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['wordlist_id'] = Variable<String>(wordlistId);
    map['number'] = Variable<int>(number);
    {
      map['mastery_wd'] = Variable<String>(
        $PacksTable.$convertermasteryWd.toSql(masteryWd),
      );
    }
    {
      map['mastery_dw'] = Variable<String>(
        $PacksTable.$convertermasteryDw.toSql(masteryDw),
      );
    }
    map['passes_wd'] = Variable<int>(passesWd);
    map['passes_dw'] = Variable<int>(passesDw);
    map['clean_passes_wd'] = Variable<int>(cleanPassesWd);
    map['clean_passes_dw'] = Variable<int>(cleanPassesDw);
    if (!nullToAbsent || lastPassAtWd != null) {
      map['last_pass_at_wd'] = Variable<DateTime>(lastPassAtWd);
    }
    if (!nullToAbsent || lastPassAtDw != null) {
      map['last_pass_at_dw'] = Variable<DateTime>(lastPassAtDw);
    }
    if (!nullToAbsent || masteredAtWd != null) {
      map['mastered_at_wd'] = Variable<DateTime>(masteredAtWd);
    }
    if (!nullToAbsent || masteredAtDw != null) {
      map['mastered_at_dw'] = Variable<DateTime>(masteredAtDw);
    }
    if (!nullToAbsent || lastDirection != null) {
      map['last_direction'] = Variable<String>(
        $PacksTable.$converterlastDirectionn.toSql(lastDirection),
      );
    }
    if (!nullToAbsent || learnedAt != null) {
      map['learned_at'] = Variable<DateTime>(learnedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PacksCompanion toCompanion(bool nullToAbsent) {
    return PacksCompanion(
      id: Value(id),
      wordlistId: Value(wordlistId),
      number: Value(number),
      masteryWd: Value(masteryWd),
      masteryDw: Value(masteryDw),
      passesWd: Value(passesWd),
      passesDw: Value(passesDw),
      cleanPassesWd: Value(cleanPassesWd),
      cleanPassesDw: Value(cleanPassesDw),
      lastPassAtWd: lastPassAtWd == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPassAtWd),
      lastPassAtDw: lastPassAtDw == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPassAtDw),
      masteredAtWd: masteredAtWd == null && nullToAbsent
          ? const Value.absent()
          : Value(masteredAtWd),
      masteredAtDw: masteredAtDw == null && nullToAbsent
          ? const Value.absent()
          : Value(masteredAtDw),
      lastDirection: lastDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDirection),
      learnedAt: learnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(learnedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Pack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pack(
      id: serializer.fromJson<String>(json['id']),
      wordlistId: serializer.fromJson<String>(json['wordlistId']),
      number: serializer.fromJson<int>(json['number']),
      masteryWd: $PacksTable.$convertermasteryWd.fromJson(
        serializer.fromJson<String>(json['masteryWd']),
      ),
      masteryDw: $PacksTable.$convertermasteryDw.fromJson(
        serializer.fromJson<String>(json['masteryDw']),
      ),
      passesWd: serializer.fromJson<int>(json['passesWd']),
      passesDw: serializer.fromJson<int>(json['passesDw']),
      cleanPassesWd: serializer.fromJson<int>(json['cleanPassesWd']),
      cleanPassesDw: serializer.fromJson<int>(json['cleanPassesDw']),
      lastPassAtWd: serializer.fromJson<DateTime?>(json['lastPassAtWd']),
      lastPassAtDw: serializer.fromJson<DateTime?>(json['lastPassAtDw']),
      masteredAtWd: serializer.fromJson<DateTime?>(json['masteredAtWd']),
      masteredAtDw: serializer.fromJson<DateTime?>(json['masteredAtDw']),
      lastDirection: $PacksTable.$converterlastDirectionn.fromJson(
        serializer.fromJson<String?>(json['lastDirection']),
      ),
      learnedAt: serializer.fromJson<DateTime?>(json['learnedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'wordlistId': serializer.toJson<String>(wordlistId),
      'number': serializer.toJson<int>(number),
      'masteryWd': serializer.toJson<String>(
        $PacksTable.$convertermasteryWd.toJson(masteryWd),
      ),
      'masteryDw': serializer.toJson<String>(
        $PacksTable.$convertermasteryDw.toJson(masteryDw),
      ),
      'passesWd': serializer.toJson<int>(passesWd),
      'passesDw': serializer.toJson<int>(passesDw),
      'cleanPassesWd': serializer.toJson<int>(cleanPassesWd),
      'cleanPassesDw': serializer.toJson<int>(cleanPassesDw),
      'lastPassAtWd': serializer.toJson<DateTime?>(lastPassAtWd),
      'lastPassAtDw': serializer.toJson<DateTime?>(lastPassAtDw),
      'masteredAtWd': serializer.toJson<DateTime?>(masteredAtWd),
      'masteredAtDw': serializer.toJson<DateTime?>(masteredAtDw),
      'lastDirection': serializer.toJson<String?>(
        $PacksTable.$converterlastDirectionn.toJson(lastDirection),
      ),
      'learnedAt': serializer.toJson<DateTime?>(learnedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Pack copyWith({
    String? id,
    String? wordlistId,
    int? number,
    Mastery? masteryWd,
    Mastery? masteryDw,
    int? passesWd,
    int? passesDw,
    int? cleanPassesWd,
    int? cleanPassesDw,
    Value<DateTime?> lastPassAtWd = const Value.absent(),
    Value<DateTime?> lastPassAtDw = const Value.absent(),
    Value<DateTime?> masteredAtWd = const Value.absent(),
    Value<DateTime?> masteredAtDw = const Value.absent(),
    Value<Direction?> lastDirection = const Value.absent(),
    Value<DateTime?> learnedAt = const Value.absent(),
    DateTime? createdAt,
  }) => Pack(
    id: id ?? this.id,
    wordlistId: wordlistId ?? this.wordlistId,
    number: number ?? this.number,
    masteryWd: masteryWd ?? this.masteryWd,
    masteryDw: masteryDw ?? this.masteryDw,
    passesWd: passesWd ?? this.passesWd,
    passesDw: passesDw ?? this.passesDw,
    cleanPassesWd: cleanPassesWd ?? this.cleanPassesWd,
    cleanPassesDw: cleanPassesDw ?? this.cleanPassesDw,
    lastPassAtWd: lastPassAtWd.present ? lastPassAtWd.value : this.lastPassAtWd,
    lastPassAtDw: lastPassAtDw.present ? lastPassAtDw.value : this.lastPassAtDw,
    masteredAtWd: masteredAtWd.present ? masteredAtWd.value : this.masteredAtWd,
    masteredAtDw: masteredAtDw.present ? masteredAtDw.value : this.masteredAtDw,
    lastDirection: lastDirection.present
        ? lastDirection.value
        : this.lastDirection,
    learnedAt: learnedAt.present ? learnedAt.value : this.learnedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Pack copyWithCompanion(PacksCompanion data) {
    return Pack(
      id: data.id.present ? data.id.value : this.id,
      wordlistId: data.wordlistId.present
          ? data.wordlistId.value
          : this.wordlistId,
      number: data.number.present ? data.number.value : this.number,
      masteryWd: data.masteryWd.present ? data.masteryWd.value : this.masteryWd,
      masteryDw: data.masteryDw.present ? data.masteryDw.value : this.masteryDw,
      passesWd: data.passesWd.present ? data.passesWd.value : this.passesWd,
      passesDw: data.passesDw.present ? data.passesDw.value : this.passesDw,
      cleanPassesWd: data.cleanPassesWd.present
          ? data.cleanPassesWd.value
          : this.cleanPassesWd,
      cleanPassesDw: data.cleanPassesDw.present
          ? data.cleanPassesDw.value
          : this.cleanPassesDw,
      lastPassAtWd: data.lastPassAtWd.present
          ? data.lastPassAtWd.value
          : this.lastPassAtWd,
      lastPassAtDw: data.lastPassAtDw.present
          ? data.lastPassAtDw.value
          : this.lastPassAtDw,
      masteredAtWd: data.masteredAtWd.present
          ? data.masteredAtWd.value
          : this.masteredAtWd,
      masteredAtDw: data.masteredAtDw.present
          ? data.masteredAtDw.value
          : this.masteredAtDw,
      lastDirection: data.lastDirection.present
          ? data.lastDirection.value
          : this.lastDirection,
      learnedAt: data.learnedAt.present ? data.learnedAt.value : this.learnedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pack(')
          ..write('id: $id, ')
          ..write('wordlistId: $wordlistId, ')
          ..write('number: $number, ')
          ..write('masteryWd: $masteryWd, ')
          ..write('masteryDw: $masteryDw, ')
          ..write('passesWd: $passesWd, ')
          ..write('passesDw: $passesDw, ')
          ..write('cleanPassesWd: $cleanPassesWd, ')
          ..write('cleanPassesDw: $cleanPassesDw, ')
          ..write('lastPassAtWd: $lastPassAtWd, ')
          ..write('lastPassAtDw: $lastPassAtDw, ')
          ..write('masteredAtWd: $masteredAtWd, ')
          ..write('masteredAtDw: $masteredAtDw, ')
          ..write('lastDirection: $lastDirection, ')
          ..write('learnedAt: $learnedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wordlistId,
    number,
    masteryWd,
    masteryDw,
    passesWd,
    passesDw,
    cleanPassesWd,
    cleanPassesDw,
    lastPassAtWd,
    lastPassAtDw,
    masteredAtWd,
    masteredAtDw,
    lastDirection,
    learnedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pack &&
          other.id == this.id &&
          other.wordlistId == this.wordlistId &&
          other.number == this.number &&
          other.masteryWd == this.masteryWd &&
          other.masteryDw == this.masteryDw &&
          other.passesWd == this.passesWd &&
          other.passesDw == this.passesDw &&
          other.cleanPassesWd == this.cleanPassesWd &&
          other.cleanPassesDw == this.cleanPassesDw &&
          other.lastPassAtWd == this.lastPassAtWd &&
          other.lastPassAtDw == this.lastPassAtDw &&
          other.masteredAtWd == this.masteredAtWd &&
          other.masteredAtDw == this.masteredAtDw &&
          other.lastDirection == this.lastDirection &&
          other.learnedAt == this.learnedAt &&
          other.createdAt == this.createdAt);
}

class PacksCompanion extends UpdateCompanion<Pack> {
  final Value<String> id;
  final Value<String> wordlistId;
  final Value<int> number;
  final Value<Mastery> masteryWd;
  final Value<Mastery> masteryDw;
  final Value<int> passesWd;
  final Value<int> passesDw;
  final Value<int> cleanPassesWd;
  final Value<int> cleanPassesDw;
  final Value<DateTime?> lastPassAtWd;
  final Value<DateTime?> lastPassAtDw;
  final Value<DateTime?> masteredAtWd;
  final Value<DateTime?> masteredAtDw;
  final Value<Direction?> lastDirection;
  final Value<DateTime?> learnedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PacksCompanion({
    this.id = const Value.absent(),
    this.wordlistId = const Value.absent(),
    this.number = const Value.absent(),
    this.masteryWd = const Value.absent(),
    this.masteryDw = const Value.absent(),
    this.passesWd = const Value.absent(),
    this.passesDw = const Value.absent(),
    this.cleanPassesWd = const Value.absent(),
    this.cleanPassesDw = const Value.absent(),
    this.lastPassAtWd = const Value.absent(),
    this.lastPassAtDw = const Value.absent(),
    this.masteredAtWd = const Value.absent(),
    this.masteredAtDw = const Value.absent(),
    this.lastDirection = const Value.absent(),
    this.learnedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PacksCompanion.insert({
    required String id,
    required String wordlistId,
    required int number,
    required Mastery masteryWd,
    required Mastery masteryDw,
    this.passesWd = const Value.absent(),
    this.passesDw = const Value.absent(),
    this.cleanPassesWd = const Value.absent(),
    this.cleanPassesDw = const Value.absent(),
    this.lastPassAtWd = const Value.absent(),
    this.lastPassAtDw = const Value.absent(),
    this.masteredAtWd = const Value.absent(),
    this.masteredAtDw = const Value.absent(),
    this.lastDirection = const Value.absent(),
    this.learnedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       wordlistId = Value(wordlistId),
       number = Value(number),
       masteryWd = Value(masteryWd),
       masteryDw = Value(masteryDw),
       createdAt = Value(createdAt);
  static Insertable<Pack> custom({
    Expression<String>? id,
    Expression<String>? wordlistId,
    Expression<int>? number,
    Expression<String>? masteryWd,
    Expression<String>? masteryDw,
    Expression<int>? passesWd,
    Expression<int>? passesDw,
    Expression<int>? cleanPassesWd,
    Expression<int>? cleanPassesDw,
    Expression<DateTime>? lastPassAtWd,
    Expression<DateTime>? lastPassAtDw,
    Expression<DateTime>? masteredAtWd,
    Expression<DateTime>? masteredAtDw,
    Expression<String>? lastDirection,
    Expression<DateTime>? learnedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordlistId != null) 'wordlist_id': wordlistId,
      if (number != null) 'number': number,
      if (masteryWd != null) 'mastery_wd': masteryWd,
      if (masteryDw != null) 'mastery_dw': masteryDw,
      if (passesWd != null) 'passes_wd': passesWd,
      if (passesDw != null) 'passes_dw': passesDw,
      if (cleanPassesWd != null) 'clean_passes_wd': cleanPassesWd,
      if (cleanPassesDw != null) 'clean_passes_dw': cleanPassesDw,
      if (lastPassAtWd != null) 'last_pass_at_wd': lastPassAtWd,
      if (lastPassAtDw != null) 'last_pass_at_dw': lastPassAtDw,
      if (masteredAtWd != null) 'mastered_at_wd': masteredAtWd,
      if (masteredAtDw != null) 'mastered_at_dw': masteredAtDw,
      if (lastDirection != null) 'last_direction': lastDirection,
      if (learnedAt != null) 'learned_at': learnedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PacksCompanion copyWith({
    Value<String>? id,
    Value<String>? wordlistId,
    Value<int>? number,
    Value<Mastery>? masteryWd,
    Value<Mastery>? masteryDw,
    Value<int>? passesWd,
    Value<int>? passesDw,
    Value<int>? cleanPassesWd,
    Value<int>? cleanPassesDw,
    Value<DateTime?>? lastPassAtWd,
    Value<DateTime?>? lastPassAtDw,
    Value<DateTime?>? masteredAtWd,
    Value<DateTime?>? masteredAtDw,
    Value<Direction?>? lastDirection,
    Value<DateTime?>? learnedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PacksCompanion(
      id: id ?? this.id,
      wordlistId: wordlistId ?? this.wordlistId,
      number: number ?? this.number,
      masteryWd: masteryWd ?? this.masteryWd,
      masteryDw: masteryDw ?? this.masteryDw,
      passesWd: passesWd ?? this.passesWd,
      passesDw: passesDw ?? this.passesDw,
      cleanPassesWd: cleanPassesWd ?? this.cleanPassesWd,
      cleanPassesDw: cleanPassesDw ?? this.cleanPassesDw,
      lastPassAtWd: lastPassAtWd ?? this.lastPassAtWd,
      lastPassAtDw: lastPassAtDw ?? this.lastPassAtDw,
      masteredAtWd: masteredAtWd ?? this.masteredAtWd,
      masteredAtDw: masteredAtDw ?? this.masteredAtDw,
      lastDirection: lastDirection ?? this.lastDirection,
      learnedAt: learnedAt ?? this.learnedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (wordlistId.present) {
      map['wordlist_id'] = Variable<String>(wordlistId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (masteryWd.present) {
      map['mastery_wd'] = Variable<String>(
        $PacksTable.$convertermasteryWd.toSql(masteryWd.value),
      );
    }
    if (masteryDw.present) {
      map['mastery_dw'] = Variable<String>(
        $PacksTable.$convertermasteryDw.toSql(masteryDw.value),
      );
    }
    if (passesWd.present) {
      map['passes_wd'] = Variable<int>(passesWd.value);
    }
    if (passesDw.present) {
      map['passes_dw'] = Variable<int>(passesDw.value);
    }
    if (cleanPassesWd.present) {
      map['clean_passes_wd'] = Variable<int>(cleanPassesWd.value);
    }
    if (cleanPassesDw.present) {
      map['clean_passes_dw'] = Variable<int>(cleanPassesDw.value);
    }
    if (lastPassAtWd.present) {
      map['last_pass_at_wd'] = Variable<DateTime>(lastPassAtWd.value);
    }
    if (lastPassAtDw.present) {
      map['last_pass_at_dw'] = Variable<DateTime>(lastPassAtDw.value);
    }
    if (masteredAtWd.present) {
      map['mastered_at_wd'] = Variable<DateTime>(masteredAtWd.value);
    }
    if (masteredAtDw.present) {
      map['mastered_at_dw'] = Variable<DateTime>(masteredAtDw.value);
    }
    if (lastDirection.present) {
      map['last_direction'] = Variable<String>(
        $PacksTable.$converterlastDirectionn.toSql(lastDirection.value),
      );
    }
    if (learnedAt.present) {
      map['learned_at'] = Variable<DateTime>(learnedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PacksCompanion(')
          ..write('id: $id, ')
          ..write('wordlistId: $wordlistId, ')
          ..write('number: $number, ')
          ..write('masteryWd: $masteryWd, ')
          ..write('masteryDw: $masteryDw, ')
          ..write('passesWd: $passesWd, ')
          ..write('passesDw: $passesDw, ')
          ..write('cleanPassesWd: $cleanPassesWd, ')
          ..write('cleanPassesDw: $cleanPassesDw, ')
          ..write('lastPassAtWd: $lastPassAtWd, ')
          ..write('lastPassAtDw: $lastPassAtDw, ')
          ..write('masteredAtWd: $masteredAtWd, ')
          ..write('masteredAtDw: $masteredAtDw, ')
          ..write('lastDirection: $lastDirection, ')
          ..write('learnedAt: $learnedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, key, parentId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;

  /// Display spelling (first entered).
  final String name;

  /// Trimmed, spaces collapsed, lower-cased.
  final String key;
  final String? parentId;
  final DateTime createdAt;
  const Category({
    required this.id,
    required this.name,
    required this.key,
    this.parentId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      key: Value(key),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      key: serializer.fromJson<String>(json['key']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'key': serializer.toJson<String>(key),
      'parentId': serializer.toJson<String?>(parentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? key,
    Value<String?> parentId = const Value.absent(),
    DateTime? createdAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    key: key ?? this.key,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      key: data.key.present ? data.key.value : this.key,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('key: $key, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, key, parentId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.key == this.key &&
          other.parentId == this.parentId &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> key;
  final Value<String?> parentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.key = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String key,
    this.parentId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       key = Value(key),
       createdAt = Value(createdAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? key,
    Expression<String>? parentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (key != null) 'key': key,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? key,
    Value<String?>? parentId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('key: $key, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordlistIdMeta = const VerificationMeta(
    'wordlistId',
  );
  @override
  late final GeneratedColumn<String> wordlistId = GeneratedColumn<String>(
    'wordlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wordlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posMeta = const VerificationMeta('pos');
  @override
  late final GeneratedColumn<String> pos = GeneratedColumn<String>(
    'pos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posRawMeta = const VerificationMeta('posRaw');
  @override
  late final GeneratedColumn<String> posRaw = GeneratedColumn<String>(
    'pos_raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES packs (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Tone?, String> tone =
      GeneratedColumn<String>(
        'tone',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Tone?>($WordsTable.$convertertonen);
  static const VerificationMeta _counterIntuitiveMeta = const VerificationMeta(
    'counterIntuitive',
  );
  @override
  late final GeneratedColumn<bool> counterIntuitive = GeneratedColumn<bool>(
    'counter_intuitive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("counter_intuitive" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _multipleMeaningsMeta = const VerificationMeta(
    'multipleMeanings',
  );
  @override
  late final GeneratedColumn<bool> multipleMeanings = GeneratedColumn<bool>(
    'multiple_meanings',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("multiple_meanings" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _subcategoryIdMeta = const VerificationMeta(
    'subcategoryId',
  );
  @override
  late final GeneratedColumn<String> subcategoryId = GeneratedColumn<String>(
    'subcategory_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _masteredWdMeta = const VerificationMeta(
    'masteredWd',
  );
  @override
  late final GeneratedColumn<bool> masteredWd = GeneratedColumn<bool>(
    'mastered_wd',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mastered_wd" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _masteredDwMeta = const VerificationMeta(
    'masteredDw',
  );
  @override
  late final GeneratedColumn<bool> masteredDw = GeneratedColumn<bool>(
    'mastered_dw',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mastered_dw" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _revealCountWdMeta = const VerificationMeta(
    'revealCountWd',
  );
  @override
  late final GeneratedColumn<int> revealCountWd = GeneratedColumn<int>(
    'reveal_count_wd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revealCountDwMeta = const VerificationMeta(
    'revealCountDw',
  );
  @override
  late final GeneratedColumn<int> revealCountDw = GeneratedColumn<int>(
    'reveal_count_dw',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastRevealedAtMeta = const VerificationMeta(
    'lastRevealedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRevealedAt =
      GeneratedColumn<DateTime>(
        'last_revealed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordlistId,
    position,
    term,
    pos,
    posRaw,
    definition,
    packId,
    tone,
    counterIntuitive,
    multipleMeanings,
    categoryId,
    subcategoryId,
    masteredWd,
    masteredDw,
    revealCountWd,
    revealCountDw,
    lastSeenAt,
    lastRevealedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('wordlist_id')) {
      context.handle(
        _wordlistIdMeta,
        wordlistId.isAcceptableOrUnknown(data['wordlist_id']!, _wordlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordlistIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('pos')) {
      context.handle(
        _posMeta,
        pos.isAcceptableOrUnknown(data['pos']!, _posMeta),
      );
    }
    if (data.containsKey('pos_raw')) {
      context.handle(
        _posRawMeta,
        posRaw.isAcceptableOrUnknown(data['pos_raw']!, _posRawMeta),
      );
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('counter_intuitive')) {
      context.handle(
        _counterIntuitiveMeta,
        counterIntuitive.isAcceptableOrUnknown(
          data['counter_intuitive']!,
          _counterIntuitiveMeta,
        ),
      );
    }
    if (data.containsKey('multiple_meanings')) {
      context.handle(
        _multipleMeaningsMeta,
        multipleMeanings.isAcceptableOrUnknown(
          data['multiple_meanings']!,
          _multipleMeaningsMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
        _subcategoryIdMeta,
        subcategoryId.isAcceptableOrUnknown(
          data['subcategory_id']!,
          _subcategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('mastered_wd')) {
      context.handle(
        _masteredWdMeta,
        masteredWd.isAcceptableOrUnknown(data['mastered_wd']!, _masteredWdMeta),
      );
    }
    if (data.containsKey('mastered_dw')) {
      context.handle(
        _masteredDwMeta,
        masteredDw.isAcceptableOrUnknown(data['mastered_dw']!, _masteredDwMeta),
      );
    }
    if (data.containsKey('reveal_count_wd')) {
      context.handle(
        _revealCountWdMeta,
        revealCountWd.isAcceptableOrUnknown(
          data['reveal_count_wd']!,
          _revealCountWdMeta,
        ),
      );
    }
    if (data.containsKey('reveal_count_dw')) {
      context.handle(
        _revealCountDwMeta,
        revealCountDw.isAcceptableOrUnknown(
          data['reveal_count_dw']!,
          _revealCountDwMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('last_revealed_at')) {
      context.handle(
        _lastRevealedAtMeta,
        lastRevealedAt.isAcceptableOrUnknown(
          data['last_revealed_at']!,
          _lastRevealedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {wordlistId, position},
  ];
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      wordlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wordlist_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      pos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pos'],
      ),
      posRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pos_raw'],
      ),
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      tone: $WordsTable.$convertertonen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tone'],
        ),
      ),
      counterIntuitive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}counter_intuitive'],
      )!,
      multipleMeanings: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}multiple_meanings'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      subcategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory_id'],
      ),
      masteredWd: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mastered_wd'],
      )!,
      masteredDw: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mastered_dw'],
      )!,
      revealCountWd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reveal_count_wd'],
      )!,
      revealCountDw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reveal_count_dw'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      lastRevealedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_revealed_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Tone, String, String> $convertertone =
      const EnumNameConverter<Tone>(Tone.values);
  static JsonTypeConverter2<Tone?, String?, String?> $convertertonen =
      JsonTypeConverter2.asNullable($convertertone);
}

class Word extends DataClass implements Insertable<Word> {
  final String id;
  final String wordlistId;

  /// 0-based order after de-duplication.
  final int position;
  final String term;

  /// Canonical key (`noun`, `adjective`, …, `other`) or null.
  final String? pos;
  final String? posRaw;
  final String definition;
  final String packId;
  final Tone? tone;
  final bool counterIntuitive;
  final bool multipleMeanings;
  final String? categoryId;
  final String? subcategoryId;
  final bool masteredWd;
  final bool masteredDw;
  final int revealCountWd;
  final int revealCountDw;
  final DateTime? lastSeenAt;
  final DateTime? lastRevealedAt;
  final DateTime updatedAt;
  const Word({
    required this.id,
    required this.wordlistId,
    required this.position,
    required this.term,
    this.pos,
    this.posRaw,
    required this.definition,
    required this.packId,
    this.tone,
    required this.counterIntuitive,
    required this.multipleMeanings,
    this.categoryId,
    this.subcategoryId,
    required this.masteredWd,
    required this.masteredDw,
    required this.revealCountWd,
    required this.revealCountDw,
    this.lastSeenAt,
    this.lastRevealedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['wordlist_id'] = Variable<String>(wordlistId);
    map['position'] = Variable<int>(position);
    map['term'] = Variable<String>(term);
    if (!nullToAbsent || pos != null) {
      map['pos'] = Variable<String>(pos);
    }
    if (!nullToAbsent || posRaw != null) {
      map['pos_raw'] = Variable<String>(posRaw);
    }
    map['definition'] = Variable<String>(definition);
    map['pack_id'] = Variable<String>(packId);
    if (!nullToAbsent || tone != null) {
      map['tone'] = Variable<String>($WordsTable.$convertertonen.toSql(tone));
    }
    map['counter_intuitive'] = Variable<bool>(counterIntuitive);
    map['multiple_meanings'] = Variable<bool>(multipleMeanings);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<String>(subcategoryId);
    }
    map['mastered_wd'] = Variable<bool>(masteredWd);
    map['mastered_dw'] = Variable<bool>(masteredDw);
    map['reveal_count_wd'] = Variable<int>(revealCountWd);
    map['reveal_count_dw'] = Variable<int>(revealCountDw);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    if (!nullToAbsent || lastRevealedAt != null) {
      map['last_revealed_at'] = Variable<DateTime>(lastRevealedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      wordlistId: Value(wordlistId),
      position: Value(position),
      term: Value(term),
      pos: pos == null && nullToAbsent ? const Value.absent() : Value(pos),
      posRaw: posRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(posRaw),
      definition: Value(definition),
      packId: Value(packId),
      tone: tone == null && nullToAbsent ? const Value.absent() : Value(tone),
      counterIntuitive: Value(counterIntuitive),
      multipleMeanings: Value(multipleMeanings),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      masteredWd: Value(masteredWd),
      masteredDw: Value(masteredDw),
      revealCountWd: Value(revealCountWd),
      revealCountDw: Value(revealCountDw),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      lastRevealedAt: lastRevealedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRevealedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<String>(json['id']),
      wordlistId: serializer.fromJson<String>(json['wordlistId']),
      position: serializer.fromJson<int>(json['position']),
      term: serializer.fromJson<String>(json['term']),
      pos: serializer.fromJson<String?>(json['pos']),
      posRaw: serializer.fromJson<String?>(json['posRaw']),
      definition: serializer.fromJson<String>(json['definition']),
      packId: serializer.fromJson<String>(json['packId']),
      tone: $WordsTable.$convertertonen.fromJson(
        serializer.fromJson<String?>(json['tone']),
      ),
      counterIntuitive: serializer.fromJson<bool>(json['counterIntuitive']),
      multipleMeanings: serializer.fromJson<bool>(json['multipleMeanings']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      subcategoryId: serializer.fromJson<String?>(json['subcategoryId']),
      masteredWd: serializer.fromJson<bool>(json['masteredWd']),
      masteredDw: serializer.fromJson<bool>(json['masteredDw']),
      revealCountWd: serializer.fromJson<int>(json['revealCountWd']),
      revealCountDw: serializer.fromJson<int>(json['revealCountDw']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      lastRevealedAt: serializer.fromJson<DateTime?>(json['lastRevealedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'wordlistId': serializer.toJson<String>(wordlistId),
      'position': serializer.toJson<int>(position),
      'term': serializer.toJson<String>(term),
      'pos': serializer.toJson<String?>(pos),
      'posRaw': serializer.toJson<String?>(posRaw),
      'definition': serializer.toJson<String>(definition),
      'packId': serializer.toJson<String>(packId),
      'tone': serializer.toJson<String?>(
        $WordsTable.$convertertonen.toJson(tone),
      ),
      'counterIntuitive': serializer.toJson<bool>(counterIntuitive),
      'multipleMeanings': serializer.toJson<bool>(multipleMeanings),
      'categoryId': serializer.toJson<String?>(categoryId),
      'subcategoryId': serializer.toJson<String?>(subcategoryId),
      'masteredWd': serializer.toJson<bool>(masteredWd),
      'masteredDw': serializer.toJson<bool>(masteredDw),
      'revealCountWd': serializer.toJson<int>(revealCountWd),
      'revealCountDw': serializer.toJson<int>(revealCountDw),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'lastRevealedAt': serializer.toJson<DateTime?>(lastRevealedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Word copyWith({
    String? id,
    String? wordlistId,
    int? position,
    String? term,
    Value<String?> pos = const Value.absent(),
    Value<String?> posRaw = const Value.absent(),
    String? definition,
    String? packId,
    Value<Tone?> tone = const Value.absent(),
    bool? counterIntuitive,
    bool? multipleMeanings,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> subcategoryId = const Value.absent(),
    bool? masteredWd,
    bool? masteredDw,
    int? revealCountWd,
    int? revealCountDw,
    Value<DateTime?> lastSeenAt = const Value.absent(),
    Value<DateTime?> lastRevealedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => Word(
    id: id ?? this.id,
    wordlistId: wordlistId ?? this.wordlistId,
    position: position ?? this.position,
    term: term ?? this.term,
    pos: pos.present ? pos.value : this.pos,
    posRaw: posRaw.present ? posRaw.value : this.posRaw,
    definition: definition ?? this.definition,
    packId: packId ?? this.packId,
    tone: tone.present ? tone.value : this.tone,
    counterIntuitive: counterIntuitive ?? this.counterIntuitive,
    multipleMeanings: multipleMeanings ?? this.multipleMeanings,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    subcategoryId: subcategoryId.present
        ? subcategoryId.value
        : this.subcategoryId,
    masteredWd: masteredWd ?? this.masteredWd,
    masteredDw: masteredDw ?? this.masteredDw,
    revealCountWd: revealCountWd ?? this.revealCountWd,
    revealCountDw: revealCountDw ?? this.revealCountDw,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    lastRevealedAt: lastRevealedAt.present
        ? lastRevealedAt.value
        : this.lastRevealedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      wordlistId: data.wordlistId.present
          ? data.wordlistId.value
          : this.wordlistId,
      position: data.position.present ? data.position.value : this.position,
      term: data.term.present ? data.term.value : this.term,
      pos: data.pos.present ? data.pos.value : this.pos,
      posRaw: data.posRaw.present ? data.posRaw.value : this.posRaw,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      packId: data.packId.present ? data.packId.value : this.packId,
      tone: data.tone.present ? data.tone.value : this.tone,
      counterIntuitive: data.counterIntuitive.present
          ? data.counterIntuitive.value
          : this.counterIntuitive,
      multipleMeanings: data.multipleMeanings.present
          ? data.multipleMeanings.value
          : this.multipleMeanings,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      masteredWd: data.masteredWd.present
          ? data.masteredWd.value
          : this.masteredWd,
      masteredDw: data.masteredDw.present
          ? data.masteredDw.value
          : this.masteredDw,
      revealCountWd: data.revealCountWd.present
          ? data.revealCountWd.value
          : this.revealCountWd,
      revealCountDw: data.revealCountDw.present
          ? data.revealCountDw.value
          : this.revealCountDw,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      lastRevealedAt: data.lastRevealedAt.present
          ? data.lastRevealedAt.value
          : this.lastRevealedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('wordlistId: $wordlistId, ')
          ..write('position: $position, ')
          ..write('term: $term, ')
          ..write('pos: $pos, ')
          ..write('posRaw: $posRaw, ')
          ..write('definition: $definition, ')
          ..write('packId: $packId, ')
          ..write('tone: $tone, ')
          ..write('counterIntuitive: $counterIntuitive, ')
          ..write('multipleMeanings: $multipleMeanings, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('masteredWd: $masteredWd, ')
          ..write('masteredDw: $masteredDw, ')
          ..write('revealCountWd: $revealCountWd, ')
          ..write('revealCountDw: $revealCountDw, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastRevealedAt: $lastRevealedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wordlistId,
    position,
    term,
    pos,
    posRaw,
    definition,
    packId,
    tone,
    counterIntuitive,
    multipleMeanings,
    categoryId,
    subcategoryId,
    masteredWd,
    masteredDw,
    revealCountWd,
    revealCountDw,
    lastSeenAt,
    lastRevealedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.wordlistId == this.wordlistId &&
          other.position == this.position &&
          other.term == this.term &&
          other.pos == this.pos &&
          other.posRaw == this.posRaw &&
          other.definition == this.definition &&
          other.packId == this.packId &&
          other.tone == this.tone &&
          other.counterIntuitive == this.counterIntuitive &&
          other.multipleMeanings == this.multipleMeanings &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.masteredWd == this.masteredWd &&
          other.masteredDw == this.masteredDw &&
          other.revealCountWd == this.revealCountWd &&
          other.revealCountDw == this.revealCountDw &&
          other.lastSeenAt == this.lastSeenAt &&
          other.lastRevealedAt == this.lastRevealedAt &&
          other.updatedAt == this.updatedAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<String> id;
  final Value<String> wordlistId;
  final Value<int> position;
  final Value<String> term;
  final Value<String?> pos;
  final Value<String?> posRaw;
  final Value<String> definition;
  final Value<String> packId;
  final Value<Tone?> tone;
  final Value<bool> counterIntuitive;
  final Value<bool> multipleMeanings;
  final Value<String?> categoryId;
  final Value<String?> subcategoryId;
  final Value<bool> masteredWd;
  final Value<bool> masteredDw;
  final Value<int> revealCountWd;
  final Value<int> revealCountDw;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime?> lastRevealedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.wordlistId = const Value.absent(),
    this.position = const Value.absent(),
    this.term = const Value.absent(),
    this.pos = const Value.absent(),
    this.posRaw = const Value.absent(),
    this.definition = const Value.absent(),
    this.packId = const Value.absent(),
    this.tone = const Value.absent(),
    this.counterIntuitive = const Value.absent(),
    this.multipleMeanings = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.masteredWd = const Value.absent(),
    this.masteredDw = const Value.absent(),
    this.revealCountWd = const Value.absent(),
    this.revealCountDw = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastRevealedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordsCompanion.insert({
    required String id,
    required String wordlistId,
    required int position,
    required String term,
    this.pos = const Value.absent(),
    this.posRaw = const Value.absent(),
    required String definition,
    required String packId,
    this.tone = const Value.absent(),
    this.counterIntuitive = const Value.absent(),
    this.multipleMeanings = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.masteredWd = const Value.absent(),
    this.masteredDw = const Value.absent(),
    this.revealCountWd = const Value.absent(),
    this.revealCountDw = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastRevealedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       wordlistId = Value(wordlistId),
       position = Value(position),
       term = Value(term),
       definition = Value(definition),
       packId = Value(packId),
       updatedAt = Value(updatedAt);
  static Insertable<Word> custom({
    Expression<String>? id,
    Expression<String>? wordlistId,
    Expression<int>? position,
    Expression<String>? term,
    Expression<String>? pos,
    Expression<String>? posRaw,
    Expression<String>? definition,
    Expression<String>? packId,
    Expression<String>? tone,
    Expression<bool>? counterIntuitive,
    Expression<bool>? multipleMeanings,
    Expression<String>? categoryId,
    Expression<String>? subcategoryId,
    Expression<bool>? masteredWd,
    Expression<bool>? masteredDw,
    Expression<int>? revealCountWd,
    Expression<int>? revealCountDw,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? lastRevealedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordlistId != null) 'wordlist_id': wordlistId,
      if (position != null) 'position': position,
      if (term != null) 'term': term,
      if (pos != null) 'pos': pos,
      if (posRaw != null) 'pos_raw': posRaw,
      if (definition != null) 'definition': definition,
      if (packId != null) 'pack_id': packId,
      if (tone != null) 'tone': tone,
      if (counterIntuitive != null) 'counter_intuitive': counterIntuitive,
      if (multipleMeanings != null) 'multiple_meanings': multipleMeanings,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (masteredWd != null) 'mastered_wd': masteredWd,
      if (masteredDw != null) 'mastered_dw': masteredDw,
      if (revealCountWd != null) 'reveal_count_wd': revealCountWd,
      if (revealCountDw != null) 'reveal_count_dw': revealCountDw,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (lastRevealedAt != null) 'last_revealed_at': lastRevealedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordsCompanion copyWith({
    Value<String>? id,
    Value<String>? wordlistId,
    Value<int>? position,
    Value<String>? term,
    Value<String?>? pos,
    Value<String?>? posRaw,
    Value<String>? definition,
    Value<String>? packId,
    Value<Tone?>? tone,
    Value<bool>? counterIntuitive,
    Value<bool>? multipleMeanings,
    Value<String?>? categoryId,
    Value<String?>? subcategoryId,
    Value<bool>? masteredWd,
    Value<bool>? masteredDw,
    Value<int>? revealCountWd,
    Value<int>? revealCountDw,
    Value<DateTime?>? lastSeenAt,
    Value<DateTime?>? lastRevealedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      wordlistId: wordlistId ?? this.wordlistId,
      position: position ?? this.position,
      term: term ?? this.term,
      pos: pos ?? this.pos,
      posRaw: posRaw ?? this.posRaw,
      definition: definition ?? this.definition,
      packId: packId ?? this.packId,
      tone: tone ?? this.tone,
      counterIntuitive: counterIntuitive ?? this.counterIntuitive,
      multipleMeanings: multipleMeanings ?? this.multipleMeanings,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      masteredWd: masteredWd ?? this.masteredWd,
      masteredDw: masteredDw ?? this.masteredDw,
      revealCountWd: revealCountWd ?? this.revealCountWd,
      revealCountDw: revealCountDw ?? this.revealCountDw,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastRevealedAt: lastRevealedAt ?? this.lastRevealedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (wordlistId.present) {
      map['wordlist_id'] = Variable<String>(wordlistId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (pos.present) {
      map['pos'] = Variable<String>(pos.value);
    }
    if (posRaw.present) {
      map['pos_raw'] = Variable<String>(posRaw.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(
        $WordsTable.$convertertonen.toSql(tone.value),
      );
    }
    if (counterIntuitive.present) {
      map['counter_intuitive'] = Variable<bool>(counterIntuitive.value);
    }
    if (multipleMeanings.present) {
      map['multiple_meanings'] = Variable<bool>(multipleMeanings.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<String>(subcategoryId.value);
    }
    if (masteredWd.present) {
      map['mastered_wd'] = Variable<bool>(masteredWd.value);
    }
    if (masteredDw.present) {
      map['mastered_dw'] = Variable<bool>(masteredDw.value);
    }
    if (revealCountWd.present) {
      map['reveal_count_wd'] = Variable<int>(revealCountWd.value);
    }
    if (revealCountDw.present) {
      map['reveal_count_dw'] = Variable<int>(revealCountDw.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (lastRevealedAt.present) {
      map['last_revealed_at'] = Variable<DateTime>(lastRevealedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('wordlistId: $wordlistId, ')
          ..write('position: $position, ')
          ..write('term: $term, ')
          ..write('pos: $pos, ')
          ..write('posRaw: $posRaw, ')
          ..write('definition: $definition, ')
          ..write('packId: $packId, ')
          ..write('tone: $tone, ')
          ..write('counterIntuitive: $counterIntuitive, ')
          ..write('multipleMeanings: $multipleMeanings, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('masteredWd: $masteredWd, ')
          ..write('masteredDw: $masteredDw, ')
          ..write('revealCountWd: $revealCountWd, ')
          ..write('revealCountDw: $revealCountDw, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastRevealedAt: $lastRevealedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PassSessionsTable extends PassSessions
    with TableInfo<$PassSessionsTable, PassSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PassSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES packs (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Direction, String> direction =
      GeneratedColumn<String>(
        'direction',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Direction>($PassSessionsTable.$converterdirection);
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> revealed =
      GeneratedColumn<String>(
        'revealed',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($PassSessionsTable.$converterrevealed);
  static const VerificationMeta _currentRevealedMeta = const VerificationMeta(
    'currentRevealed',
  );
  @override
  late final GeneratedColumn<bool> currentRevealed = GeneratedColumn<bool>(
    'current_revealed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("current_revealed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _passNumberMeta = const VerificationMeta(
    'passNumber',
  );
  @override
  late final GeneratedColumn<int> passNumber = GeneratedColumn<int>(
    'pass_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packId,
    direction,
    idx,
    revealed,
    currentRevealed,
    passNumber,
    startedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pass_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PassSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('current_revealed')) {
      context.handle(
        _currentRevealedMeta,
        currentRevealed.isAcceptableOrUnknown(
          data['current_revealed']!,
          _currentRevealedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentRevealedMeta);
    }
    if (data.containsKey('pass_number')) {
      context.handle(
        _passNumberMeta,
        passNumber.isAcceptableOrUnknown(data['pass_number']!, _passNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_passNumberMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {packId, direction},
  ];
  @override
  PassSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PassSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      direction: $PassSessionsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
      revealed: $PassSessionsTable.$converterrevealed.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}revealed'],
        )!,
      ),
      currentRevealed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}current_revealed'],
      )!,
      passNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pass_number'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PassSessionsTable createAlias(String alias) {
    return $PassSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Direction, String, String> $converterdirection =
      const EnumNameConverter<Direction>(Direction.values);
  static TypeConverter<List<String>, String> $converterrevealed =
      const StringListConverter();
}

class PassSession extends DataClass implements Insertable<PassSession> {
  final String id;
  final String packId;
  final Direction direction;
  final int idx;

  /// Word ids peeked this pass.
  final List<String> revealed;
  final bool currentRevealed;
  final int passNumber;
  final DateTime startedAt;
  final DateTime updatedAt;
  const PassSession({
    required this.id,
    required this.packId,
    required this.direction,
    required this.idx,
    required this.revealed,
    required this.currentRevealed,
    required this.passNumber,
    required this.startedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pack_id'] = Variable<String>(packId);
    {
      map['direction'] = Variable<String>(
        $PassSessionsTable.$converterdirection.toSql(direction),
      );
    }
    map['idx'] = Variable<int>(idx);
    {
      map['revealed'] = Variable<String>(
        $PassSessionsTable.$converterrevealed.toSql(revealed),
      );
    }
    map['current_revealed'] = Variable<bool>(currentRevealed);
    map['pass_number'] = Variable<int>(passNumber);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PassSessionsCompanion toCompanion(bool nullToAbsent) {
    return PassSessionsCompanion(
      id: Value(id),
      packId: Value(packId),
      direction: Value(direction),
      idx: Value(idx),
      revealed: Value(revealed),
      currentRevealed: Value(currentRevealed),
      passNumber: Value(passNumber),
      startedAt: Value(startedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PassSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PassSession(
      id: serializer.fromJson<String>(json['id']),
      packId: serializer.fromJson<String>(json['packId']),
      direction: $PassSessionsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      idx: serializer.fromJson<int>(json['idx']),
      revealed: serializer.fromJson<List<String>>(json['revealed']),
      currentRevealed: serializer.fromJson<bool>(json['currentRevealed']),
      passNumber: serializer.fromJson<int>(json['passNumber']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'packId': serializer.toJson<String>(packId),
      'direction': serializer.toJson<String>(
        $PassSessionsTable.$converterdirection.toJson(direction),
      ),
      'idx': serializer.toJson<int>(idx),
      'revealed': serializer.toJson<List<String>>(revealed),
      'currentRevealed': serializer.toJson<bool>(currentRevealed),
      'passNumber': serializer.toJson<int>(passNumber),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PassSession copyWith({
    String? id,
    String? packId,
    Direction? direction,
    int? idx,
    List<String>? revealed,
    bool? currentRevealed,
    int? passNumber,
    DateTime? startedAt,
    DateTime? updatedAt,
  }) => PassSession(
    id: id ?? this.id,
    packId: packId ?? this.packId,
    direction: direction ?? this.direction,
    idx: idx ?? this.idx,
    revealed: revealed ?? this.revealed,
    currentRevealed: currentRevealed ?? this.currentRevealed,
    passNumber: passNumber ?? this.passNumber,
    startedAt: startedAt ?? this.startedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PassSession copyWithCompanion(PassSessionsCompanion data) {
    return PassSession(
      id: data.id.present ? data.id.value : this.id,
      packId: data.packId.present ? data.packId.value : this.packId,
      direction: data.direction.present ? data.direction.value : this.direction,
      idx: data.idx.present ? data.idx.value : this.idx,
      revealed: data.revealed.present ? data.revealed.value : this.revealed,
      currentRevealed: data.currentRevealed.present
          ? data.currentRevealed.value
          : this.currentRevealed,
      passNumber: data.passNumber.present
          ? data.passNumber.value
          : this.passNumber,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PassSession(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('direction: $direction, ')
          ..write('idx: $idx, ')
          ..write('revealed: $revealed, ')
          ..write('currentRevealed: $currentRevealed, ')
          ..write('passNumber: $passNumber, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packId,
    direction,
    idx,
    revealed,
    currentRevealed,
    passNumber,
    startedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PassSession &&
          other.id == this.id &&
          other.packId == this.packId &&
          other.direction == this.direction &&
          other.idx == this.idx &&
          other.revealed == this.revealed &&
          other.currentRevealed == this.currentRevealed &&
          other.passNumber == this.passNumber &&
          other.startedAt == this.startedAt &&
          other.updatedAt == this.updatedAt);
}

class PassSessionsCompanion extends UpdateCompanion<PassSession> {
  final Value<String> id;
  final Value<String> packId;
  final Value<Direction> direction;
  final Value<int> idx;
  final Value<List<String>> revealed;
  final Value<bool> currentRevealed;
  final Value<int> passNumber;
  final Value<DateTime> startedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PassSessionsCompanion({
    this.id = const Value.absent(),
    this.packId = const Value.absent(),
    this.direction = const Value.absent(),
    this.idx = const Value.absent(),
    this.revealed = const Value.absent(),
    this.currentRevealed = const Value.absent(),
    this.passNumber = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PassSessionsCompanion.insert({
    required String id,
    required String packId,
    required Direction direction,
    required int idx,
    required List<String> revealed,
    required bool currentRevealed,
    required int passNumber,
    required DateTime startedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       packId = Value(packId),
       direction = Value(direction),
       idx = Value(idx),
       revealed = Value(revealed),
       currentRevealed = Value(currentRevealed),
       passNumber = Value(passNumber),
       startedAt = Value(startedAt),
       updatedAt = Value(updatedAt);
  static Insertable<PassSession> custom({
    Expression<String>? id,
    Expression<String>? packId,
    Expression<String>? direction,
    Expression<int>? idx,
    Expression<String>? revealed,
    Expression<bool>? currentRevealed,
    Expression<int>? passNumber,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packId != null) 'pack_id': packId,
      if (direction != null) 'direction': direction,
      if (idx != null) 'idx': idx,
      if (revealed != null) 'revealed': revealed,
      if (currentRevealed != null) 'current_revealed': currentRevealed,
      if (passNumber != null) 'pass_number': passNumber,
      if (startedAt != null) 'started_at': startedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PassSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? packId,
    Value<Direction>? direction,
    Value<int>? idx,
    Value<List<String>>? revealed,
    Value<bool>? currentRevealed,
    Value<int>? passNumber,
    Value<DateTime>? startedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PassSessionsCompanion(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      direction: direction ?? this.direction,
      idx: idx ?? this.idx,
      revealed: revealed ?? this.revealed,
      currentRevealed: currentRevealed ?? this.currentRevealed,
      passNumber: passNumber ?? this.passNumber,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $PassSessionsTable.$converterdirection.toSql(direction.value),
      );
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (revealed.present) {
      map['revealed'] = Variable<String>(
        $PassSessionsTable.$converterrevealed.toSql(revealed.value),
      );
    }
    if (currentRevealed.present) {
      map['current_revealed'] = Variable<bool>(currentRevealed.value);
    }
    if (passNumber.present) {
      map['pass_number'] = Variable<int>(passNumber.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PassSessionsCompanion(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('direction: $direction, ')
          ..write('idx: $idx, ')
          ..write('revealed: $revealed, ')
          ..write('currentRevealed: $currentRevealed, ')
          ..write('passNumber: $passNumber, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packSizeMeta = const VerificationMeta(
    'packSize',
  );
  @override
  late final GeneratedColumn<int> packSize = GeneratedColumn<int>(
    'pack_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Direction, String>
  defaultDirection = GeneratedColumn<String>(
    'default_direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Direction>($AppSettingsTable.$converterdefaultDirection);
  @override
  late final GeneratedColumnWithTypeConverter<LearnedRule, String> learnedRule =
      GeneratedColumn<String>(
        'learned_rule',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LearnedRule>($AppSettingsTable.$converterlearnedRule);
  static const VerificationMeta _showPosMeta = const VerificationMeta(
    'showPos',
  );
  @override
  late final GeneratedColumn<bool> showPos = GeneratedColumn<bool>(
    'show_pos',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_pos" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _demoteOnRevealMeta = const VerificationMeta(
    'demoteOnReveal',
  );
  @override
  late final GeneratedColumn<bool> demoteOnReveal = GeneratedColumn<bool>(
    'demote_on_reveal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("demote_on_reveal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _studyButtonsMeta = const VerificationMeta(
    'studyButtons',
  );
  @override
  late final GeneratedColumn<bool> studyButtons = GeneratedColumn<bool>(
    'study_buttons',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("study_buttons" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packSize,
    defaultDirection,
    learnedRule,
    showPos,
    demoteOnReveal,
    theme,
    studyButtons,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pack_size')) {
      context.handle(
        _packSizeMeta,
        packSize.isAcceptableOrUnknown(data['pack_size']!, _packSizeMeta),
      );
    }
    if (data.containsKey('show_pos')) {
      context.handle(
        _showPosMeta,
        showPos.isAcceptableOrUnknown(data['show_pos']!, _showPosMeta),
      );
    }
    if (data.containsKey('demote_on_reveal')) {
      context.handle(
        _demoteOnRevealMeta,
        demoteOnReveal.isAcceptableOrUnknown(
          data['demote_on_reveal']!,
          _demoteOnRevealMeta,
        ),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('study_buttons')) {
      context.handle(
        _studyButtonsMeta,
        studyButtons.isAcceptableOrUnknown(
          data['study_buttons']!,
          _studyButtonsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pack_size'],
      )!,
      defaultDirection: $AppSettingsTable.$converterdefaultDirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}default_direction'],
        )!,
      ),
      learnedRule: $AppSettingsTable.$converterlearnedRule.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}learned_rule'],
        )!,
      ),
      showPos: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_pos'],
      )!,
      demoteOnReveal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}demote_on_reveal'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      studyButtons: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}study_buttons'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Direction, String, String>
  $converterdefaultDirection = const EnumNameConverter<Direction>(
    Direction.values,
  );
  static JsonTypeConverter2<LearnedRule, String, String> $converterlearnedRule =
      const EnumNameConverter<LearnedRule>(LearnedRule.values);
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final int packSize;
  final Direction defaultDirection;
  final LearnedRule learnedRule;
  final bool showPos;
  final bool demoteOnReveal;

  /// `light` | `dark` | `system`.
  final String theme;

  /// Show / Next / Previous buttons under the study card; off = tap and
  /// swipe only (D-34). Schema v2.
  final bool studyButtons;
  const AppSetting({
    required this.id,
    required this.packSize,
    required this.defaultDirection,
    required this.learnedRule,
    required this.showPos,
    required this.demoteOnReveal,
    required this.theme,
    required this.studyButtons,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pack_size'] = Variable<int>(packSize);
    {
      map['default_direction'] = Variable<String>(
        $AppSettingsTable.$converterdefaultDirection.toSql(defaultDirection),
      );
    }
    {
      map['learned_rule'] = Variable<String>(
        $AppSettingsTable.$converterlearnedRule.toSql(learnedRule),
      );
    }
    map['show_pos'] = Variable<bool>(showPos);
    map['demote_on_reveal'] = Variable<bool>(demoteOnReveal);
    map['theme'] = Variable<String>(theme);
    map['study_buttons'] = Variable<bool>(studyButtons);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      packSize: Value(packSize),
      defaultDirection: Value(defaultDirection),
      learnedRule: Value(learnedRule),
      showPos: Value(showPos),
      demoteOnReveal: Value(demoteOnReveal),
      theme: Value(theme),
      studyButtons: Value(studyButtons),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      packSize: serializer.fromJson<int>(json['packSize']),
      defaultDirection: $AppSettingsTable.$converterdefaultDirection.fromJson(
        serializer.fromJson<String>(json['defaultDirection']),
      ),
      learnedRule: $AppSettingsTable.$converterlearnedRule.fromJson(
        serializer.fromJson<String>(json['learnedRule']),
      ),
      showPos: serializer.fromJson<bool>(json['showPos']),
      demoteOnReveal: serializer.fromJson<bool>(json['demoteOnReveal']),
      theme: serializer.fromJson<String>(json['theme']),
      studyButtons: serializer.fromJson<bool>(json['studyButtons']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packSize': serializer.toJson<int>(packSize),
      'defaultDirection': serializer.toJson<String>(
        $AppSettingsTable.$converterdefaultDirection.toJson(defaultDirection),
      ),
      'learnedRule': serializer.toJson<String>(
        $AppSettingsTable.$converterlearnedRule.toJson(learnedRule),
      ),
      'showPos': serializer.toJson<bool>(showPos),
      'demoteOnReveal': serializer.toJson<bool>(demoteOnReveal),
      'theme': serializer.toJson<String>(theme),
      'studyButtons': serializer.toJson<bool>(studyButtons),
    };
  }

  AppSetting copyWith({
    int? id,
    int? packSize,
    Direction? defaultDirection,
    LearnedRule? learnedRule,
    bool? showPos,
    bool? demoteOnReveal,
    String? theme,
    bool? studyButtons,
  }) => AppSetting(
    id: id ?? this.id,
    packSize: packSize ?? this.packSize,
    defaultDirection: defaultDirection ?? this.defaultDirection,
    learnedRule: learnedRule ?? this.learnedRule,
    showPos: showPos ?? this.showPos,
    demoteOnReveal: demoteOnReveal ?? this.demoteOnReveal,
    theme: theme ?? this.theme,
    studyButtons: studyButtons ?? this.studyButtons,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      packSize: data.packSize.present ? data.packSize.value : this.packSize,
      defaultDirection: data.defaultDirection.present
          ? data.defaultDirection.value
          : this.defaultDirection,
      learnedRule: data.learnedRule.present
          ? data.learnedRule.value
          : this.learnedRule,
      showPos: data.showPos.present ? data.showPos.value : this.showPos,
      demoteOnReveal: data.demoteOnReveal.present
          ? data.demoteOnReveal.value
          : this.demoteOnReveal,
      theme: data.theme.present ? data.theme.value : this.theme,
      studyButtons: data.studyButtons.present
          ? data.studyButtons.value
          : this.studyButtons,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('packSize: $packSize, ')
          ..write('defaultDirection: $defaultDirection, ')
          ..write('learnedRule: $learnedRule, ')
          ..write('showPos: $showPos, ')
          ..write('demoteOnReveal: $demoteOnReveal, ')
          ..write('theme: $theme, ')
          ..write('studyButtons: $studyButtons')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packSize,
    defaultDirection,
    learnedRule,
    showPos,
    demoteOnReveal,
    theme,
    studyButtons,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.packSize == this.packSize &&
          other.defaultDirection == this.defaultDirection &&
          other.learnedRule == this.learnedRule &&
          other.showPos == this.showPos &&
          other.demoteOnReveal == this.demoteOnReveal &&
          other.theme == this.theme &&
          other.studyButtons == this.studyButtons);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<int> packSize;
  final Value<Direction> defaultDirection;
  final Value<LearnedRule> learnedRule;
  final Value<bool> showPos;
  final Value<bool> demoteOnReveal;
  final Value<String> theme;
  final Value<bool> studyButtons;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.packSize = const Value.absent(),
    this.defaultDirection = const Value.absent(),
    this.learnedRule = const Value.absent(),
    this.showPos = const Value.absent(),
    this.demoteOnReveal = const Value.absent(),
    this.theme = const Value.absent(),
    this.studyButtons = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.packSize = const Value.absent(),
    required Direction defaultDirection,
    required LearnedRule learnedRule,
    this.showPos = const Value.absent(),
    this.demoteOnReveal = const Value.absent(),
    this.theme = const Value.absent(),
    this.studyButtons = const Value.absent(),
  }) : defaultDirection = Value(defaultDirection),
       learnedRule = Value(learnedRule);
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<int>? packSize,
    Expression<String>? defaultDirection,
    Expression<String>? learnedRule,
    Expression<bool>? showPos,
    Expression<bool>? demoteOnReveal,
    Expression<String>? theme,
    Expression<bool>? studyButtons,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packSize != null) 'pack_size': packSize,
      if (defaultDirection != null) 'default_direction': defaultDirection,
      if (learnedRule != null) 'learned_rule': learnedRule,
      if (showPos != null) 'show_pos': showPos,
      if (demoteOnReveal != null) 'demote_on_reveal': demoteOnReveal,
      if (theme != null) 'theme': theme,
      if (studyButtons != null) 'study_buttons': studyButtons,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? packSize,
    Value<Direction>? defaultDirection,
    Value<LearnedRule>? learnedRule,
    Value<bool>? showPos,
    Value<bool>? demoteOnReveal,
    Value<String>? theme,
    Value<bool>? studyButtons,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      packSize: packSize ?? this.packSize,
      defaultDirection: defaultDirection ?? this.defaultDirection,
      learnedRule: learnedRule ?? this.learnedRule,
      showPos: showPos ?? this.showPos,
      demoteOnReveal: demoteOnReveal ?? this.demoteOnReveal,
      theme: theme ?? this.theme,
      studyButtons: studyButtons ?? this.studyButtons,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packSize.present) {
      map['pack_size'] = Variable<int>(packSize.value);
    }
    if (defaultDirection.present) {
      map['default_direction'] = Variable<String>(
        $AppSettingsTable.$converterdefaultDirection.toSql(
          defaultDirection.value,
        ),
      );
    }
    if (learnedRule.present) {
      map['learned_rule'] = Variable<String>(
        $AppSettingsTable.$converterlearnedRule.toSql(learnedRule.value),
      );
    }
    if (showPos.present) {
      map['show_pos'] = Variable<bool>(showPos.value);
    }
    if (demoteOnReveal.present) {
      map['demote_on_reveal'] = Variable<bool>(demoteOnReveal.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (studyButtons.present) {
      map['study_buttons'] = Variable<bool>(studyButtons.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('packSize: $packSize, ')
          ..write('defaultDirection: $defaultDirection, ')
          ..write('learnedRule: $learnedRule, ')
          ..write('showPos: $showPos, ')
          ..write('demoteOnReveal: $demoteOnReveal, ')
          ..write('theme: $theme, ')
          ..write('studyButtons: $studyButtons')
          ..write(')'))
        .toString();
  }
}

class $UiStateTable extends UiState with TableInfo<$UiStateTable, UiStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UiStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  expandedNodeIds = GeneratedColumn<String>(
    'expanded_node_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($UiStateTable.$converterexpandedNodeIds);
  static const VerificationMeta _selectedNodeIdMeta = const VerificationMeta(
    'selectedNodeId',
  );
  @override
  late final GeneratedColumn<String> selectedNodeId = GeneratedColumn<String>(
    'selected_node_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewerModeMeta = const VerificationMeta(
    'viewerMode',
  );
  @override
  late final GeneratedColumn<String> viewerMode = GeneratedColumn<String>(
    'viewer_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('card'),
  );
  static const VerificationMeta _treePanelOpenMeta = const VerificationMeta(
    'treePanelOpen',
  );
  @override
  late final GeneratedColumn<bool> treePanelOpen = GeneratedColumn<bool>(
    'tree_panel_open',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tree_panel_open" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _gestureHintPassesMeta = const VerificationMeta(
    'gestureHintPasses',
  );
  @override
  late final GeneratedColumn<int> gestureHintPasses = GeneratedColumn<int>(
    'gesture_hint_passes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    expandedNodeIds,
    selectedNodeId,
    viewerMode,
    treePanelOpen,
    gestureHintPasses,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ui_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<UiStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('selected_node_id')) {
      context.handle(
        _selectedNodeIdMeta,
        selectedNodeId.isAcceptableOrUnknown(
          data['selected_node_id']!,
          _selectedNodeIdMeta,
        ),
      );
    }
    if (data.containsKey('viewer_mode')) {
      context.handle(
        _viewerModeMeta,
        viewerMode.isAcceptableOrUnknown(data['viewer_mode']!, _viewerModeMeta),
      );
    }
    if (data.containsKey('tree_panel_open')) {
      context.handle(
        _treePanelOpenMeta,
        treePanelOpen.isAcceptableOrUnknown(
          data['tree_panel_open']!,
          _treePanelOpenMeta,
        ),
      );
    }
    if (data.containsKey('gesture_hint_passes')) {
      context.handle(
        _gestureHintPassesMeta,
        gestureHintPasses.isAcceptableOrUnknown(
          data['gesture_hint_passes']!,
          _gestureHintPassesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UiStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UiStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      expandedNodeIds: $UiStateTable.$converterexpandedNodeIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expanded_node_ids'],
        )!,
      ),
      selectedNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_node_id'],
      ),
      viewerMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}viewer_mode'],
      )!,
      treePanelOpen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tree_panel_open'],
      )!,
      gestureHintPasses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gesture_hint_passes'],
      )!,
    );
  }

  @override
  $UiStateTable createAlias(String alias) {
    return $UiStateTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterexpandedNodeIds =
      const StringListConverter();
}

class UiStateData extends DataClass implements Insertable<UiStateData> {
  final int id;
  final List<String> expandedNodeIds;
  final String? selectedNodeId;

  /// `card` | `list`.
  final String viewerMode;
  final bool treePanelOpen;

  /// Passes finished with the study buttons off; the gesture hint shows for
  /// the first three (D-34). Schema v2.
  final int gestureHintPasses;
  const UiStateData({
    required this.id,
    required this.expandedNodeIds,
    this.selectedNodeId,
    required this.viewerMode,
    required this.treePanelOpen,
    required this.gestureHintPasses,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['expanded_node_ids'] = Variable<String>(
        $UiStateTable.$converterexpandedNodeIds.toSql(expandedNodeIds),
      );
    }
    if (!nullToAbsent || selectedNodeId != null) {
      map['selected_node_id'] = Variable<String>(selectedNodeId);
    }
    map['viewer_mode'] = Variable<String>(viewerMode);
    map['tree_panel_open'] = Variable<bool>(treePanelOpen);
    map['gesture_hint_passes'] = Variable<int>(gestureHintPasses);
    return map;
  }

  UiStateCompanion toCompanion(bool nullToAbsent) {
    return UiStateCompanion(
      id: Value(id),
      expandedNodeIds: Value(expandedNodeIds),
      selectedNodeId: selectedNodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedNodeId),
      viewerMode: Value(viewerMode),
      treePanelOpen: Value(treePanelOpen),
      gestureHintPasses: Value(gestureHintPasses),
    );
  }

  factory UiStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UiStateData(
      id: serializer.fromJson<int>(json['id']),
      expandedNodeIds: serializer.fromJson<List<String>>(
        json['expandedNodeIds'],
      ),
      selectedNodeId: serializer.fromJson<String?>(json['selectedNodeId']),
      viewerMode: serializer.fromJson<String>(json['viewerMode']),
      treePanelOpen: serializer.fromJson<bool>(json['treePanelOpen']),
      gestureHintPasses: serializer.fromJson<int>(json['gestureHintPasses']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'expandedNodeIds': serializer.toJson<List<String>>(expandedNodeIds),
      'selectedNodeId': serializer.toJson<String?>(selectedNodeId),
      'viewerMode': serializer.toJson<String>(viewerMode),
      'treePanelOpen': serializer.toJson<bool>(treePanelOpen),
      'gestureHintPasses': serializer.toJson<int>(gestureHintPasses),
    };
  }

  UiStateData copyWith({
    int? id,
    List<String>? expandedNodeIds,
    Value<String?> selectedNodeId = const Value.absent(),
    String? viewerMode,
    bool? treePanelOpen,
    int? gestureHintPasses,
  }) => UiStateData(
    id: id ?? this.id,
    expandedNodeIds: expandedNodeIds ?? this.expandedNodeIds,
    selectedNodeId: selectedNodeId.present
        ? selectedNodeId.value
        : this.selectedNodeId,
    viewerMode: viewerMode ?? this.viewerMode,
    treePanelOpen: treePanelOpen ?? this.treePanelOpen,
    gestureHintPasses: gestureHintPasses ?? this.gestureHintPasses,
  );
  UiStateData copyWithCompanion(UiStateCompanion data) {
    return UiStateData(
      id: data.id.present ? data.id.value : this.id,
      expandedNodeIds: data.expandedNodeIds.present
          ? data.expandedNodeIds.value
          : this.expandedNodeIds,
      selectedNodeId: data.selectedNodeId.present
          ? data.selectedNodeId.value
          : this.selectedNodeId,
      viewerMode: data.viewerMode.present
          ? data.viewerMode.value
          : this.viewerMode,
      treePanelOpen: data.treePanelOpen.present
          ? data.treePanelOpen.value
          : this.treePanelOpen,
      gestureHintPasses: data.gestureHintPasses.present
          ? data.gestureHintPasses.value
          : this.gestureHintPasses,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UiStateData(')
          ..write('id: $id, ')
          ..write('expandedNodeIds: $expandedNodeIds, ')
          ..write('selectedNodeId: $selectedNodeId, ')
          ..write('viewerMode: $viewerMode, ')
          ..write('treePanelOpen: $treePanelOpen, ')
          ..write('gestureHintPasses: $gestureHintPasses')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    expandedNodeIds,
    selectedNodeId,
    viewerMode,
    treePanelOpen,
    gestureHintPasses,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UiStateData &&
          other.id == this.id &&
          other.expandedNodeIds == this.expandedNodeIds &&
          other.selectedNodeId == this.selectedNodeId &&
          other.viewerMode == this.viewerMode &&
          other.treePanelOpen == this.treePanelOpen &&
          other.gestureHintPasses == this.gestureHintPasses);
}

class UiStateCompanion extends UpdateCompanion<UiStateData> {
  final Value<int> id;
  final Value<List<String>> expandedNodeIds;
  final Value<String?> selectedNodeId;
  final Value<String> viewerMode;
  final Value<bool> treePanelOpen;
  final Value<int> gestureHintPasses;
  const UiStateCompanion({
    this.id = const Value.absent(),
    this.expandedNodeIds = const Value.absent(),
    this.selectedNodeId = const Value.absent(),
    this.viewerMode = const Value.absent(),
    this.treePanelOpen = const Value.absent(),
    this.gestureHintPasses = const Value.absent(),
  });
  UiStateCompanion.insert({
    this.id = const Value.absent(),
    required List<String> expandedNodeIds,
    this.selectedNodeId = const Value.absent(),
    this.viewerMode = const Value.absent(),
    this.treePanelOpen = const Value.absent(),
    this.gestureHintPasses = const Value.absent(),
  }) : expandedNodeIds = Value(expandedNodeIds);
  static Insertable<UiStateData> custom({
    Expression<int>? id,
    Expression<String>? expandedNodeIds,
    Expression<String>? selectedNodeId,
    Expression<String>? viewerMode,
    Expression<bool>? treePanelOpen,
    Expression<int>? gestureHintPasses,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expandedNodeIds != null) 'expanded_node_ids': expandedNodeIds,
      if (selectedNodeId != null) 'selected_node_id': selectedNodeId,
      if (viewerMode != null) 'viewer_mode': viewerMode,
      if (treePanelOpen != null) 'tree_panel_open': treePanelOpen,
      if (gestureHintPasses != null) 'gesture_hint_passes': gestureHintPasses,
    });
  }

  UiStateCompanion copyWith({
    Value<int>? id,
    Value<List<String>>? expandedNodeIds,
    Value<String?>? selectedNodeId,
    Value<String>? viewerMode,
    Value<bool>? treePanelOpen,
    Value<int>? gestureHintPasses,
  }) {
    return UiStateCompanion(
      id: id ?? this.id,
      expandedNodeIds: expandedNodeIds ?? this.expandedNodeIds,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
      viewerMode: viewerMode ?? this.viewerMode,
      treePanelOpen: treePanelOpen ?? this.treePanelOpen,
      gestureHintPasses: gestureHintPasses ?? this.gestureHintPasses,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (expandedNodeIds.present) {
      map['expanded_node_ids'] = Variable<String>(
        $UiStateTable.$converterexpandedNodeIds.toSql(expandedNodeIds.value),
      );
    }
    if (selectedNodeId.present) {
      map['selected_node_id'] = Variable<String>(selectedNodeId.value);
    }
    if (viewerMode.present) {
      map['viewer_mode'] = Variable<String>(viewerMode.value);
    }
    if (treePanelOpen.present) {
      map['tree_panel_open'] = Variable<bool>(treePanelOpen.value);
    }
    if (gestureHintPasses.present) {
      map['gesture_hint_passes'] = Variable<int>(gestureHintPasses.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UiStateCompanion(')
          ..write('id: $id, ')
          ..write('expandedNodeIds: $expandedNodeIds, ')
          ..write('selectedNodeId: $selectedNodeId, ')
          ..write('viewerMode: $viewerMode, ')
          ..write('treePanelOpen: $treePanelOpen, ')
          ..write('gestureHintPasses: $gestureHintPasses')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordlistsTable wordlists = $WordlistsTable(this);
  late final $PacksTable packs = $PacksTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $PassSessionsTable passSessions = $PassSessionsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $UiStateTable uiState = $UiStateTable(this);
  late final Index wordsPackId = Index(
    'words_pack_id',
    'CREATE INDEX words_pack_id ON words (pack_id)',
  );
  late final Index wordsCategoryId = Index(
    'words_category_id',
    'CREATE INDEX words_category_id ON words (category_id)',
  );
  late final Index wordsSubcategoryId = Index(
    'words_subcategory_id',
    'CREATE INDEX words_subcategory_id ON words (subcategory_id)',
  );
  late final Index wordsTone = Index(
    'words_tone',
    'CREATE INDEX words_tone ON words (tone)',
  );
  late final Index wordsTerm = Index(
    'words_term',
    'CREATE INDEX words_term ON words (term)',
  );
  late final Index packsWordlistId = Index(
    'packs_wordlist_id',
    'CREATE INDEX packs_wordlist_id ON packs (wordlist_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    wordlists,
    packs,
    categories,
    words,
    passSessions,
    appSettings,
    uiState,
    wordsPackId,
    wordsCategoryId,
    wordsSubcategoryId,
    wordsTone,
    wordsTerm,
    packsWordlistId,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wordlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('packs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wordlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('words', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('words', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('words', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'packs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pass_sessions', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$WordlistsTableCreateCompanionBuilder =
    WordlistsCompanion Function({
      required String id,
      required String name,
      required String sourceFilename,
      required String sourceFormat,
      required int wordCount,
      required DateTime importedAt,
      Value<int> rowid,
    });
typedef $$WordlistsTableUpdateCompanionBuilder =
    WordlistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> sourceFilename,
      Value<String> sourceFormat,
      Value<int> wordCount,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

final class $$WordlistsTableReferences
    extends BaseReferences<_$AppDatabase, $WordlistsTable, Wordlist> {
  $$WordlistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PacksTable, List<Pack>> _packsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.packs,
    aliasName: $_aliasNameGenerator(db.wordlists.id, db.packs.wordlistId),
  );

  $$PacksTableProcessedTableManager get packsRefs {
    final manager = $$PacksTableTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.wordlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_packsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordsTable, List<Word>> _wordsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.words,
    aliasName: $_aliasNameGenerator(db.wordlists.id, db.words.wordlistId),
  );

  $$WordsTableProcessedTableManager get wordsRefs {
    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.wordlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordlistsTableFilterComposer
    extends Composer<_$AppDatabase, $WordlistsTable> {
  $$WordlistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFormat => $composableBuilder(
    column: $table.sourceFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> packsRefs(
    Expression<bool> Function($$PacksTableFilterComposer f) f,
  ) {
    final $$PacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.wordlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordsRefs(
    Expression<bool> Function($$WordsTableFilterComposer f) f,
  ) {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.wordlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordlistsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordlistsTable> {
  $$WordlistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFormat => $composableBuilder(
    column: $table.sourceFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordlistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordlistsTable> {
  $$WordlistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFormat => $composableBuilder(
    column: $table.sourceFormat,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  Expression<T> packsRefs<T extends Object>(
    Expression<T> Function($$PacksTableAnnotationComposer a) f,
  ) {
    final $$PacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.wordlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordsRefs<T extends Object>(
    Expression<T> Function($$WordsTableAnnotationComposer a) f,
  ) {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.wordlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordlistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordlistsTable,
          Wordlist,
          $$WordlistsTableFilterComposer,
          $$WordlistsTableOrderingComposer,
          $$WordlistsTableAnnotationComposer,
          $$WordlistsTableCreateCompanionBuilder,
          $$WordlistsTableUpdateCompanionBuilder,
          (Wordlist, $$WordlistsTableReferences),
          Wordlist,
          PrefetchHooks Function({bool packsRefs, bool wordsRefs})
        > {
  $$WordlistsTableTableManager(_$AppDatabase db, $WordlistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordlistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordlistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordlistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sourceFilename = const Value.absent(),
                Value<String> sourceFormat = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordlistsCompanion(
                id: id,
                name: name,
                sourceFilename: sourceFilename,
                sourceFormat: sourceFormat,
                wordCount: wordCount,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String sourceFilename,
                required String sourceFormat,
                required int wordCount,
                required DateTime importedAt,
                Value<int> rowid = const Value.absent(),
              }) => WordlistsCompanion.insert(
                id: id,
                name: name,
                sourceFilename: sourceFilename,
                sourceFormat: sourceFormat,
                wordCount: wordCount,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordlistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packsRefs = false, wordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (packsRefs) db.packs,
                if (wordsRefs) db.words,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (packsRefs)
                    await $_getPrefetchedData<Wordlist, $WordlistsTable, Pack>(
                      currentTable: table,
                      referencedTable: $$WordlistsTableReferences
                          ._packsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WordlistsTableReferences(db, table, p0).packsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wordlistId == item.id),
                      typedResults: items,
                    ),
                  if (wordsRefs)
                    await $_getPrefetchedData<Wordlist, $WordlistsTable, Word>(
                      currentTable: table,
                      referencedTable: $$WordlistsTableReferences
                          ._wordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WordlistsTableReferences(db, table, p0).wordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wordlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WordlistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordlistsTable,
      Wordlist,
      $$WordlistsTableFilterComposer,
      $$WordlistsTableOrderingComposer,
      $$WordlistsTableAnnotationComposer,
      $$WordlistsTableCreateCompanionBuilder,
      $$WordlistsTableUpdateCompanionBuilder,
      (Wordlist, $$WordlistsTableReferences),
      Wordlist,
      PrefetchHooks Function({bool packsRefs, bool wordsRefs})
    >;
typedef $$PacksTableCreateCompanionBuilder =
    PacksCompanion Function({
      required String id,
      required String wordlistId,
      required int number,
      required Mastery masteryWd,
      required Mastery masteryDw,
      Value<int> passesWd,
      Value<int> passesDw,
      Value<int> cleanPassesWd,
      Value<int> cleanPassesDw,
      Value<DateTime?> lastPassAtWd,
      Value<DateTime?> lastPassAtDw,
      Value<DateTime?> masteredAtWd,
      Value<DateTime?> masteredAtDw,
      Value<Direction?> lastDirection,
      Value<DateTime?> learnedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PacksTableUpdateCompanionBuilder =
    PacksCompanion Function({
      Value<String> id,
      Value<String> wordlistId,
      Value<int> number,
      Value<Mastery> masteryWd,
      Value<Mastery> masteryDw,
      Value<int> passesWd,
      Value<int> passesDw,
      Value<int> cleanPassesWd,
      Value<int> cleanPassesDw,
      Value<DateTime?> lastPassAtWd,
      Value<DateTime?> lastPassAtDw,
      Value<DateTime?> masteredAtWd,
      Value<DateTime?> masteredAtDw,
      Value<Direction?> lastDirection,
      Value<DateTime?> learnedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PacksTableReferences
    extends BaseReferences<_$AppDatabase, $PacksTable, Pack> {
  $$PacksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordlistsTable _wordlistIdTable(_$AppDatabase db) => db.wordlists
      .createAlias($_aliasNameGenerator(db.packs.wordlistId, db.wordlists.id));

  $$WordlistsTableProcessedTableManager get wordlistId {
    final $_column = $_itemColumn<String>('wordlist_id')!;

    final manager = $$WordlistsTableTableManager(
      $_db,
      $_db.wordlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WordsTable, List<Word>> _wordsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.words,
    aliasName: $_aliasNameGenerator(db.packs.id, db.words.packId),
  );

  $$WordsTableProcessedTableManager get wordsRefs {
    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PassSessionsTable, List<PassSession>>
  _passSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.passSessions,
    aliasName: $_aliasNameGenerator(db.packs.id, db.passSessions.packId),
  );

  $$PassSessionsTableProcessedTableManager get passSessionsRefs {
    final manager = $$PassSessionsTableTableManager(
      $_db,
      $_db.passSessions,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_passSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PacksTableFilterComposer extends Composer<_$AppDatabase, $PacksTable> {
  $$PacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Mastery, Mastery, String> get masteryWd =>
      $composableBuilder(
        column: $table.masteryWd,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Mastery, Mastery, String> get masteryDw =>
      $composableBuilder(
        column: $table.masteryDw,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get passesWd => $composableBuilder(
    column: $table.passesWd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passesDw => $composableBuilder(
    column: $table.passesDw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cleanPassesWd => $composableBuilder(
    column: $table.cleanPassesWd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cleanPassesDw => $composableBuilder(
    column: $table.cleanPassesDw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPassAtWd => $composableBuilder(
    column: $table.lastPassAtWd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPassAtDw => $composableBuilder(
    column: $table.lastPassAtDw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get masteredAtWd => $composableBuilder(
    column: $table.masteredAtWd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get masteredAtDw => $composableBuilder(
    column: $table.masteredAtDw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Direction?, Direction, String>
  get lastDirection => $composableBuilder(
    column: $table.lastDirection,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get learnedAt => $composableBuilder(
    column: $table.learnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordlistsTableFilterComposer get wordlistId {
    final $$WordlistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordlistId,
      referencedTable: $db.wordlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordlistsTableFilterComposer(
            $db: $db,
            $table: $db.wordlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> wordsRefs(
    Expression<bool> Function($$WordsTableFilterComposer f) f,
  ) {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> passSessionsRefs(
    Expression<bool> Function($$PassSessionsTableFilterComposer f) f,
  ) {
    final $$PassSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.passSessions,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PassSessionsTableFilterComposer(
            $db: $db,
            $table: $db.passSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PacksTableOrderingComposer
    extends Composer<_$AppDatabase, $PacksTable> {
  $$PacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masteryWd => $composableBuilder(
    column: $table.masteryWd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masteryDw => $composableBuilder(
    column: $table.masteryDw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passesWd => $composableBuilder(
    column: $table.passesWd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passesDw => $composableBuilder(
    column: $table.passesDw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cleanPassesWd => $composableBuilder(
    column: $table.cleanPassesWd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cleanPassesDw => $composableBuilder(
    column: $table.cleanPassesDw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPassAtWd => $composableBuilder(
    column: $table.lastPassAtWd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPassAtDw => $composableBuilder(
    column: $table.lastPassAtDw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get masteredAtWd => $composableBuilder(
    column: $table.masteredAtWd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get masteredAtDw => $composableBuilder(
    column: $table.masteredAtDw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastDirection => $composableBuilder(
    column: $table.lastDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get learnedAt => $composableBuilder(
    column: $table.learnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordlistsTableOrderingComposer get wordlistId {
    final $$WordlistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordlistId,
      referencedTable: $db.wordlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordlistsTableOrderingComposer(
            $db: $db,
            $table: $db.wordlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PacksTable> {
  $$PacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Mastery, String> get masteryWd =>
      $composableBuilder(column: $table.masteryWd, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Mastery, String> get masteryDw =>
      $composableBuilder(column: $table.masteryDw, builder: (column) => column);

  GeneratedColumn<int> get passesWd =>
      $composableBuilder(column: $table.passesWd, builder: (column) => column);

  GeneratedColumn<int> get passesDw =>
      $composableBuilder(column: $table.passesDw, builder: (column) => column);

  GeneratedColumn<int> get cleanPassesWd => $composableBuilder(
    column: $table.cleanPassesWd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cleanPassesDw => $composableBuilder(
    column: $table.cleanPassesDw,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPassAtWd => $composableBuilder(
    column: $table.lastPassAtWd,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPassAtDw => $composableBuilder(
    column: $table.lastPassAtDw,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get masteredAtWd => $composableBuilder(
    column: $table.masteredAtWd,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get masteredAtDw => $composableBuilder(
    column: $table.masteredAtDw,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Direction?, String> get lastDirection =>
      $composableBuilder(
        column: $table.lastDirection,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get learnedAt =>
      $composableBuilder(column: $table.learnedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WordlistsTableAnnotationComposer get wordlistId {
    final $$WordlistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordlistId,
      referencedTable: $db.wordlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordlistsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> wordsRefs<T extends Object>(
    Expression<T> Function($$WordsTableAnnotationComposer a) f,
  ) {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> passSessionsRefs<T extends Object>(
    Expression<T> Function($$PassSessionsTableAnnotationComposer a) f,
  ) {
    final $$PassSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.passSessions,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PassSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.passSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PacksTable,
          Pack,
          $$PacksTableFilterComposer,
          $$PacksTableOrderingComposer,
          $$PacksTableAnnotationComposer,
          $$PacksTableCreateCompanionBuilder,
          $$PacksTableUpdateCompanionBuilder,
          (Pack, $$PacksTableReferences),
          Pack,
          PrefetchHooks Function({
            bool wordlistId,
            bool wordsRefs,
            bool passSessionsRefs,
          })
        > {
  $$PacksTableTableManager(_$AppDatabase db, $PacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> wordlistId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<Mastery> masteryWd = const Value.absent(),
                Value<Mastery> masteryDw = const Value.absent(),
                Value<int> passesWd = const Value.absent(),
                Value<int> passesDw = const Value.absent(),
                Value<int> cleanPassesWd = const Value.absent(),
                Value<int> cleanPassesDw = const Value.absent(),
                Value<DateTime?> lastPassAtWd = const Value.absent(),
                Value<DateTime?> lastPassAtDw = const Value.absent(),
                Value<DateTime?> masteredAtWd = const Value.absent(),
                Value<DateTime?> masteredAtDw = const Value.absent(),
                Value<Direction?> lastDirection = const Value.absent(),
                Value<DateTime?> learnedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PacksCompanion(
                id: id,
                wordlistId: wordlistId,
                number: number,
                masteryWd: masteryWd,
                masteryDw: masteryDw,
                passesWd: passesWd,
                passesDw: passesDw,
                cleanPassesWd: cleanPassesWd,
                cleanPassesDw: cleanPassesDw,
                lastPassAtWd: lastPassAtWd,
                lastPassAtDw: lastPassAtDw,
                masteredAtWd: masteredAtWd,
                masteredAtDw: masteredAtDw,
                lastDirection: lastDirection,
                learnedAt: learnedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String wordlistId,
                required int number,
                required Mastery masteryWd,
                required Mastery masteryDw,
                Value<int> passesWd = const Value.absent(),
                Value<int> passesDw = const Value.absent(),
                Value<int> cleanPassesWd = const Value.absent(),
                Value<int> cleanPassesDw = const Value.absent(),
                Value<DateTime?> lastPassAtWd = const Value.absent(),
                Value<DateTime?> lastPassAtDw = const Value.absent(),
                Value<DateTime?> masteredAtWd = const Value.absent(),
                Value<DateTime?> masteredAtDw = const Value.absent(),
                Value<Direction?> lastDirection = const Value.absent(),
                Value<DateTime?> learnedAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PacksCompanion.insert(
                id: id,
                wordlistId: wordlistId,
                number: number,
                masteryWd: masteryWd,
                masteryDw: masteryDw,
                passesWd: passesWd,
                passesDw: passesDw,
                cleanPassesWd: cleanPassesWd,
                cleanPassesDw: cleanPassesDw,
                lastPassAtWd: lastPassAtWd,
                lastPassAtDw: lastPassAtDw,
                masteredAtWd: masteredAtWd,
                masteredAtDw: masteredAtDw,
                lastDirection: lastDirection,
                learnedAt: learnedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PacksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordlistId = false,
                wordsRefs = false,
                passSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordsRefs) db.words,
                    if (passSessionsRefs) db.passSessions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (wordlistId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wordlistId,
                                    referencedTable: $$PacksTableReferences
                                        ._wordlistIdTable(db),
                                    referencedColumn: $$PacksTableReferences
                                        ._wordlistIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordsRefs)
                        await $_getPrefetchedData<Pack, $PacksTable, Word>(
                          currentTable: table,
                          referencedTable: $$PacksTableReferences
                              ._wordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PacksTableReferences(db, table, p0).wordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (passSessionsRefs)
                        await $_getPrefetchedData<
                          Pack,
                          $PacksTable,
                          PassSession
                        >(
                          currentTable: table,
                          referencedTable: $$PacksTableReferences
                              ._passSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PacksTableReferences(
                                db,
                                table,
                                p0,
                              ).passSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PacksTable,
      Pack,
      $$PacksTableFilterComposer,
      $$PacksTableOrderingComposer,
      $$PacksTableAnnotationComposer,
      $$PacksTableCreateCompanionBuilder,
      $$PacksTableUpdateCompanionBuilder,
      (Pack, $$PacksTableReferences),
      Pack,
      PrefetchHooks Function({
        bool wordlistId,
        bool wordsRefs,
        bool passSessionsRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String key,
      Value<String?> parentId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> key,
      Value<String?> parentId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.categories.parentId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get parentId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get parentId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get parentId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool parentId})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                key: key,
                parentId: parentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String key,
                Value<String?> parentId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                key: key,
                parentId: parentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (parentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.parentId,
                                referencedTable: $$CategoriesTableReferences
                                    ._parentIdTable(db),
                                referencedColumn: $$CategoriesTableReferences
                                    ._parentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool parentId})
    >;
typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      required String id,
      required String wordlistId,
      required int position,
      required String term,
      Value<String?> pos,
      Value<String?> posRaw,
      required String definition,
      required String packId,
      Value<Tone?> tone,
      Value<bool> counterIntuitive,
      Value<bool> multipleMeanings,
      Value<String?> categoryId,
      Value<String?> subcategoryId,
      Value<bool> masteredWd,
      Value<bool> masteredDw,
      Value<int> revealCountWd,
      Value<int> revealCountDw,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> lastRevealedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<String> id,
      Value<String> wordlistId,
      Value<int> position,
      Value<String> term,
      Value<String?> pos,
      Value<String?> posRaw,
      Value<String> definition,
      Value<String> packId,
      Value<Tone?> tone,
      Value<bool> counterIntuitive,
      Value<bool> multipleMeanings,
      Value<String?> categoryId,
      Value<String?> subcategoryId,
      Value<bool> masteredWd,
      Value<bool> masteredDw,
      Value<int> revealCountWd,
      Value<int> revealCountDw,
      Value<DateTime?> lastSeenAt,
      Value<DateTime?> lastRevealedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordlistsTable _wordlistIdTable(_$AppDatabase db) => db.wordlists
      .createAlias($_aliasNameGenerator(db.words.wordlistId, db.wordlists.id));

  $$WordlistsTableProcessedTableManager get wordlistId {
    final $_column = $_itemColumn<String>('wordlist_id')!;

    final manager = $$WordlistsTableTableManager(
      $_db,
      $_db.wordlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PacksTable _packIdTable(_$AppDatabase db) =>
      db.packs.createAlias($_aliasNameGenerator(db.words.packId, db.packs.id));

  $$PacksTableProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $$PacksTableTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias($_aliasNameGenerator(db.words.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _subcategoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.words.subcategoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get subcategoryId {
    final $_column = $_itemColumn<String>('subcategory_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posRaw => $composableBuilder(
    column: $table.posRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Tone?, Tone, String> get tone =>
      $composableBuilder(
        column: $table.tone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get counterIntuitive => $composableBuilder(
    column: $table.counterIntuitive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get multipleMeanings => $composableBuilder(
    column: $table.multipleMeanings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get masteredWd => $composableBuilder(
    column: $table.masteredWd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get masteredDw => $composableBuilder(
    column: $table.masteredDw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revealCountWd => $composableBuilder(
    column: $table.revealCountWd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revealCountDw => $composableBuilder(
    column: $table.revealCountDw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRevealedAt => $composableBuilder(
    column: $table.lastRevealedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordlistsTableFilterComposer get wordlistId {
    final $$WordlistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordlistId,
      referencedTable: $db.wordlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordlistsTableFilterComposer(
            $db: $db,
            $table: $db.wordlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PacksTableFilterComposer get packId {
    final $$PacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get subcategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posRaw => $composableBuilder(
    column: $table.posRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get counterIntuitive => $composableBuilder(
    column: $table.counterIntuitive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get multipleMeanings => $composableBuilder(
    column: $table.multipleMeanings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get masteredWd => $composableBuilder(
    column: $table.masteredWd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get masteredDw => $composableBuilder(
    column: $table.masteredDw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revealCountWd => $composableBuilder(
    column: $table.revealCountWd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revealCountDw => $composableBuilder(
    column: $table.revealCountDw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRevealedAt => $composableBuilder(
    column: $table.lastRevealedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordlistsTableOrderingComposer get wordlistId {
    final $$WordlistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordlistId,
      referencedTable: $db.wordlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordlistsTableOrderingComposer(
            $db: $db,
            $table: $db.wordlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PacksTableOrderingComposer get packId {
    final $$PacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get subcategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get pos =>
      $composableBuilder(column: $table.pos, builder: (column) => column);

  GeneratedColumn<String> get posRaw =>
      $composableBuilder(column: $table.posRaw, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Tone?, String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<bool> get counterIntuitive => $composableBuilder(
    column: $table.counterIntuitive,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get multipleMeanings => $composableBuilder(
    column: $table.multipleMeanings,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get masteredWd => $composableBuilder(
    column: $table.masteredWd,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get masteredDw => $composableBuilder(
    column: $table.masteredDw,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revealCountWd => $composableBuilder(
    column: $table.revealCountWd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revealCountDw => $composableBuilder(
    column: $table.revealCountDw,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastRevealedAt => $composableBuilder(
    column: $table.lastRevealedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WordlistsTableAnnotationComposer get wordlistId {
    final $$WordlistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordlistId,
      referencedTable: $db.wordlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordlistsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PacksTableAnnotationComposer get packId {
    final $$PacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get subcategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({
            bool wordlistId,
            bool packId,
            bool categoryId,
            bool subcategoryId,
          })
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> wordlistId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String?> pos = const Value.absent(),
                Value<String?> posRaw = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<Tone?> tone = const Value.absent(),
                Value<bool> counterIntuitive = const Value.absent(),
                Value<bool> multipleMeanings = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> subcategoryId = const Value.absent(),
                Value<bool> masteredWd = const Value.absent(),
                Value<bool> masteredDw = const Value.absent(),
                Value<int> revealCountWd = const Value.absent(),
                Value<int> revealCountDw = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastRevealedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                wordlistId: wordlistId,
                position: position,
                term: term,
                pos: pos,
                posRaw: posRaw,
                definition: definition,
                packId: packId,
                tone: tone,
                counterIntuitive: counterIntuitive,
                multipleMeanings: multipleMeanings,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                masteredWd: masteredWd,
                masteredDw: masteredDw,
                revealCountWd: revealCountWd,
                revealCountDw: revealCountDw,
                lastSeenAt: lastSeenAt,
                lastRevealedAt: lastRevealedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String wordlistId,
                required int position,
                required String term,
                Value<String?> pos = const Value.absent(),
                Value<String?> posRaw = const Value.absent(),
                required String definition,
                required String packId,
                Value<Tone?> tone = const Value.absent(),
                Value<bool> counterIntuitive = const Value.absent(),
                Value<bool> multipleMeanings = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> subcategoryId = const Value.absent(),
                Value<bool> masteredWd = const Value.absent(),
                Value<bool> masteredDw = const Value.absent(),
                Value<int> revealCountWd = const Value.absent(),
                Value<int> revealCountDw = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime?> lastRevealedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                wordlistId: wordlistId,
                position: position,
                term: term,
                pos: pos,
                posRaw: posRaw,
                definition: definition,
                packId: packId,
                tone: tone,
                counterIntuitive: counterIntuitive,
                multipleMeanings: multipleMeanings,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                masteredWd: masteredWd,
                masteredDw: masteredDw,
                revealCountWd: revealCountWd,
                revealCountDw: revealCountDw,
                lastSeenAt: lastSeenAt,
                lastRevealedAt: lastRevealedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WordsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordlistId = false,
                packId = false,
                categoryId = false,
                subcategoryId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (wordlistId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wordlistId,
                                    referencedTable: $$WordsTableReferences
                                        ._wordlistIdTable(db),
                                    referencedColumn: $$WordsTableReferences
                                        ._wordlistIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (packId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.packId,
                                    referencedTable: $$WordsTableReferences
                                        ._packIdTable(db),
                                    referencedColumn: $$WordsTableReferences
                                        ._packIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$WordsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$WordsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (subcategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subcategoryId,
                                    referencedTable: $$WordsTableReferences
                                        ._subcategoryIdTable(db),
                                    referencedColumn: $$WordsTableReferences
                                        ._subcategoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({
        bool wordlistId,
        bool packId,
        bool categoryId,
        bool subcategoryId,
      })
    >;
typedef $$PassSessionsTableCreateCompanionBuilder =
    PassSessionsCompanion Function({
      required String id,
      required String packId,
      required Direction direction,
      required int idx,
      required List<String> revealed,
      required bool currentRevealed,
      required int passNumber,
      required DateTime startedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PassSessionsTableUpdateCompanionBuilder =
    PassSessionsCompanion Function({
      Value<String> id,
      Value<String> packId,
      Value<Direction> direction,
      Value<int> idx,
      Value<List<String>> revealed,
      Value<bool> currentRevealed,
      Value<int> passNumber,
      Value<DateTime> startedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PassSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $PassSessionsTable, PassSession> {
  $$PassSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PacksTable _packIdTable(_$AppDatabase db) => db.packs.createAlias(
    $_aliasNameGenerator(db.passSessions.packId, db.packs.id),
  );

  $$PacksTableProcessedTableManager get packId {
    final $_column = $_itemColumn<String>('pack_id')!;

    final manager = $$PacksTableTableManager(
      $_db,
      $_db.packs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PassSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PassSessionsTable> {
  $$PassSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Direction, Direction, String> get direction =>
      $composableBuilder(
        column: $table.direction,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get revealed => $composableBuilder(
    column: $table.revealed,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get currentRevealed => $composableBuilder(
    column: $table.currentRevealed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passNumber => $composableBuilder(
    column: $table.passNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PacksTableFilterComposer get packId {
    final $$PacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableFilterComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PassSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PassSessionsTable> {
  $$PassSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revealed => $composableBuilder(
    column: $table.revealed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get currentRevealed => $composableBuilder(
    column: $table.currentRevealed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passNumber => $composableBuilder(
    column: $table.passNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PacksTableOrderingComposer get packId {
    final $$PacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableOrderingComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PassSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PassSessionsTable> {
  $$PassSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Direction, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get revealed =>
      $composableBuilder(column: $table.revealed, builder: (column) => column);

  GeneratedColumn<bool> get currentRevealed => $composableBuilder(
    column: $table.currentRevealed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passNumber => $composableBuilder(
    column: $table.passNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PacksTableAnnotationComposer get packId {
    final $$PacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.packs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PacksTableAnnotationComposer(
            $db: $db,
            $table: $db.packs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PassSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PassSessionsTable,
          PassSession,
          $$PassSessionsTableFilterComposer,
          $$PassSessionsTableOrderingComposer,
          $$PassSessionsTableAnnotationComposer,
          $$PassSessionsTableCreateCompanionBuilder,
          $$PassSessionsTableUpdateCompanionBuilder,
          (PassSession, $$PassSessionsTableReferences),
          PassSession,
          PrefetchHooks Function({bool packId})
        > {
  $$PassSessionsTableTableManager(_$AppDatabase db, $PassSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PassSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PassSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PassSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<Direction> direction = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<List<String>> revealed = const Value.absent(),
                Value<bool> currentRevealed = const Value.absent(),
                Value<int> passNumber = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PassSessionsCompanion(
                id: id,
                packId: packId,
                direction: direction,
                idx: idx,
                revealed: revealed,
                currentRevealed: currentRevealed,
                passNumber: passNumber,
                startedAt: startedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String packId,
                required Direction direction,
                required int idx,
                required List<String> revealed,
                required bool currentRevealed,
                required int passNumber,
                required DateTime startedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PassSessionsCompanion.insert(
                id: id,
                packId: packId,
                direction: direction,
                idx: idx,
                revealed: revealed,
                currentRevealed: currentRevealed,
                passNumber: passNumber,
                startedAt: startedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PassSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.packId,
                                referencedTable: $$PassSessionsTableReferences
                                    ._packIdTable(db),
                                referencedColumn: $$PassSessionsTableReferences
                                    ._packIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PassSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PassSessionsTable,
      PassSession,
      $$PassSessionsTableFilterComposer,
      $$PassSessionsTableOrderingComposer,
      $$PassSessionsTableAnnotationComposer,
      $$PassSessionsTableCreateCompanionBuilder,
      $$PassSessionsTableUpdateCompanionBuilder,
      (PassSession, $$PassSessionsTableReferences),
      PassSession,
      PrefetchHooks Function({bool packId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> packSize,
      required Direction defaultDirection,
      required LearnedRule learnedRule,
      Value<bool> showPos,
      Value<bool> demoteOnReveal,
      Value<String> theme,
      Value<bool> studyButtons,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> packSize,
      Value<Direction> defaultDirection,
      Value<LearnedRule> learnedRule,
      Value<bool> showPos,
      Value<bool> demoteOnReveal,
      Value<String> theme,
      Value<bool> studyButtons,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packSize => $composableBuilder(
    column: $table.packSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Direction, Direction, String>
  get defaultDirection => $composableBuilder(
    column: $table.defaultDirection,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LearnedRule, LearnedRule, String>
  get learnedRule => $composableBuilder(
    column: $table.learnedRule,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get showPos => $composableBuilder(
    column: $table.showPos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get demoteOnReveal => $composableBuilder(
    column: $table.demoteOnReveal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get studyButtons => $composableBuilder(
    column: $table.studyButtons,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packSize => $composableBuilder(
    column: $table.packSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultDirection => $composableBuilder(
    column: $table.defaultDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learnedRule => $composableBuilder(
    column: $table.learnedRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showPos => $composableBuilder(
    column: $table.showPos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get demoteOnReveal => $composableBuilder(
    column: $table.demoteOnReveal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get studyButtons => $composableBuilder(
    column: $table.studyButtons,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get packSize =>
      $composableBuilder(column: $table.packSize, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Direction, String> get defaultDirection =>
      $composableBuilder(
        column: $table.defaultDirection,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<LearnedRule, String> get learnedRule =>
      $composableBuilder(
        column: $table.learnedRule,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get showPos =>
      $composableBuilder(column: $table.showPos, builder: (column) => column);

  GeneratedColumn<bool> get demoteOnReveal => $composableBuilder(
    column: $table.demoteOnReveal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<bool> get studyButtons => $composableBuilder(
    column: $table.studyButtons,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> packSize = const Value.absent(),
                Value<Direction> defaultDirection = const Value.absent(),
                Value<LearnedRule> learnedRule = const Value.absent(),
                Value<bool> showPos = const Value.absent(),
                Value<bool> demoteOnReveal = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<bool> studyButtons = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                packSize: packSize,
                defaultDirection: defaultDirection,
                learnedRule: learnedRule,
                showPos: showPos,
                demoteOnReveal: demoteOnReveal,
                theme: theme,
                studyButtons: studyButtons,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> packSize = const Value.absent(),
                required Direction defaultDirection,
                required LearnedRule learnedRule,
                Value<bool> showPos = const Value.absent(),
                Value<bool> demoteOnReveal = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<bool> studyButtons = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                packSize: packSize,
                defaultDirection: defaultDirection,
                learnedRule: learnedRule,
                showPos: showPos,
                demoteOnReveal: demoteOnReveal,
                theme: theme,
                studyButtons: studyButtons,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$UiStateTableCreateCompanionBuilder =
    UiStateCompanion Function({
      Value<int> id,
      required List<String> expandedNodeIds,
      Value<String?> selectedNodeId,
      Value<String> viewerMode,
      Value<bool> treePanelOpen,
      Value<int> gestureHintPasses,
    });
typedef $$UiStateTableUpdateCompanionBuilder =
    UiStateCompanion Function({
      Value<int> id,
      Value<List<String>> expandedNodeIds,
      Value<String?> selectedNodeId,
      Value<String> viewerMode,
      Value<bool> treePanelOpen,
      Value<int> gestureHintPasses,
    });

class $$UiStateTableFilterComposer
    extends Composer<_$AppDatabase, $UiStateTable> {
  $$UiStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get expandedNodeIds => $composableBuilder(
    column: $table.expandedNodeIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get selectedNodeId => $composableBuilder(
    column: $table.selectedNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewerMode => $composableBuilder(
    column: $table.viewerMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get treePanelOpen => $composableBuilder(
    column: $table.treePanelOpen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gestureHintPasses => $composableBuilder(
    column: $table.gestureHintPasses,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UiStateTableOrderingComposer
    extends Composer<_$AppDatabase, $UiStateTable> {
  $$UiStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expandedNodeIds => $composableBuilder(
    column: $table.expandedNodeIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedNodeId => $composableBuilder(
    column: $table.selectedNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewerMode => $composableBuilder(
    column: $table.viewerMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get treePanelOpen => $composableBuilder(
    column: $table.treePanelOpen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gestureHintPasses => $composableBuilder(
    column: $table.gestureHintPasses,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UiStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $UiStateTable> {
  $$UiStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get expandedNodeIds =>
      $composableBuilder(
        column: $table.expandedNodeIds,
        builder: (column) => column,
      );

  GeneratedColumn<String> get selectedNodeId => $composableBuilder(
    column: $table.selectedNodeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get viewerMode => $composableBuilder(
    column: $table.viewerMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get treePanelOpen => $composableBuilder(
    column: $table.treePanelOpen,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gestureHintPasses => $composableBuilder(
    column: $table.gestureHintPasses,
    builder: (column) => column,
  );
}

class $$UiStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UiStateTable,
          UiStateData,
          $$UiStateTableFilterComposer,
          $$UiStateTableOrderingComposer,
          $$UiStateTableAnnotationComposer,
          $$UiStateTableCreateCompanionBuilder,
          $$UiStateTableUpdateCompanionBuilder,
          (
            UiStateData,
            BaseReferences<_$AppDatabase, $UiStateTable, UiStateData>,
          ),
          UiStateData,
          PrefetchHooks Function()
        > {
  $$UiStateTableTableManager(_$AppDatabase db, $UiStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UiStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UiStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UiStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<List<String>> expandedNodeIds = const Value.absent(),
                Value<String?> selectedNodeId = const Value.absent(),
                Value<String> viewerMode = const Value.absent(),
                Value<bool> treePanelOpen = const Value.absent(),
                Value<int> gestureHintPasses = const Value.absent(),
              }) => UiStateCompanion(
                id: id,
                expandedNodeIds: expandedNodeIds,
                selectedNodeId: selectedNodeId,
                viewerMode: viewerMode,
                treePanelOpen: treePanelOpen,
                gestureHintPasses: gestureHintPasses,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required List<String> expandedNodeIds,
                Value<String?> selectedNodeId = const Value.absent(),
                Value<String> viewerMode = const Value.absent(),
                Value<bool> treePanelOpen = const Value.absent(),
                Value<int> gestureHintPasses = const Value.absent(),
              }) => UiStateCompanion.insert(
                id: id,
                expandedNodeIds: expandedNodeIds,
                selectedNodeId: selectedNodeId,
                viewerMode: viewerMode,
                treePanelOpen: treePanelOpen,
                gestureHintPasses: gestureHintPasses,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UiStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UiStateTable,
      UiStateData,
      $$UiStateTableFilterComposer,
      $$UiStateTableOrderingComposer,
      $$UiStateTableAnnotationComposer,
      $$UiStateTableCreateCompanionBuilder,
      $$UiStateTableUpdateCompanionBuilder,
      (UiStateData, BaseReferences<_$AppDatabase, $UiStateTable, UiStateData>),
      UiStateData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordlistsTableTableManager get wordlists =>
      $$WordlistsTableTableManager(_db, _db.wordlists);
  $$PacksTableTableManager get packs =>
      $$PacksTableTableManager(_db, _db.packs);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$PassSessionsTableTableManager get passSessions =>
      $$PassSessionsTableTableManager(_db, _db.passSessions);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$UiStateTableTableManager get uiState =>
      $$UiStateTableTableManager(_db, _db.uiState);
}
