---
id: NICK-1
title: Collection "Ticket Book": riffle stack with haptics (replaces flipbook paging)
type: feature
status: backlog
created: 2026-07-04
updated: 2026-10-19
---

## What
Rebuild the Collection tab as the designed "Ticket Book": tickets grouped by month in an overlapping riffle stack, where tapping a peeking ticket expands it with a spring and a haptic tick, and tapping the expanded ticket opens it. This replaces the earlier flipbook/page-turn idea; the design chose the riffle stack instead (see `Design/screens/handoff.md` §1).

## Expected Outcome
- Header: large title "Ticket Book" (Bodoni Moda), search and account icon buttons, and a caps total ("112 TICKETS").
- Tickets newest first, grouped by month, each group with a header ("OCTOBER 2026", "2 OF 4"). Tickets are 370pt wide with 16pt side margins.
- Stacking: each ticket overlaps the previous one, leaving its top 64pt visible. The selected ticket of a month is fully visible and the next starts 12pt below it. The last ticket of each month is always fully visible.
- Interaction: tap a peeking ticket to select it (spring about 0.34s, selection haptic per step); tap the selected ticket to open it. The design recommends making the riffle scroll-linked (the ticket crossing a line near the top expands, one haptic per ticket) with tap-to-select kept; tap-only is the fallback if that feels busy.
- Reduce Motion: no spring, selection changes instantly or cross-fades.
- Stays fast at 500 tickets (lazy loading by month).
- States: empty ("Coming attractions." with a dashed slot and a "Log a Movie" button), one ticket (a dashed "No. 000002 · Next showing" tab from `TicketStore.nextSerialNumber`, plus "Tap a ticket to open it."), loading placeholders (for later cloud sync), and search-your-tickets (capsule field, year chips, result count, results as the same stack).
- Dark mode supported (chrome only; tickets keep their paper colors).

## Affected Files
- `Nickelog/Features/Collection/CollectionView.swift` (rewrite; likely split into header, month section, and riffle stack views)
- `Nickelog/Features/Ticket/TicketCard.swift` (reused at 370pt width; see NICK-11)
- `Nickelog/Services/TicketStore.swift` (read-only use; `nextSerialNumber` already exists)
- `NickelogTests/` (month grouping and search matching logic if extracted)

## Risks / Notes
- Depends on NICK-7 (design foundation: colors, type, components) and NICK-11 (ticket title must sit within the 64pt peek).
- Opening a ticket hands off to NICK-10 (the opened-ticket screen); the lift-out transition (matched geometry) spans both.
- The hand-off flags a known conflict: stepping the selection on vertical swipe fights the page scroll; resolve in exploration.
- What "search your tickets" matches (title, place, review, year?) is left to the code and needs a decision.
- The account icon button needs a destination; the account/settings screen is not designed yet.
- Needs a real device to judge the haptics and the riffle feel; the simulator can't.
