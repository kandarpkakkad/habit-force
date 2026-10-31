import 'package:drift/drift.dart';

import '../../platform/storage/database.dart';

class AppSettings {
  final int headsUpMinutes;
  final int hardBufferMinutes;
  final int pauseMinutes;
  final int pauseCooldownSeconds;
  final String pausePhrase;

  const AppSettings({
    required this.headsUpMinutes,
    required this.hardBufferMinutes,
    required this.pauseMinutes,
    required this.pauseCooldownSeconds,
    required this.pausePhrase,
  });

  /// The schema's defaults. Used by tests and as a fallback before the first
  /// read; the row itself is created by `onCreate`.
  static const defaults = AppSettings(
    headsUpMinutes: 10,
    hardBufferMinutes: 15,
    pauseMinutes: 5,
    pauseCooldownSeconds: 60,
    pausePhrase: 'I am choosing to break my own rule',
  );

  factory AppSettings.fromRow(SettingsRow r) => AppSettings(
        headsUpMinutes: r.headsUpMinutes,
        hardBufferMinutes: r.hardBufferMinutes,
        pauseMinutes: r.pauseMinutes,
        pauseCooldownSeconds: r.pauseCooldownSeconds,
        pausePhrase: r.pausePhrase,
      );

  AppSettings copyWith({
    int? headsUpMinutes,
    int? hardBufferMinutes,
    int? pauseMinutes,
    int? pauseCooldownSeconds,
    String? pausePhrase,
  }) =>
      AppSettings(
        headsUpMinutes: headsUpMinutes ?? this.headsUpMinutes,
        hardBufferMinutes: hardBufferMinutes ?? this.hardBufferMinutes,
        pauseMinutes: pauseMinutes ?? this.pauseMinutes,
        pauseCooldownSeconds: pauseCooldownSeconds ?? this.pauseCooldownSeconds,
        pausePhrase: pausePhrase ?? this.pausePhrase,
      );
}

/// Field → message, mirroring the CHECKs (docs/01-platform/storage/lld.md §4).
Map<String, String> validateSettings(AppSettings s) => {
      if (s.headsUpMinutes < 0 || s.headsUpMinutes > 120) 'headsUp': 'Between 0 and 120 minutes',
      if (s.hardBufferMinutes < 0 || s.hardBufferMinutes > 120) 'buffer': 'Between 0 and 120 minutes',
      if (s.pauseMinutes < 1 || s.pauseMinutes > 30) 'pauseMinutes': 'Between 1 and 30 minutes',
      if (s.pauseCooldownSeconds < 10 || s.pauseCooldownSeconds > 600)
        'cooldown': 'Between 10 seconds and 10 minutes',
      if (s.pausePhrase.trim().length < 8 || s.pausePhrase.trim().length > 80)
        'phrase': 'Use 8 to 80 characters',
    };

class SettingsRepository {
  final AppDatabase db;

  /// Set by boot: republish the plan after a change, since the plan carries
  /// the pause settings and the heads-up time.
  Future<void> Function() onChanged = () async {};

  SettingsRepository(this.db);

  Stream<AppSettings> watch() =>
      (db.select(db.settings)..where((t) => t.id.equals(1))).watchSingle().map(AppSettings.fromRow);

  Future<AppSettings> get() async =>
      AppSettings.fromRow(await (db.select(db.settings)..where((t) => t.id.equals(1))).getSingle());

  Future<void> update(AppSettings s) async {
    await (db.update(db.settings)..where((t) => t.id.equals(1))).write(SettingsCompanion(
      headsUpMinutes: Value(s.headsUpMinutes),
      hardBufferMinutes: Value(s.hardBufferMinutes),
      pauseMinutes: Value(s.pauseMinutes),
      pauseCooldownSeconds: Value(s.pauseCooldownSeconds),
      pausePhrase: Value(s.pausePhrase.trim()),
    ));
    await onChanged();
  }
}
