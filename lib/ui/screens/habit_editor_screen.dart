import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../common/clock_time.dart';
import '../../common/dates.dart';
import '../../common/ids.dart';
import '../../domain/alarms/alarm.dart';
import '../../domain/habits/habit.dart';
import '../../platform/permissions/permissions.dart';
import '../theme/format.dart';
import '../widgets/widgets.dart';
import 'alarm_editor_screen.dart';
import 'app_picker_screen.dart';
import 'overlap_sheet.dart';

/// S5 — create or edit a habit. Saving goes through `saveWithSheet`, so the
/// overlap sheet is the editor's, not a separate route.
class HabitEditorScreen extends StatefulWidget {
  final Habit? habit;

  const HabitEditorScreen({super.key, this.habit});

  @override
  State<HabitEditorScreen> createState() => _HabitEditorScreenState();
}

class _HabitEditorScreenState extends State<HabitEditorScreen> {
  late final String _id = widget.habit?.id ?? newId();
  late final DateTime _createdAt = widget.habit?.createdAt ?? DateTime.now();
  late final _name = TextEditingController(text: widget.habit?.name ?? '');
  late int _days = widget.habit?.days ?? kWeekdays;
  // No literal default pretending to be a choice: an unset time is null and
  // the field says so (design-system §4).
  late ClockTime? _start = widget.habit?.start;
  late ClockTime? _end = widget.habit?.end;
  late Strictness _strictness = widget.habit?.strictness ?? Strictness.soft;
  late int _priority = widget.habit?.priority ?? kPriorityNormal;
  late bool _dnd = widget.habit?.dnd ?? false;
  late List<BlockedApp> _apps = [...?widget.habit?.apps];
  Map<String, String> _errors = const {};
  bool _saving = false;

  bool get _isNew => widget.habit == null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool start) async {
    final current = start ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current?.hour ?? (start ? 21 : 22), minute: current?.minute ?? 0),
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (picked == null) return;
    setState(() {
      final t = ClockTime.hm(picked.hour, picked.minute);
      if (start) {
        _start = t;
      } else {
        _end = t;
      }
    });
  }

  Future<void> _save() async {
    if (_start == null || _end == null) {
      setState(() => _errors = {'time': 'Pick a start and an end'});
      return;
    }
    final s = AppScope.of(context);
    final draft = Habit(
      id: _id,
      name: _name.text,
      days: _days,
      start: _start!,
      end: _end!,
      strictness: _strictness,
      priority: _strictness == Strictness.hard ? kPriorityNormal : _priority,
      dnd: _dnd,
      enabled: widget.habit?.enabled ?? true,
      apps: _apps,
      createdAt: _createdAt,
    );
    setState(() => _saving = true);
    final errors = await saveWithSheet(context, s.habits, draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (errors == null) {
      Navigator.pop(context);
    } else {
      setState(() => _errors = errors);
    }
  }

  Future<void> _archive() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive this habit?'),
        content: const Text(
          'It stops running and leaves the list. Its history stays. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Archive')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await AppScope.of(context).habits.archive(_id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final err = Theme.of(context).colorScheme.error;
    final crosses = _start != null && _end != null && _end!.minutes < _start!.minutes;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New habit' : 'Edit habit'),
        actions: [
          if (!_isNew) IconButton(tooltip: 'Archive', icon: const Icon(Icons.archive_outlined), onPressed: _archive),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(onPressed: _saving ? null : _save, child: const Text('Save')),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(
          controller: _name,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: 'Name', hintText: 'e.g. Learning', errorText: _errors['name']),
        ),
        const SizedBox(height: 8),
        Text('Days', style: t.labelLarge),
        const SizedBox(height: 4),
        DayChips(mask: _days, onChanged: (m) => setState(() => _days = m)),
        if (_errors['days'] != null) Text(_errors['days']!, style: t.bodySmall?.copyWith(color: err)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickTime(true),
              child: Text(_start == null ? 'Start' : 'Start ${_start!.label}'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickTime(false),
              child: Text(_end == null ? 'End' : 'End ${_end!.label}'),
            ),
          ),
        ]),
        if (crosses) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Ends the next day', style: t.bodySmall)),
        if (_errors['time'] != null) Text(_errors['time']!, style: t.bodySmall?.copyWith(color: err)),
        const SizedBox(height: 16),
        SegmentedButton<Strictness>(
          segments: const [
            ButtonSegment(value: Strictness.hard, label: Text('Hard')),
            ButtonSegment(value: Strictness.soft, label: Text('Soft')),
          ],
          selected: {_strictness},
          onSelectionChanged: (v) => setState(() => _strictness = v.single),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _strictness == Strictness.hard ? 'Hard: nothing may overlap it.' : 'Soft: moves for hard habits.',
            style: t.bodySmall,
          ),
        ),
        if (_strictness == Strictness.soft) ...[
          const SizedBox(height: 16),
          Text('Priority', style: t.labelLarge),
          const SizedBox(height: 4),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: kPriorityLow, label: Text('Low')),
              ButtonSegment(value: kPriorityNormal, label: Text('Normal')),
              ButtonSegment(value: kPriorityHigh, label: Text('High')),
            ],
            selected: {_priority},
            onSelectionChanged: (v) => setState(() => _priority = v.single),
          ),
        ],
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Blocked apps'),
          subtitle: Text(_apps.isEmpty
              ? 'None — this habit only reminds and rings'
              : _apps.length <= 2
                  ? _apps.map((a) => a.label).join(', ')
                  : '${_apps.take(2).map((a) => a.label).join(', ')} +${_apps.length - 2}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final chosen = await Navigator.of(context).push<List<BlockedApp>>(
              MaterialPageRoute(builder: (_) => AppPickerScreen(chosen: _apps)),
            );
            if (chosen != null) setState(() => _apps = chosen);
          },
        ),
        ListenableBuilder(
          listenable: s.permissions,
          builder: (context, _) {
            // Offered regardless of access: never gate a feature on a check
            // (AGENTS.md §2). The helper says what will happen.
            final noAccess = s.permissions.status?[PermissionKey.dnd] == false;
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Turn on Do Not Disturb'),
              subtitle: noAccess ? const Text('Needs access — see Setup. Ignored until then.') : null,
              value: _dnd,
              onChanged: (v) => setState(() => _dnd = v),
            );
          },
        ),
        const SectionHeader('Alarms'),
        if (_isNew)
          Text('Save the habit to add alarms', style: t.bodyMedium)
        else
          StreamBuilder<List<Alarm>>(
            stream: s.alarms.watchAll(),
            builder: (context, snap) {
              final mine = [for (final a in snap.data ?? const <Alarm>[]) if (a.habitId == _id) a];
              return Column(children: [
                for (final a in mine)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.alarm),
                    title: Text(
                      '${offsetLabel(a.offsetMinutes)} ${a.anchor == AlarmAnchor.habitStart ? 'start' : 'end'}',
                    ),
                    subtitle: a.label.isEmpty ? null : Text(a.label),
                    trailing: a.enabled ? null : const Text('Off'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AlarmEditorScreen(alarm: a, habitName: _name.text)),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add alarm'),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AlarmEditorScreen(habitId: _id, habitName: _name.text),
                    )),
                  ),
                ),
              ]);
            },
          ),
      ]),
    );
  }
}
