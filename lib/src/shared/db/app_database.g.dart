// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ScannedDocumentGroupsDbModelTable extends ScannedDocumentGroupsDbModel
    with
        TableInfo<
          $ScannedDocumentGroupsDbModelTable,
          ScannedDocumentGroupsDbModelData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannedDocumentGroupsDbModelTable(this.attachedDatabase, [this._alias]);
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
    id,
    relativePath,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scanned_document_groups_db_model';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScannedDocumentGroupsDbModelData> instance, {
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
  ScannedDocumentGroupsDbModelData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedDocumentGroupsDbModelData(
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
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ScannedDocumentGroupsDbModelTable createAlias(String alias) {
    return $ScannedDocumentGroupsDbModelTable(attachedDatabase, alias);
  }
}

class ScannedDocumentGroupsDbModelData extends DataClass
    implements Insertable<ScannedDocumentGroupsDbModelData> {
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String id;
  final String relativePath;
  final String name;
  const ScannedDocumentGroupsDbModelData({
    required this.createdAt,
    this.updatedAt,
    required this.id,
    required this.relativePath,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['id'] = Variable<String>(id);
    map['relative_path'] = Variable<String>(relativePath);
    map['name'] = Variable<String>(name);
    return map;
  }

  ScannedDocumentGroupsDbModelCompanion toCompanion(bool nullToAbsent) {
    return ScannedDocumentGroupsDbModelCompanion(
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      id: Value(id),
      relativePath: Value(relativePath),
      name: Value(name),
    );
  }

  factory ScannedDocumentGroupsDbModelData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedDocumentGroupsDbModelData(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'id': serializer.toJson<String>(id),
      'relativePath': serializer.toJson<String>(relativePath),
      'name': serializer.toJson<String>(name),
    };
  }

  ScannedDocumentGroupsDbModelData copyWith({
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? id,
    String? relativePath,
    String? name,
  }) => ScannedDocumentGroupsDbModelData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    id: id ?? this.id,
    relativePath: relativePath ?? this.relativePath,
    name: name ?? this.name,
  );
  ScannedDocumentGroupsDbModelData copyWithCompanion(
    ScannedDocumentGroupsDbModelCompanion data,
  ) {
    return ScannedDocumentGroupsDbModelData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocumentGroupsDbModelData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('relativePath: $relativePath, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, id, relativePath, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedDocumentGroupsDbModelData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.relativePath == this.relativePath &&
          other.name == this.name);
}

class ScannedDocumentGroupsDbModelCompanion
    extends UpdateCompanion<ScannedDocumentGroupsDbModelData> {
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> id;
  final Value<String> relativePath;
  final Value<String> name;
  final Value<int> rowid;
  const ScannedDocumentGroupsDbModelCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScannedDocumentGroupsDbModelCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String relativePath,
    required String name,
    this.rowid = const Value.absent(),
  }) : relativePath = Value(relativePath),
       name = Value(name);
  static Insertable<ScannedDocumentGroupsDbModelData> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? relativePath,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (relativePath != null) 'relative_path': relativePath,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScannedDocumentGroupsDbModelCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? id,
    Value<String>? relativePath,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return ScannedDocumentGroupsDbModelCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      relativePath: relativePath ?? this.relativePath,
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
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
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
    return (StringBuffer('ScannedDocumentGroupsDbModelCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('relativePath: $relativePath, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScannedDocumentsDbModelTable extends ScannedDocumentsDbModel
    with TableInfo<$ScannedDocumentsDbModelTable, ScannedDocumentsDbModelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannedDocumentsDbModelTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES scanned_document_groups_db_model (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    relativePath,
    id,
    name,
    ext,
    groupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scanned_documents_db_model';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScannedDocumentsDbModelData> instance, {
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
    if (data.containsKey('ext')) {
      context.handle(
        _extMeta,
        ext.isAcceptableOrUnknown(data['ext']!, _extMeta),
      );
    } else if (isInserting) {
      context.missing(_extMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScannedDocumentsDbModelData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedDocumentsDbModelData(
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ext'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
    );
  }

  @override
  $ScannedDocumentsDbModelTable createAlias(String alias) {
    return $ScannedDocumentsDbModelTable(attachedDatabase, alias);
  }
}

class ScannedDocumentsDbModelData extends DataClass
    implements Insertable<ScannedDocumentsDbModelData> {
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String relativePath;
  final String id;
  final String name;
  final String ext;
  final String groupId;
  const ScannedDocumentsDbModelData({
    required this.createdAt,
    this.updatedAt,
    required this.relativePath,
    required this.id,
    required this.name,
    required this.ext,
    required this.groupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['relative_path'] = Variable<String>(relativePath);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['ext'] = Variable<String>(ext);
    map['group_id'] = Variable<String>(groupId);
    return map;
  }

  ScannedDocumentsDbModelCompanion toCompanion(bool nullToAbsent) {
    return ScannedDocumentsDbModelCompanion(
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      relativePath: Value(relativePath),
      id: Value(id),
      name: Value(name),
      ext: Value(ext),
      groupId: Value(groupId),
    );
  }

  factory ScannedDocumentsDbModelData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedDocumentsDbModelData(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      ext: serializer.fromJson<String>(json['ext']),
      groupId: serializer.fromJson<String>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'relativePath': serializer.toJson<String>(relativePath),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'ext': serializer.toJson<String>(ext),
      'groupId': serializer.toJson<String>(groupId),
    };
  }

  ScannedDocumentsDbModelData copyWith({
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? relativePath,
    String? id,
    String? name,
    String? ext,
    String? groupId,
  }) => ScannedDocumentsDbModelData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    relativePath: relativePath ?? this.relativePath,
    id: id ?? this.id,
    name: name ?? this.name,
    ext: ext ?? this.ext,
    groupId: groupId ?? this.groupId,
  );
  ScannedDocumentsDbModelData copyWithCompanion(
    ScannedDocumentsDbModelCompanion data,
  ) {
    return ScannedDocumentsDbModelData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      ext: data.ext.present ? data.ext.value : this.ext,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocumentsDbModelData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('relativePath: $relativePath, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ext: $ext, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(createdAt, updatedAt, relativePath, id, name, ext, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedDocumentsDbModelData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.relativePath == this.relativePath &&
          other.id == this.id &&
          other.name == this.name &&
          other.ext == this.ext &&
          other.groupId == this.groupId);
}

class ScannedDocumentsDbModelCompanion
    extends UpdateCompanion<ScannedDocumentsDbModelData> {
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> relativePath;
  final Value<String> id;
  final Value<String> name;
  final Value<String> ext;
  final Value<String> groupId;
  final Value<int> rowid;
  const ScannedDocumentsDbModelCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.ext = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScannedDocumentsDbModelCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String relativePath,
    this.id = const Value.absent(),
    required String name,
    required String ext,
    required String groupId,
    this.rowid = const Value.absent(),
  }) : relativePath = Value(relativePath),
       name = Value(name),
       ext = Value(ext),
       groupId = Value(groupId);
  static Insertable<ScannedDocumentsDbModelData> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? relativePath,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? ext,
    Expression<String>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (relativePath != null) 'relative_path': relativePath,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (ext != null) 'ext': ext,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScannedDocumentsDbModelCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? relativePath,
    Value<String>? id,
    Value<String>? name,
    Value<String>? ext,
    Value<String>? groupId,
    Value<int>? rowid,
  }) {
    return ScannedDocumentsDbModelCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relativePath: relativePath ?? this.relativePath,
      id: id ?? this.id,
      name: name ?? this.name,
      ext: ext ?? this.ext,
      groupId: groupId ?? this.groupId,
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
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ext.present) {
      map['ext'] = Variable<String>(ext.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocumentsDbModelCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('relativePath: $relativePath, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ext: $ext, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScannedDocumentTranscriptionsDbModelTable
    extends ScannedDocumentTranscriptionsDbModel
    with
        TableInfo<
          $ScannedDocumentTranscriptionsDbModelTable,
          ScannedDocumentTranscriptionsDbModelData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannedDocumentTranscriptionsDbModelTable(
    this.attachedDatabase, [
    this._alias,
  ]);
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
  static const VerificationMeta _docIdMeta = const VerificationMeta('docId');
  @override
  late final GeneratedColumn<String> docId = GeneratedColumn<String>(
    'doc_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES scanned_documents_db_model (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _timeMsToTranscribeMeta =
      const VerificationMeta('timeMsToTranscribe');
  @override
  late final GeneratedColumn<int> timeMsToTranscribe = GeneratedColumn<int>(
    'time_ms_to_transcribe',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _timeMsToReadMeta = const VerificationMeta(
    'timeMsToRead',
  );
  @override
  late final GeneratedColumn<int> timeMsToRead = GeneratedColumn<int>(
    'time_ms_to_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    relativePath,
    ext,
    id,
    docId,
    timeMsToTranscribe,
    timeMsToRead,
    wordCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scanned_document_transcriptions_db_model';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScannedDocumentTranscriptionsDbModelData> instance, {
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
    if (data.containsKey('doc_id')) {
      context.handle(
        _docIdMeta,
        docId.isAcceptableOrUnknown(data['doc_id']!, _docIdMeta),
      );
    } else if (isInserting) {
      context.missing(_docIdMeta);
    }
    if (data.containsKey('time_ms_to_transcribe')) {
      context.handle(
        _timeMsToTranscribeMeta,
        timeMsToTranscribe.isAcceptableOrUnknown(
          data['time_ms_to_transcribe']!,
          _timeMsToTranscribeMeta,
        ),
      );
    }
    if (data.containsKey('time_ms_to_read')) {
      context.handle(
        _timeMsToReadMeta,
        timeMsToRead.isAcceptableOrUnknown(
          data['time_ms_to_read']!,
          _timeMsToReadMeta,
        ),
      );
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScannedDocumentTranscriptionsDbModelData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedDocumentTranscriptionsDbModelData(
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
      ext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ext'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      docId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_id'],
      )!,
      timeMsToTranscribe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_ms_to_transcribe'],
      )!,
      timeMsToRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_ms_to_read'],
      )!,
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
    );
  }

  @override
  $ScannedDocumentTranscriptionsDbModelTable createAlias(String alias) {
    return $ScannedDocumentTranscriptionsDbModelTable(attachedDatabase, alias);
  }
}

class ScannedDocumentTranscriptionsDbModelData extends DataClass
    implements Insertable<ScannedDocumentTranscriptionsDbModelData> {
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String relativePath;
  final String ext;
  final String id;
  final String docId;
  final int timeMsToTranscribe;
  final int timeMsToRead;
  final int wordCount;
  const ScannedDocumentTranscriptionsDbModelData({
    required this.createdAt,
    this.updatedAt,
    required this.relativePath,
    required this.ext,
    required this.id,
    required this.docId,
    required this.timeMsToTranscribe,
    required this.timeMsToRead,
    required this.wordCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['relative_path'] = Variable<String>(relativePath);
    map['ext'] = Variable<String>(ext);
    map['id'] = Variable<String>(id);
    map['doc_id'] = Variable<String>(docId);
    map['time_ms_to_transcribe'] = Variable<int>(timeMsToTranscribe);
    map['time_ms_to_read'] = Variable<int>(timeMsToRead);
    map['word_count'] = Variable<int>(wordCount);
    return map;
  }

  ScannedDocumentTranscriptionsDbModelCompanion toCompanion(bool nullToAbsent) {
    return ScannedDocumentTranscriptionsDbModelCompanion(
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      relativePath: Value(relativePath),
      ext: Value(ext),
      id: Value(id),
      docId: Value(docId),
      timeMsToTranscribe: Value(timeMsToTranscribe),
      timeMsToRead: Value(timeMsToRead),
      wordCount: Value(wordCount),
    );
  }

  factory ScannedDocumentTranscriptionsDbModelData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedDocumentTranscriptionsDbModelData(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      ext: serializer.fromJson<String>(json['ext']),
      id: serializer.fromJson<String>(json['id']),
      docId: serializer.fromJson<String>(json['docId']),
      timeMsToTranscribe: serializer.fromJson<int>(json['timeMsToTranscribe']),
      timeMsToRead: serializer.fromJson<int>(json['timeMsToRead']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'relativePath': serializer.toJson<String>(relativePath),
      'ext': serializer.toJson<String>(ext),
      'id': serializer.toJson<String>(id),
      'docId': serializer.toJson<String>(docId),
      'timeMsToTranscribe': serializer.toJson<int>(timeMsToTranscribe),
      'timeMsToRead': serializer.toJson<int>(timeMsToRead),
      'wordCount': serializer.toJson<int>(wordCount),
    };
  }

  ScannedDocumentTranscriptionsDbModelData copyWith({
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? relativePath,
    String? ext,
    String? id,
    String? docId,
    int? timeMsToTranscribe,
    int? timeMsToRead,
    int? wordCount,
  }) => ScannedDocumentTranscriptionsDbModelData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    relativePath: relativePath ?? this.relativePath,
    ext: ext ?? this.ext,
    id: id ?? this.id,
    docId: docId ?? this.docId,
    timeMsToTranscribe: timeMsToTranscribe ?? this.timeMsToTranscribe,
    timeMsToRead: timeMsToRead ?? this.timeMsToRead,
    wordCount: wordCount ?? this.wordCount,
  );
  ScannedDocumentTranscriptionsDbModelData copyWithCompanion(
    ScannedDocumentTranscriptionsDbModelCompanion data,
  ) {
    return ScannedDocumentTranscriptionsDbModelData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      ext: data.ext.present ? data.ext.value : this.ext,
      id: data.id.present ? data.id.value : this.id,
      docId: data.docId.present ? data.docId.value : this.docId,
      timeMsToTranscribe: data.timeMsToTranscribe.present
          ? data.timeMsToTranscribe.value
          : this.timeMsToTranscribe,
      timeMsToRead: data.timeMsToRead.present
          ? data.timeMsToRead.value
          : this.timeMsToRead,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocumentTranscriptionsDbModelData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('relativePath: $relativePath, ')
          ..write('ext: $ext, ')
          ..write('id: $id, ')
          ..write('docId: $docId, ')
          ..write('timeMsToTranscribe: $timeMsToTranscribe, ')
          ..write('timeMsToRead: $timeMsToRead, ')
          ..write('wordCount: $wordCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    relativePath,
    ext,
    id,
    docId,
    timeMsToTranscribe,
    timeMsToRead,
    wordCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedDocumentTranscriptionsDbModelData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.relativePath == this.relativePath &&
          other.ext == this.ext &&
          other.id == this.id &&
          other.docId == this.docId &&
          other.timeMsToTranscribe == this.timeMsToTranscribe &&
          other.timeMsToRead == this.timeMsToRead &&
          other.wordCount == this.wordCount);
}

class ScannedDocumentTranscriptionsDbModelCompanion
    extends UpdateCompanion<ScannedDocumentTranscriptionsDbModelData> {
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> relativePath;
  final Value<String> ext;
  final Value<String> id;
  final Value<String> docId;
  final Value<int> timeMsToTranscribe;
  final Value<int> timeMsToRead;
  final Value<int> wordCount;
  final Value<int> rowid;
  const ScannedDocumentTranscriptionsDbModelCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.ext = const Value.absent(),
    this.id = const Value.absent(),
    this.docId = const Value.absent(),
    this.timeMsToTranscribe = const Value.absent(),
    this.timeMsToRead = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScannedDocumentTranscriptionsDbModelCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String relativePath,
    required String ext,
    this.id = const Value.absent(),
    required String docId,
    this.timeMsToTranscribe = const Value.absent(),
    this.timeMsToRead = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : relativePath = Value(relativePath),
       ext = Value(ext),
       docId = Value(docId);
  static Insertable<ScannedDocumentTranscriptionsDbModelData> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? relativePath,
    Expression<String>? ext,
    Expression<String>? id,
    Expression<String>? docId,
    Expression<int>? timeMsToTranscribe,
    Expression<int>? timeMsToRead,
    Expression<int>? wordCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (relativePath != null) 'relative_path': relativePath,
      if (ext != null) 'ext': ext,
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
      if (timeMsToTranscribe != null)
        'time_ms_to_transcribe': timeMsToTranscribe,
      if (timeMsToRead != null) 'time_ms_to_read': timeMsToRead,
      if (wordCount != null) 'word_count': wordCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScannedDocumentTranscriptionsDbModelCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? relativePath,
    Value<String>? ext,
    Value<String>? id,
    Value<String>? docId,
    Value<int>? timeMsToTranscribe,
    Value<int>? timeMsToRead,
    Value<int>? wordCount,
    Value<int>? rowid,
  }) {
    return ScannedDocumentTranscriptionsDbModelCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relativePath: relativePath ?? this.relativePath,
      ext: ext ?? this.ext,
      id: id ?? this.id,
      docId: docId ?? this.docId,
      timeMsToTranscribe: timeMsToTranscribe ?? this.timeMsToTranscribe,
      timeMsToRead: timeMsToRead ?? this.timeMsToRead,
      wordCount: wordCount ?? this.wordCount,
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
    if (ext.present) {
      map['ext'] = Variable<String>(ext.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (docId.present) {
      map['doc_id'] = Variable<String>(docId.value);
    }
    if (timeMsToTranscribe.present) {
      map['time_ms_to_transcribe'] = Variable<int>(timeMsToTranscribe.value);
    }
    if (timeMsToRead.present) {
      map['time_ms_to_read'] = Variable<int>(timeMsToRead.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScannedDocumentTranscriptionsDbModelCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('relativePath: $relativePath, ')
          ..write('ext: $ext, ')
          ..write('id: $id, ')
          ..write('docId: $docId, ')
          ..write('timeMsToTranscribe: $timeMsToTranscribe, ')
          ..write('timeMsToRead: $timeMsToRead, ')
          ..write('wordCount: $wordCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobsDbModelTable extends JobsDbModel
    with TableInfo<$JobsDbModelTable, JobsDbModelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsDbModelTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _groupKeyMeta = const VerificationMeta(
    'groupKey',
  );
  @override
  late final GeneratedColumn<String> groupKey = GeneratedColumn<String>(
    'group_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemKeyMeta = const VerificationMeta(
    'itemKey',
  );
  @override
  late final GeneratedColumn<String> itemKey = GeneratedColumn<String>(
    'item_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<JobStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(JobStatus.queued.name),
      ).withConverter<JobStatus>($JobsDbModelTable.$converterstatus);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxAttemptsMeta = const VerificationMeta(
    'maxAttempts',
  );
  @override
  late final GeneratedColumn<int> maxAttempts = GeneratedColumn<int>(
    'max_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _runAfterMeta = const VerificationMeta(
    'runAfter',
  );
  @override
  late final GeneratedColumn<DateTime> runAfter = GeneratedColumn<DateTime>(
    'run_after',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heartbeatAtMeta = const VerificationMeta(
    'heartbeatAt',
  );
  @override
  late final GeneratedColumn<DateTime> heartbeatAt = GeneratedColumn<DateTime>(
    'heartbeat_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partialOutputMeta = const VerificationMeta(
    'partialOutput',
  );
  @override
  late final GeneratedColumn<String> partialOutput = GeneratedColumn<String>(
    'partial_output',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    groupKey,
    itemKey,
    payload,
    status,
    attempts,
    maxAttempts,
    runAfter,
    heartbeatAt,
    partialOutput,
    elapsedMs,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs_db_model';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobsDbModelData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('group_key')) {
      context.handle(
        _groupKeyMeta,
        groupKey.isAcceptableOrUnknown(data['group_key']!, _groupKeyMeta),
      );
    }
    if (data.containsKey('item_key')) {
      context.handle(
        _itemKeyMeta,
        itemKey.isAcceptableOrUnknown(data['item_key']!, _itemKeyMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('max_attempts')) {
      context.handle(
        _maxAttemptsMeta,
        maxAttempts.isAcceptableOrUnknown(
          data['max_attempts']!,
          _maxAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('run_after')) {
      context.handle(
        _runAfterMeta,
        runAfter.isAcceptableOrUnknown(data['run_after']!, _runAfterMeta),
      );
    } else if (isInserting) {
      context.missing(_runAfterMeta);
    }
    if (data.containsKey('heartbeat_at')) {
      context.handle(
        _heartbeatAtMeta,
        heartbeatAt.isAcceptableOrUnknown(
          data['heartbeat_at']!,
          _heartbeatAtMeta,
        ),
      );
    }
    if (data.containsKey('partial_output')) {
      context.handle(
        _partialOutputMeta,
        partialOutput.isAcceptableOrUnknown(
          data['partial_output']!,
          _partialOutputMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobsDbModelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobsDbModelData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      groupKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_key'],
      ),
      itemKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_key'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: $JobsDbModelTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      maxAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_attempts'],
      )!,
      runAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}run_after'],
      )!,
      heartbeatAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}heartbeat_at'],
      ),
      partialOutput: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partial_output'],
      ),
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $JobsDbModelTable createAlias(String alias) {
    return $JobsDbModelTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JobStatus, String, String> $converterstatus =
      const EnumNameConverter<JobStatus>(JobStatus.values);
}

class JobsDbModelData extends DataClass implements Insertable<JobsDbModelData> {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Optional logical bucket for batch cancellation (e.g., `groupId`).
  final String? groupKey;

  /// Optional deduplication / lookup key for the target item (e.g., `docId`).
  final String? itemKey;

  /// Serialized job input (e.g., JSON with `relativePath`, `docId`, `groupId`).
  final String payload;
  final JobStatus status;

  /// for DLQ
  final int attempts;
  final int maxAttempts;
  final DateTime runAfter;
  final DateTime? heartbeatAt;

  /// Checkpointed partial output (e.g., streamed OCR text for Qwen-VL prefill
  /// resumption after an interruption or app restart).
  final String? partialOutput;

  /// Cumulative active execution time in milliseconds across attempts.
  final int elapsedMs;
  final String? lastError;
  const JobsDbModelData({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    this.groupKey,
    this.itemKey,
    required this.payload,
    required this.status,
    required this.attempts,
    required this.maxAttempts,
    required this.runAfter,
    this.heartbeatAt,
    this.partialOutput,
    required this.elapsedMs,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || groupKey != null) {
      map['group_key'] = Variable<String>(groupKey);
    }
    if (!nullToAbsent || itemKey != null) {
      map['item_key'] = Variable<String>(itemKey);
    }
    map['payload'] = Variable<String>(payload);
    {
      map['status'] = Variable<String>(
        $JobsDbModelTable.$converterstatus.toSql(status),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    map['max_attempts'] = Variable<int>(maxAttempts);
    map['run_after'] = Variable<DateTime>(runAfter);
    if (!nullToAbsent || heartbeatAt != null) {
      map['heartbeat_at'] = Variable<DateTime>(heartbeatAt);
    }
    if (!nullToAbsent || partialOutput != null) {
      map['partial_output'] = Variable<String>(partialOutput);
    }
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  JobsDbModelCompanion toCompanion(bool nullToAbsent) {
    return JobsDbModelCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      groupKey: groupKey == null && nullToAbsent
          ? const Value.absent()
          : Value(groupKey),
      itemKey: itemKey == null && nullToAbsent
          ? const Value.absent()
          : Value(itemKey),
      payload: Value(payload),
      status: Value(status),
      attempts: Value(attempts),
      maxAttempts: Value(maxAttempts),
      runAfter: Value(runAfter),
      heartbeatAt: heartbeatAt == null && nullToAbsent
          ? const Value.absent()
          : Value(heartbeatAt),
      partialOutput: partialOutput == null && nullToAbsent
          ? const Value.absent()
          : Value(partialOutput),
      elapsedMs: Value(elapsedMs),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory JobsDbModelData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobsDbModelData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      groupKey: serializer.fromJson<String?>(json['groupKey']),
      itemKey: serializer.fromJson<String?>(json['itemKey']),
      payload: serializer.fromJson<String>(json['payload']),
      status: $JobsDbModelTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      attempts: serializer.fromJson<int>(json['attempts']),
      maxAttempts: serializer.fromJson<int>(json['maxAttempts']),
      runAfter: serializer.fromJson<DateTime>(json['runAfter']),
      heartbeatAt: serializer.fromJson<DateTime?>(json['heartbeatAt']),
      partialOutput: serializer.fromJson<String?>(json['partialOutput']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'groupKey': serializer.toJson<String?>(groupKey),
      'itemKey': serializer.toJson<String?>(itemKey),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(
        $JobsDbModelTable.$converterstatus.toJson(status),
      ),
      'attempts': serializer.toJson<int>(attempts),
      'maxAttempts': serializer.toJson<int>(maxAttempts),
      'runAfter': serializer.toJson<DateTime>(runAfter),
      'heartbeatAt': serializer.toJson<DateTime?>(heartbeatAt),
      'partialOutput': serializer.toJson<String?>(partialOutput),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  JobsDbModelData copyWith({
    String? id,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> groupKey = const Value.absent(),
    Value<String?> itemKey = const Value.absent(),
    String? payload,
    JobStatus? status,
    int? attempts,
    int? maxAttempts,
    DateTime? runAfter,
    Value<DateTime?> heartbeatAt = const Value.absent(),
    Value<String?> partialOutput = const Value.absent(),
    int? elapsedMs,
    Value<String?> lastError = const Value.absent(),
  }) => JobsDbModelData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    groupKey: groupKey.present ? groupKey.value : this.groupKey,
    itemKey: itemKey.present ? itemKey.value : this.itemKey,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    maxAttempts: maxAttempts ?? this.maxAttempts,
    runAfter: runAfter ?? this.runAfter,
    heartbeatAt: heartbeatAt.present ? heartbeatAt.value : this.heartbeatAt,
    partialOutput: partialOutput.present
        ? partialOutput.value
        : this.partialOutput,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  JobsDbModelData copyWithCompanion(JobsDbModelCompanion data) {
    return JobsDbModelData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      groupKey: data.groupKey.present ? data.groupKey.value : this.groupKey,
      itemKey: data.itemKey.present ? data.itemKey.value : this.itemKey,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      maxAttempts: data.maxAttempts.present
          ? data.maxAttempts.value
          : this.maxAttempts,
      runAfter: data.runAfter.present ? data.runAfter.value : this.runAfter,
      heartbeatAt: data.heartbeatAt.present
          ? data.heartbeatAt.value
          : this.heartbeatAt,
      partialOutput: data.partialOutput.present
          ? data.partialOutput.value
          : this.partialOutput,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobsDbModelData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('groupKey: $groupKey, ')
          ..write('itemKey: $itemKey, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('runAfter: $runAfter, ')
          ..write('heartbeatAt: $heartbeatAt, ')
          ..write('partialOutput: $partialOutput, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    groupKey,
    itemKey,
    payload,
    status,
    attempts,
    maxAttempts,
    runAfter,
    heartbeatAt,
    partialOutput,
    elapsedMs,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobsDbModelData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.groupKey == this.groupKey &&
          other.itemKey == this.itemKey &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.maxAttempts == this.maxAttempts &&
          other.runAfter == this.runAfter &&
          other.heartbeatAt == this.heartbeatAt &&
          other.partialOutput == this.partialOutput &&
          other.elapsedMs == this.elapsedMs &&
          other.lastError == this.lastError);
}

class JobsDbModelCompanion extends UpdateCompanion<JobsDbModelData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> groupKey;
  final Value<String?> itemKey;
  final Value<String> payload;
  final Value<JobStatus> status;
  final Value<int> attempts;
  final Value<int> maxAttempts;
  final Value<DateTime> runAfter;
  final Value<DateTime?> heartbeatAt;
  final Value<String?> partialOutput;
  final Value<int> elapsedMs;
  final Value<String?> lastError;
  final Value<int> rowid;
  const JobsDbModelCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.groupKey = const Value.absent(),
    this.itemKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    this.runAfter = const Value.absent(),
    this.heartbeatAt = const Value.absent(),
    this.partialOutput = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobsDbModelCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.groupKey = const Value.absent(),
    this.itemKey = const Value.absent(),
    required String payload,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.maxAttempts = const Value.absent(),
    required DateTime runAfter,
    this.heartbeatAt = const Value.absent(),
    this.partialOutput = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : payload = Value(payload),
       runAfter = Value(runAfter);
  static Insertable<JobsDbModelData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? groupKey,
    Expression<String>? itemKey,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<int>? maxAttempts,
    Expression<DateTime>? runAfter,
    Expression<DateTime>? heartbeatAt,
    Expression<String>? partialOutput,
    Expression<int>? elapsedMs,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (groupKey != null) 'group_key': groupKey,
      if (itemKey != null) 'item_key': itemKey,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (maxAttempts != null) 'max_attempts': maxAttempts,
      if (runAfter != null) 'run_after': runAfter,
      if (heartbeatAt != null) 'heartbeat_at': heartbeatAt,
      if (partialOutput != null) 'partial_output': partialOutput,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobsDbModelCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String?>? groupKey,
    Value<String?>? itemKey,
    Value<String>? payload,
    Value<JobStatus>? status,
    Value<int>? attempts,
    Value<int>? maxAttempts,
    Value<DateTime>? runAfter,
    Value<DateTime?>? heartbeatAt,
    Value<String?>? partialOutput,
    Value<int>? elapsedMs,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return JobsDbModelCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupKey: groupKey ?? this.groupKey,
      itemKey: itemKey ?? this.itemKey,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      runAfter: runAfter ?? this.runAfter,
      heartbeatAt: heartbeatAt ?? this.heartbeatAt,
      partialOutput: partialOutput ?? this.partialOutput,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (groupKey.present) {
      map['group_key'] = Variable<String>(groupKey.value);
    }
    if (itemKey.present) {
      map['item_key'] = Variable<String>(itemKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $JobsDbModelTable.$converterstatus.toSql(status.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (maxAttempts.present) {
      map['max_attempts'] = Variable<int>(maxAttempts.value);
    }
    if (runAfter.present) {
      map['run_after'] = Variable<DateTime>(runAfter.value);
    }
    if (heartbeatAt.present) {
      map['heartbeat_at'] = Variable<DateTime>(heartbeatAt.value);
    }
    if (partialOutput.present) {
      map['partial_output'] = Variable<String>(partialOutput.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsDbModelCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('groupKey: $groupKey, ')
          ..write('itemKey: $itemKey, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('maxAttempts: $maxAttempts, ')
          ..write('runAfter: $runAfter, ')
          ..write('heartbeatAt: $heartbeatAt, ')
          ..write('partialOutput: $partialOutput, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ScannedDocumentGroupCountData extends DataClass {
  final String id;
  final int? docCount;
  const ScannedDocumentGroupCountData({required this.id, this.docCount});
  factory ScannedDocumentGroupCountData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannedDocumentGroupCountData(
      id: serializer.fromJson<String>(json['id']),
      docCount: serializer.fromJson<int?>(json['docCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'docCount': serializer.toJson<int?>(docCount),
    };
  }

  ScannedDocumentGroupCountData copyWith({
    String? id,
    Value<int?> docCount = const Value.absent(),
  }) => ScannedDocumentGroupCountData(
    id: id ?? this.id,
    docCount: docCount.present ? docCount.value : this.docCount,
  );
  @override
  String toString() {
    return (StringBuffer('ScannedDocumentGroupCountData(')
          ..write('id: $id, ')
          ..write('docCount: $docCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, docCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannedDocumentGroupCountData &&
          other.id == this.id &&
          other.docCount == this.docCount);
}

class $ScannedDocumentGroupCountView
    extends
        ViewInfo<$ScannedDocumentGroupCountView, ScannedDocumentGroupCountData>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$AppDatabase attachedDatabase;
  $ScannedDocumentGroupCountView(this.attachedDatabase, [this._alias]);
  $ScannedDocumentGroupsDbModelTable get groups =>
      attachedDatabase.scannedDocumentGroupsDbModel.createAlias('t0');
  $ScannedDocumentsDbModelTable get scannedDocuments =>
      attachedDatabase.scannedDocumentsDbModel.createAlias('t1');
  @override
  List<GeneratedColumn> get $columns => [id, docCount];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'scanned_document_group_count';
  @override
  Map<SqlDialect, String>? get createViewStatements => null;
  @override
  $ScannedDocumentGroupCountView get asDslTable => this;
  @override
  ScannedDocumentGroupCountData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannedDocumentGroupCountData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
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
  late final GeneratedColumn<int> docCount = GeneratedColumn<int>(
    'doc_count',
    aliasedName,
    true,
    generatedAs: GeneratedAs(BaseAggregate(scannedDocuments.id).count(), false),
    type: DriftSqlType.int,
  );
  @override
  $ScannedDocumentGroupCountView createAlias(String alias) {
    return $ScannedDocumentGroupCountView(attachedDatabase, alias);
  }

  @override
  Query? get query =>
      (attachedDatabase.selectOnly(groups)..addColumns($columns)).join([
        leftOuterJoin(
          scannedDocuments,
          scannedDocuments.groupId.equalsExp(groups.id),
        ),
      ])..groupBy([groups.id]);
  @override
  Set<String> get readTables => const {
    'scanned_document_groups_db_model',
    'scanned_documents_db_model',
  };
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScannedDocumentGroupsDbModelTable scannedDocumentGroupsDbModel =
      $ScannedDocumentGroupsDbModelTable(this);
  late final $ScannedDocumentsDbModelTable scannedDocumentsDbModel =
      $ScannedDocumentsDbModelTable(this);
  late final $ScannedDocumentTranscriptionsDbModelTable
  scannedDocumentTranscriptionsDbModel =
      $ScannedDocumentTranscriptionsDbModelTable(this);
  late final $JobsDbModelTable jobsDbModel = $JobsDbModelTable(this);
  late final $ScannedDocumentGroupCountView scannedDocumentGroupCount =
      $ScannedDocumentGroupCountView(this);
  late final Index idxJobsStatusRunAfter = Index(
    'idx_jobs_status_run_after',
    'CREATE INDEX idx_jobs_status_run_after ON jobs_db_model (status, run_after)',
  );
  late final Index idxJobsGroupKey = Index(
    'idx_jobs_group_key',
    'CREATE INDEX idx_jobs_group_key ON jobs_db_model (group_key)',
  );
  late final Index idxJobsItemKey = Index(
    'idx_jobs_item_key',
    'CREATE INDEX idx_jobs_item_key ON jobs_db_model (item_key)',
  );
  late final ScannedDocumentGroupsDao scannedDocumentGroupsDao =
      ScannedDocumentGroupsDao(this as AppDatabase);
  late final ScannedDocumentDao scannedDocumentDao = ScannedDocumentDao(
    this as AppDatabase,
  );
  late final ScannedDocumentTranscriptionDao scannedDocumentTranscriptionDao =
      ScannedDocumentTranscriptionDao(this as AppDatabase);
  late final JobDao jobDao = JobDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scannedDocumentGroupsDbModel,
    scannedDocumentsDbModel,
    scannedDocumentTranscriptionsDbModel,
    jobsDbModel,
    scannedDocumentGroupCount,
    idxJobsStatusRunAfter,
    idxJobsGroupKey,
    idxJobsItemKey,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scanned_document_groups_db_model',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('scanned_documents_db_model', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'scanned_documents_db_model',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate(
          'scanned_document_transcriptions_db_model',
          kind: UpdateKind.delete,
        ),
      ],
    ),
  ]);
}

typedef $$ScannedDocumentGroupsDbModelTableCreateCompanionBuilder =
    ScannedDocumentGroupsDbModelCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> id,
      required String relativePath,
      required String name,
      Value<int> rowid,
    });
typedef $$ScannedDocumentGroupsDbModelTableUpdateCompanionBuilder =
    ScannedDocumentGroupsDbModelCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> id,
      Value<String> relativePath,
      Value<String> name,
      Value<int> rowid,
    });

final class $$ScannedDocumentGroupsDbModelTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScannedDocumentGroupsDbModelTable,
          ScannedDocumentGroupsDbModelData
        > {
  $$ScannedDocumentGroupsDbModelTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ScannedDocumentsDbModelTable,
    List<ScannedDocumentsDbModelData>
  >
  _scannedDocumentsDbModelRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scannedDocumentsDbModel,
        aliasName: 'scanned_document_groups_db_model__id__scanned_documents_db_model__group_id',
      );

  $$ScannedDocumentsDbModelTableProcessedTableManager
  get scannedDocumentsDbModelRefs {
    final manager = $$ScannedDocumentsDbModelTableTableManager(
      $_db,
      $_db.scannedDocumentsDbModel,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scannedDocumentsDbModelRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScannedDocumentGroupsDbModelTableFilterComposer
    extends Composer<_$AppDatabase, $ScannedDocumentGroupsDbModelTable> {
  $$ScannedDocumentGroupsDbModelTableFilterComposer({
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

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scannedDocumentsDbModelRefs(
    Expression<bool> Function($$ScannedDocumentsDbModelTableFilterComposer f) f,
  ) {
    final $$ScannedDocumentsDbModelTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scannedDocumentsDbModel,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentsDbModelTableFilterComposer(
                $db: $db,
                $table: $db.scannedDocumentsDbModel,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScannedDocumentGroupsDbModelTableOrderingComposer
    extends Composer<_$AppDatabase, $ScannedDocumentGroupsDbModelTable> {
  $$ScannedDocumentGroupsDbModelTableOrderingComposer({
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

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScannedDocumentGroupsDbModelTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScannedDocumentGroupsDbModelTable> {
  $$ScannedDocumentGroupsDbModelTableAnnotationComposer({
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

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> scannedDocumentsDbModelRefs<T extends Object>(
    Expression<T> Function($$ScannedDocumentsDbModelTableAnnotationComposer a)
    f,
  ) {
    final $$ScannedDocumentsDbModelTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scannedDocumentsDbModel,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentsDbModelTableAnnotationComposer(
                $db: $db,
                $table: $db.scannedDocumentsDbModel,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScannedDocumentGroupsDbModelTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScannedDocumentGroupsDbModelTable,
          ScannedDocumentGroupsDbModelData,
          $$ScannedDocumentGroupsDbModelTableFilterComposer,
          $$ScannedDocumentGroupsDbModelTableOrderingComposer,
          $$ScannedDocumentGroupsDbModelTableAnnotationComposer,
          $$ScannedDocumentGroupsDbModelTableCreateCompanionBuilder,
          $$ScannedDocumentGroupsDbModelTableUpdateCompanionBuilder,
          (
            ScannedDocumentGroupsDbModelData,
            $$ScannedDocumentGroupsDbModelTableReferences,
          ),
          ScannedDocumentGroupsDbModelData,
          PrefetchHooks Function({bool scannedDocumentsDbModelRefs})
        > {
  $$ScannedDocumentGroupsDbModelTableTableManager(
    _$AppDatabase db,
    $ScannedDocumentGroupsDbModelTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScannedDocumentGroupsDbModelTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScannedDocumentGroupsDbModelTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScannedDocumentGroupsDbModelTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentGroupsDbModelCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                relativePath: relativePath,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                required String relativePath,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentGroupsDbModelCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                relativePath: relativePath,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ScannedDocumentGroupsDbModelTable,
                    ScannedDocumentGroupsDbModelData
                  >(table),
                  $$ScannedDocumentGroupsDbModelTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scannedDocumentsDbModelRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (scannedDocumentsDbModelRefs) db.scannedDocumentsDbModel,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scannedDocumentsDbModelRefs)
                    await $_getPrefetchedDataByColumns<
                      ScannedDocumentGroupsDbModelData,
                      $ScannedDocumentGroupsDbModelTable,
                      ScannedDocumentsDbModelData,
                      $ScannedDocumentsDbModelTable
                    >(
                      currentTable: table,
                      referencedTable:
                          $$ScannedDocumentGroupsDbModelTableReferences
                              ._scannedDocumentsDbModelRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ScannedDocumentGroupsDbModelTableReferences(
                            db,
                            table,
                            p0,
                          ).scannedDocumentsDbModelRefs,
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

typedef $$ScannedDocumentGroupsDbModelTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScannedDocumentGroupsDbModelTable,
      ScannedDocumentGroupsDbModelData,
      $$ScannedDocumentGroupsDbModelTableFilterComposer,
      $$ScannedDocumentGroupsDbModelTableOrderingComposer,
      $$ScannedDocumentGroupsDbModelTableAnnotationComposer,
      $$ScannedDocumentGroupsDbModelTableCreateCompanionBuilder,
      $$ScannedDocumentGroupsDbModelTableUpdateCompanionBuilder,
      (
        ScannedDocumentGroupsDbModelData,
        $$ScannedDocumentGroupsDbModelTableReferences,
      ),
      ScannedDocumentGroupsDbModelData,
      PrefetchHooks Function({bool scannedDocumentsDbModelRefs})
    >;
typedef $$ScannedDocumentsDbModelTableCreateCompanionBuilder =
    ScannedDocumentsDbModelCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String relativePath,
      Value<String> id,
      required String name,
      required String ext,
      required String groupId,
      Value<int> rowid,
    });
typedef $$ScannedDocumentsDbModelTableUpdateCompanionBuilder =
    ScannedDocumentsDbModelCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> relativePath,
      Value<String> id,
      Value<String> name,
      Value<String> ext,
      Value<String> groupId,
      Value<int> rowid,
    });

final class $$ScannedDocumentsDbModelTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScannedDocumentsDbModelTable,
          ScannedDocumentsDbModelData
        > {
  $$ScannedDocumentsDbModelTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScannedDocumentGroupsDbModelTable _groupIdTable(_$AppDatabase db) =>
      db.scannedDocumentGroupsDbModel.createAlias(
        'scanned_documents_db_model__group_id__scanned_document_groups_db_model__id',
      );

  $$ScannedDocumentGroupsDbModelTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$ScannedDocumentGroupsDbModelTableTableManager(
      $_db,
      $_db.scannedDocumentGroupsDbModel,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ScannedDocumentTranscriptionsDbModelTable,
    List<ScannedDocumentTranscriptionsDbModelData>
  >
  _scannedDocumentTranscriptionsDbModelRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scannedDocumentTranscriptionsDbModel,
        aliasName: 'scanned_documents_db_model__id__scanned_document_transcriptions_db_model__doc_id',
      );

  $$ScannedDocumentTranscriptionsDbModelTableProcessedTableManager
  get scannedDocumentTranscriptionsDbModelRefs {
    final manager = $$ScannedDocumentTranscriptionsDbModelTableTableManager(
      $_db,
      $_db.scannedDocumentTranscriptionsDbModel,
    ).filter((f) => f.docId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scannedDocumentTranscriptionsDbModelRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScannedDocumentsDbModelTableFilterComposer
    extends Composer<_$AppDatabase, $ScannedDocumentsDbModelTable> {
  $$ScannedDocumentsDbModelTableFilterComposer({
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

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ext => $composableBuilder(
    column: $table.ext,
    builder: (column) => ColumnFilters(column),
  );

  $$ScannedDocumentGroupsDbModelTableFilterComposer get groupId {
    final $$ScannedDocumentGroupsDbModelTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.scannedDocumentGroupsDbModel,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentGroupsDbModelTableFilterComposer(
                $db: $db,
                $table: $db.scannedDocumentGroupsDbModel,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> scannedDocumentTranscriptionsDbModelRefs(
    Expression<bool> Function(
      $$ScannedDocumentTranscriptionsDbModelTableFilterComposer f,
    )
    f,
  ) {
    final $$ScannedDocumentTranscriptionsDbModelTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scannedDocumentTranscriptionsDbModel,
          getReferencedColumn: (t) => t.docId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentTranscriptionsDbModelTableFilterComposer(
                $db: $db,
                $table: $db.scannedDocumentTranscriptionsDbModel,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScannedDocumentsDbModelTableOrderingComposer
    extends Composer<_$AppDatabase, $ScannedDocumentsDbModelTable> {
  $$ScannedDocumentsDbModelTableOrderingComposer({
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

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ext => $composableBuilder(
    column: $table.ext,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScannedDocumentGroupsDbModelTableOrderingComposer get groupId {
    final $$ScannedDocumentGroupsDbModelTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.scannedDocumentGroupsDbModel,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentGroupsDbModelTableOrderingComposer(
                $db: $db,
                $table: $db.scannedDocumentGroupsDbModel,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScannedDocumentsDbModelTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScannedDocumentsDbModelTable> {
  $$ScannedDocumentsDbModelTableAnnotationComposer({
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

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ext =>
      $composableBuilder(column: $table.ext, builder: (column) => column);

  $$ScannedDocumentGroupsDbModelTableAnnotationComposer get groupId {
    final $$ScannedDocumentGroupsDbModelTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.groupId,
          referencedTable: $db.scannedDocumentGroupsDbModel,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentGroupsDbModelTableAnnotationComposer(
                $db: $db,
                $table: $db.scannedDocumentGroupsDbModel,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> scannedDocumentTranscriptionsDbModelRefs<T extends Object>(
    Expression<T> Function(
      $$ScannedDocumentTranscriptionsDbModelTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ScannedDocumentTranscriptionsDbModelTableAnnotationComposer
    composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scannedDocumentTranscriptionsDbModel,
      getReferencedColumn: (t) => t.docId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScannedDocumentTranscriptionsDbModelTableAnnotationComposer(
            $db: $db,
            $table: $db.scannedDocumentTranscriptionsDbModel,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScannedDocumentsDbModelTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScannedDocumentsDbModelTable,
          ScannedDocumentsDbModelData,
          $$ScannedDocumentsDbModelTableFilterComposer,
          $$ScannedDocumentsDbModelTableOrderingComposer,
          $$ScannedDocumentsDbModelTableAnnotationComposer,
          $$ScannedDocumentsDbModelTableCreateCompanionBuilder,
          $$ScannedDocumentsDbModelTableUpdateCompanionBuilder,
          (
            ScannedDocumentsDbModelData,
            $$ScannedDocumentsDbModelTableReferences,
          ),
          ScannedDocumentsDbModelData,
          PrefetchHooks Function({
            bool groupId,
            bool scannedDocumentTranscriptionsDbModelRefs,
          })
        > {
  $$ScannedDocumentsDbModelTableTableManager(
    _$AppDatabase db,
    $ScannedDocumentsDbModelTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScannedDocumentsDbModelTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScannedDocumentsDbModelTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScannedDocumentsDbModelTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> ext = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsDbModelCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                relativePath: relativePath,
                id: id,
                name: name,
                ext: ext,
                groupId: groupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String relativePath,
                Value<String> id = const Value.absent(),
                required String name,
                required String ext,
                required String groupId,
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentsDbModelCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                relativePath: relativePath,
                id: id,
                name: name,
                ext: ext,
                groupId: groupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ScannedDocumentsDbModelTable,
                    ScannedDocumentsDbModelData
                  >(table),
                  $$ScannedDocumentsDbModelTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                groupId = false,
                scannedDocumentTranscriptionsDbModelRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scannedDocumentTranscriptionsDbModelRefs)
                      db.scannedDocumentTranscriptionsDbModel,
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
                        if (groupId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.groupId,
                            referencedTable:
                                $$ScannedDocumentsDbModelTableReferences
                                    ._groupIdTable(db),
                            referencedColumn:
                                $$ScannedDocumentsDbModelTableReferences
                                    ._groupIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scannedDocumentTranscriptionsDbModelRefs)
                        await $_getPrefetchedDataByColumns<
                          ScannedDocumentsDbModelData,
                          $ScannedDocumentsDbModelTable,
                          ScannedDocumentTranscriptionsDbModelData,
                          $ScannedDocumentTranscriptionsDbModelTable
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ScannedDocumentsDbModelTableReferences
                                  ._scannedDocumentTranscriptionsDbModelRefsTable(
                                    db,
                                  ),
                          managerFromTypedResult: (p0) =>
                              $$ScannedDocumentsDbModelTableReferences(
                                db,
                                table,
                                p0,
                              ).scannedDocumentTranscriptionsDbModelRefs,
                          currentColumn: 'id',
                          referencedColumn: 'doc_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ScannedDocumentsDbModelTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScannedDocumentsDbModelTable,
      ScannedDocumentsDbModelData,
      $$ScannedDocumentsDbModelTableFilterComposer,
      $$ScannedDocumentsDbModelTableOrderingComposer,
      $$ScannedDocumentsDbModelTableAnnotationComposer,
      $$ScannedDocumentsDbModelTableCreateCompanionBuilder,
      $$ScannedDocumentsDbModelTableUpdateCompanionBuilder,
      (ScannedDocumentsDbModelData, $$ScannedDocumentsDbModelTableReferences),
      ScannedDocumentsDbModelData,
      PrefetchHooks Function({
        bool groupId,
        bool scannedDocumentTranscriptionsDbModelRefs,
      })
    >;
typedef $$ScannedDocumentTranscriptionsDbModelTableCreateCompanionBuilder =
    ScannedDocumentTranscriptionsDbModelCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      required String relativePath,
      required String ext,
      Value<String> id,
      required String docId,
      Value<int> timeMsToTranscribe,
      Value<int> timeMsToRead,
      Value<int> wordCount,
      Value<int> rowid,
    });
typedef $$ScannedDocumentTranscriptionsDbModelTableUpdateCompanionBuilder =
    ScannedDocumentTranscriptionsDbModelCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> relativePath,
      Value<String> ext,
      Value<String> id,
      Value<String> docId,
      Value<int> timeMsToTranscribe,
      Value<int> timeMsToRead,
      Value<int> wordCount,
      Value<int> rowid,
    });

final class $$ScannedDocumentTranscriptionsDbModelTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScannedDocumentTranscriptionsDbModelTable,
          ScannedDocumentTranscriptionsDbModelData
        > {
  $$ScannedDocumentTranscriptionsDbModelTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScannedDocumentsDbModelTable _docIdTable(_$AppDatabase db) =>
      db.scannedDocumentsDbModel.createAlias(
        'scanned_document_transcriptions_db_model__doc_id__scanned_documents_db_model__id',
      );

  $$ScannedDocumentsDbModelTableProcessedTableManager get docId {
    final $_column = $_itemColumn<String>('doc_id')!;

    final manager = $$ScannedDocumentsDbModelTableTableManager(
      $_db,
      $_db.scannedDocumentsDbModel,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_docIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScannedDocumentTranscriptionsDbModelTableFilterComposer
    extends
        Composer<_$AppDatabase, $ScannedDocumentTranscriptionsDbModelTable> {
  $$ScannedDocumentTranscriptionsDbModelTableFilterComposer({
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

  ColumnFilters<String> get ext => $composableBuilder(
    column: $table.ext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeMsToTranscribe => $composableBuilder(
    column: $table.timeMsToTranscribe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeMsToRead => $composableBuilder(
    column: $table.timeMsToRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  $$ScannedDocumentsDbModelTableFilterComposer get docId {
    final $$ScannedDocumentsDbModelTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.docId,
          referencedTable: $db.scannedDocumentsDbModel,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentsDbModelTableFilterComposer(
                $db: $db,
                $table: $db.scannedDocumentsDbModel,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScannedDocumentTranscriptionsDbModelTableOrderingComposer
    extends
        Composer<_$AppDatabase, $ScannedDocumentTranscriptionsDbModelTable> {
  $$ScannedDocumentTranscriptionsDbModelTableOrderingComposer({
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

  ColumnOrderings<String> get ext => $composableBuilder(
    column: $table.ext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMsToTranscribe => $composableBuilder(
    column: $table.timeMsToTranscribe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMsToRead => $composableBuilder(
    column: $table.timeMsToRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScannedDocumentsDbModelTableOrderingComposer get docId {
    final $$ScannedDocumentsDbModelTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.docId,
          referencedTable: $db.scannedDocumentsDbModel,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentsDbModelTableOrderingComposer(
                $db: $db,
                $table: $db.scannedDocumentsDbModel,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScannedDocumentTranscriptionsDbModelTableAnnotationComposer
    extends
        Composer<_$AppDatabase, $ScannedDocumentTranscriptionsDbModelTable> {
  $$ScannedDocumentTranscriptionsDbModelTableAnnotationComposer({
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

  GeneratedColumn<String> get ext =>
      $composableBuilder(column: $table.ext, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timeMsToTranscribe => $composableBuilder(
    column: $table.timeMsToTranscribe,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeMsToRead => $composableBuilder(
    column: $table.timeMsToRead,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  $$ScannedDocumentsDbModelTableAnnotationComposer get docId {
    final $$ScannedDocumentsDbModelTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.docId,
          referencedTable: $db.scannedDocumentsDbModel,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScannedDocumentsDbModelTableAnnotationComposer(
                $db: $db,
                $table: $db.scannedDocumentsDbModel,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScannedDocumentTranscriptionsDbModelTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScannedDocumentTranscriptionsDbModelTable,
          ScannedDocumentTranscriptionsDbModelData,
          $$ScannedDocumentTranscriptionsDbModelTableFilterComposer,
          $$ScannedDocumentTranscriptionsDbModelTableOrderingComposer,
          $$ScannedDocumentTranscriptionsDbModelTableAnnotationComposer,
          $$ScannedDocumentTranscriptionsDbModelTableCreateCompanionBuilder,
          $$ScannedDocumentTranscriptionsDbModelTableUpdateCompanionBuilder,
          (
            ScannedDocumentTranscriptionsDbModelData,
            $$ScannedDocumentTranscriptionsDbModelTableReferences,
          ),
          ScannedDocumentTranscriptionsDbModelData,
          PrefetchHooks Function({bool docId})
        > {
  $$ScannedDocumentTranscriptionsDbModelTableTableManager(
    _$AppDatabase db,
    $ScannedDocumentTranscriptionsDbModelTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScannedDocumentTranscriptionsDbModelTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScannedDocumentTranscriptionsDbModelTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScannedDocumentTranscriptionsDbModelTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> ext = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> docId = const Value.absent(),
                Value<int> timeMsToTranscribe = const Value.absent(),
                Value<int> timeMsToRead = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentTranscriptionsDbModelCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                relativePath: relativePath,
                ext: ext,
                id: id,
                docId: docId,
                timeMsToTranscribe: timeMsToTranscribe,
                timeMsToRead: timeMsToRead,
                wordCount: wordCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required String relativePath,
                required String ext,
                Value<String> id = const Value.absent(),
                required String docId,
                Value<int> timeMsToTranscribe = const Value.absent(),
                Value<int> timeMsToRead = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScannedDocumentTranscriptionsDbModelCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                relativePath: relativePath,
                ext: ext,
                id: id,
                docId: docId,
                timeMsToTranscribe: timeMsToTranscribe,
                timeMsToRead: timeMsToRead,
                wordCount: wordCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ScannedDocumentTranscriptionsDbModelTable,
                    ScannedDocumentTranscriptionsDbModelData
                  >(table),
                  $$ScannedDocumentTranscriptionsDbModelTableReferences(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({docId = false}) {
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
                    if (docId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.docId,
                        referencedTable:
                            $$ScannedDocumentTranscriptionsDbModelTableReferences
                                ._docIdTable(db),
                        referencedColumn:
                            $$ScannedDocumentTranscriptionsDbModelTableReferences
                                ._docIdTable(db)
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

typedef $$ScannedDocumentTranscriptionsDbModelTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScannedDocumentTranscriptionsDbModelTable,
      ScannedDocumentTranscriptionsDbModelData,
      $$ScannedDocumentTranscriptionsDbModelTableFilterComposer,
      $$ScannedDocumentTranscriptionsDbModelTableOrderingComposer,
      $$ScannedDocumentTranscriptionsDbModelTableAnnotationComposer,
      $$ScannedDocumentTranscriptionsDbModelTableCreateCompanionBuilder,
      $$ScannedDocumentTranscriptionsDbModelTableUpdateCompanionBuilder,
      (
        ScannedDocumentTranscriptionsDbModelData,
        $$ScannedDocumentTranscriptionsDbModelTableReferences,
      ),
      ScannedDocumentTranscriptionsDbModelData,
      PrefetchHooks Function({bool docId})
    >;
typedef $$JobsDbModelTableCreateCompanionBuilder =
    JobsDbModelCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> groupKey,
      Value<String?> itemKey,
      required String payload,
      Value<JobStatus> status,
      Value<int> attempts,
      Value<int> maxAttempts,
      required DateTime runAfter,
      Value<DateTime?> heartbeatAt,
      Value<String?> partialOutput,
      Value<int> elapsedMs,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$JobsDbModelTableUpdateCompanionBuilder =
    JobsDbModelCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String?> groupKey,
      Value<String?> itemKey,
      Value<String> payload,
      Value<JobStatus> status,
      Value<int> attempts,
      Value<int> maxAttempts,
      Value<DateTime> runAfter,
      Value<DateTime?> heartbeatAt,
      Value<String?> partialOutput,
      Value<int> elapsedMs,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$JobsDbModelTableFilterComposer
    extends Composer<_$AppDatabase, $JobsDbModelTable> {
  $$JobsDbModelTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupKey => $composableBuilder(
    column: $table.groupKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<JobStatus, JobStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxAttempts => $composableBuilder(
    column: $table.maxAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get runAfter => $composableBuilder(
    column: $table.runAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get heartbeatAt => $composableBuilder(
    column: $table.heartbeatAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partialOutput => $composableBuilder(
    column: $table.partialOutput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JobsDbModelTableOrderingComposer
    extends Composer<_$AppDatabase, $JobsDbModelTable> {
  $$JobsDbModelTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupKey => $composableBuilder(
    column: $table.groupKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxAttempts => $composableBuilder(
    column: $table.maxAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get runAfter => $composableBuilder(
    column: $table.runAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get heartbeatAt => $composableBuilder(
    column: $table.heartbeatAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partialOutput => $composableBuilder(
    column: $table.partialOutput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobsDbModelTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobsDbModelTable> {
  $$JobsDbModelTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get groupKey =>
      $composableBuilder(column: $table.groupKey, builder: (column) => column);

  GeneratedColumn<String> get itemKey =>
      $composableBuilder(column: $table.itemKey, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JobStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get maxAttempts => $composableBuilder(
    column: $table.maxAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get runAfter =>
      $composableBuilder(column: $table.runAfter, builder: (column) => column);

  GeneratedColumn<DateTime> get heartbeatAt => $composableBuilder(
    column: $table.heartbeatAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partialOutput => $composableBuilder(
    column: $table.partialOutput,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$JobsDbModelTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsDbModelTable,
          JobsDbModelData,
          $$JobsDbModelTableFilterComposer,
          $$JobsDbModelTableOrderingComposer,
          $$JobsDbModelTableAnnotationComposer,
          $$JobsDbModelTableCreateCompanionBuilder,
          $$JobsDbModelTableUpdateCompanionBuilder,
          (
            JobsDbModelData,
            BaseReferences<_$AppDatabase, $JobsDbModelTable, JobsDbModelData>,
          ),
          JobsDbModelData,
          PrefetchHooks Function()
        > {
  $$JobsDbModelTableTableManager(_$AppDatabase db, $JobsDbModelTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsDbModelTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsDbModelTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsDbModelTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> groupKey = const Value.absent(),
                Value<String?> itemKey = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<JobStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> maxAttempts = const Value.absent(),
                Value<DateTime> runAfter = const Value.absent(),
                Value<DateTime?> heartbeatAt = const Value.absent(),
                Value<String?> partialOutput = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsDbModelCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                groupKey: groupKey,
                itemKey: itemKey,
                payload: payload,
                status: status,
                attempts: attempts,
                maxAttempts: maxAttempts,
                runAfter: runAfter,
                heartbeatAt: heartbeatAt,
                partialOutput: partialOutput,
                elapsedMs: elapsedMs,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> groupKey = const Value.absent(),
                Value<String?> itemKey = const Value.absent(),
                required String payload,
                Value<JobStatus> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> maxAttempts = const Value.absent(),
                required DateTime runAfter,
                Value<DateTime?> heartbeatAt = const Value.absent(),
                Value<String?> partialOutput = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsDbModelCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                groupKey: groupKey,
                itemKey: itemKey,
                payload: payload,
                status: status,
                attempts: attempts,
                maxAttempts: maxAttempts,
                runAfter: runAfter,
                heartbeatAt: heartbeatAt,
                partialOutput: partialOutput,
                elapsedMs: elapsedMs,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JobsDbModelTable, JobsDbModelData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $JobsDbModelTable,
                    JobsDbModelData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JobsDbModelTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsDbModelTable,
      JobsDbModelData,
      $$JobsDbModelTableFilterComposer,
      $$JobsDbModelTableOrderingComposer,
      $$JobsDbModelTableAnnotationComposer,
      $$JobsDbModelTableCreateCompanionBuilder,
      $$JobsDbModelTableUpdateCompanionBuilder,
      (
        JobsDbModelData,
        BaseReferences<_$AppDatabase, $JobsDbModelTable, JobsDbModelData>,
      ),
      JobsDbModelData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScannedDocumentGroupsDbModelTableTableManager
  get scannedDocumentGroupsDbModel =>
      $$ScannedDocumentGroupsDbModelTableTableManager(
        _db,
        _db.scannedDocumentGroupsDbModel,
      );
  $$ScannedDocumentsDbModelTableTableManager get scannedDocumentsDbModel =>
      $$ScannedDocumentsDbModelTableTableManager(
        _db,
        _db.scannedDocumentsDbModel,
      );
  $$ScannedDocumentTranscriptionsDbModelTableTableManager
  get scannedDocumentTranscriptionsDbModel =>
      $$ScannedDocumentTranscriptionsDbModelTableTableManager(
        _db,
        _db.scannedDocumentTranscriptionsDbModel,
      );
  $$JobsDbModelTableTableManager get jobsDbModel =>
      $$JobsDbModelTableTableManager(_db, _db.jobsDbModel);
}
