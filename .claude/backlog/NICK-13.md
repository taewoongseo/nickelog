# PRD: Plan a screening: "Coming Soon" list and logging a planned film later

**Ticket:** NICK-13
**Status:** ✅ Complete
**Created:** 2026-10-24

---

## TL;DR
Add a second way to start a ticket: save a film you're going to watch, keep it in a "Coming Soon" tab in the Ticket Book, and log it later through the admission slip once you've watched it. It makes the app useful before the screening too, and it is the base for inviting friends later (NICK-16).

---

## Problem
Nickelog only works after the fact: you can only log a film you have already watched. There is no way to keep a film you plan to see, and nothing to log later when you finally watch it.

---

## Solution
After tapping a film in search, a choice appears first: "Log My Stub" (today's flow, for a film you've seen) or "Save My Seat" (new, for a film you're going to see). The planning flow uses a version of the admission slip: the scheduled date is optional (left empty, the ticket reads "TBD"), the place is optional, and the review is locked until the film is watched (the ticket reads "Not yet screened"). The user still picks one of the three designs. A planned ticket has no ticket number; the number is only given when the film is logged, so the number counts films watched, and the number spot on a planned ticket is blank.

The Ticket Book gets a two-word switch under its title, like "Screened 12 · Coming Soon 3": the active word in ink, the other dimmed, with a thin marquee-style underline. The bottom bar stays as it is. "Screened" shows logged tickets; "Coming Soon" shows planned tickets in the same overlapping stack, grouped by month of the scheduled date with the soonest first, and a final "TBD" group for tickets with no date (in the order they were saved). The header total counts only logged tickets, Coming Soon shows its own count, and "search your tickets" searches whichever tab you're on. From Coming Soon you open a planned ticket and tap a log button, which leads to the same admission slip: the scheduled date is kept (and can be changed), or starts as today if it was "TBD", and it can never be in the future. Saving with the required review turns the planned ticket into a logged ticket and gives it its number.

The feeling matters most: old-fashioned and analog, like holding a real ticket. The wording, the planned ticket and its screens should keep that voice and never feel like a to-do list.

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | Let a ticket be planned: add a planned state and an optional scheduled date to `Ticket`, with no serial number while planned; logged tickets behave as today | ✅ Done |
| 2 | Add to `TicketStore` a way to save a planned ticket (no serial), to log a planned ticket (it becomes a logged ticket and gets the next serial, keeping or changing its date), and make sure delete works for both and counts cover logged tickets only | ✅ Done |
| 3 | Add the Coming Soon ordering (soonest scheduled date first, "TBD" tickets after them in the order saved) and the per-tab count and search helpers | ✅ Done |
| 4 | Add unit tests for tasks 2 and 3: planned tickets get no serial, logging assigns it, serials still never get reused, the ordering, the counts, and search per tab | ✅ Done |
| 5 | Build the choice shown after tapping a film in search, as a small sheet that slides up over the results: the title "Which showing is this?" with the film's name and year, then two buttons: "Log My Stub" (with "Print a ticket for a film you've seen.") and "Save My Seat" (with "Save it for later.") | ✅ Done |
| 6 | Rename "Log a Movie" to "Add a Film" wherever it appears (the bottom tab label, the search screen title, the button in the empty Ticket Book), replace the wording that assumes the film was already watched ("What did you see?" and "Search a film you watched."), and use "film" instead of "movie" in all text the user sees | ✅ Done |
| 7 | Build the planning form as a version of the admission slip: optional scheduled date (empty means "TBD"), optional place, review locked and showing "Not yet screened", no ticket number | ✅ Done |
| 8 | Add a planned variant of the ticket card ("TBD" for an empty date, blank place, "Not yet screened" for the review, blank number spot) in all three designs, and show it to the user for approval because the ticket layout is locked | ✅ Done |
| 9 | Connect the planning flow: planning form, then the design picker (three designs), then save to Coming Soon and land on the planned ticket's screen | ✅ Done |
| 10 | Build the planned ticket's screen: the planned ticket with a button to log it, and Edit and Delete buttons (edit the date, place and design with the review staying locked; delete asks "are you sure?" first) | ✅ Done |
| 11 | Log a planned ticket through the admission slip: scheduled date prefilled (today if "TBD", never a future date, changeable), review required, and saving turns it into a logged ticket with its number | ✅ Done |
| 12 | Add the "Screened" and "Coming Soon" switch under the Ticket Book's title (active word in ink, the other dimmed, thin marquee-style underline), with each side's own count, and keep the header total for logged tickets only | ✅ Done |
| 13 | Show the Coming Soon list as the overlapping stack grouped by month of the scheduled date (soonest first) with a "TBD" group at the end, open a planned ticket on tap, and add the empty state: "Nothing showing soon." with a "Plan a Screening" button that goes to the search | ✅ Done |
| 14 | Make "search your tickets" search whichever tab is showing | ✅ Done |
| 15 | Regenerate the project, run the build and all tests, and check the whole flow on the simulator (choice, plan, save, Coming Soon, log, tabs, search) | ✅ Done |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
- Anything special for a planned date that has passed (a planned ticket is left alone; no "past due" marking)
- Sending or receiving invitations, the link, the web page, "Maya saved this", and the envelope animation (NICK-16)
- In-app "send to friends and followers" (needs the follow system, a later feature)
- Profiles, following and the feed (later tickets)
- Anything needing accounts or Supabase

---

## Files That Will Change
- `Nickelog/Models/Ticket.swift`: planned state and optional scheduled date (additive)
- `Nickelog/Services/TicketStore.swift`: save a planned ticket without a serial, log a planned ticket (assigns the serial), keep delete and serial rules
- `Nickelog/Features/Search/SearchView.swift`: tapping a film leads to the choice screen; the new "Add a Film" title and wording
- `Nickelog/App/RootView.swift` and `Nickelog/DesignSystem/Components/AppTabBar.swift`: the tab label becomes "Add a Film"
- `Nickelog/Features/Collection/CollectionView.swift`: the empty Ticket Book button becomes "Add a Film"
- `Nickelog/Features/Log/` (new choice screen and planning form): optional date, optional place, locked review
- `Nickelog/Features/Log/LogFormView.swift`: a mode for logging a planned ticket, with the date prefilled
- `Nickelog/Features/Ticket/TicketCard.swift`: planned variant of the ticket
- `Nickelog/Features/Ticket/TicketDesignPickerView.swift`: used in the planning flow
- `Nickelog/Features/Ticket/TicketView.swift`: the planned ticket's screen with the log button
- `Nickelog/Features/Collection/CollectionView.swift`, `TicketBookView.swift`, `TicketGrouping.swift`, `TicketSearch.swift`: the two tabs, Coming Soon order, counts, search per tab, empty state
- `NickelogTests/`: tests for tasks 2 and 3

---

## Open Questions
- None of the earlier open points remain, apart from the two notes below.
- The tests in task 4 came from my proposal during exploration, not an explicit request; drop them if you'd rather not have them.
- The new caption under "Add a Film" and the search's first message are not decided yet (I suggested "WHICH ONE?" and "Search a film."); confirm when building task 6.
- The planned ticket's look (task 8) needs your approval, since the ticket layout is locked.
- With exactly one planned ticket, Coming Soon does not show the dashed "Next showing" tab (planned tickets have no number).
