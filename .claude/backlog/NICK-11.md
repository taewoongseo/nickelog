# PRD: Make the ticket title readable inside the Ticket Book's 64pt peek

**Ticket:** NICK-11
**Status:** ✅ Complete
**Created:** 2026-10-24

---

## TL;DR
In the Ticket Book each ticket shows only its top 64pt when it is overlapped. Make the title and the year readable in that space, including two-line titles, by making the title a bit smaller and tightening the spacing above it.

---

## Problem
A render of the top 64pt in all three designs shows that one-line titles and the year already fit, but two-line titles get their second line cut off and lose the year. The longest titles lose the year in all three designs. Design B's wide font wraps even "The Godfather Part II". The year must always be visible, so today's sizes and spacing don't work.

---

## Solution
Reduce the title font size on all three ticket designs by roughly a quarter and tighten the spacing above the title and between the title and the year, so that a two-line title plus the year fit in the top 64pt. Titles still wrap to two lines as they do now, and the opened ticket shows the full title. The exact numbers are decided by rendering the top 64pt of all three designs with short, two-line and very long titles and getting the user's approval, because the ticket layout is locked. The change applies to every place the ticket is drawn (Ticket Book, one-ticket state, design picker, opened ticket). The rest of the ticket's look stays the same.

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | Render the top 64pt of all three designs with short, two-line and very long titles to use as the "before" measurement | ✅ Done |
| 2 | Reduce each design's title font size by roughly a quarter and tighten the top spacing and the gap between title and year, so a two-line title plus the year fit in 64pt | ✅ Done |
| 3 | Render the 64pt peek again for all three designs and show the user the before and after, and get approval of the final sizes and spacing (adjust and repeat if needed) | ✅ Done |
| 4 | Check the full ticket in the design picker and on the opened ticket screen in all three designs, to confirm it still looks balanced and the notched corners and top border are undisturbed | ✅ Done |
| 5 | Regenerate the project, run the build and all tests | ✅ Done |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
- A Ticket Book-only layout, a first-line-only or "…" peek, or shrinking only when a title wraps
- Changing the two-line limit or the shrink-to-fit rule
- Any other change to the ticket layout (date and place box, review, stub)

---

## Files That Will Change
- `Nickelog/Features/Ticket/TicketTheme.swift`: title size for each of the three designs
- `Nickelog/Features/Ticket/TicketCard.swift`: top spacing and the gap between title and year in the main body

---

## Open Questions
None. Note: the final sizes depend on the render approval in task 3, and the new title size will also appear on any share image planned in NICK-10.
