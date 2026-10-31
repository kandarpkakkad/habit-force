import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../common/dates.dart';
import '../../domain/habits/habit.dart';
import '../../domain/history/history.dart';
import '../../platform/storage/database.dart';
import '../widgets/widgets.dart';
import 'habit_editor_screen.dart';
import 'overlap_sheet.dart';

/// S2 — every habit that is not archived.
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    void open([Habit? h]) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => HabitEditorScreen(habit: h)));

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a habit',
        onPressed: open,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Habit>>(
        stream: s.habits.watchCurrent(),
        builder: (context, snap) {
          final habits = snap.data;
          if (habits == null) return const SizedBox.shrink();
          if (habits.isEmpty) {
            return EmptyState(
              text: 'A habit is a time you protect. Add the first one.',
              action: 'Add a habit',
              onAction: open,
            );
          }
          return StreamBuilder<List<EventRow>>(
            stream: s.history.watchStreakEvents(),
            builder: (context, events) => ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final h in habits)
                  _HabitCard(
                    habit: h,
                    streak: streak(h.id, events.data ?? const [], DateTime.now()),
                    onTap: () => open(h),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final int streak;
  final VoidCallback onTap;

  const _HabitCard({required this.habit, required this.streak, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final dim = habit.enabled ? null : Theme.of(context).colorScheme.onSurfaceVariant;
    final apps = habit.apps.length;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(habit.name, style: t.titleMedium?.copyWith(color: dim))),
                  const SizedBox(width: 8),
                  StrictnessBadge(hard: habit.hard),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Text('${daysLabel(habit.days)} · ', style: TextStyle(color: dim)),
                  TimeRangeText(start: habit.start, end: habit.end, style: TextStyle(color: dim)),
                ]),
                const SizedBox(height: 2),
                Text(
                  [
                    if (apps > 0) apps == 1 ? '1 app blocked' : '$apps apps blocked',
                    if (streak > 0) '$streak in a row',
                    if (!habit.enabled) 'Off',
                  ].join(' · '),
                  style: t.bodySmall,
                ),
              ]),
            ),
            Switch(
              value: habit.enabled,
              onChanged: (on) async {
                final errors = await saveWithSheet(context, s.habits, habit.copyWith(enabled: on));
                if (context.mounted && errors != null && errors.isNotEmpty) {
                  say(context, errors.values.first);
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}
