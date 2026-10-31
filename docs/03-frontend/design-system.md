# Design system

Material 3, one seed colour, the platform font. Code: `lib/ui/theme/`.

## 1. Colour

```dart
const kSeed = Color(0xFF2E5BBA);   // a steady blue: neither alarm-red nor reward-green
ColorScheme.fromSeed(seedColor: kSeed, brightness: light | dark)
```

The app follows the system theme. Meaning is carried by role, never by a raw colour:

| Meaning | Role |
|---|---|
| Hard habit | `tertiaryContainer` / `onTertiaryContainer` |
| Soft habit | `secondaryContainer` / `onSecondaryContainer` |
| Running now | `primaryContainer` |
| Required permission missing | `errorContainer` |
| Optional permission missing | `surfaceContainerHighest` with an amber icon (`Colors.amber.shade700`) |
| Done, past, disabled | `onSurfaceVariant` text, no fill |

## 2. Type

Material's default scale. Every time of day and duration uses **tabular figures**, so a column
of times lines up and a countdown does not jitter:

```dart
TextStyle times = base.copyWith(fontFeatures: [FontFeature.tabularFigures()]);
```

Times are always 24-hour `HH:MM`. Durations: *45 min*, *1 h 30 min*.

## 3. Components

| Component | Use |
|---|---|
| `DayChips` | Seven `FilterChip`s, M T W T F S S. Shown compact on cards as *Mon–Fri*, *Weekends*, *Every day*, or a list |
| `StrictnessBadge` | *Hard* / *Soft* pill, colours from §1 |
| `TimeRangeText` | *21:00–22:00*, with *next day* in small type when it crosses midnight |
| `HabitCard` | Name, days, time range, badge, *3 apps blocked*, streak as *6 in a row* — words, no emoji |
| `PermissionRow` | Title, status icon, one line of consequence, an action button |
| `EmptyState` | One sentence of what goes here and one button to add the first |

## 4. Placeholders

**A placeholder is guidance, a value is content.** Hints are styled with `hintStyle` in
`onSurfaceVariant` at reduced opacity, so they never read as typed text. A hint is a shape or
an instruction — *e.g. Learning* — never a real-looking value. A field is never seeded with a
literal default to mean "nothing"; the default is applied on save.

## 5. Native screens

The block screen and the alarm screen are Kotlin (D16) and always dark, because they are most
often seen at night and over a lock screen.

| Token | Value |
|---|---|
| Background | `#121418` |
| Primary text | `#F2F3F7` |
| Secondary text | `#A9AEBB` |
| Accent (primary button) | `#7FA2F0` — `kSeed` lightened for a dark ground |
| Button text on accent | `#0D1B3D` |
| Habit name / alarm time | 34 sp / 72 sp, medium |
| Body | 16 sp |

Buttons are full width, 56 dp tall, 16 dp apart, 24 dp side margins. The primary action is
the one that keeps the rule: *Go to the home screen*, *Dismiss*.
