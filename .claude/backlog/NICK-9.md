# PRD: Restyle the Log It form as the "admission slip"

**Ticket:** NICK-9
**Status:** ✅ Complete
**Created:** 2026-10-24

---

## TL;DR
Replace the plain iOS form on the Log It screen with the designed "admission slip": a header with the film, and a paper-slip card holding the date, place and one-line review. It is the screen every logged ticket starts from, and it should feel like part of the ticket's world.

---

## Problem
The Log It screen still uses the standard iOS settings-style form. It doesn't match the designed look (slip card, ticket-style fonts, live character counters), and today a ticket can be made with an empty review.

---

## Solution
Rebuild the form as the designed admission slip (`Design/screens/handoff.md` §4). The header shows "NOW LOGGING" in red, the film title and the year. Under it, a slip card (surface fill, thin border with a finer rule just inside) has a top row with "ADMISSION SLIP" and the serial number the ticket will get, a dashed divider, and three underlined fields: Screened (the built-in date picker, no future dates), Played At (25 characters, with a live counter), and One-line Review (80 characters, up to three lines, with a live counter). Underlines darken while a field is focused, and counters turn red near the limit (23 of 25, 72 of 80). The "Pick a Design →" button is pinned near the bottom and rides above the keyboard while the form scrolls.

The review is now required: the button is dimmed and can't be tapped while the review is empty or only spaces, with the hint "Add a one-line review to continue." This applies when editing too. When editing, the header says "Editing" instead of "NOW LOGGING" and the slip shows the ticket's own number instead of the next one. Korean (and other composed-character) typing must work correctly in the place and review fields, including with the character limits. No ticket preview appears on this screen.

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | Add input helpers to `TicketInput`: whether a review counts as written (not empty or only spaces), the counter warning thresholds (23 of 25 and 72 of 80), and a way to apply the character limits that does not break Korean, Japanese or Chinese text while a character is still being composed | ✅ Done |
| 2 | Add unit tests for those helpers, including blank and spaces-only reviews, the thresholds, and Korean text at the limits | ✅ Done |
| 3 | Build the slip container: surface fill, 1pt hairline border at radius 4 with a 0.5pt inner rule inset 4pt, inner padding, and the top row ("ADMISSION SLIP" left, serial in red Courier right) followed by a 1.5pt dashed divider | ✅ Done |
| 4 | Build the slip field row: a caps label with an optional live counter, an underlined input that turns ink while focused, counter turning red at the thresholds, and accessible labels and counter text | ✅ Done |
| 5 | Rebuild the header: "NOW LOGGING" (red label), film title, and year (hidden when missing), with "Editing" in place of "NOW LOGGING" in edit mode | ✅ Done |
| 6 | Assemble the form on the slip: Screened (built-in compact date picker, defaulting to today, no future dates), Played At (25-character cap, newlines become spaces, placeholder "AMC Lincoln Square, Netflix, couch"), and One-line Review (80-character cap, up to 3 lines, newlines become spaces, placeholder "One line. Make it count."), with the serial from the next free number when logging and the ticket's own number when editing | ✅ Done |
| 7 | Pin the "Pick a Design →" button 34pt above the bottom safe area so it rides above the keyboard while the form scrolls and keeps the focused field visible; dim and disable it with the hint "Add a one-line review to continue." while the review is empty or only spaces | ✅ Done |
| 8 | Check typing Korean into the place and review fields on the simulator: composition works, counters and limits behave, and the ticket shows the text | ✅ Done (partly: see Open Questions) |
| 9 | Regenerate the project, run the build and all tests, and check the log and edit modes on the simulator, including a small phone and a large text size | ✅ Done |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
- A watchlist or invitation path where the review isn't written (a different workflow, handled later; see NICK-13)
- A Korean font matching each ticket design (a separate future ticket; the system font fills in for now)
- A custom Courier-styled date control (the built-in picker is kept)
- A ticket preview on this screen

---

## Files That Will Change
- `Nickelog/Features/Log/LogFormView.swift`: replace the form with the slip, new header, pinned button area, review-required state, edit-mode header and serial
- `Nickelog/Models/TicketInput.swift`: review-written check, counter thresholds, composition-safe limiting
- `Nickelog/Features/Log/` or `Nickelog/DesignSystem/Components/` (new): the slip container and slip field row
- `NickelogTests/TicketInputTests.swift`: tests for the new helpers

---

## Open Questions
None. Notes:
- The tests in tasks 1 and 2 came from my proposal during exploration, not an explicit request; drop them if you'd rather not have them.
- The built-in date picker will not look like the Courier design; this was accepted.
- Requiring a review changes today's behaviour (a blank review is allowed now). There are no saved tickets to migrate.
- The pinned button and a three-line review compete for space on small iPhones with the keyboard up; this needs checking on the simulator in task 9.
- Task 8 check: Korean text shows correctly, the counters count whole characters, and the 80-character limit holds with Korean text. Real keyboard composition (typing syllables letter by letter) can't be reproduced on the simulator, so it still needs a try on a real iPhone with a Korean keyboard.
- Not seen on screen: the pinned button riding above the on-screen keyboard (the simulator kept its keyboard hidden). It uses the standard bottom inset, but confirm it on a real iPhone.
