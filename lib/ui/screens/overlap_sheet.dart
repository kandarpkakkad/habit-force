import 'package:flutter/material.dart';

import '../../domain/habits/habit.dart';
import '../../domain/habits/habits_repository.dart';
import '../../domain/schedule/overlaps.dart';
import '../../domain/schedule/week.dart';

/// Saves [draft], showing the overlap sheet as many times as it takes. Used
/// by the editor and by the enable switch, so both go through `save`
/// (AGENTS.md §2, *One entry point per transition*).
///
/// Returns the field errors when the draft is invalid, `null` once saved, and
/// an empty map when the person backed out.
Future<Map<String, String>?> saveWithSheet(
  BuildContext context,
  HabitsRepository habits,
  Habit draft,
) async {
  Map<String, Proposal>? resolution;
  while (true) {
    final outcome = await habits.save(draft, resolution: resolution);
    if (!context.mounted) return const {};
    switch (outcome) {
      case Saved():
        return null;
      case Invalid(:final errors):
        return errors;
      case SaveRefused(:final report):
        await showModalBottomSheet<void>(
          context: context,
          builder: (_) => _RefusedSheet(report),
        );
        return const {};
      case SaveNeedsChoice(:final report):
        final chosen = await showModalBottomSheet<Map<String, Proposal>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _ChoiceSheet(report),
        );
        if (chosen == null) return const {};
        resolution = chosen;
    }
  }
}

String _clashLine(Clash c) =>
    '${c.other.name} · ${c.other.hard ? 'Hard' : 'Soft'} · ${describeSpans(c.common).join(', ')}';

class _RefusedSheet extends StatelessWidget {
  final Refused report;

  const _RefusedSheet(this.report);

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Can't save — this overlaps a hard habit", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final c in report.clashes.where((c) => c.refused))
              Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(_clashLine(c))),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ),
          ]),
        ),
      );
}

class _ChoiceSheet extends StatefulWidget {
  final NeedsChoice report;

  const _ChoiceSheet(this.report);

  @override
  State<_ChoiceSheet> createState() => _ChoiceSheetState();
}

class _ChoiceSheetState extends State<_ChoiceSheet> {
  final _chosen = <String, Proposal>{};

  bool get _complete => widget.report.sections.every((s) => _chosen.containsKey(s.yielder.id));

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('This overlaps another habit', style: t.titleMedium),
            for (final s in widget.report.sections) ...[
              const SizedBox(height: 16),
              Text(
                s.isCandidate ? 'Your habit gives way' : '${s.yielder.name} gives way',
                style: t.titleSmall,
              ),
              const SizedBox(height: 4),
              for (final c in s.clashes) Text(_clashLine(c), style: t.bodySmall),
              if (s.blocked)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'No free time for ${s.yielder.name} on all its days — edit it first.',
                    style: t.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              RadioGroup<Proposal>(
                groupValue: _chosen[s.yielder.id],
                onChanged: (p) => setState(() => _chosen[s.yielder.id] = p!),
                child: Column(children: [
                  for (final p in s.proposals)
                    RadioListTile<Proposal>(
                      contentPadding: EdgeInsets.zero,
                      value: p,
                      title: Text(p.sentence),
                    ),
                ]),
              ),
            ],
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _complete ? () => Navigator.pop(context, Map.of(_chosen)) : null,
                child: const Text('Save'),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
