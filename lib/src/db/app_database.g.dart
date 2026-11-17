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
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _absolutePathMeta = const VerificationMeta(
    'absolutePath',
  );
  @override
  late final GeneratedColumn<String> absolutePath = GeneratedColumn<String>(
    'absolute_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    relativePath,
    absolutePath,
    id,
    name,
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
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('absolute_path')) {
      context.handle(
        _absolutePathMeta,
        absolutePath.isAcceptableOrUnknown(
          data['absolute_path']!,
          _absolutePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_absolutePathMeta);
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
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      absolutePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}absolute_path'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
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
  final String relativePath;
  final String absolutePath;
  final String id;
  final String name;
  const ScannedDocumentsGroup({
    required this.createdAt,
    this.updatedAt,
    required this.relativePath,
    required this.absolutePath,
    required this.id,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['relative_path'] = Variable<String>(relativePath);
    map['absolute_path'] = Variable<String>(absolutePath);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ScannedDocumentsGroupsCompanion toCompanion(bool nullToAbsent) {
    return ScannedDocumentsGroupsCompanion(
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      relativePath: Value(relativePath),
      absolutePath: Value(absolutePath),
      id: Value(id),
      name: Value(name),
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
      relativePath: serializer.fromJson<String>(json['relativePath']),
      absolutePath: serializer.fromJson<String>(json['absolutePath']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'relativePath': serializer.toJson<String>(relativePath),
      'absolutePath': serializer.toJson<String>(absolutePath),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  ScannedDocumentsGroup copyWith({
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? relativePath,
    String? absolutePath,
    String? id,
    String? name,
  }) => ScannedDocumentsGroup(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    relativePath: relativePath ?? this.relativePath,
    absolutePath: absolutePath ?? this.absolutePath,
    id: id ?? this.id,
    name: name ?? this.name,
  );
  ScannedDocumentsGroup copyWithCompanion(
    ScannedDocumentsGroupsCompanion data,
  ) {
    return ScannedDocumentsGroup(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      absolutePath: data.absolutePath.present
          ? data.absolutePath.value
          : this.absolutePath,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocumentsGroup(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('relativePath: $relativePath, ')
          ..write('absolutePath: $absolutePath, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(createdAt, updatedAt, relativePath, absolutePath, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedDocumentsGroup &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.relativePath == this.relativePath &&
          other.absolutePath == this.absolutePath &&
          other.id == this.id &&
          other.name == this.name);
}

class ScannedDocumentsGroupsCompanion
    extends UpdateCompanion<ScannedDocumentsGroup> {
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> relativePath;
  final Value<String> absolutePath;
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const ScannedDocumentsGroupsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.absolutePath = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScannedDocumentsGroupsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String relativePath,
    required String absolutePath,
    this.id = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : relativePath = Value(relativePath),
       absolutePath = Value(absolutePath),
       name = Value(name);
  static Insertable<ScannedDocumentsGroup> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? relativePath,
    Expression<String>? absolutePath,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (relativePath != null) 'relative_path': relativePath,
      if (absolutePath != null) 'absolute_path': absolutePath,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScannedDocumentsGroupsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? relativePath,
    Value<String>? absolutePath,
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return ScannedDocumentsGroupsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relativePath: relativePath ?? this.relativePath,
      absolutePath: absolutePath ?? this.absolutePath,
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (absolutePath.present) {
      map['absolute_path'] = Variable<String>(absolutePath.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
          ..write('relativePath: $relativePath, ')
          ..write('absolutePath: $absolutePath, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
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
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _absolutePathMeta = const VerificationMeta(
    'absolutePath',
  );
  @override
  late final GeneratedColumn<String> absolutePath = GeneratedColumn<String>(
    'absolute_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extMeta = const VerificationMeta('ext');
  @override
  late final GeneratedColumn<String> ext = GeneratedColumn<String>(
    'ext',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    relativePath,
    absolutePath,
    ext,
    id,
    groupId,
    name,
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
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('absolute_path')) {
      context.handle(
        _absolutePathMeta,
        absolutePath.isAcceptableOrUnknown(
          data['absolute_path']!,
          _absolutePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_absolutePathMeta);
    }
    if (data.containsKey('ext')) {
      context.handle(
        _extMeta,
        ext.isAcceptableOrUnknown(data['ext']!, _extMeta),
      );
    } else if (isInserting) {
      context.missing(_extMeta);
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
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      absolutePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}absolute_path'],
      )!,
      ext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ext'],
      )!,
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
  final String relativePath;
  final String absolutePath;
  final String ext;
  final String id;
  final String groupId;
  final String name;
  const ScannedDocument({
    required this.createdAt,
    this.updatedAt,
    required this.relativePath,
    required this.absolutePath,
    required this.ext,
    required this.id,
    required this.groupId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['relative_path'] = Variable<String>(relativePath);
    map['absolute_path'] = Variable<String>(absolutePath);
    map['ext'] = Variable<String>(ext);
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['name'] = Variable<String>(name);
    return map;
  }

  ScannedDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ScannedDocumentsCompanion(
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      relativePath: Value(relativePath),
      absolutePath: Value(absolutePath),
      ext: Value(ext),
      id: Value(id),
      groupId: Value(groupId),
      name: Value(name),
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
      relativePath: serializer.fromJson<String>(json['relativePath']),
      absolutePath: serializer.fromJson<String>(json['absolutePath']),
      ext: serializer.fromJson<String>(json['ext']),
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'relativePath': serializer.toJson<String>(relativePath),
      'absolutePath': serializer.toJson<String>(absolutePath),
      'ext': serializer.toJson<String>(ext),
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'name': serializer.toJson<String>(name),
    };
  }

  ScannedDocument copyWith({
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? relativePath,
    String? absolutePath,
    String? ext,
    String? id,
    String? groupId,
    String? name,
  }) => ScannedDocument(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    relativePath: relativePath ?? this.relativePath,
    absolutePath: absolutePath ?? this.absolutePath,
    ext: ext ?? this.ext,
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    name: name ?? this.name,
  );
  ScannedDocument copyWithCompanion(ScannedDocumentsCompanion data) {
    return ScannedDocument(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      absolutePath: data.absolutePath.present
          ? data.absolutePath.value
          : this.absolutePath,
      ext: data.ext.present ? data.ext.value : this.ext,
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocument(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('relativePath: $relativePath, ')
          ..write('absolutePath: $absolutePath, ')
          ..write('ext: $ext, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    relativePath,
    absolutePath,
    ext,
    id,
    groupId,
    name,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedDocument &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.relativePath == this.relativePath &&
          other.absolutePath == this.absolutePath &&
          other.ext == this.ext &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name);
}

class ScannedDocumentsCompanion extends UpdateCompanion<ScannedDocument> {
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> relativePath;
  final Value<String> absolutePath;
  final Value<String> ext;
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> name;
  final Value<int> rowid;
  const ScannedDocumentsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.absolutePath = const Value.absent(),
    this.ext = const Value.absent(),
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScannedDocumentsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String relativePath,
    required String absolutePath,
    required String ext,
    this.id = const Value.absent(),
    required String groupId,
    required String name,
    this.rowid = const Value.absent(),
  }) : relativePath = Value(relativePath),
       absolutePath = Value(absolutePath),
       ext = Value(ext),
       groupId = Value(groupId),
       name = Value(name);
  static Insertable<ScannedDocument> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? relativePath,
    Expression<String>? absolutePath,
    Expression<String>? ext,
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (relativePath != null) 'relative_path': relativePath,
      if (absolutePath != null) 'absolute_path': absolutePath,
      if (ext != null) 'ext': ext,
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScannedDocumentsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? relativePath,
    Value<String>? absolutePath,
    Value<String>? ext,
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return ScannedDocumentsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relativePath: relativePath ?? this.relativePath,
      absolutePath: absolutePath ?? this.absolutePath,
      ext: ext ?? this.ext,
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
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
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (absolutePath.present) {
      map['absolute_path'] = Variable<String>(absolutePath.value);
    }
    if (ext.present) {
      map['ext'] = Variable<String>(ext.value);
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
          ..write('relativePath: $relativePath, ')
          ..write('absolutePath: $absolutePath, ')
          ..write('ext: $ext, ')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
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
      required String relativePath,
      required String absolutePath,
      Value<String> id,
      required String name,
      Value<int> rowid,
    });
typedef $$ScannedDocumentsGroupsTableUpdateCompanionBuilder =
    ScannedDocumentsGroupsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> relativePath,
      Value<String> absolutePath,
      Value<String> id,
      Value<String> name,
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

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get absolutePath => $composableBuilder(
    column: $table.absolutePath,
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

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get absolutePath => $composableBuilder(
    column: $table.absolutePath,
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

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get absolutePath => $composableBuilder(
    column: $table.absolutePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

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
                Value<String> relativePath = const Value.absent(),
                Value<String> absolutePath = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsGroupsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                relativePath: relativePath,
                absolutePath: absolutePath,
                id: id,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String relativePath,
                required String absolutePath,
                Value<String> id = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsGroupsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                relativePath: relativePath,
                absolutePath: absolutePath,
                id: id,
                name: name,
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
      required String relativePath,
      required String absolutePath,
      required String ext,
      Value<String> id,
      required String groupId,
      required String name,
      Value<int> rowid,
    });
typedef $$ScannedDocumentsTableUpdateCompanionBuilder =
    ScannedDocumentsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> relativePath,
      Value<String> absolutePath,
      Value<String> ext,
      Value<String> id,
      Value<String> groupId,
      Value<String> name,
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

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get absolutePath => $composableBuilder(
    column: $table.absolutePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ext => $composableBuilder(
    column: $table.ext,
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

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get absolutePath => $composableBuilder(
    column: $table.absolutePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ext => $composableBuilder(
    column: $table.ext,
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

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get absolutePath => $composableBuilder(
    column: $table.absolutePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ext =>
      $composableBuilder(column: $table.ext, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

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
                Value<String> relativePath = const Value.absent(),
                Value<String> absolutePath = const Value.absent(),
                Value<String> ext = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                relativePath: relativePath,
                absolutePath: absolutePath,
                ext: ext,
                id: id,
                groupId: groupId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String relativePath,
                required String absolutePath,
                required String ext,
                Value<String> id = const Value.absent(),
                required String groupId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                relativePath: relativePath,
                absolutePath: absolutePath,
                ext: ext,
                id: id,
                groupId: groupId,
                name: name,
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
