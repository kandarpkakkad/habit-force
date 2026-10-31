# Glossary

Terms used precisely throughout. If a document uses one of these loosely, the document is wrong.

| Term | Means | Does not mean |
|---|---|---|
| **Habit** | A named weekly rule: days, a start minute, an end minute, strictness, blocked apps | One occurrence of it — that is a window |
| **Window** | One occurrence of a habit on one date. Belongs to the date it **starts** on | A habit |
| **Occurrence key** | `<habitId>@<yyyy-mm-dd>` — names one window, in the plan and in events | An id in any table |
| **Hard / soft** | Strictness. Hard never moves; soft gives way | Priority |
| **Priority** | Low / normal / high, among soft habits only | Strictness |
| **Gives way / yields** | The habit an overlap resolution changes | The habit being edited — it may be the other one (D13) |
| **Buffer** | The minutes before a hard window that a soft window may not occupy (D14) | A gap between hard habits |
| **Crosses midnight** | `end_minute < start_minute`. The window ends the next day | Two windows |
| **Week minute** | `day × 1440 + minute`, Monday 00:00 = 0, wrapping at 10 080 | A wall-clock instant |
| **Plan** | The 14-day list of windows and alarm instants Dart hands to Kotlin | The habits |
| **Horizon** | The last date the plan covers | — |
| **Boundary** | A moment Kotlin must act on: a heads-up, a start, an end, or the expiry warning | An alarm |
| **Alarm** | Something that rings, at a clock time or relative to a habit's start or end | A notification |
| **Alarm entry** | One planned ringing on one date and minute; may merge several alarms (D15) | An alarm row |
| **Challenge** | What dismissing an alarm takes: none, sum, phrase | The pause sentence |
| **Pause** | A timed suspension of all blocking, after cooldown and the typed sentence | Disabling a habit |
| **Event** | A record of something that happened, appended by Kotlin, kept by Dart | A plan entry |
| **Blocker / enforcer** | The accessibility service that sends blocked apps away | The block screen |
| **Block screen** | The native screen shown after an app is sent away | — |
