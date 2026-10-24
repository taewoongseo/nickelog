# PRD: Plan a screening: "Coming Soon" list and logging a planned film later

**Ticket:** NICK-13
**Status:** 🟡 In Progress
**Created:** 2026-10-24

---

## TL;DR
Add a second way to start a ticket: save a film you're going to watch, keep it in a "Coming Soon" tab in the Ticket Book, and log it later through the admission slip once you've watched it. It makes the app useful before the screening too, and it is the base for inviting friends later (NICK-16).

---

## Problem
Nickelog only works after the fact: you can only log a film you have already watched. There is no way to keep a film you plan to see, and nothing to log later when you finally watch it.

---

## Solution
After tapping a film in search, a choice appears first: "I watched this" (today's flow) or "I'm going to watch this" (new). The planning flow uses a version of the admission slip: the scheduled date is optional (left empty, the ticket reads "TBD"), the place is optional, and the review is locked until the film is watched (the ticket reads "Not yet screened"). The user still picks one of the three designs. A planned ticket has no ticket number; the number is only given when the film is logged, so the number counts films watched, and the number spot on a planned ticket is blank.

The Ticket Book gets two tabs: "Screened" (logged tickets) and "Coming Soon" (planned tickets), ordered with the soonest scheduled date first and "TBD" tickets after them in the order they were saved. The header total counts only logged tickets, Coming Soon shows its own count, and "search your tickets" searches whichever tab you're on. From Coming Soon you open a planned ticket and tap a log button, which leads to the same admission slip: the scheduled date is kept (and can be changed), or starts as today if it was "TBD", and it can never be in the future. Saving with the required review turns the planned ticket into a logged ticket and gives it its number.

The feeling matters most: old-fashioned and analog, like holding a real ticket. The wording, the planned ticket and its screens should keep that voice and never feel like a to-do list.

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | Let a ticket be planned: add a planned state and an optional scheduled date to `Ticket`, with no serial number while planned; logged tickets behave as today | ⬜ Not started |
| 2 | Add to `TicketStore` a way to save a planned ticket (no serial), to log a planned ticket (it becomes a logged ticket and gets the next serial, keeping or changing its date), and make sure delete works for both and counts cover logged tickets only | ⬜ Not started |
| 3 | Add the Coming Soon ordering (soonest scheduled date first, "TBD" tickets after them in the order saved) and the per-tab count and search helpers | ⬜ Not started |
| 4 | Add unit tests for tasks 2 and 3: planned tickets get no serial, logging assigns it, serials still never get reused, the ordering, the counts, and search per tab | ⬜ Not started |
| 5 | Build the choice screen shown after tapping a film in search: "I watched this" or "I'm going to watch this", in the old-theatre voice | ⬜ Not started |
| 6 | Build the planning form as a version of the admission slip: optional scheduled date (empty means "TBD"), optional place, review locked and showing "Not yet screened", no ticket number | ⬜ Not started |
| 7 | Add a planned variant of the ticket card ("TBD" for an empty date, blank place, "Not yet screened" for the review, blank number spot) in all three designs, and show it to the user for approval because the ticket layout is locked | ⬜ Not started |
| 8 | Connect the planning flow: planning form, then the design picker (three designs), then save to Coming Soon and land on the planned ticket's screen | ⬜ Not started |
| 9 | Build the planned ticket's screen: the planned ticket with a button to log it | ⬜ Not started |
| 10 | Log a planned ticket through the admission slip: scheduled date prefilled (today if "TBD", never a future date, changeable), review required, and saving turns it into a logged ticket with its number | ⬜ Not started |
| 11 | Add the "Screened" and "Coming Soon" tabs to the Ticket Book, with each tab's own count, and keep the header total for logged tickets only | ⬜ Not started |
| 12 | Show the Coming Soon list in its order, open a planned ticket on tap, and add an empty state for an empty Coming Soon tab | ⬜ Not started |
| 13 | Make "search your tickets" search whichever tab is showing | ⬜ Not started |
| 14 | Regenerate the project, run the build and all tests, and check the whole flow on the simulator (choice, plan, save, Coming Soon, log, tabs, search) | ⬜ Not started |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
- Sending or receiving invitations, the link, the web page, "Maya saved this", and the envelope animation (NICK-16)
- In-app "send to friends and followers" (needs the follow system, a later feature)
- Profiles, following and the feed (later tickets)
- Anything needing accounts or Supabase

---

## Files That Will Change
- `Nickelog/Models/Ticket.swift`: planned state and optional scheduled date (additive)
- `Nickelog/Services/TicketStore.swift`: save a planned ticket without a serial, log a planned ticket (assigns the serial), keep delete and serial rules
- `Nickelog/Features/Search/SearchView.swift`: tapping a film leads to the choice screen
- `Nickelog/Features/Log/` (new choice screen and planning form): optional date, optional place, locked review
- `Nickelog/Features/Log/LogFormView.swift`: a mode for logging a planned ticket, with the date prefilled
- `Nickelog/Features/Ticket/TicketCard.swift`: planned variant of the ticket
- `Nickelog/Features/Ticket/TicketDesignPickerView.swift`: used in the planning flow
- `Nickelog/Features/Ticket/TicketView.swift`: the planned ticket's screen with the log button
- `Nickelog/Features/Collection/CollectionView.swift`, `TicketBookView.swift`, `TicketGrouping.swift`, `TicketSearch.swift`: the two tabs, Coming Soon order, counts, search per tab, empty state
- `NickelogTests/`: tests for tasks 2 and 3

---

## Open Questions
- Editing or deleting a planned ticket (the Edit and Delete buttons from NICK-6): what is allowed, and how the planned ticket's screen shows them. To be decided when building task 9.
- The look of an empty Coming Soon tab and what the Coming Soon tab shows when it holds exactly one ticket (wording and design not decided).
- The tests in task 4 came from my proposal during exploration, not an explicit request; drop them if you'd rather not have them.
- The planned ticket's look (task 7) needs your approval, since the ticket layout is locked.
