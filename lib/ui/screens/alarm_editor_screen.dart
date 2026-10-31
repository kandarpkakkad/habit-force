import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../common/clock_time.dart';
import '../../common/dates.dart';
import '../../common/ids.dart';
import '../../domain/alarms/alarm.dart';
import '../../domain/schedule/planner.dart';
import '../../platform/bridge/native_bridge.dart';
import '../theme/format.dart';
import '../widgets/widgets.dart';

/// S7 — a clock alarm, or one tied to [habitId]'s start or end.
class AlarmEditorScreen extends StatefulWidget {
  final Alarm? alarm;

  /// For a new habit-tied alarm. Ignored when editing.
  final String? habitId;
  final String? habitName;

  const AlarmEditorScreen({super.key, this.alarm, this.habitId, this.habitName});

  @override
  State<AlarmEditorScreen> createState() => _AlarmEditorScreenState();
}

class _AlarmEditorScreenState extends State<AlarmEditorScreen> {
  late final String _id = widget.alarm?.id ?? newId();
  late final DateTime _createdAt = widget.alarm?.createdAt ?? DateTime.now();
  late final String? _habitId = widget.alarm?.habitId ?? widget.habitId;
  late AlarmAnchor _anchor =
      widget.alarm?.anchor ?? (_habitId == null ? AlarmAnchor.clock : AlarmAnchor.habitStart);
  late int? _minute = widget.alarm?.minute;
  late int _offset = widget.alarm?.offsetMinutes ?? -5;
  late int _days = widget.alarm?.days ?? 0;
  late final _label = TextEditingController(text: widget.alarm?.label ?? '');
  late Challenge _challenge = widget.alarm?.challenge ?? Challenge.sum;
  late int _snoozeMinutes = widget.alarm?.snoozeMinutes ?? 5;
  late int _snoozeLimit = widget.alarm?.snoozeLimit ?? 2;
  late bool _vibrate = widget.alarm?.vibrate ?? true;
  Map<String, String> _errors = const {};

  bool get _isClock => _anchor == AlarmAnchor.clock;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Alarm _draft() => Alarm(
        id: _id,
        label: _label.text,
        anchor: _anchor,
        habitId: _isClock ? null : _habitId,
        minute: _isClock ? _minute : null,
        offsetMinutes: _isClock ? 0 : _offset,
        days: _isClock ? _days : 0,
        enabled: widget.alarm?.enabled ?? true,
        vibrate: _vibrate,
        snoozeMinutes: _snoozeMinutes,
        snoozeLimit: _snoozeLimit,
        challenge: _challenge,
        createdAt: _createdAt,
      );

  Future<void> _pickTime() async {
    final m = _minute;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m == null ? 7 : m ~/ 60, minute: m == null ? 0 : m % 60),
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (picked != null) setState(() => _minute = picked.hour * 60 + picked.minute);
  }

  Future<void> _save() async {
    final errors = await AppScope.of(context).alarms.save(_draft());
    if (!mounted) return;
    if (errors.isEmpty) {
      Navigator.pop(context);
    } else {
      setState(() => _errors = errors);
    }
  }

  Future<void> _test() async {
    final draft = _draft();
    if (_isClock && _minute == null) {
      setState(() => _errors = {'time': 'Pick a time'});
      return;
    }
    try {
      final at = await AppScope.of(context).bridge.testAlarm(testEntry(draft, habitName: widget.habitName));
      if (mounted) say(context, 'Rings at ${hhmm(minuteOfDay(at))}:${at.second.toString().padLeft(2, '0')}');
    } on BridgeException catch (e) {
      if (mounted) say(context, 'Could not set the test alarm: $e');
    }
  }

  Future<void> _delete() async {
    await AppScope.of(context).alarms.delete(_id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final err = Theme.of(context).colorScheme.error;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'New alarm' : 'Edit alarm'),
        actions: [
          if (widget.alarm != null)
            IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(onPressed: _save, child: const Text('Save')),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (_isClock) ...[
          OutlinedButton(
            onPressed: _pickTime,
            child: Text(_minute == null ? 'Time' : ClockTime(_minute!).label, style: t.displaySmall),
          ),
          if (_errors['time'] != null) Text(_errors['time']!, style: t.bodySmall?.copyWith(color: err)),
          const SizedBox(height: 16),
          DayChips(mask: _days, onChanged: (m) => setState(() => _days = m)),
          if (_days == 0 && _minute != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('No days: rings once, ${dateLabel(onceDateFor(_minute!, now))}', style: t.bodySmall),
            ),
        ] else ...[
          Text(widget.habitName?.isNotEmpty == true ? widget.habitName! : 'Habit', style: t.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<AlarmAnchor>(
            segments: const [
              ButtonSegment(value: AlarmAnchor.habitStart, label: Text('At start')),
              ButtonSegment(value: AlarmAnchor.habitEnd, label: Text('At end')),
            ],
            selected: {_anchor},
            onSelectionChanged: (v) => setState(() => _anchor = v.single),
          ),
          const SizedBox(height: 8),
          Row(children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _offset > -180 ? () => setState(() => _offset -= 5) : null,
            ),
            Expanded(child: Text(offsetLabel(_offset), textAlign: TextAlign.center, style: t.titleMedium)),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _offset < 180 ? () => setState(() => _offset += 5) : null,
            ),
          ]),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _label,
          maxLength: 40,
          decoration: InputDecoration(labelText: 'Label', hintText: 'Optional', errorText: _errors['label']),
        ),
        Text('Challenge to dismiss', style: t.labelLarge),
        const SizedBox(height: 4),
        SegmentedButton<Challenge>(
          segments: const [
            ButtonSegment(value: Challenge.none, label: Text('None')),
            ButtonSegment(value: Challenge.sum, label: Text('Sum')),
            ButtonSegment(value: Challenge.phrase, label: Text('Phrase')),
          ],
          selected: {_challenge},
          onSelectionChanged: (v) => setState(() => _challenge = v.single),
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Text('Snooze'),
          const SizedBox(width: 12),
          DropdownButton<int>(
            value: _snoozeMinutes,
            items: [for (final m in const [1, 3, 5, 10, 15, 20, 30]) DropdownMenuItem(value: m, child: Text('$m min'))],
            onChanged: (v) => setState(() => _snoozeMinutes = v!),
          ),
          const SizedBox(width: 12),
          const Text('up to'),
          const SizedBox(width: 12),
          DropdownButton<int>(
            value: _snoozeLimit,
            items: [
              for (var n = 0; n <= 10; n++)
                DropdownMenuItem(value: n, child: Text(n == 0 ? 'never' : n == 1 ? 'once' : '$n times')),
            ],
            onChanged: (v) => setState(() => _snoozeLimit = v!),
          ),
        ]),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vibrate'),
          value: _vibrate,
          onChanged: (v) => setState(() => _vibrate = v),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.alarm_on),
          label: const Text('Test — rings in 10 seconds'),
          onPressed: _test,
        ),
      ]),
    );
  }
}
