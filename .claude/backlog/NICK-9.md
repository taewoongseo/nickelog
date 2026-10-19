---
id: NICK-9
title: Restyle Log It form as the "admission slip"
type: feature
status: backlog
created: 2026-10-19
---

## What
Apply the designed Log It form (`Design/screens/handoff.md` §4): a header with "NOW LOGGING", the film title and year, and a custom "admission slip" container holding the date, place, and review fields. No ticket preview on this screen, by decision.

## Expected Outcome
- Header: "NOW LOGGING" (red label), the film title (Bodoni Moda 700, 36pt), the year (Bodoni italic 18pt, or hidden when missing). Back button "Search" in red, no centre title.
- Admission slip: surface fill, 1pt hairline border at radius 4 with a 0.5pt inner rule; a top row with "ADMISSION SLIP" and the upcoming serial ("No. 000113" from `nextSerialNumber`, red Courier Prime), then a dashed divider.
- Fields: Screened (native compact DatePicker, defaults to today, no future dates), Played At (25-character cap with a live "11 / 25" counter, Courier Prime, placeholder "AMC Lincoln Square, Netflix, couch"), One-line Review (80-character cap with a "42 / 80" counter, 3-line multiline, Old Standard TT italic, placeholder "One line. Make it count."). Newlines in the place field are turned into spaces.
- Underlines turn ink while a field is focused. Counters turn red at 23 or more of 25 and 72 or more of 80.
- Primary pill "Pick a Design →" pinned 34pt above the bottom safe area, riding above the keyboard.

## Affected Files
- `Nickelog/Features/Log/LogFormView.swift` (restyle; custom slip container and fields)
- `Nickelog/Models/TicketInput.swift` (limits already defined; no change expected)
- `NickelogTests/` (counter warning thresholds if extracted)

## Risks / Notes
- Depends on NICK-7.
- Keeping the pinned button above the keyboard while the form scrolls needs care on small screens.
- Custom underlined fields replace the native `Form`, so focus handling, accessibility labels, and Dynamic Type must be rebuilt by hand.
- The Korean/Japanese/Chinese keyboard concern from the code review (clamping text during composition) applies here and should be tested.
- Empty review is still allowed today; whether to require one is undecided.
