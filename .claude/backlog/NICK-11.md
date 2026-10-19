---
id: NICK-11
title: Make the ticket title readable inside the Ticket Book's 64pt peek
type: chore
status: backlog
created: 2026-10-19
---

## What
In the Ticket Book each ticket is overlapped so only its top 64pt shows. The design notes the locked ticket's title sits a little low for that. Check it, and move the title up if needed.

## Expected Outcome
- At the Ticket Book's 370pt width, the title (including long, two-line titles) is fully readable within the top 64pt of the ticket, for all three designs.
- The ticket's look is otherwise unchanged.

## Affected Files
- `Nickelog/Features/Ticket/TicketCard.swift` (main body layout: how the top half is positioned)

## Risks / Notes
- This changes the **locked** ticket layout, so confirm the exact change with the user before building.
- 64pt at 370pt width is about 225 points at the 1300×640 reference scale. In current renders a one-line title already sits well inside that and a two-line title is close, so the first step is to measure, not assume.
- Two-line titles and the shrink-to-fit rule (titles shrink down to 50%) could push the title lower; check the longest cases.
- Must not break the notched corners or the top border, which also occupy the peek area.
- Needed before NICK-1 can look right.
