import 'package:flutter/material.dart';

import '../../common/clock_time.dart';
import '../../common/dates.dart';
import '../theme/theme.dart';

/// Seven filter chips, M T W T F S S. Monday = bit 0.
class DayChips extends StatelessWidget {
  final int mask;
  final ValueChanged<int> onChanged;

  const DayChips({super.key, required this.mask, required this.onChanged});

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 6,
        children: [
          for (var i = 0; i < 7; i++)
            FilterChip(
              label: Text(kDayLetters[i]),
              tooltip: kDayNames[i],
              showCheckmark: false,
              selected: hasDay(mask, i),
              onSelected: (on) => onChanged(on ? mask | (1 << i) : mask & ~(1 << i)),
            ),
        ],
      );
}

class StrictnessBadge extends StatelessWidget {
  final bool hard;

  const StrictnessBadge({super.key, required this.hard});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final bg = hard ? c.tertiaryContainer : c.secondaryContainer;
    final fg = hard ? c.onTertiaryContainer : c.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(hard ? 'Hard' : 'Soft', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg)),
    );
  }
}

/// *21:00–22:00*, with *next day* when it crosses midnight.
class TimeRangeText extends StatelessWidget {
  final ClockTime start;
  final ClockTime end;
  final TextStyle? style;

  const TimeRangeText({super.key, required this.start, required this.end, this.style});

  @override
  Widget build(BuildContext context) {
    final base = times(style ?? Theme.of(context).textTheme.bodyMedium);
    return Text.rich(TextSpan(children: [
      TextSpan(text: '${start.label}–${end.label}', style: base),
      if (end.minutes < start.minutes)
        TextSpan(
          text: '  next day',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
    ]));
  }
}

class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      );
}

class EmptyState extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.text, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            if (action != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(action!)),
            ],
          ]),
        ),
      );
}

/// Shows [message] in a snackbar. The message is the reason, never just the
/// fact (AGENTS.md §2).
void say(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
