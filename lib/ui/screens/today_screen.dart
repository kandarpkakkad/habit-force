import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../app/services.dart';
import '../../common/clock_time.dart';
import '../../common/dates.dart';
import '../../domain/alarms/alarm.dart';
import '../../domain/habits/habit.dart';
import '../../domain/schedule/planner.dart';
import '../../domain/settings/settings.dart';
import '../../platform/bridge/native_bridge.dart';
import '../../platform/bridge/plan.dart';
import '../../platform/permissions/permissions.dart';
import '../theme/format.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'habit_editor_screen.dart';
import 'settings_screen.dart';
import 'setup_screen.dart';

DateTime _at(DateTime date, int minute) => DateTime(date.year, date.month, date.day, 0, minute);

/// S1 — what is running now, and the rest of today, worked out by the same
/// planner that feeds Kotlin, so the screen and the blocker cannot disagree.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // "37 min left" has to move without anyone touching the screen.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('Today, ${dateLabel(now)}'),
        actions: [
          ListenableBuilder(
            listenable: s.permissions,
            builder: (context, _) => IconButton(
              tooltip: 'Setup',
              icon: Badge(
                isLabelVisible: s.permissions.severity != Severity.none,
                child: const Icon(Icons.verified_user_outlined),
              ),
              onPressed: () => _push(context, const SetupScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _push(context, const SettingsScreen()),
          ),
        ],
      ),
      body: StreamBuilder<List<Habit>>(
        stream: s.habits.watchAll(),
        builder: (context, habits) => StreamBuilder<List<Alarm>>(
          stream: s.alarms.watchAll(),
          builder: (context, alarms) => StreamBuilder<AppSettings>(
            stream: s.settings.watch(),
            builder: (context, settings) {
              if (!habits.hasData || !alarms.hasData) return const SizedBox.shrink();
              final plan = buildPlan(
                habits: habits.data!,
                alarms: alarms.data!,
                settings: settings.data ?? AppSettings.defaults,
                today: now,
                generatedAt: now.millisecondsSinceEpoch,
              );
              return _body(context, s, plan, now, hasHabits: habits.data!.any((h) => h.archivedAt == null));
            },
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, Services s, Plan plan, DateTime now, {required bool hasHabits}) {
    final today = dateOnly(now);
    // The planner keeps yesterday's windows only when they run into today.
    final todays = [
      for (final w in plan.windows)
        if (w.date == today || w.date == addDays(today, -1)) w,
    ];
    final running = [
      for (final w in todays)
        if (!now.isBefore(_at(w.date, w.start)) && now.isBefore(_at(w.date, w.end))) w,
    ]..sort((a, b) {
        if (a.hard != b.hard) return a.hard ? -1 : 1;
        return b.priority.compareTo(a.priority);
      });
    final alarms = [for (final a in plan.alarms) if (a.date == today) a];

    final rows = <(DateTime, Widget)>[
      for (final w in todays) (_at(w.date, w.start), _windowRow(context, w, now)),
      for (final a in alarms) (_at(a.date, a.minute), _alarmRow(context, a, now)),
    ]..sort((x, y) => x.$1.compareTo(y.$1));

    return ListView(children: [
      _PermissionBanner(s.permissions),
      _PlanBanner(s),
      _nowCard(context, running, todays, now),
      if (!hasHabits)
        EmptyState(
          text: 'No habits yet',
          action: 'Add a habit',
          onAction: () => _push(context, const HabitEditorScreen()),
        )
      else ...[
        const SectionHeader('Today'),
        if (rows.isEmpty)
          const ListTile(title: Text('Nothing planned today'))
        else
          for (final r in rows) r.$2,
      ],
      const SizedBox(height: 24),
    ]);
  }

  Widget _nowCard(BuildContext context, List<PlanWindow> running, List<PlanWindow> todays, DateTime now) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    if (running.isNotEmpty) {
      final w = running.first;
      final end = _at(w.date, w.end);
      final left = end.difference(now).inMinutes + 1;
      final apps = {for (final r in running) ...r.apps.map((a) => a.package)}.length;
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        color: c.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(w.name, style: t.headlineSmall)),
              StrictnessBadge(hard: w.hard),
            ]),
            const SizedBox(height: 4),
            Text('until ${hhmm(w.end)} · ${durationLabel(left)} left', style: times(t.bodyLarge)),
            if (apps > 0) Text(apps == 1 ? '1 app blocked' : '$apps apps blocked'),
            if (running.length > 1) Text('Also running: ${joinNames([for (final r in running.skip(1)) r.name])}'),
          ]),
        ),
      );
    }
    final next = [for (final w in todays) if (_at(w.date, w.start).isAfter(now)) w]
      ..sort((a, b) => _at(a.date, a.start).compareTo(_at(b.date, b.start)));
    final text = next.isEmpty ? 'Nothing more planned today' : 'Free until ${hhmm(next.first.start)}';
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ListTile(
        title: Text(text, style: times(t.titleMedium)),
        subtitle: next.isEmpty ? null : Text('Next: ${next.first.name}'),
      ),
    );
  }

  Widget _windowRow(BuildContext context, PlanWindow w, DateTime now) {
    final past = !now.isBefore(_at(w.date, w.end));
    final dim = Theme.of(context).colorScheme.onSurfaceVariant;
    return ListTile(
      leading: SizedBox(
        width: 96,
        child: Text('${hhmm(w.start)}–${hhmm(w.end)}', style: times(TextStyle(color: past ? dim : null))),
      ),
      title: Text(w.name, style: TextStyle(color: past ? dim : null)),
      trailing: StrictnessBadge(hard: w.hard),
    );
  }

  Widget _alarmRow(BuildContext context, PlanAlarm a, DateTime now) {
    final past = !now.isBefore(_at(a.date, a.minute));
    final dim = Theme.of(context).colorScheme.onSurfaceVariant;
    return ListTile(
      leading: SizedBox(
        width: 96,
        child: Text(hhmm(a.minute), style: times(TextStyle(color: past ? dim : null))),
      ),
      title: Text(a.label.isEmpty ? 'Alarm' : a.label, style: TextStyle(color: past ? dim : null)),
      trailing: Icon(Icons.alarm, color: dim),
    );
  }
}

void _push(BuildContext context, Widget screen) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

class _PermissionBanner extends StatelessWidget {
  final PermissionsController permissions;

  const _PermissionBanner(this.permissions);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: permissions,
        builder: (context, _) {
          final severity = permissions.severity;
          if (severity == Severity.none) return const SizedBox.shrink();
          final c = Theme.of(context).colorScheme;
          final missing = permissions.missing.toList();
          final required = missing.where((k) => k.required).toList();
          final text = required.isNotEmpty
              ? '${required.first.without} ${missing.length == 1 ? '1 permission' : '${missing.length} permissions'} missing.'
              : '${missing.length == 1 ? '1 optional permission' : '${missing.length} optional permissions'} missing.';
          return Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            color: severity == Severity.required ? c.errorContainer : c.surfaceContainerHighest,
            child: ListTile(
              leading: Icon(
                Icons.warning_amber_rounded,
                color: severity == Severity.required ? c.onErrorContainer : Colors.amber.shade700,
              ),
              title: Text(text),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _push(context, const SetupScreen()),
            ),
          );
        },
      );
}

class _PlanBanner extends StatelessWidget {
  final Services s;

  const _PlanBanner(this.s);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([s.publisher.state, s.planStatus]),
        builder: (context, _) {
          final publish = s.publisher.state.value;
          final status = s.planStatus.value;
          String? problem;
          if (publish != null && !publish.ok) {
            problem = 'Could not hand the schedule to Android: ${publish.error}';
          } else if (status != null && status.state != PlanState.ok) {
            problem = switch (status.state) {
              PlanState.missing => 'No schedule has been handed to Android yet.',
              PlanState.unreadable => "Android's copy of the schedule can't be read: ${status.error ?? 'no reason given'}",
              PlanState.expired => 'The schedule ran out on ${status.horizon ?? 'an earlier day'}.',
              PlanState.ok => null,
            };
          }
          if (problem == null) return const SizedBox.shrink();
          return Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              title: Text(problem),
              trailing: TextButton(onPressed: s.refresh, child: const Text('Try again')),
            ),
          );
        },
      );
}
