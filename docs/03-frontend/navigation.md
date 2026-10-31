# Navigation

Code: `lib/ui/shell/`.

## 1. Shell

A `NavigationBar` with four destinations, each keeping its own scroll position:

| Tab | Icon | Screen |
|---|---|---|
| Today | `today` | S1 |
| Habits | `repeat` | S2 |
| Alarms | `alarm` | S3 |
| History | `history` | S4 |

Today's app bar carries **Setup** (`verified_user`, with a dot while anything is missing) and
**Settings** (`settings`).

## 2. Routes

Plain `Navigator.push` with `MaterialPageRoute`. No named routes, no deep links — nothing
outside the app links into it.

| From | To |
|---|---|
| Habits FAB, a habit card | Habit editor (S5) |
| Habit editor → *Blocked apps* | App picker (S6), returns the chosen list |
| Habit editor → *Add alarm* | Alarm editor (S7) for that habit |
| Alarms FAB, an alarm row | Alarm editor (S7) |
| Today → Setup icon or banner | Setup (S8) |
| Today → Settings icon | Settings (S9) |

The overlap sheet is a modal bottom sheet over the habit editor, not a route.

## 3. First launch

While there are no habits yet and a required permission is missing, Setup is pushed over
Today on launch — which in practice is the first launch. Once a habit exists, only the banner
and the dot. Nothing is stored to remember this; the habit count is the memory.

## 4. Native screens

`BlockActivity` and `AlarmActivity` are Android activities, outside the Flutter navigator.
Leaving either never returns to Habit Force unless it was already in front.
