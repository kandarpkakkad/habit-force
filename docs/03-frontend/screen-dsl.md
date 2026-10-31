# Screens

A compact notation for every screen, so a screen can be discussed without opening its code.

```
screen <id> <Name>
  bar:      title · actions
  body:     components, top to bottom
  empty:    what shows with no data
  actions:  what each control does
```

---

```
screen S1 Today
  bar:      "Today, Sat 31 Oct" · [Setup •] [Settings]
  body:     PermissionBanner?            red / amber, "Blocking is off — 1 permission missing" → S8
            PlanBanner?                  only when planStatus ≠ ok: the reason, and [Try again]
            NowCard                      running:  "Learning · until 22:00 · 37 min left"
                                                   "3 apps blocked" · StrictnessBadge
                                         free:     "Free until 21:00" · "next: Learning"
                                         nothing today: "Nothing planned today"
            Section "Today"              rows in time order, windows and alarms together:
                                         "21:00–22:00  Learning     Soft"   (past rows dimmed)
                                         "06:30        ⏰ Wake up"
  empty:    "No habits yet" · [Add a habit] → S5
```

```
screen S2 Habits
  bar:      "Habits"
  body:     HabitCard per habit, enabled first, then disabled (dimmed), each by start time
            card: name · DayChips(compact) · TimeRangeText · StrictnessBadge
                  "3 apps blocked" · "6 in a row" · Switch(enabled)
  fab:      [+] → S5 new
  empty:    "A habit is a time you protect. Add the first one." · [Add a habit]
  actions:  tap card → S5 edit · switch → setEnabled (enabling runs the overlap check)
```

```
screen S3 Alarms
  bar:      "Alarms"
  body:     Section "Clock"   rows: "06:30  Wake up  · Mon–Fri" · Switch
                              once: "07:15 · Once, Sun 1 Nov"; done: "Done" dimmed
            Section "With habits"  rows: "5 min before Learning starts" · Switch
  fab:      [+] → S7 new clock alarm
  empty:    "No alarms yet." · [Add an alarm]
```

```
screen S4 History
  bar:      "History"
  body:     Section "Streaks"   per habit: name · "6 in a row"
            Section per day, newest first, last 14 days:
                                "Sat 31 Oct" then the lines from history LLD §3
  refresh:  pull → collect()
  empty:    "Nothing has happened yet. It will, at 21:00." (the next window's time, when known)
```

```
screen S5 Habit editor
  bar:      "New habit" | "Edit habit" · [Archive] (edit only)
  body:     TextField "Name"            hint "e.g. Learning"
            DayChips
            Row  [Start 21:00] [End 22:00]   time pickers; "ends next day" under End when it crosses
            Segmented  Hard | Soft     helper: "Hard: nothing may overlap it." / "Soft: moves for hard habits."
            Segmented  Low | Normal | High   (soft only)
            ListTile "Blocked apps"    "Instagram, YouTube +1" → S6
            Switch   "Turn on Do Not Disturb"   helper when no access: "Needs access — see Setup"
            Section "Alarms"           rows of this habit's alarms · [Add alarm] → S7(habit)
                                       new habit: "Save the habit to add alarms"
  bottom:   [Save]
  actions:  Save → save(); Invalid → errors on fields; Refused → OverlapSheet(refused);
            NeedsChoice → OverlapSheet(choices) → save(resolution)
```

```
sheet OverlapSheet
  refused:  "Can't save — this overlaps a hard habit"
            per clash: "Sleep · Hard" · "Mon–Fri 22:30–23:00"
            [Close]
  choices:  per section:
              "Learning gives way" (or "Your new habit gives way")
              clashes: "Sleep · Hard · Mon–Fri 22:45–23:00"
              Radio  "Shift to 22:30–23:30"
              Radio  "Shift to 19:30–20:30"
              Radio  "Trim to 21:00–22:15"
              Radio  "Keep both — both block during the overlap"   (soft–soft only)
              or "No free time for Learning on all its days — edit it first"
            [Cancel]  [Save]   Save enabled when every section has a choice
```

```
screen S6 App picker
  bar:      "Blocked apps" · [Done]
  body:     SearchField "Search apps"
            Section "Chosen" (checked, on top)
            Section "All apps" CheckboxListTile per app, by label
  actions:  Done → pop with the chosen list
```

```
screen S7 Alarm editor
  bar:      "New alarm" | "Edit alarm" · [Delete] (edit only)
  body:     clock:  [Time 06:30]  DayChips  helper "No days: rings once, Sun 1 Nov"
            habit:  Segmented  At start | At end   ·   Offset stepper "5 min before"
            TextField "Label"   hint "Optional"
            Segmented  Challenge: None | Sum | Phrase
            Row  "Snooze"  [5 min ▾]  "up to"  [2 times ▾]
            Switch "Vibrate"
            [Test — rings in 10 seconds]
  bottom:   [Save]
```

```
screen S8 Setup
  bar:      "Setup"
  body:     intro: "Habit Force needs these to work while it is closed."
            PermissionRow ×6 (permissions LLD §1), required first
            accessibility row: second line about restricted settings · [App info]
  actions:  each row's button → openPermission(key); statuses re-read on resume
```

```
screen S9 Settings
  bar:      "Settings"
  body:     NumberField "Heads-up before a habit"   suffix "min"   helper "0 turns it off"
            NumberField "Buffer before hard habits" suffix "min"
            NumberField "Pause length"              suffix "min"
            NumberField "Wait before pausing"       suffix "s"     helper "Doubled for hard habits"
            TextField   "Pause sentence"
            ListTile    "Habit Force 0.1.0 (1)"
  bottom:   [Save]
```

```
native BlockActivity        blocking LLD §5
native AlarmActivity        alarms LLD §5
```
