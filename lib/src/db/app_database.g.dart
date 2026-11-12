// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ScannedDocumentsGroupsTable extends ScannedDocumentsGroups
    with TableInfo<$ScannedDocumentsGroupsTable, ScannedDocumentsGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannedDocumentsGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => generateId(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativeFolderPathMeta =
      const VerificationMeta('relativeFolderPath');
  @override
  late final GeneratedColumn<String> relativeFolderPath =
      GeneratedColumn<String>(
        'relative_folder_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _absoluteFolderPathMeta =
      const VerificationMeta('absoluteFolderPath');
  @override
  late final GeneratedColumn<String> absoluteFolderPath =
      GeneratedColumn<String>(
        'absolute_folder_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    name,
    relativeFolderPath,
    absoluteFolderPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scanned_documents_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScannedDocumentsGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('relative_folder_path')) {
      context.handle(
        _relativeFolderPathMeta,
        relativeFolderPath.isAcceptableOrUnknown(
          data['relative_folder_path']!,
          _relativeFolderPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativeFolderPathMeta);
    }
    if (data.containsKey('absolute_folder_path')) {
      context.handle(
        _absoluteFolderPathMeta,
        absoluteFolderPath.isAcceptableOrUnknown(
          data['absolute_folder_path']!,
          _absoluteFolderPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_absoluteFolderPathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScannedDocumentsGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedDocumentsGroup(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      relativeFolderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_folder_path'],
      )!,
      absoluteFolderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}absolute_folder_path'],
      )!,
    );
  }

  @override
  $ScannedDocumentsGroupsTable createAlias(String alias) {
    return $ScannedDocumentsGroupsTable(attachedDatabase, alias);
  }
}

class ScannedDocumentsGroup extends DataClass
    implements Insertable<ScannedDocumentsGroup> {
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String id;
  final String name;
  final String relativeFolderPath;
  final String absoluteFolderPath;
  const ScannedDocumentsGroup({
    required this.createdAt,
    this.updatedAt,
    required this.id,
    required this.name,
    required this.relativeFolderPath,
    required this.absoluteFolderPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['relative_folder_path'] = Variable<String>(relativeFolderPath);
    map['absolute_folder_path'] = Variable<String>(absoluteFolderPath);
    return map;
  }

  ScannedDocumentsGroupsCompanion toCompanion(bool nullToAbsent) {
    return ScannedDocumentsGroupsCompanion(
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      id: Value(id),
      name: Value(name),
      relativeFolderPath: Value(relativeFolderPath),
      absoluteFolderPath: Value(absoluteFolderPath),
    );
  }

  factory ScannedDocumentsGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedDocumentsGroup(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      relativeFolderPath: serializer.fromJson<String>(
        json['relativeFolderPath'],
      ),
      absoluteFolderPath: serializer.fromJson<String>(
        json['absoluteFolderPath'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'relativeFolderPath': serializer.toJson<String>(relativeFolderPath),
      'absoluteFolderPath': serializer.toJson<String>(absoluteFolderPath),
    };
  }

  ScannedDocumentsGroup copyWith({
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? id,
    String? name,
    String? relativeFolderPath,
    String? absoluteFolderPath,
  }) => ScannedDocumentsGroup(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    relativeFolderPath: relativeFolderPath ?? this.relativeFolderPath,
    absoluteFolderPath: absoluteFolderPath ?? this.absoluteFolderPath,
  );
  ScannedDocumentsGroup copyWithCompanion(
    ScannedDocumentsGroupsCompanion data,
  ) {
    return ScannedDocumentsGroup(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      relativeFolderPath: data.relativeFolderPath.present
          ? data.relativeFolderPath.value
          : this.relativeFolderPath,
      absoluteFolderPath: data.absoluteFolderPath.present
          ? data.absoluteFolderPath.value
          : this.absoluteFolderPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocumentsGroup(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relativeFolderPath: $relativeFolderPath, ')
          ..write('absoluteFolderPath: $absoluteFolderPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    name,
    relativeFolderPath,
    absoluteFolderPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedDocumentsGroup &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.relativeFolderPath == this.relativeFolderPath &&
          other.absoluteFolderPath == this.absoluteFolderPath);
}

class ScannedDocumentsGroupsCompanion
    extends UpdateCompanion<ScannedDocumentsGroup> {
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String> relativeFolderPath;
  final Value<String> absoluteFolderPath;
  final Value<int> rowid;
  const ScannedDocumentsGroupsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.relativeFolderPath = const Value.absent(),
    this.absoluteFolderPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScannedDocumentsGroupsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    required String relativeFolderPath,
    required String absoluteFolderPath,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       relativeFolderPath = Value(relativeFolderPath),
       absoluteFolderPath = Value(absoluteFolderPath);
  static Insertable<ScannedDocumentsGroup> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? relativeFolderPath,
    Expression<String>? absoluteFolderPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (relativeFolderPath != null)
        'relative_folder_path': relativeFolderPath,
      if (absoluteFolderPath != null)
        'absolute_folder_path': absoluteFolderPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScannedDocumentsGroupsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String>? relativeFolderPath,
    Value<String>? absoluteFolderPath,
    Value<int>? rowid,
  }) {
    return ScannedDocumentsGroupsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      relativeFolderPath: relativeFolderPath ?? this.relativeFolderPath,
      absoluteFolderPath: absoluteFolderPath ?? this.absoluteFolderPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (relativeFolderPath.present) {
      map['relative_folder_path'] = Variable<String>(relativeFolderPath.value);
    }
    if (absoluteFolderPath.present) {
      map['absolute_folder_path'] = Variable<String>(absoluteFolderPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocumentsGroupsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relativeFolderPath: $relativeFolderPath, ')
          ..write('absoluteFolderPath: $absoluteFolderPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScannedDocumentsTable extends ScannedDocuments
    with TableInfo<$ScannedDocumentsTable, ScannedDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannedDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => generateId(),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scanned_documents_groups (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativeImagePathMeta = const VerificationMeta(
    'relativeImagePath',
  );
  @override
  late final GeneratedColumn<String> relativeImagePath =
      GeneratedColumn<String>(
        'relative_image_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _absoluteImagePathMeta = const VerificationMeta(
    'absoluteImagePath',
  );
  @override
  late final GeneratedColumn<String> absoluteImagePath =
      GeneratedColumn<String>(
        'absolute_image_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    groupId,
    name,
    relativeImagePath,
    absoluteImagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scanned_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScannedDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('relative_image_path')) {
      context.handle(
        _relativeImagePathMeta,
        relativeImagePath.isAcceptableOrUnknown(
          data['relative_image_path']!,
          _relativeImagePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativeImagePathMeta);
    }
    if (data.containsKey('absolute_image_path')) {
      context.handle(
        _absoluteImagePathMeta,
        absoluteImagePath.isAcceptableOrUnknown(
          data['absolute_image_path']!,
          _absoluteImagePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_absoluteImagePathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScannedDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedDocument(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      relativeImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_image_path'],
      )!,
      absoluteImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}absolute_image_path'],
      )!,
    );
  }

  @override
  $ScannedDocumentsTable createAlias(String alias) {
    return $ScannedDocumentsTable(attachedDatabase, alias);
  }
}

class ScannedDocument extends DataClass implements Insertable<ScannedDocument> {
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String id;
  final String groupId;
  final String name;
  final String relativeImagePath;
  final String absoluteImagePath;
  const ScannedDocument({
    required this.createdAt,
    this.updatedAt,
    required this.id,
    required this.groupId,
    required this.name,
    required this.relativeImagePath,
    required this.absoluteImagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['name'] = Variable<String>(name);
    map['relative_image_path'] = Variable<String>(relativeImagePath);
    map['absolute_image_path'] = Variable<String>(absoluteImagePath);
    return map;
  }

  ScannedDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ScannedDocumentsCompanion(
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      id: Value(id),
      groupId: Value(groupId),
      name: Value(name),
      relativeImagePath: Value(relativeImagePath),
      absoluteImagePath: Value(absoluteImagePath),
    );
  }

  factory ScannedDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedDocument(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      relativeImagePath: serializer.fromJson<String>(json['relativeImagePath']),
      absoluteImagePath: serializer.fromJson<String>(json['absoluteImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'name': serializer.toJson<String>(name),
      'relativeImagePath': serializer.toJson<String>(relativeImagePath),
      'absoluteImagePath': serializer.toJson<String>(absoluteImagePath),
    };
  }

  ScannedDocument copyWith({
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? id,
    String? groupId,
    String? name,
    String? relativeImagePath,
    String? absoluteImagePath,
  }) => ScannedDocument(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    name: name ?? this.name,
    relativeImagePath: relativeImagePath ?? this.relativeImagePath,
    absoluteImagePath: absoluteImagePath ?? this.absoluteImagePath,
  );
  ScannedDocument copyWithCompanion(ScannedDocumentsCompanion data) {
    return ScannedDocument(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      relativeImagePath: data.relativeImagePath.present
          ? data.relativeImagePath.value
          : this.relativeImagePath,
      absoluteImagePath: data.absoluteImagePath.present
          ? data.absoluteImagePath.value
          : this.absoluteImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocument(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('relativeImagePath: $relativeImagePath, ')
          ..write('absoluteImagePath: $absoluteImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    groupId,
    name,
    relativeImagePath,
    absoluteImagePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedDocument &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.relativeImagePath == this.relativeImagePath &&
          other.absoluteImagePath == this.absoluteImagePath);
}

class ScannedDocumentsCompanion extends UpdateCompanion<ScannedDocument> {
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> name;
  final Value<String> relativeImagePath;
  final Value<String> absoluteImagePath;
  final Value<int> rowid;
  const ScannedDocumentsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.relativeImagePath = const Value.absent(),
    this.absoluteImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScannedDocumentsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String groupId,
    required String name,
    required String relativeImagePath,
    required String absoluteImagePath,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       name = Value(name),
       relativeImagePath = Value(relativeImagePath),
       absoluteImagePath = Value(absoluteImagePath);
  static Insertable<ScannedDocument> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<String>? relativeImagePath,
    Expression<String>? absoluteImagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (relativeImagePath != null) 'relative_image_path': relativeImagePath,
      if (absoluteImagePath != null) 'absolute_image_path': absoluteImagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScannedDocumentsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? name,
    Value<String>? relativeImagePath,
    Value<String>? absoluteImagePath,
    Value<int>? rowid,
  }) {
    return ScannedDocumentsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      relativeImagePath: relativeImagePath ?? this.relativeImagePath,
      absoluteImagePath: absoluteImagePath ?? this.absoluteImagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (relativeImagePath.present) {
      map['relative_image_path'] = Variable<String>(relativeImagePath.value);
    }
    if (absoluteImagePath.present) {
      map['absolute_image_path'] = Variable<String>(absoluteImagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocumentsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('relativeImagePath: $relativeImagePath, ')
          ..write('absoluteImagePath: $absoluteImagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ScannedDocumentsViewData extends DataClass {
  final String groupId;
  final String groupName;
  final String docId;
  final String docName;
  final String documentGroupId;
  const ScannedDocumentsViewData({
    required this.groupId,
    required this.groupName,
    required this.docId,
    required this.docName,
    required this.documentGroupId,
  });
  factory ScannedDocumentsViewData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedDocumentsViewData(
      groupId: serializer.fromJson<String>(json['groupId']),
      groupName: serializer.fromJson<String>(json['groupName']),
      docId: serializer.fromJson<String>(json['docId']),
      docName: serializer.fromJson<String>(json['docName']),
      documentGroupId: serializer.fromJson<String>(json['documentGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'groupName': serializer.toJson<String>(groupName),
      'docId': serializer.toJson<String>(docId),
      'docName': serializer.toJson<String>(docName),
      'documentGroupId': serializer.toJson<String>(documentGroupId),
    };
  }

  ScannedDocumentsViewData copyWith({
    String? groupId,
    String? groupName,
    String? docId,
    String? docName,
    String? documentGroupId,
  }) => ScannedDocumentsViewData(
    groupId: groupId ?? this.groupId,
    groupName: groupName ?? this.groupName,
    docId: docId ?? this.docId,
    docName: docName ?? this.docName,
    documentGroupId: documentGroupId ?? this.documentGroupId,
  );
  @override
  String toString() {
    return (StringBuffer('ScannedDocumentsViewData(')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('docId: $docId, ')
          ..write('docName: $docName, ')
          ..write('documentGroupId: $documentGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(groupId, groupName, docId, docName, documentGroupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedDocumentsViewData &&
          other.groupId == this.groupId &&
          other.groupName == this.groupName &&
          other.docId == this.docId &&
          other.docName == this.docName &&
          other.documentGroupId == this.documentGroupId);
}

class $ScannedDocumentsViewView
    extends ViewInfo<$ScannedDocumentsViewView, ScannedDocumentsViewData>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$AppDatabase attachedDatabase;
  $ScannedDocumentsViewView(this.attachedDatabase, [this._alias]);
  $ScannedDocumentsGroupsTable get groups =>
      attachedDatabase.scannedDocumentsGroups.createAlias('t0');
  $ScannedDocumentsTable get scannedDocuments =>
      attachedDatabase.scannedDocuments.createAlias('t1');
  @override
  List<GeneratedColumn> get $columns => [
    groupId,
    groupName,
    docId,
    docName,
    documentGroupId,
  ];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'scanned_documents_view';
  @override
  Map<SqlDialect, String>? get createViewStatements => null;
  @override
  $ScannedDocumentsViewView get asDslTable => this;
  @override
  ScannedDocumentsViewData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedDocumentsViewData(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      docId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_id'],
      )!,
      docName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_name'],
      )!,
      documentGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_group_id'],
      )!,
    );
  }

  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    generatedAs: GeneratedAs(groups.id, false),
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    generatedAs: GeneratedAs(groups.name, false),
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> docId = GeneratedColumn<String>(
    'doc_id',
    aliasedName,
    false,
    generatedAs: GeneratedAs(scannedDocuments.id, false),
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> docName = GeneratedColumn<String>(
    'doc_name',
    aliasedName,
    false,
    generatedAs: GeneratedAs(scannedDocuments.name, false),
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> documentGroupId = GeneratedColumn<String>(
    'document_group_id',
    aliasedName,
    false,
    generatedAs: GeneratedAs(scannedDocuments.groupId, false),
    type: DriftSqlType.string,
  );
  @override
  $ScannedDocumentsViewView createAlias(String alias) {
    return $ScannedDocumentsViewView(attachedDatabase, alias);
  }

  @override
  Query? get query =>
      (attachedDatabase.selectOnly(groups)..addColumns($columns)).join([
        innerJoin(
          scannedDocuments,
          scannedDocuments.groupId.equalsExp(groups.id),
        ),
      ]);
  @override
  Set<String> get readTables => const {
    'scanned_documents_groups',
    'scanned_documents',
  };
}

class ScannedGroupDocCountData extends DataClass {
  final String id;
  final String name;
  final int? docCount;
  const ScannedGroupDocCountData({
    required this.id,
    required this.name,
    this.docCount,
  });
  factory ScannedGroupDocCountData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedGroupDocCountData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      docCount: serializer.fromJson<int?>(json['docCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'docCount': serializer.toJson<int?>(docCount),
    };
  }

  ScannedGroupDocCountData copyWith({
    String? id,
    String? name,
    Value<int?> docCount = const Value.absent(),
  }) => ScannedGroupDocCountData(
    id: id ?? this.id,
    name: name ?? this.name,
    docCount: docCount.present ? docCount.value : this.docCount,
  );
  @override
  String toString() {
    return (StringBuffer('ScannedGroupDocCountData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('docCount: $docCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, docCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedGroupDocCountData &&
          other.id == this.id &&
          other.name == this.name &&
          other.docCount == this.docCount);
}

class $ScannedGroupDocCountView
    extends ViewInfo<$ScannedGroupDocCountView, ScannedGroupDocCountData>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$AppDatabase attachedDatabase;
  $ScannedGroupDocCountView(this.attachedDatabase, [this._alias]);
  $ScannedDocumentsGroupsTable get groups =>
      attachedDatabase.scannedDocumentsGroups.createAlias('t0');
  $ScannedDocumentsTable get scannedDocuments =>
      attachedDatabase.scannedDocuments.createAlias('t1');
  @override
  List<GeneratedColumn> get $columns => [id, name, docCount];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'scanned_group_doc_count';
  @override
  Map<SqlDialect, String>? get createViewStatements => null;
  @override
  $ScannedGroupDocCountView get asDslTable => this;
  @override
  ScannedGroupDocCountData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedGroupDocCountData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      docCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}doc_count'],
      ),
    );
  }

  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    generatedAs: GeneratedAs(groups.id, false),
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    generatedAs: GeneratedAs(groups.name, false),
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<int> docCount = GeneratedColumn<int>(
    'doc_count',
    aliasedName,
    true,
    generatedAs: GeneratedAs(BaseAggregate(scannedDocuments.id).count(), false),
    type: DriftSqlType.int,
  );
  @override
  $ScannedGroupDocCountView createAlias(String alias) {
    return $ScannedGroupDocCountView(attachedDatabase, alias);
  }

  @override
  Query? get query =>
      (attachedDatabase.selectOnly(groups)..addColumns($columns)).join([
        leftOuterJoin(
          scannedDocuments,
          scannedDocuments.groupId.equalsExp(groups.id),
        ),
      ])..groupBy([groups.id, groups.name]);
  @override
  Set<String> get readTables => const {
    'scanned_documents_groups',
    'scanned_documents',
  };
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScannedDocumentsGroupsTable scannedDocumentsGroups =
      $ScannedDocumentsGroupsTable(this);
  late final $ScannedDocumentsTable scannedDocuments = $ScannedDocumentsTable(
    this,
  );
  late final $ScannedDocumentsViewView scannedDocumentsView =
      $ScannedDocumentsViewView(this);
  late final $ScannedGroupDocCountView scannedGroupDocCount =
      $ScannedGroupDocCountView(this);
  late final ScannedDocumentsDao scannedDocumentsDao = ScannedDocumentsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scannedDocumentsGroups,
    scannedDocuments,
    scannedDocumentsView,
    scannedGroupDocCount,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scanned_documents_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scanned_documents', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ScannedDocumentsGroupsTableCreateCompanionBuilder =
    ScannedDocumentsGroupsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> id,
      required String name,
      required String relativeFolderPath,
      required String absoluteFolderPath,
      Value<int> rowid,
    });
typedef $$ScannedDocumentsGroupsTableUpdateCompanionBuilder =
    ScannedDocumentsGroupsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> id,
      Value<String> name,
      Value<String> relativeFolderPath,
      Value<String> absoluteFolderPath,
      Value<int> rowid,
    });

final class $$ScannedDocumentsGroupsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScannedDocumentsGroupsTable,
          ScannedDocumentsGroup
        > {
  $$ScannedDocumentsGroupsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ScannedDocumentsTable, List<ScannedDocument>>
  _scannedDocumentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scannedDocuments,
    aliasName: 'scanned_documents_groups__id__scanned_documents__group_id',
  );

  $$ScannedDocumentsTableProcessedTableManager get scannedDocumentsRefs {
    final manager = $$ScannedDocumentsTableTableManager(
      $_db,
      $_db.scannedDocuments,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scannedDocumentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScannedDocumentsGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $ScannedDocumentsGroupsTable> {
  $$ScannedDocumentsGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativeFolderPath => $composableBuilder(
    column: $table.relativeFolderPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get absoluteFolderPath => $composableBuilder(
    column: $table.absoluteFolderPath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scannedDocumentsRefs(
    Expression<bool> Function($$ScannedDocumentsTableFilterComposer f) f,
  ) {
    final $$ScannedDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scannedDocuments,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScannedDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.scannedDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScannedDocumentsGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScannedDocumentsGroupsTable> {
  $$ScannedDocumentsGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativeFolderPath => $composableBuilder(
    column: $table.relativeFolderPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get absoluteFolderPath => $composableBuilder(
    column: $table.absoluteFolderPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScannedDocumentsGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScannedDocumentsGroupsTable> {
  $$ScannedDocumentsGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get relativeFolderPath => $composableBuilder(
    column: $table.relativeFolderPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get absoluteFolderPath => $composableBuilder(
    column: $table.absoluteFolderPath,
    builder: (column) => column,
  );

  Expression<T> scannedDocumentsRefs<T extends Object>(
    Expression<T> Function($$ScannedDocumentsTableAnnotationComposer a) f,
  ) {
    final $$ScannedDocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scannedDocuments,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScannedDocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.scannedDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScannedDocumentsGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScannedDocumentsGroupsTable,
          ScannedDocumentsGroup,
          $$ScannedDocumentsGroupsTableFilterComposer,
          $$ScannedDocumentsGroupsTableOrderingComposer,
          $$ScannedDocumentsGroupsTableAnnotationComposer,
          $$ScannedDocumentsGroupsTableCreateCompanionBuilder,
          $$ScannedDocumentsGroupsTableUpdateCompanionBuilder,
          (ScannedDocumentsGroup, $$ScannedDocumentsGroupsTableReferences),
          ScannedDocumentsGroup,
          PrefetchHooks Function({bool scannedDocumentsRefs})
        > {
  $$ScannedDocumentsGroupsTableTableManager(
    _$AppDatabase db,
    $ScannedDocumentsGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScannedDocumentsGroupsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScannedDocumentsGroupsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScannedDocumentsGroupsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> relativeFolderPath = const Value.absent(),
                Value<String> absoluteFolderPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsGroupsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                relativeFolderPath: relativeFolderPath,
                absoluteFolderPath: absoluteFolderPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                required String name,
                required String relativeFolderPath,
                required String absoluteFolderPath,
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsGroupsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                relativeFolderPath: relativeFolderPath,
                absoluteFolderPath: absoluteFolderPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ScannedDocumentsGroupsTable,
                    ScannedDocumentsGroup
                  >(table),
                  $$ScannedDocumentsGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scannedDocumentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (scannedDocumentsRefs) db.scannedDocuments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scannedDocumentsRefs)
                    await $_getPrefetchedDataByColumns<
                      ScannedDocumentsGroup,
                      $ScannedDocumentsGroupsTable,
                      ScannedDocument,
                      $ScannedDocumentsTable
                    >(
                      currentTable: table,
                      referencedTable: $$ScannedDocumentsGroupsTableReferences
                          ._scannedDocumentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ScannedDocumentsGroupsTableReferences(
                            db,
                            table,
                            p0,
                          ).scannedDocumentsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'group_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScannedDocumentsGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScannedDocumentsGroupsTable,
      ScannedDocumentsGroup,
      $$ScannedDocumentsGroupsTableFilterComposer,
      $$ScannedDocumentsGroupsTableOrderingComposer,
      $$ScannedDocumentsGroupsTableAnnotationComposer,
      $$ScannedDocumentsGroupsTableCreateCompanionBuilder,
      $$ScannedDocumentsGroupsTableUpdateCompanionBuilder,
      (ScannedDocumentsGroup, $$ScannedDocumentsGroupsTableReferences),
      ScannedDocumentsGroup,
      PrefetchHooks Function({bool scannedDocumentsRefs})
    >;
typedef $$ScannedDocumentsTableCreateCompanionBuilder =
    ScannedDocumentsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> id,
      required String groupId,
      required String name,
      required String relativeImagePath,
      required String absoluteImagePath,
      Value<int> rowid,
    });
typedef $$ScannedDocumentsTableUpdateCompanionBuilder =
    ScannedDocumentsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> id,
      Value<String> groupId,
      Value<String> name,
      Value<String> relativeImagePath,
      Value<String> absoluteImagePath,
      Value<int> rowid,
    });

final class $$ScannedDocumentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ScannedDocumentsTable, ScannedDocument> {
  $$ScannedDocumentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScannedDocumentsGroupsTable _groupIdTable(_$AppDatabase db) => db
      .scannedDocumentsGroups
      .createAlias('scanned_documents__group_id__scanned_documents_groups__id');

  $$ScannedDocumentsGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$ScannedDocumentsGroupsTableTableManager(
      $_db,
      $_db.scannedDocumentsGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScannedDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $ScannedDocumentsTable> {
  $$ScannedDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativeImagePath => $composableBuilder(
    column: $table.relativeImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get absoluteImagePath => $composableBuilder(
    column: $table.absoluteImagePath,
    builder: (column) => ColumnFilters(column),
  );

  $$ScannedDocumentsGroupsTableFilterComposer get groupId {
    final $$ScannedDocumentsGroupsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.scannedDocumentsGroups,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentsGroupsTableFilterComposer(
                $db: $db,
                $table: $db.scannedDocumentsGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScannedDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScannedDocumentsTable> {
  $$ScannedDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativeImagePath => $composableBuilder(
    column: $table.relativeImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get absoluteImagePath => $composableBuilder(
    column: $table.absoluteImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScannedDocumentsGroupsTableOrderingComposer get groupId {
    final $$ScannedDocumentsGroupsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.scannedDocumentsGroups,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentsGroupsTableOrderingComposer(
                $db: $db,
                $table: $db.scannedDocumentsGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScannedDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScannedDocumentsTable> {
  $$ScannedDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get relativeImagePath => $composableBuilder(
    column: $table.relativeImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get absoluteImagePath => $composableBuilder(
    column: $table.absoluteImagePath,
    builder: (column) => column,
  );

  $$ScannedDocumentsGroupsTableAnnotationComposer get groupId {
    final $$ScannedDocumentsGroupsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.scannedDocumentsGroups,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentsGroupsTableAnnotationComposer(
                $db: $db,
                $table: $db.scannedDocumentsGroups,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScannedDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScannedDocumentsTable,
          ScannedDocument,
          $$ScannedDocumentsTableFilterComposer,
          $$ScannedDocumentsTableOrderingComposer,
          $$ScannedDocumentsTableAnnotationComposer,
          $$ScannedDocumentsTableCreateCompanionBuilder,
          $$ScannedDocumentsTableUpdateCompanionBuilder,
          (ScannedDocument, $$ScannedDocumentsTableReferences),
          ScannedDocument,
          PrefetchHooks Function({bool groupId})
        > {
  $$ScannedDocumentsTableTableManager(
    _$AppDatabase db,
    $ScannedDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScannedDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScannedDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScannedDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> relativeImagePath = const Value.absent(),
                Value<String> absoluteImagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                groupId: groupId,
                name: name,
                relativeImagePath: relativeImagePath,
                absoluteImagePath: absoluteImagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                required String groupId,
                required String name,
                required String relativeImagePath,
                required String absoluteImagePath,
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                groupId: groupId,
                name: name,
                relativeImagePath: relativeImagePath,
                absoluteImagePath: absoluteImagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScannedDocumentsTable, ScannedDocument>(table),
                  $$ScannedDocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
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
                    if (groupId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.groupId,
                        referencedTable: $$ScannedDocumentsTableReferences
                            ._groupIdTable(db),
                        referencedColumn: $$ScannedDocumentsTableReferences
                            ._groupIdTable(db)
                            .id,
                      ) as T;
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

typedef $$ScannedDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScannedDocumentsTable,
      ScannedDocument,
      $$ScannedDocumentsTableFilterComposer,
      $$ScannedDocumentsTableOrderingComposer,
      $$ScannedDocumentsTableAnnotationComposer,
      $$ScannedDocumentsTableCreateCompanionBuilder,
      $$ScannedDocumentsTableUpdateCompanionBuilder,
      (ScannedDocument, $$ScannedDocumentsTableReferences),
      ScannedDocument,
      PrefetchHooks Function({bool groupId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScannedDocumentsGroupsTableTableManager get scannedDocumentsGroups =>
      $$ScannedDocumentsGroupsTableTableManager(
        _db,
        _db.scannedDocumentsGroups,
      );
  $$ScannedDocumentsTableTableManager get scannedDocuments =>
      $$ScannedDocumentsTableTableManager(_db, _db.scannedDocuments);
}
