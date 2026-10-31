// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headsUpMinutesMeta = const VerificationMeta(
    'headsUpMinutes',
  );
  @override
  late final GeneratedColumn<int> headsUpMinutes = GeneratedColumn<int>(
    'heads_up_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _hardBufferMinutesMeta = const VerificationMeta(
    'hardBufferMinutes',
  );
  @override
  late final GeneratedColumn<int> hardBufferMinutes = GeneratedColumn<int>(
    'hard_buffer_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _pauseMinutesMeta = const VerificationMeta(
    'pauseMinutes',
  );
  @override
  late final GeneratedColumn<int> pauseMinutes = GeneratedColumn<int>(
    'pause_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _pauseCooldownSecondsMeta =
      const VerificationMeta('pauseCooldownSeconds');
  @override
  late final GeneratedColumn<int> pauseCooldownSeconds = GeneratedColumn<int>(
    'pause_cooldown_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _pausePhraseMeta = const VerificationMeta(
    'pausePhrase',
  );
  @override
  late final GeneratedColumn<String> pausePhrase = GeneratedColumn<String>(
    'pause_phrase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('I am choosing to break my own rule'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    headsUpMinutes,
    hardBufferMinutes,
    pauseMinutes,
    pauseCooldownSeconds,
    pausePhrase,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('heads_up_minutes')) {
      context.handle(
        _headsUpMinutesMeta,
        headsUpMinutes.isAcceptableOrUnknown(
          data['heads_up_minutes']!,
          _headsUpMinutesMeta,
        ),
      );
    }
    if (data.containsKey('hard_buffer_minutes')) {
      context.handle(
        _hardBufferMinutesMeta,
        hardBufferMinutes.isAcceptableOrUnknown(
          data['hard_buffer_minutes']!,
          _hardBufferMinutesMeta,
        ),
      );
    }
    if (data.containsKey('pause_minutes')) {
      context.handle(
        _pauseMinutesMeta,
        pauseMinutes.isAcceptableOrUnknown(
          data['pause_minutes']!,
          _pauseMinutesMeta,
        ),
      );
    }
    if (data.containsKey('pause_cooldown_seconds')) {
      context.handle(
        _pauseCooldownSecondsMeta,
        pauseCooldownSeconds.isAcceptableOrUnknown(
          data['pause_cooldown_seconds']!,
          _pauseCooldownSecondsMeta,
        ),
      );
    }
    if (data.containsKey('pause_phrase')) {
      context.handle(
        _pausePhraseMeta,
        pausePhrase.isAcceptableOrUnknown(
          data['pause_phrase']!,
          _pausePhraseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      headsUpMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heads_up_minutes'],
      )!,
      hardBufferMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hard_buffer_minutes'],
      )!,
      pauseMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pause_minutes'],
      )!,
      pauseCooldownSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pause_cooldown_seconds'],
      )!,
      pausePhrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pause_phrase'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final int id;
  final int headsUpMinutes;
  final int hardBufferMinutes;
  final int pauseMinutes;
  final int pauseCooldownSeconds;
  final String pausePhrase;
  const SettingsRow({
    required this.id,
    required this.headsUpMinutes,
    required this.hardBufferMinutes,
    required this.pauseMinutes,
    required this.pauseCooldownSeconds,
    required this.pausePhrase,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['heads_up_minutes'] = Variable<int>(headsUpMinutes);
    map['hard_buffer_minutes'] = Variable<int>(hardBufferMinutes);
    map['pause_minutes'] = Variable<int>(pauseMinutes);
    map['pause_cooldown_seconds'] = Variable<int>(pauseCooldownSeconds);
    map['pause_phrase'] = Variable<String>(pausePhrase);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      headsUpMinutes: Value(headsUpMinutes),
      hardBufferMinutes: Value(hardBufferMinutes),
      pauseMinutes: Value(pauseMinutes),
      pauseCooldownSeconds: Value(pauseCooldownSeconds),
      pausePhrase: Value(pausePhrase),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<int>(json['id']),
      headsUpMinutes: serializer.fromJson<int>(json['headsUpMinutes']),
      hardBufferMinutes: serializer.fromJson<int>(json['hardBufferMinutes']),
      pauseMinutes: serializer.fromJson<int>(json['pauseMinutes']),
      pauseCooldownSeconds: serializer.fromJson<int>(
        json['pauseCooldownSeconds'],
      ),
      pausePhrase: serializer.fromJson<String>(json['pausePhrase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'headsUpMinutes': serializer.toJson<int>(headsUpMinutes),
      'hardBufferMinutes': serializer.toJson<int>(hardBufferMinutes),
      'pauseMinutes': serializer.toJson<int>(pauseMinutes),
      'pauseCooldownSeconds': serializer.toJson<int>(pauseCooldownSeconds),
      'pausePhrase': serializer.toJson<String>(pausePhrase),
    };
  }

  SettingsRow copyWith({
    int? id,
    int? headsUpMinutes,
    int? hardBufferMinutes,
    int? pauseMinutes,
    int? pauseCooldownSeconds,
    String? pausePhrase,
  }) => SettingsRow(
    id: id ?? this.id,
    headsUpMinutes: headsUpMinutes ?? this.headsUpMinutes,
    hardBufferMinutes: hardBufferMinutes ?? this.hardBufferMinutes,
    pauseMinutes: pauseMinutes ?? this.pauseMinutes,
    pauseCooldownSeconds: pauseCooldownSeconds ?? this.pauseCooldownSeconds,
    pausePhrase: pausePhrase ?? this.pausePhrase,
  );
  SettingsRow copyWithCompanion(SettingsCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      headsUpMinutes: data.headsUpMinutes.present
          ? data.headsUpMinutes.value
          : this.headsUpMinutes,
      hardBufferMinutes: data.hardBufferMinutes.present
          ? data.hardBufferMinutes.value
          : this.hardBufferMinutes,
      pauseMinutes: data.pauseMinutes.present
          ? data.pauseMinutes.value
          : this.pauseMinutes,
      pauseCooldownSeconds: data.pauseCooldownSeconds.present
          ? data.pauseCooldownSeconds.value
          : this.pauseCooldownSeconds,
      pausePhrase: data.pausePhrase.present
          ? data.pausePhrase.value
          : this.pausePhrase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('headsUpMinutes: $headsUpMinutes, ')
          ..write('hardBufferMinutes: $hardBufferMinutes, ')
          ..write('pauseMinutes: $pauseMinutes, ')
          ..write('pauseCooldownSeconds: $pauseCooldownSeconds, ')
          ..write('pausePhrase: $pausePhrase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    headsUpMinutes,
    hardBufferMinutes,
    pauseMinutes,
    pauseCooldownSeconds,
    pausePhrase,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.headsUpMinutes == this.headsUpMinutes &&
          other.hardBufferMinutes == this.hardBufferMinutes &&
          other.pauseMinutes == this.pauseMinutes &&
          other.pauseCooldownSeconds == this.pauseCooldownSeconds &&
          other.pausePhrase == this.pausePhrase);
}

class SettingsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<int> headsUpMinutes;
  final Value<int> hardBufferMinutes;
  final Value<int> pauseMinutes;
  final Value<int> pauseCooldownSeconds;
  final Value<String> pausePhrase;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.headsUpMinutes = const Value.absent(),
    this.hardBufferMinutes = const Value.absent(),
    this.pauseMinutes = const Value.absent(),
    this.pauseCooldownSeconds = const Value.absent(),
    this.pausePhrase = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.headsUpMinutes = const Value.absent(),
    this.hardBufferMinutes = const Value.absent(),
    this.pauseMinutes = const Value.absent(),
    this.pauseCooldownSeconds = const Value.absent(),
    this.pausePhrase = const Value.absent(),
  });
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<int>? headsUpMinutes,
    Expression<int>? hardBufferMinutes,
    Expression<int>? pauseMinutes,
    Expression<int>? pauseCooldownSeconds,
    Expression<String>? pausePhrase,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (headsUpMinutes != null) 'heads_up_minutes': headsUpMinutes,
      if (hardBufferMinutes != null) 'hard_buffer_minutes': hardBufferMinutes,
      if (pauseMinutes != null) 'pause_minutes': pauseMinutes,
      if (pauseCooldownSeconds != null)
        'pause_cooldown_seconds': pauseCooldownSeconds,
      if (pausePhrase != null) 'pause_phrase': pausePhrase,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? headsUpMinutes,
    Value<int>? hardBufferMinutes,
    Value<int>? pauseMinutes,
    Value<int>? pauseCooldownSeconds,
    Value<String>? pausePhrase,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      headsUpMinutes: headsUpMinutes ?? this.headsUpMinutes,
      hardBufferMinutes: hardBufferMinutes ?? this.hardBufferMinutes,
      pauseMinutes: pauseMinutes ?? this.pauseMinutes,
      pauseCooldownSeconds: pauseCooldownSeconds ?? this.pauseCooldownSeconds,
      pausePhrase: pausePhrase ?? this.pausePhrase,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (headsUpMinutes.present) {
      map['heads_up_minutes'] = Variable<int>(headsUpMinutes.value);
    }
    if (hardBufferMinutes.present) {
      map['hard_buffer_minutes'] = Variable<int>(hardBufferMinutes.value);
    }
    if (pauseMinutes.present) {
      map['pause_minutes'] = Variable<int>(pauseMinutes.value);
    }
    if (pauseCooldownSeconds.present) {
      map['pause_cooldown_seconds'] = Variable<int>(pauseCooldownSeconds.value);
    }
    if (pausePhrase.present) {
      map['pause_phrase'] = Variable<String>(pausePhrase.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('headsUpMinutes: $headsUpMinutes, ')
          ..write('hardBufferMinutes: $hardBufferMinutes, ')
          ..write('pauseMinutes: $pauseMinutes, ')
          ..write('pauseCooldownSeconds: $pauseCooldownSeconds, ')
          ..write('pausePhrase: $pausePhrase')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, HabitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strictnessMeta = const VerificationMeta(
    'strictness',
  );
  @override
  late final GeneratedColumn<String> strictness = GeneratedColumn<String>(
    'strictness',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _dndMeta = const VerificationMeta('dnd');
  @override
  late final GeneratedColumn<bool> dnd = GeneratedColumn<bool>(
    'dnd',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dnd" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    days,
    startMinute,
    endMinute,
    strictness,
    priority,
    dnd,
    enabled,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitRow> instance, {
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
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('strictness')) {
      context.handle(
        _strictnessMeta,
        strictness.isAcceptableOrUnknown(data['strictness']!, _strictnessMeta),
      );
    } else if (isInserting) {
      context.missing(_strictnessMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('dnd')) {
      context.handle(
        _dndMeta,
        dnd.isAcceptableOrUnknown(data['dnd']!, _dndMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
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
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      strictness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strictness'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      dnd: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dnd'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class HabitRow extends DataClass implements Insertable<HabitRow> {
  final String id;
  final String name;
  final int days;
  final int startMinute;
  final int endMinute;
  final String strictness;
  final int priority;
  final bool dnd;
  final bool enabled;
  final int createdAt;
  final int? archivedAt;
  const HabitRow({
    required this.id,
    required this.name,
    required this.days,
    required this.startMinute,
    required this.endMinute,
    required this.strictness,
    required this.priority,
    required this.dnd,
    required this.enabled,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['days'] = Variable<int>(days);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_minute'] = Variable<int>(endMinute);
    map['strictness'] = Variable<String>(strictness);
    map['priority'] = Variable<int>(priority);
    map['dnd'] = Variable<bool>(dnd);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(archivedAt);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      days: Value(days),
      startMinute: Value(startMinute),
      endMinute: Value(endMinute),
      strictness: Value(strictness),
      priority: Value(priority),
      dnd: Value(dnd),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory HabitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      days: serializer.fromJson<int>(json['days']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      strictness: serializer.fromJson<String>(json['strictness']),
      priority: serializer.fromJson<int>(json['priority']),
      dnd: serializer.fromJson<bool>(json['dnd']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      archivedAt: serializer.fromJson<int?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'days': serializer.toJson<int>(days),
      'startMinute': serializer.toJson<int>(startMinute),
      'endMinute': serializer.toJson<int>(endMinute),
      'strictness': serializer.toJson<String>(strictness),
      'priority': serializer.toJson<int>(priority),
      'dnd': serializer.toJson<bool>(dnd),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<int>(createdAt),
      'archivedAt': serializer.toJson<int?>(archivedAt),
    };
  }

  HabitRow copyWith({
    String? id,
    String? name,
    int? days,
    int? startMinute,
    int? endMinute,
    String? strictness,
    int? priority,
    bool? dnd,
    bool? enabled,
    int? createdAt,
    Value<int?> archivedAt = const Value.absent(),
  }) => HabitRow(
    id: id ?? this.id,
    name: name ?? this.name,
    days: days ?? this.days,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    strictness: strictness ?? this.strictness,
    priority: priority ?? this.priority,
    dnd: dnd ?? this.dnd,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  HabitRow copyWithCompanion(HabitsCompanion data) {
    return HabitRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      days: data.days.present ? data.days.value : this.days,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      strictness: data.strictness.present
          ? data.strictness.value
          : this.strictness,
      priority: data.priority.present ? data.priority.value : this.priority,
      dnd: data.dnd.present ? data.dnd.value : this.dnd,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('days: $days, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('strictness: $strictness, ')
          ..write('priority: $priority, ')
          ..write('dnd: $dnd, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    days,
    startMinute,
    endMinute,
    strictness,
    priority,
    dnd,
    enabled,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.days == this.days &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.strictness == this.strictness &&
          other.priority == this.priority &&
          other.dnd == this.dnd &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class HabitsCompanion extends UpdateCompanion<HabitRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> days;
  final Value<int> startMinute;
  final Value<int> endMinute;
  final Value<String> strictness;
  final Value<int> priority;
  final Value<bool> dnd;
  final Value<bool> enabled;
  final Value<int> createdAt;
  final Value<int?> archivedAt;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.days = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.strictness = const Value.absent(),
    this.priority = const Value.absent(),
    this.dnd = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String name,
    required int days,
    required int startMinute,
    required int endMinute,
    required String strictness,
    this.priority = const Value.absent(),
    this.dnd = const Value.absent(),
    this.enabled = const Value.absent(),
    required int createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       days = Value(days),
       startMinute = Value(startMinute),
       endMinute = Value(endMinute),
       strictness = Value(strictness),
       createdAt = Value(createdAt);
  static Insertable<HabitRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? days,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<String>? strictness,
    Expression<int>? priority,
    Expression<bool>? dnd,
    Expression<bool>? enabled,
    Expression<int>? createdAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (days != null) 'days': days,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (strictness != null) 'strictness': strictness,
      if (priority != null) 'priority': priority,
      if (dnd != null) 'dnd': dnd,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? days,
    Value<int>? startMinute,
    Value<int>? endMinute,
    Value<String>? strictness,
    Value<int>? priority,
    Value<bool>? dnd,
    Value<bool>? enabled,
    Value<int>? createdAt,
    Value<int?>? archivedAt,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      days: days ?? this.days,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      strictness: strictness ?? this.strictness,
      priority: priority ?? this.priority,
      dnd: dnd ?? this.dnd,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
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
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (strictness.present) {
      map['strictness'] = Variable<String>(strictness.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (dnd.present) {
      map['dnd'] = Variable<bool>(dnd.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('days: $days, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('strictness: $strictness, ')
          ..write('priority: $priority, ')
          ..write('dnd: $dnd, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitAppsTable extends HabitApps
    with TableInfo<$HabitAppsTable, HabitAppRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitAppsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _packageMeta = const VerificationMeta(
    'package',
  );
  @override
  late final GeneratedColumn<String> package = GeneratedColumn<String>(
    'package',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [habitId, package, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitAppRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('package')) {
      context.handle(
        _packageMeta,
        package.isAcceptableOrUnknown(data['package']!, _packageMeta),
      );
    } else if (isInserting) {
      context.missing(_packageMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId, package};
  @override
  HabitAppRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitAppRow(
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      package: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
    );
  }

  @override
  $HabitAppsTable createAlias(String alias) {
    return $HabitAppsTable(attachedDatabase, alias);
  }
}

class HabitAppRow extends DataClass implements Insertable<HabitAppRow> {
  final String habitId;
  final String package;
  final String label;
  const HabitAppRow({
    required this.habitId,
    required this.package,
    required this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<String>(habitId);
    map['package'] = Variable<String>(package);
    map['label'] = Variable<String>(label);
    return map;
  }

  HabitAppsCompanion toCompanion(bool nullToAbsent) {
    return HabitAppsCompanion(
      habitId: Value(habitId),
      package: Value(package),
      label: Value(label),
    );
  }

  factory HabitAppRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitAppRow(
      habitId: serializer.fromJson<String>(json['habitId']),
      package: serializer.fromJson<String>(json['package']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<String>(habitId),
      'package': serializer.toJson<String>(package),
      'label': serializer.toJson<String>(label),
    };
  }

  HabitAppRow copyWith({String? habitId, String? package, String? label}) =>
      HabitAppRow(
        habitId: habitId ?? this.habitId,
        package: package ?? this.package,
        label: label ?? this.label,
      );
  HabitAppRow copyWithCompanion(HabitAppsCompanion data) {
    return HabitAppRow(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      package: data.package.present ? data.package.value : this.package,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitAppRow(')
          ..write('habitId: $habitId, ')
          ..write('package: $package, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, package, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitAppRow &&
          other.habitId == this.habitId &&
          other.package == this.package &&
          other.label == this.label);
}

class HabitAppsCompanion extends UpdateCompanion<HabitAppRow> {
  final Value<String> habitId;
  final Value<String> package;
  final Value<String> label;
  final Value<int> rowid;
  const HabitAppsCompanion({
    this.habitId = const Value.absent(),
    this.package = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitAppsCompanion.insert({
    required String habitId,
    required String package,
    required String label,
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       package = Value(package),
       label = Value(label);
  static Insertable<HabitAppRow> custom({
    Expression<String>? habitId,
    Expression<String>? package,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (package != null) 'package': package,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitAppsCompanion copyWith({
    Value<String>? habitId,
    Value<String>? package,
    Value<String>? label,
    Value<int>? rowid,
  }) {
    return HabitAppsCompanion(
      habitId: habitId ?? this.habitId,
      package: package ?? this.package,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (package.present) {
      map['package'] = Variable<String>(package.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitAppsCompanion(')
          ..write('habitId: $habitId, ')
          ..write('package: $package, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlarmsTable extends Alarms with TableInfo<$AlarmsTable, AlarmRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _anchorMeta = const VerificationMeta('anchor');
  @override
  late final GeneratedColumn<String> anchor = GeneratedColumn<String>(
    'anchor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _offsetMinutesMeta = const VerificationMeta(
    'offsetMinutes',
  );
  @override
  late final GeneratedColumn<int> offsetMinutes = GeneratedColumn<int>(
    'offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _onceDateMeta = const VerificationMeta(
    'onceDate',
  );
  @override
  late final GeneratedColumn<String> onceDate = GeneratedColumn<String>(
    'once_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _vibrateMeta = const VerificationMeta(
    'vibrate',
  );
  @override
  late final GeneratedColumn<bool> vibrate = GeneratedColumn<bool>(
    'vibrate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibrate" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _snoozeMinutesMeta = const VerificationMeta(
    'snoozeMinutes',
  );
  @override
  late final GeneratedColumn<int> snoozeMinutes = GeneratedColumn<int>(
    'snooze_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _snoozeLimitMeta = const VerificationMeta(
    'snoozeLimit',
  );
  @override
  late final GeneratedColumn<int> snoozeLimit = GeneratedColumn<int>(
    'snooze_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _challengeMeta = const VerificationMeta(
    'challenge',
  );
  @override
  late final GeneratedColumn<String> challenge = GeneratedColumn<String>(
    'challenge',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sum'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    anchor,
    habitId,
    minute,
    offsetMinutes,
    days,
    onceDate,
    enabled,
    vibrate,
    snoozeMinutes,
    snoozeLimit,
    challenge,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alarms';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlarmRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('anchor')) {
      context.handle(
        _anchorMeta,
        anchor.isAcceptableOrUnknown(data['anchor']!, _anchorMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    }
    if (data.containsKey('offset_minutes')) {
      context.handle(
        _offsetMinutesMeta,
        offsetMinutes.isAcceptableOrUnknown(
          data['offset_minutes']!,
          _offsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    }
    if (data.containsKey('once_date')) {
      context.handle(
        _onceDateMeta,
        onceDate.isAcceptableOrUnknown(data['once_date']!, _onceDateMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('vibrate')) {
      context.handle(
        _vibrateMeta,
        vibrate.isAcceptableOrUnknown(data['vibrate']!, _vibrateMeta),
      );
    }
    if (data.containsKey('snooze_minutes')) {
      context.handle(
        _snoozeMinutesMeta,
        snoozeMinutes.isAcceptableOrUnknown(
          data['snooze_minutes']!,
          _snoozeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('snooze_limit')) {
      context.handle(
        _snoozeLimitMeta,
        snoozeLimit.isAcceptableOrUnknown(
          data['snooze_limit']!,
          _snoozeLimitMeta,
        ),
      );
    }
    if (data.containsKey('challenge')) {
      context.handle(
        _challengeMeta,
        challenge.isAcceptableOrUnknown(data['challenge']!, _challengeMeta),
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
  AlarmRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlarmRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      anchor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      ),
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      ),
      offsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_minutes'],
      )!,
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days'],
      )!,
      onceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}once_date'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      vibrate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibrate'],
      )!,
      snoozeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_minutes'],
      )!,
      snoozeLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_limit'],
      )!,
      challenge: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}challenge'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AlarmsTable createAlias(String alias) {
    return $AlarmsTable(attachedDatabase, alias);
  }
}

class AlarmRow extends DataClass implements Insertable<AlarmRow> {
  final String id;
  final String label;
  final String anchor;
  final String? habitId;
  final int? minute;
  final int offsetMinutes;
  final int days;
  final String? onceDate;
  final bool enabled;
  final bool vibrate;
  final int snoozeMinutes;
  final int snoozeLimit;
  final String challenge;
  final int createdAt;
  const AlarmRow({
    required this.id,
    required this.label,
    required this.anchor,
    this.habitId,
    this.minute,
    required this.offsetMinutes,
    required this.days,
    this.onceDate,
    required this.enabled,
    required this.vibrate,
    required this.snoozeMinutes,
    required this.snoozeLimit,
    required this.challenge,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['anchor'] = Variable<String>(anchor);
    if (!nullToAbsent || habitId != null) {
      map['habit_id'] = Variable<String>(habitId);
    }
    if (!nullToAbsent || minute != null) {
      map['minute'] = Variable<int>(minute);
    }
    map['offset_minutes'] = Variable<int>(offsetMinutes);
    map['days'] = Variable<int>(days);
    if (!nullToAbsent || onceDate != null) {
      map['once_date'] = Variable<String>(onceDate);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['vibrate'] = Variable<bool>(vibrate);
    map['snooze_minutes'] = Variable<int>(snoozeMinutes);
    map['snooze_limit'] = Variable<int>(snoozeLimit);
    map['challenge'] = Variable<String>(challenge);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AlarmsCompanion toCompanion(bool nullToAbsent) {
    return AlarmsCompanion(
      id: Value(id),
      label: Value(label),
      anchor: Value(anchor),
      habitId: habitId == null && nullToAbsent
          ? const Value.absent()
          : Value(habitId),
      minute: minute == null && nullToAbsent
          ? const Value.absent()
          : Value(minute),
      offsetMinutes: Value(offsetMinutes),
      days: Value(days),
      onceDate: onceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(onceDate),
      enabled: Value(enabled),
      vibrate: Value(vibrate),
      snoozeMinutes: Value(snoozeMinutes),
      snoozeLimit: Value(snoozeLimit),
      challenge: Value(challenge),
      createdAt: Value(createdAt),
    );
  }

  factory AlarmRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlarmRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      anchor: serializer.fromJson<String>(json['anchor']),
      habitId: serializer.fromJson<String?>(json['habitId']),
      minute: serializer.fromJson<int?>(json['minute']),
      offsetMinutes: serializer.fromJson<int>(json['offsetMinutes']),
      days: serializer.fromJson<int>(json['days']),
      onceDate: serializer.fromJson<String?>(json['onceDate']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      vibrate: serializer.fromJson<bool>(json['vibrate']),
      snoozeMinutes: serializer.fromJson<int>(json['snoozeMinutes']),
      snoozeLimit: serializer.fromJson<int>(json['snoozeLimit']),
      challenge: serializer.fromJson<String>(json['challenge']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'anchor': serializer.toJson<String>(anchor),
      'habitId': serializer.toJson<String?>(habitId),
      'minute': serializer.toJson<int?>(minute),
      'offsetMinutes': serializer.toJson<int>(offsetMinutes),
      'days': serializer.toJson<int>(days),
      'onceDate': serializer.toJson<String?>(onceDate),
      'enabled': serializer.toJson<bool>(enabled),
      'vibrate': serializer.toJson<bool>(vibrate),
      'snoozeMinutes': serializer.toJson<int>(snoozeMinutes),
      'snoozeLimit': serializer.toJson<int>(snoozeLimit),
      'challenge': serializer.toJson<String>(challenge),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AlarmRow copyWith({
    String? id,
    String? label,
    String? anchor,
    Value<String?> habitId = const Value.absent(),
    Value<int?> minute = const Value.absent(),
    int? offsetMinutes,
    int? days,
    Value<String?> onceDate = const Value.absent(),
    bool? enabled,
    bool? vibrate,
    int? snoozeMinutes,
    int? snoozeLimit,
    String? challenge,
    int? createdAt,
  }) => AlarmRow(
    id: id ?? this.id,
    label: label ?? this.label,
    anchor: anchor ?? this.anchor,
    habitId: habitId.present ? habitId.value : this.habitId,
    minute: minute.present ? minute.value : this.minute,
    offsetMinutes: offsetMinutes ?? this.offsetMinutes,
    days: days ?? this.days,
    onceDate: onceDate.present ? onceDate.value : this.onceDate,
    enabled: enabled ?? this.enabled,
    vibrate: vibrate ?? this.vibrate,
    snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    snoozeLimit: snoozeLimit ?? this.snoozeLimit,
    challenge: challenge ?? this.challenge,
    createdAt: createdAt ?? this.createdAt,
  );
  AlarmRow copyWithCompanion(AlarmsCompanion data) {
    return AlarmRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      anchor: data.anchor.present ? data.anchor.value : this.anchor,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      minute: data.minute.present ? data.minute.value : this.minute,
      offsetMinutes: data.offsetMinutes.present
          ? data.offsetMinutes.value
          : this.offsetMinutes,
      days: data.days.present ? data.days.value : this.days,
      onceDate: data.onceDate.present ? data.onceDate.value : this.onceDate,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      vibrate: data.vibrate.present ? data.vibrate.value : this.vibrate,
      snoozeMinutes: data.snoozeMinutes.present
          ? data.snoozeMinutes.value
          : this.snoozeMinutes,
      snoozeLimit: data.snoozeLimit.present
          ? data.snoozeLimit.value
          : this.snoozeLimit,
      challenge: data.challenge.present ? data.challenge.value : this.challenge,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlarmRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('anchor: $anchor, ')
          ..write('habitId: $habitId, ')
          ..write('minute: $minute, ')
          ..write('offsetMinutes: $offsetMinutes, ')
          ..write('days: $days, ')
          ..write('onceDate: $onceDate, ')
          ..write('enabled: $enabled, ')
          ..write('vibrate: $vibrate, ')
          ..write('snoozeMinutes: $snoozeMinutes, ')
          ..write('snoozeLimit: $snoozeLimit, ')
          ..write('challenge: $challenge, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    anchor,
    habitId,
    minute,
    offsetMinutes,
    days,
    onceDate,
    enabled,
    vibrate,
    snoozeMinutes,
    snoozeLimit,
    challenge,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlarmRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.anchor == this.anchor &&
          other.habitId == this.habitId &&
          other.minute == this.minute &&
          other.offsetMinutes == this.offsetMinutes &&
          other.days == this.days &&
          other.onceDate == this.onceDate &&
          other.enabled == this.enabled &&
          other.vibrate == this.vibrate &&
          other.snoozeMinutes == this.snoozeMinutes &&
          other.snoozeLimit == this.snoozeLimit &&
          other.challenge == this.challenge &&
          other.createdAt == this.createdAt);
}

class AlarmsCompanion extends UpdateCompanion<AlarmRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> anchor;
  final Value<String?> habitId;
  final Value<int?> minute;
  final Value<int> offsetMinutes;
  final Value<int> days;
  final Value<String?> onceDate;
  final Value<bool> enabled;
  final Value<bool> vibrate;
  final Value<int> snoozeMinutes;
  final Value<int> snoozeLimit;
  final Value<String> challenge;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AlarmsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.anchor = const Value.absent(),
    this.habitId = const Value.absent(),
    this.minute = const Value.absent(),
    this.offsetMinutes = const Value.absent(),
    this.days = const Value.absent(),
    this.onceDate = const Value.absent(),
    this.enabled = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
    this.snoozeLimit = const Value.absent(),
    this.challenge = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlarmsCompanion.insert({
    required String id,
    this.label = const Value.absent(),
    required String anchor,
    this.habitId = const Value.absent(),
    this.minute = const Value.absent(),
    this.offsetMinutes = const Value.absent(),
    this.days = const Value.absent(),
    this.onceDate = const Value.absent(),
    this.enabled = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
    this.snoozeLimit = const Value.absent(),
    this.challenge = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       anchor = Value(anchor),
       createdAt = Value(createdAt);
  static Insertable<AlarmRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? anchor,
    Expression<String>? habitId,
    Expression<int>? minute,
    Expression<int>? offsetMinutes,
    Expression<int>? days,
    Expression<String>? onceDate,
    Expression<bool>? enabled,
    Expression<bool>? vibrate,
    Expression<int>? snoozeMinutes,
    Expression<int>? snoozeLimit,
    Expression<String>? challenge,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (anchor != null) 'anchor': anchor,
      if (habitId != null) 'habit_id': habitId,
      if (minute != null) 'minute': minute,
      if (offsetMinutes != null) 'offset_minutes': offsetMinutes,
      if (days != null) 'days': days,
      if (onceDate != null) 'once_date': onceDate,
      if (enabled != null) 'enabled': enabled,
      if (vibrate != null) 'vibrate': vibrate,
      if (snoozeMinutes != null) 'snooze_minutes': snoozeMinutes,
      if (snoozeLimit != null) 'snooze_limit': snoozeLimit,
      if (challenge != null) 'challenge': challenge,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlarmsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? anchor,
    Value<String?>? habitId,
    Value<int?>? minute,
    Value<int>? offsetMinutes,
    Value<int>? days,
    Value<String?>? onceDate,
    Value<bool>? enabled,
    Value<bool>? vibrate,
    Value<int>? snoozeMinutes,
    Value<int>? snoozeLimit,
    Value<String>? challenge,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AlarmsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      anchor: anchor ?? this.anchor,
      habitId: habitId ?? this.habitId,
      minute: minute ?? this.minute,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      days: days ?? this.days,
      onceDate: onceDate ?? this.onceDate,
      enabled: enabled ?? this.enabled,
      vibrate: vibrate ?? this.vibrate,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      snoozeLimit: snoozeLimit ?? this.snoozeLimit,
      challenge: challenge ?? this.challenge,
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
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (anchor.present) {
      map['anchor'] = Variable<String>(anchor.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (offsetMinutes.present) {
      map['offset_minutes'] = Variable<int>(offsetMinutes.value);
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    if (onceDate.present) {
      map['once_date'] = Variable<String>(onceDate.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (vibrate.present) {
      map['vibrate'] = Variable<bool>(vibrate.value);
    }
    if (snoozeMinutes.present) {
      map['snooze_minutes'] = Variable<int>(snoozeMinutes.value);
    }
    if (snoozeLimit.present) {
      map['snooze_limit'] = Variable<int>(snoozeLimit.value);
    }
    if (challenge.present) {
      map['challenge'] = Variable<String>(challenge.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlarmsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('anchor: $anchor, ')
          ..write('habitId: $habitId, ')
          ..write('minute: $minute, ')
          ..write('offsetMinutes: $offsetMinutes, ')
          ..write('days: $days, ')
          ..write('onceDate: $onceDate, ')
          ..write('enabled: $enabled, ')
          ..write('vibrate: $vibrate, ')
          ..write('snoozeMinutes: $snoozeMinutes, ')
          ..write('snoozeLimit: $snoozeLimit, ')
          ..write('challenge: $challenge, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurrenceMeta = const VerificationMeta(
    'occurrence',
  );
  @override
  late final GeneratedColumn<String> occurrence = GeneratedColumn<String>(
    'occurrence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alarmIdMeta = const VerificationMeta(
    'alarmId',
  );
  @override
  late final GeneratedColumn<String> alarmId = GeneratedColumn<String>(
    'alarm_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packageMeta = const VerificationMeta(
    'package',
  );
  @override
  late final GeneratedColumn<String> package = GeneratedColumn<String>(
    'package',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    at,
    kind,
    habitId,
    occurrence,
    alarmId,
    package,
    detail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    }
    if (data.containsKey('occurrence')) {
      context.handle(
        _occurrenceMeta,
        occurrence.isAcceptableOrUnknown(data['occurrence']!, _occurrenceMeta),
      );
    }
    if (data.containsKey('alarm_id')) {
      context.handle(
        _alarmIdMeta,
        alarmId.isAcceptableOrUnknown(data['alarm_id']!, _alarmIdMeta),
      );
    }
    if (data.containsKey('package')) {
      context.handle(
        _packageMeta,
        package.isAcceptableOrUnknown(data['package']!, _packageMeta),
      );
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      ),
      occurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence'],
      ),
      alarmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alarm_id'],
      ),
      package: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package'],
      ),
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final String id;
  final int at;
  final String kind;
  final String? habitId;
  final String? occurrence;
  final String? alarmId;
  final String? package;
  final String? detail;
  const EventRow({
    required this.id,
    required this.at,
    required this.kind,
    this.habitId,
    this.occurrence,
    this.alarmId,
    this.package,
    this.detail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['at'] = Variable<int>(at);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || habitId != null) {
      map['habit_id'] = Variable<String>(habitId);
    }
    if (!nullToAbsent || occurrence != null) {
      map['occurrence'] = Variable<String>(occurrence);
    }
    if (!nullToAbsent || alarmId != null) {
      map['alarm_id'] = Variable<String>(alarmId);
    }
    if (!nullToAbsent || package != null) {
      map['package'] = Variable<String>(package);
    }
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      at: Value(at),
      kind: Value(kind),
      habitId: habitId == null && nullToAbsent
          ? const Value.absent()
          : Value(habitId),
      occurrence: occurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrence),
      alarmId: alarmId == null && nullToAbsent
          ? const Value.absent()
          : Value(alarmId),
      package: package == null && nullToAbsent
          ? const Value.absent()
          : Value(package),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
    );
  }

  factory EventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<String>(json['id']),
      at: serializer.fromJson<int>(json['at']),
      kind: serializer.fromJson<String>(json['kind']),
      habitId: serializer.fromJson<String?>(json['habitId']),
      occurrence: serializer.fromJson<String?>(json['occurrence']),
      alarmId: serializer.fromJson<String?>(json['alarmId']),
      package: serializer.fromJson<String?>(json['package']),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'at': serializer.toJson<int>(at),
      'kind': serializer.toJson<String>(kind),
      'habitId': serializer.toJson<String?>(habitId),
      'occurrence': serializer.toJson<String?>(occurrence),
      'alarmId': serializer.toJson<String?>(alarmId),
      'package': serializer.toJson<String?>(package),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  EventRow copyWith({
    String? id,
    int? at,
    String? kind,
    Value<String?> habitId = const Value.absent(),
    Value<String?> occurrence = const Value.absent(),
    Value<String?> alarmId = const Value.absent(),
    Value<String?> package = const Value.absent(),
    Value<String?> detail = const Value.absent(),
  }) => EventRow(
    id: id ?? this.id,
    at: at ?? this.at,
    kind: kind ?? this.kind,
    habitId: habitId.present ? habitId.value : this.habitId,
    occurrence: occurrence.present ? occurrence.value : this.occurrence,
    alarmId: alarmId.present ? alarmId.value : this.alarmId,
    package: package.present ? package.value : this.package,
    detail: detail.present ? detail.value : this.detail,
  );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      kind: data.kind.present ? data.kind.value : this.kind,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      occurrence: data.occurrence.present
          ? data.occurrence.value
          : this.occurrence,
      alarmId: data.alarmId.present ? data.alarmId.value : this.alarmId,
      package: data.package.present ? data.package.value : this.package,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('kind: $kind, ')
          ..write('habitId: $habitId, ')
          ..write('occurrence: $occurrence, ')
          ..write('alarmId: $alarmId, ')
          ..write('package: $package, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, at, kind, habitId, occurrence, alarmId, package, detail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.at == this.at &&
          other.kind == this.kind &&
          other.habitId == this.habitId &&
          other.occurrence == this.occurrence &&
          other.alarmId == this.alarmId &&
          other.package == this.package &&
          other.detail == this.detail);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<String> id;
  final Value<int> at;
  final Value<String> kind;
  final Value<String?> habitId;
  final Value<String?> occurrence;
  final Value<String?> alarmId;
  final Value<String?> package;
  final Value<String?> detail;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.kind = const Value.absent(),
    this.habitId = const Value.absent(),
    this.occurrence = const Value.absent(),
    this.alarmId = const Value.absent(),
    this.package = const Value.absent(),
    this.detail = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required int at,
    required String kind,
    this.habitId = const Value.absent(),
    this.occurrence = const Value.absent(),
    this.alarmId = const Value.absent(),
    this.package = const Value.absent(),
    this.detail = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       at = Value(at),
       kind = Value(kind);
  static Insertable<EventRow> custom({
    Expression<String>? id,
    Expression<int>? at,
    Expression<String>? kind,
    Expression<String>? habitId,
    Expression<String>? occurrence,
    Expression<String>? alarmId,
    Expression<String>? package,
    Expression<String>? detail,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (kind != null) 'kind': kind,
      if (habitId != null) 'habit_id': habitId,
      if (occurrence != null) 'occurrence': occurrence,
      if (alarmId != null) 'alarm_id': alarmId,
      if (package != null) 'package': package,
      if (detail != null) 'detail': detail,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<int>? at,
    Value<String>? kind,
    Value<String?>? habitId,
    Value<String?>? occurrence,
    Value<String?>? alarmId,
    Value<String?>? package,
    Value<String?>? detail,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      kind: kind ?? this.kind,
      habitId: habitId ?? this.habitId,
      occurrence: occurrence ?? this.occurrence,
      alarmId: alarmId ?? this.alarmId,
      package: package ?? this.package,
      detail: detail ?? this.detail,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (occurrence.present) {
      map['occurrence'] = Variable<String>(occurrence.value);
    }
    if (alarmId.present) {
      map['alarm_id'] = Variable<String>(alarmId.value);
    }
    if (package.present) {
      map['package'] = Variable<String>(package.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('kind: $kind, ')
          ..write('habitId: $habitId, ')
          ..write('occurrence: $occurrence, ')
          ..write('alarmId: $alarmId, ')
          ..write('package: $package, ')
          ..write('detail: $detail, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitAppsTable habitApps = $HabitAppsTable(this);
  late final $AlarmsTable alarms = $AlarmsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final Index alarmsHabit = Index(
    'alarms_habit',
    'CREATE INDEX alarms_habit ON alarms (habit_id)',
  );
  late final Index eventsAt = Index(
    'events_at',
    'CREATE INDEX events_at ON events (at)',
  );
  late final Index eventsHabitKind = Index(
    'events_habit_kind',
    'CREATE INDEX events_habit_kind ON events (habit_id, kind, at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    habits,
    habitApps,
    alarms,
    events,
    alarmsHabit,
    eventsAt,
    eventsHabitKind,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_apps', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('alarms', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<int> headsUpMinutes,
      Value<int> hardBufferMinutes,
      Value<int> pauseMinutes,
      Value<int> pauseCooldownSeconds,
      Value<String> pausePhrase,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<int> headsUpMinutes,
      Value<int> hardBufferMinutes,
      Value<int> pauseMinutes,
      Value<int> pauseCooldownSeconds,
      Value<String> pausePhrase,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

  ColumnFilters<int> get headsUpMinutes => $composableBuilder(
    column: $table.headsUpMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hardBufferMinutes => $composableBuilder(
    column: $table.hardBufferMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauseMinutes => $composableBuilder(
    column: $table.pauseMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauseCooldownSeconds => $composableBuilder(
    column: $table.pauseCooldownSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pausePhrase => $composableBuilder(
    column: $table.pausePhrase,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

  ColumnOrderings<int> get headsUpMinutes => $composableBuilder(
    column: $table.headsUpMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hardBufferMinutes => $composableBuilder(
    column: $table.hardBufferMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauseMinutes => $composableBuilder(
    column: $table.pauseMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauseCooldownSeconds => $composableBuilder(
    column: $table.pauseCooldownSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pausePhrase => $composableBuilder(
    column: $table.pausePhrase,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get headsUpMinutes => $composableBuilder(
    column: $table.headsUpMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hardBufferMinutes => $composableBuilder(
    column: $table.hardBufferMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pauseMinutes => $composableBuilder(
    column: $table.pauseMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pauseCooldownSeconds => $composableBuilder(
    column: $table.pauseCooldownSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pausePhrase => $composableBuilder(
    column: $table.pausePhrase,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingsRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> headsUpMinutes = const Value.absent(),
                Value<int> hardBufferMinutes = const Value.absent(),
                Value<int> pauseMinutes = const Value.absent(),
                Value<int> pauseCooldownSeconds = const Value.absent(),
                Value<String> pausePhrase = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                headsUpMinutes: headsUpMinutes,
                hardBufferMinutes: hardBufferMinutes,
                pauseMinutes: pauseMinutes,
                pauseCooldownSeconds: pauseCooldownSeconds,
                pausePhrase: pausePhrase,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> headsUpMinutes = const Value.absent(),
                Value<int> hardBufferMinutes = const Value.absent(),
                Value<int> pauseMinutes = const Value.absent(),
                Value<int> pauseCooldownSeconds = const Value.absent(),
                Value<String> pausePhrase = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                headsUpMinutes: headsUpMinutes,
                hardBufferMinutes: hardBufferMinutes,
                pauseMinutes: pauseMinutes,
                pauseCooldownSeconds: pauseCooldownSeconds,
                pausePhrase: pausePhrase,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingsRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingsRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>),
      SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      required String id,
      required String name,
      required int days,
      required int startMinute,
      required int endMinute,
      required String strictness,
      Value<int> priority,
      Value<bool> dnd,
      Value<bool> enabled,
      required int createdAt,
      Value<int?> archivedAt,
      Value<int> rowid,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> days,
      Value<int> startMinute,
      Value<int> endMinute,
      Value<String> strictness,
      Value<int> priority,
      Value<bool> dnd,
      Value<bool> enabled,
      Value<int> createdAt,
      Value<int?> archivedAt,
      Value<int> rowid,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, HabitRow> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitAppsTable, List<HabitAppRow>>
  _habitAppsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitApps,
    aliasName: 'habits__id__habit_apps__habit_id',
  );

  $$HabitAppsTableProcessedTableManager get habitAppsRefs {
    final manager = $$HabitAppsTableTableManager(
      $_db,
      $_db.habitApps,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitAppsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AlarmsTable, List<AlarmRow>> _alarmsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.alarms,
    aliasName: 'habits__id__alarms__habit_id',
  );

  $$AlarmsTableProcessedTableManager get alarmsRefs {
    final manager = $$AlarmsTableTableManager(
      $_db,
      $_db.alarms,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_alarmsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
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

  ColumnFilters<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strictness => $composableBuilder(
    column: $table.strictness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dnd => $composableBuilder(
    column: $table.dnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitAppsRefs(
    Expression<bool> Function($$HabitAppsTableFilterComposer f) f,
  ) {
    final $$HabitAppsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitApps,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitAppsTableFilterComposer(
            $db: $db,
            $table: $db.habitApps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> alarmsRefs(
    Expression<bool> Function($$AlarmsTableFilterComposer f) f,
  ) {
    final $$AlarmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alarms,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlarmsTableFilterComposer(
            $db: $db,
            $table: $db.alarms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
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

  ColumnOrderings<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strictness => $composableBuilder(
    column: $table.strictness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dnd => $composableBuilder(
    column: $table.dnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
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

  GeneratedColumn<int> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<String> get strictness => $composableBuilder(
    column: $table.strictness,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get dnd =>
      $composableBuilder(column: $table.dnd, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> habitAppsRefs<T extends Object>(
    Expression<T> Function($$HabitAppsTableAnnotationComposer a) f,
  ) {
    final $$HabitAppsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitApps,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitAppsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitApps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> alarmsRefs<T extends Object>(
    Expression<T> Function($$AlarmsTableAnnotationComposer a) f,
  ) {
    final $$AlarmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alarms,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlarmsTableAnnotationComposer(
            $db: $db,
            $table: $db.alarms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          HabitRow,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (HabitRow, $$HabitsTableReferences),
          HabitRow,
          PrefetchHooks Function({bool habitAppsRefs, bool alarmsRefs})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> days = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<String> strictness = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> dnd = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                days: days,
                startMinute: startMinute,
                endMinute: endMinute,
                strictness: strictness,
                priority: priority,
                dnd: dnd,
                enabled: enabled,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int days,
                required int startMinute,
                required int endMinute,
                required String strictness,
                Value<int> priority = const Value.absent(),
                Value<bool> dnd = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                required int createdAt,
                Value<int?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                days: days,
                startMinute: startMinute,
                endMinute: endMinute,
                strictness: strictness,
                priority: priority,
                dnd: dnd,
                enabled: enabled,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HabitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({habitAppsRefs = false, alarmsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (habitAppsRefs) db.habitApps,
                if (alarmsRefs) db.alarms,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitAppsRefs)
                    await $_getPrefetchedData<
                      HabitRow,
                      $HabitsTable,
                      HabitAppRow
                    >(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences
                          ._habitAppsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).habitAppsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                  if (alarmsRefs)
                    await $_getPrefetchedData<HabitRow, $HabitsTable, AlarmRow>(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences._alarmsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).alarmsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      HabitRow,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (HabitRow, $$HabitsTableReferences),
      HabitRow,
      PrefetchHooks Function({bool habitAppsRefs, bool alarmsRefs})
    >;
typedef $$HabitAppsTableCreateCompanionBuilder =
    HabitAppsCompanion Function({
      required String habitId,
      required String package,
      required String label,
      Value<int> rowid,
    });
typedef $$HabitAppsTableUpdateCompanionBuilder =
    HabitAppsCompanion Function({
      Value<String> habitId,
      Value<String> package,
      Value<String> label,
      Value<int> rowid,
    });

final class $$HabitAppsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitAppsTable, HabitAppRow> {
  $$HabitAppsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('habit_apps__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitAppsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitAppsTable> {
  $$HabitAppsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitAppsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitAppsTable> {
  $$HabitAppsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitAppsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitAppsTable> {
  $$HabitAppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get package =>
      $composableBuilder(column: $table.package, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitAppsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitAppsTable,
          HabitAppRow,
          $$HabitAppsTableFilterComposer,
          $$HabitAppsTableOrderingComposer,
          $$HabitAppsTableAnnotationComposer,
          $$HabitAppsTableCreateCompanionBuilder,
          $$HabitAppsTableUpdateCompanionBuilder,
          (HabitAppRow, $$HabitAppsTableReferences),
          HabitAppRow,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitAppsTableTableManager(_$AppDatabase db, $HabitAppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitAppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitAppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitAppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> habitId = const Value.absent(),
                Value<String> package = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitAppsCompanion(
                habitId: habitId,
                package: package,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitId,
                required String package,
                required String label,
                Value<int> rowid = const Value.absent(),
              }) => HabitAppsCompanion.insert(
                habitId: habitId,
                package: package,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitAppsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
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
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitAppsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$HabitAppsTableReferences
                                    ._habitIdTable(db)
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

typedef $$HabitAppsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitAppsTable,
      HabitAppRow,
      $$HabitAppsTableFilterComposer,
      $$HabitAppsTableOrderingComposer,
      $$HabitAppsTableAnnotationComposer,
      $$HabitAppsTableCreateCompanionBuilder,
      $$HabitAppsTableUpdateCompanionBuilder,
      (HabitAppRow, $$HabitAppsTableReferences),
      HabitAppRow,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$AlarmsTableCreateCompanionBuilder =
    AlarmsCompanion Function({
      required String id,
      Value<String> label,
      required String anchor,
      Value<String?> habitId,
      Value<int?> minute,
      Value<int> offsetMinutes,
      Value<int> days,
      Value<String?> onceDate,
      Value<bool> enabled,
      Value<bool> vibrate,
      Value<int> snoozeMinutes,
      Value<int> snoozeLimit,
      Value<String> challenge,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$AlarmsTableUpdateCompanionBuilder =
    AlarmsCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> anchor,
      Value<String?> habitId,
      Value<int?> minute,
      Value<int> offsetMinutes,
      Value<int> days,
      Value<String?> onceDate,
      Value<bool> enabled,
      Value<bool> vibrate,
      Value<int> snoozeMinutes,
      Value<int> snoozeLimit,
      Value<String> challenge,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$AlarmsTableReferences
    extends BaseReferences<_$AppDatabase, $AlarmsTable, AlarmRow> {
  $$AlarmsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('alarms__habit_id__habits__id');

  $$HabitsTableProcessedTableManager? get habitId {
    final $_column = $_itemColumn<String>('habit_id');
    if ($_column == null) return null;
    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlarmsTableFilterComposer
    extends Composer<_$AppDatabase, $AlarmsTable> {
  $$AlarmsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onceDate => $composableBuilder(
    column: $table.onceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeLimit => $composableBuilder(
    column: $table.snoozeLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get challenge => $composableBuilder(
    column: $table.challenge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlarmsTable> {
  $$AlarmsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onceDate => $composableBuilder(
    column: $table.onceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeLimit => $composableBuilder(
    column: $table.snoozeLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get challenge => $composableBuilder(
    column: $table.challenge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlarmsTable> {
  $$AlarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get anchor =>
      $composableBuilder(column: $table.anchor, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<String> get onceDate =>
      $composableBuilder(column: $table.onceDate, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get vibrate =>
      $composableBuilder(column: $table.vibrate, builder: (column) => column);

  GeneratedColumn<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozeLimit => $composableBuilder(
    column: $table.snoozeLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get challenge =>
      $composableBuilder(column: $table.challenge, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlarmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlarmsTable,
          AlarmRow,
          $$AlarmsTableFilterComposer,
          $$AlarmsTableOrderingComposer,
          $$AlarmsTableAnnotationComposer,
          $$AlarmsTableCreateCompanionBuilder,
          $$AlarmsTableUpdateCompanionBuilder,
          (AlarmRow, $$AlarmsTableReferences),
          AlarmRow,
          PrefetchHooks Function({bool habitId})
        > {
  $$AlarmsTableTableManager(_$AppDatabase db, $AlarmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> anchor = const Value.absent(),
                Value<String?> habitId = const Value.absent(),
                Value<int?> minute = const Value.absent(),
                Value<int> offsetMinutes = const Value.absent(),
                Value<int> days = const Value.absent(),
                Value<String?> onceDate = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
                Value<int> snoozeLimit = const Value.absent(),
                Value<String> challenge = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlarmsCompanion(
                id: id,
                label: label,
                anchor: anchor,
                habitId: habitId,
                minute: minute,
                offsetMinutes: offsetMinutes,
                days: days,
                onceDate: onceDate,
                enabled: enabled,
                vibrate: vibrate,
                snoozeMinutes: snoozeMinutes,
                snoozeLimit: snoozeLimit,
                challenge: challenge,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> label = const Value.absent(),
                required String anchor,
                Value<String?> habitId = const Value.absent(),
                Value<int?> minute = const Value.absent(),
                Value<int> offsetMinutes = const Value.absent(),
                Value<int> days = const Value.absent(),
                Value<String?> onceDate = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
                Value<int> snoozeLimit = const Value.absent(),
                Value<String> challenge = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AlarmsCompanion.insert(
                id: id,
                label: label,
                anchor: anchor,
                habitId: habitId,
                minute: minute,
                offsetMinutes: offsetMinutes,
                days: days,
                onceDate: onceDate,
                enabled: enabled,
                vibrate: vibrate,
                snoozeMinutes: snoozeMinutes,
                snoozeLimit: snoozeLimit,
                challenge: challenge,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AlarmsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
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
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$AlarmsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$AlarmsTableReferences
                                    ._habitIdTable(db)
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

typedef $$AlarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlarmsTable,
      AlarmRow,
      $$AlarmsTableFilterComposer,
      $$AlarmsTableOrderingComposer,
      $$AlarmsTableAnnotationComposer,
      $$AlarmsTableCreateCompanionBuilder,
      $$AlarmsTableUpdateCompanionBuilder,
      (AlarmRow, $$AlarmsTableReferences),
      AlarmRow,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required String id,
      required int at,
      required String kind,
      Value<String?> habitId,
      Value<String?> occurrence,
      Value<String?> alarmId,
      Value<String?> package,
      Value<String?> detail,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<String> id,
      Value<int> at,
      Value<String> kind,
      Value<String?> habitId,
      Value<String?> occurrence,
      Value<String?> alarmId,
      Value<String?> package,
      Value<String?> detail,
      Value<int> rowid,
    });

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrence => $composableBuilder(
    column: $table.occurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alarmId => $composableBuilder(
    column: $table.alarmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrence => $composableBuilder(
    column: $table.occurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alarmId => $composableBuilder(
    column: $table.alarmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get package => $composableBuilder(
    column: $table.package,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get occurrence => $composableBuilder(
    column: $table.occurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alarmId =>
      $composableBuilder(column: $table.alarmId, builder: (column) => column);

  GeneratedColumn<String> get package =>
      $composableBuilder(column: $table.package, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          EventRow,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
          EventRow,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> habitId = const Value.absent(),
                Value<String?> occurrence = const Value.absent(),
                Value<String?> alarmId = const Value.absent(),
                Value<String?> package = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                at: at,
                kind: kind,
                habitId: habitId,
                occurrence: occurrence,
                alarmId: alarmId,
                package: package,
                detail: detail,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int at,
                required String kind,
                Value<String?> habitId = const Value.absent(),
                Value<String?> occurrence = const Value.absent(),
                Value<String?> alarmId = const Value.absent(),
                Value<String?> package = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                at: at,
                kind: kind,
                habitId: habitId,
                occurrence: occurrence,
                alarmId: alarmId,
                package: package,
                detail: detail,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      EventRow,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
      EventRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitAppsTableTableManager get habitApps =>
      $$HabitAppsTableTableManager(_db, _db.habitApps);
  $$AlarmsTableTableManager get alarms =>
      $$AlarmsTableTableManager(_db, _db.alarms);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
}
