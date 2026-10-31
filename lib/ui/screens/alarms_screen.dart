import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../common/clock_time.dart';
import '../../common/dates.dart';
import '../../domain/alarms/alarm.dart';
import '../../domain/habits/habit.dart';
import '../theme/format.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'alarm_editor_screen.dart';

/// S3 — clock alarms, then the ones tied to habits.
class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    void open({Alarm? alarm, String? habitName}) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AlarmEditorScreen(alarm: alarm, habitName: habitName)),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add an alarm',
        onPressed: open,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Alarm>>(
        stream: s.alarms.watchAll(),
        builder: (context, alarms) => StreamBuilder<List<Habit>>(
          stream: s.habits.watchAll(),
          builder: (context, habits) {
            if (!alarms.hasData || !habits.hasData) return const SizedBox.shrink();
            final all = alarms.data!;
            if (all.isEmpty) {
              return EmptyState(text: 'No alarms yet.', action: 'Add an alarm', onAction: open);
            }
            final byId = {for (final h in habits.data!) h.id: h};
            final today = dateOnly(DateTime.now());
            final clock = [for (final a in all) if (a.isClock) a];
            final tied = [
              for (final a in all)
                if (!a.isClock && byId[a.habitId]?.archivedAt == null) a,
            ];
            return ListView(padding: const EdgeInsets.only(bottom: 88), children: [
              if (clock.isNotEmpty) const SectionHeader('Clock'),
              for (final a in clock)
                _AlarmTile(
                  alarm: a,
                  title: ClockTime(a.minute!).label,
                  subtitle: [
                    if (a.label.isNotEmpty) a.label,
                    if (a.isDone(today))
                      'Done'
                    else if (a.isOnce)
                      'Once, ${dateLabel(a.onceDate!)}'
                    else
                      daysLabel(a.days),
                  ].join(' · '),
                  done: a.isDone(today),
                  onTap: () => open(alarm: a),
                ),
              if (tied.isNotEmpty) const SectionHeader('With habits'),
              for (final a in tied)
                _AlarmTile(
                  alarm: a,
                  title: '${offsetLabel(a.offsetMinutes)} '
                      '${byId[a.habitId]?.name ?? 'a habit'} '
                      '${a.anchor == AlarmAnchor.habitStart ? 'starts' : 'ends'}',
                  subtitle: a.label,
                  done: false,
                  onTap: () => open(alarm: a, habitName: byId[a.habitId]?.name),
                ),
            ]);
          },
        ),
      ),
    );
  }
}

class _AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;

  const _AlarmTile({
    required this.alarm,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final dim = done || !alarm.enabled ? Theme.of(context).colorScheme.onSurfaceVariant : null;
    return ListTile(
      title: Text(title, style: times(Theme.of(context).textTheme.titleMedium?.copyWith(color: dim))),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: onTap,
      // A done once-alarm reads as off; switching it on re-saves it for the
      // next time its minute comes round (docs/02-domain/alarms/lld.md §1).
      trailing: Switch(
        value: alarm.enabled && !done,
        onChanged: (on) => s.alarms.setEnabled(alarm, on),
      ),
    );
  }
}
