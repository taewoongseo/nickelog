# PRD: Collection "Ticket Book": scroll-linked riffle stack with haptics

**Ticket:** NICK-1
**Status:** ✅ Complete
**Created:** 2026-10-19

---

## TL;DR
Turn the Collection tab into the designed "Ticket Book": tickets grouped by month in an overlapping stack that opens as you scroll, with a small haptic tick for each ticket. It's the screen people see every day, and it should feel like flipping through a book of ticket stubs.

---

## Problem
The Collection is a plain list of titles and one-line reviews. It doesn't show the tickets at all, has no month grouping, no tactile feel, and no way to search your own tickets.

---

## Solution
Tickets are grouped into month sections by date watched, newest first (tickets on the same day ordered by when they were logged). Within a month the tickets overlap, each showing only its top 64pt, like a deck being riffled. As you scroll freely, the ticket crossing a fixed line near the top opens fully and you feel one small tick for each ticket that passes. Only one ticket is open at a time across the whole list; the last ticket of each month is always fully visible. Tapping a peeking ticket brings it to the line and opens it; tapping the open ticket opens it in the ticket screen with a normal push.

Each month has a header with its name on the left and, on the right, "N OF M" for the month the open ticket is in or a plain count ("M TICKETS") for the others. The screen header has the large "Ticket Book" title, a caps total, and a search button. Search switches the header to a capsule field with a red Cancel and shows matching tickets as the same stack, matching title, place, and the one-line review only (no year chips, no date matching). States: the empty state built earlier, a one-ticket state with a dashed "Next showing" tab, and a loading state with pulsing placeholder tickets (built now, shown in the real app once cloud sync exists). With Reduce Motion on, selection changes instantly.

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | Add the grouping helper: group tickets by month of date watched, newest first, with tickets on the same day ordered by logging order, kept in one replaceable place | ✅ Done |
| 2 | Add the search matching helper: a ticket matches when the text appears in its title, place, or one-line review (no date or year matching) | ✅ Done |
| 3 | Add unit tests for month grouping and ordering (including same-day ties) and for search matching (including a title like "2001: A Space Odyssey" matching "2001" but not a movie released in 2001) | ✅ Done |
| 4 | Build the month header row: month name on the left, and "N OF M" or "M TICKETS" on the right | ✅ Done |
| 5 | Build the riffle stack layout for one month: tickets 370pt wide, each overlapping the previous to leave its top 64pt visible, the open ticket fully visible with the next one starting 12pt below it, the last ticket of the month always fully visible, later tickets drawn on top | ✅ Done |
| 6 | Build the scrolling month list, loading lazily by month, with 22pt between months and about 120pt of bottom space so the floating tab bar never covers the last ticket | ✅ Done |
| 7 | Add scroll-linked selection with free scrolling: the ticket crossing a fixed line near the top is the one open ticket across the whole list | ✅ Done |
| 8 | Add the selection haptic tick each time a different ticket crosses the line, and the Reduce Motion behavior (no spring, instant change) | ✅ Done |
| 9 | Add the tap behavior: tapping a peeking ticket brings it to the line and opens it with a spring (about 0.34s), and tapping the open ticket pushes into `TicketView` | ✅ Done |
| 10 | Drive each month header's right side from the open ticket: "N OF M" for the month it is in, "M TICKETS" for the other months | ✅ Done |
| 11 | Rebuild the screen header: large "Ticket Book" title, caps total caption ("N TICKETS", "NO SCREENINGS YET" when empty), and a search icon button only | ✅ Done |
| 12 | Build the one-ticket state: the dashed open-bottom "No. 000002 · Next showing" tab above the ticket and "Tap a ticket to open it." below it, shown only when there is exactly one ticket | ✅ Done |
| 13 | Build the loading state: grey placeholder tickets in the same overlapping layout pulsing from full to 55% opacity over 1.4s (static with Reduce Motion), with "COLLECTING YOUR TICKETS…" and "Syncing with your account." | ✅ Done |
| 14 | Build the search state: the search button switches the header to a capsule field with a red Cancel, shows a caps count ("3 TICKETS MATCH"), and lists the matches as the same stack | ✅ Done |
| 15 | Wire `CollectionView` together: keep the existing empty state and the push to `TicketView`, and make the loading state something that can be shown and previewed without the real app triggering it | ✅ Done |
| 16 | Regenerate the project, run the build and tests, and check the screens on the simulator | ✅ Done |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
- The account button and account screen (a separate future ticket)
- Year chips, and any search by year or date
- The lift-out (matched geometry) transition to the opened ticket (NICK-10)
- Sorting options and a sort UI (the ordering stays easy to change later)
- Snapping/ratchet scrolling
- Dark mode
- Wiring the loading state to real cloud sync
- Edit and delete from the collection (NICK-6)

---

## Files That Will Change
- `Nickelog/Features/Collection/CollectionView.swift`: rewritten around the Ticket Book header, month sections, search, and loading states; keeps the empty state and the push to `TicketView`
- `Nickelog/Features/Collection/` (new files): month header, riffle stack with scroll-linked selection and haptics, search header and results, loading placeholder, and the grouping and search helpers
- `Nickelog/Features/Ticket/TicketCard.swift`: reused at 370pt wide (no change planned; see NICK-11)
- `Nickelog/Services/TicketStore.swift`: read-only, no change
- `NickelogTests/`: tests for grouping, ordering, and search matching

---

## Open Questions
None. Notes:
- Task 3 (tests) came from my proposal during exploration, not an explicit request; drop it if you'd rather not have it.
- The haptic and spring feel can only be judged on a real iPhone; the simulator can't show them.
- NICK-11 (two-line titles and the year getting cut off in the 64pt peek) should be done before or alongside this.
- Risks to watch while building: the open ticket growing from 64pt to 182pt can cause jitter under the finger during scrolling; rendering many overlapping tickets (grain and shadow on each) must stay smooth at 500 tickets; and the deployment target is iOS 17, so iOS 18+ scroll APIs can't be relied on.
- A newly logged ticket appears where its date watched puts it, not necessarily at the top.
