# PRD: Rebuild TicketView in SwiftUI from the design hand-off

**Ticket:** NICK-4
**Status:** 🟡 In Progress
**Created:** 2026-10-17

---

## TL;DR
Replace the placeholder ticket with a native SwiftUI recreation of the locked ticket design, in three palettes the user chooses from, with a design-picker step in the logging flow. The ticket is the product's core artifact, so this is the biggest remaining piece of V1.

---

## Problem
The ticket screen is a bare placeholder card. It doesn't look like the designed ticket, there are no palettes or fonts, and `Ticket` is missing data the design needs: a release year and a permanent serial number. Location is required in the form even though it should be optional. Users can't pick a ticket design.

---

## Solution
Build the designed ticket as real SwiftUI views (a six-notch outline shape, main body, stub, decorative details, paper grain) in three palettes. Shown in portrait with side margins, not rotated. The logging flow becomes: search, add, fill the form, pick a design (seeing their own ticket in each palette), then the finished ticket.

`Ticket` gains an optional release year, a permanent serial number, an optional location, and the chosen design. Serial numbers come from a counter that only increases, so numbers are never reused and edits never change them. Rewatches are allowed, and each ticket gets its own serial. Location is capped at 25 characters, trimmed, with newlines stripped, and a blank location leaves its cell empty. Titles, locations, and reviews fit by shrinking or wrapping. Release year may be empty. "Date watched" can't be in the future.

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | Update `Ticket`: add optional release year and serial number, make `location` optional, and define the three design ids (stored in `templateID`) | ⬜ Not started |
| 2 | Add serial assignment to `TicketStore`: a counter that only increases, assigned when a ticket is created, never reused (existing `add`/`delete` unchanged) | ⬜ Not started |
| 3 | Add input rules: location sanitizing (25-character cap, trim, strip newlines, whitespace-only counts as blank) and release-year parsing from `Movie.releaseDate` (empty when missing) | ⬜ Not started |
| 4 | Add unit tests for the serial counter, location sanitizing, and year parsing | ⬜ Not started |
| 5 | Download the 11 hand-off fonts into `Nickelog/Resources/Fonts/`, register them under `UIAppFonts` in `project.yml`, and run `xcodegen generate` | ⬜ Not started |
| 6 | Convert `paper-texture-A.png` once into a smaller neutral grayscale grain and add it to resources | ⬜ Not started |
| 7 | Define the three palettes (A burgundy, B amber, C blue) as theme values: colors, fonts, accents, per the hand-off | ⬜ Not started |
| 8 | Build the six-notch ticket outline as a custom `Shape` that scales from the 1300x640 reference | ⬜ Not started |
| 9 | Build the ticket card layout: main body (title, year, bordered date/location box, dashed divider with star, review) and stub (rotated "ADMIT ONE", serial, "5¢", NICKELOG) | ⬜ Not started |
| 10 | Add the decorative details: double-rule border, corner stars, diagonal-stripe accent, and the grain multiplied over the paper color | ⬜ Not started |
| 11 | Apply the fit rules: title shrinks to fit; location is one line shrinking to about 80%; review wraps within the 80-character cap; blank location and missing year stay empty | ⬜ Not started |
| 12 | Rebuild `TicketView` around the new card, shown in portrait with about 24pt side margins (no rotation), keeping the existing share button | ⬜ Not started |
| 13 | Build the design-picker view showing the user's real ticket in each of the three palettes | ⬜ Not started |
| 14 | Update `LogFormView`: location optional and no longer required to print, 25-character cap, no future dates, pass the release year, and create the ticket (assigning its serial) only after a design is picked, then go to the finished ticket | ⬜ Not started |
| 15 | Regenerate the project and run build and tests | ⬜ Not started |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
- Printing / loading animation screen (NICK-5)
- Editing a ticket's entries and changing its design afterward (NICK-6)
- Image export to camera roll and Instagram sharing
- Rotated landscape view of the ticket
- Non-Latin text handling (flagged only; falls back to the system font)
- Persisting the serial counter across launches (NICK-2)

---

## Files That Will Change
- `Nickelog/Models/Ticket.swift`: release year, serial number, optional location, design id
- `Nickelog/Services/TicketStore.swift`: serial counter and assignment (add-only)
- `Nickelog/Features/Ticket/TicketView.swift`: rebuilt around the new card; split into shape, theme, and card files
- `Nickelog/Features/Ticket/` (new files): outline shape, theme definitions, card, design picker
- `Nickelog/Features/Log/LogFormView.swift`: optional location, cap, date limit, release year, navigation to the picker
- `Nickelog/Resources/Fonts/` (new): bundled font files
- `Nickelog/Resources/` (new): grayscale paper grain
- `project.yml`: font registration and new resources
- `NickelogTests/`: tests for serial, location sanitizing, and year parsing

---

## Open Questions
None. Caveat: full Xcode is not installed, so tasks 12, 13, and 15 cannot be verified visually or by build until it is, and tasks 9 to 11 need a visual fix-up pass afterward. Task 4 (tests) came from my proposal during exploration rather than an explicit request, so drop it if you'd rather not have it.
