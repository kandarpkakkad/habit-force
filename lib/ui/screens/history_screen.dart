import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../common/dates.dart';
import '../../domain/alarms/alarm.dart';
import '../../domain/habits/habit.dart';
import '../../domain/history/history.dart';
import '../../platform/storage/database.dart';
import '../theme/format.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// S4 — streaks, then the last 14 days, day by day.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<void> _refresh() async {
    final s = AppScope.of(context);
    await s.collect();
    final torn = s.lastCollect.value?.torn ?? 0;
    if (mounted && torn > 0) {
      say(context, '$torn ${torn == 1 ? 'record was' : 'records were'} damaged and could not be read.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final since = addDays(dateOnly(DateTime.now()), -13);
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<List<Habit>>(
          stream: s.habits.watchAll(),
          builder: (context, habits) => StreamBuilder<List<Alarm>>(
            stream: s.alarms.watchAll(),
            builder: (context, alarms) => StreamBuilder<List<EventRow>>(
              stream: s.history.watchSince(since),
              builder: (context, events) => StreamBuilder<List<EventRow>>(
                stream: s.history.watchStreakEvents(),
                builder: (context, streakEvents) {
                  final allHabits = habits.data ?? const <Habit>[];
                  final days = buildDays(
                    events.data ?? const [],
                    habitNames: {for (final h in allHabits) h.id: h.name},
                    alarmLabels: {for (final a in alarms.data ?? const <Alarm>[]) a.id: a.label},
                    appLabels: {for (final h in allHabits) for (final a in h.apps) a.package: a.label},
                  );
                  final current = [for (final h in allHabits) if (h.archivedAt == null) h];
                  final now = DateTime.now();
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (current.isNotEmpty) const SectionHeader('Streaks'),
                      for (final h in current)
                        ListTile(
                          title: Text(h.name),
                          trailing: Text(
                            '${streak(h.id, streakEvents.data ?? const [], now)} in a row',
                            style: times(Theme.of(context).textTheme.bodyLarge),
                          ),
                        ),
                      if (days.isEmpty)
                        const EmptyState(text: 'Nothing has happened yet. It will.')
                      else
                        for (final d in days) ...[
                          SectionHeader(dateLabel(d.date)),
                          for (final l in d.lines)
                            ListTile(
                              dense: true,
                              leading: SizedBox(
                                width: 48,
                                child: Text(l.time ?? '', style: times(Theme.of(context).textTheme.bodyMedium)),
                              ),
                              title: Text(l.text),
                            ),
                        ],
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
