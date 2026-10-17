---
id: NICK-5
title: "Printing" loading screen between design pick and finished ticket
type: feature
status: backlog
created: 2026-10-17
---

## What
After the user picks a ticket design, show a short, playful old-film/theater-themed loading animation (a ticket being printed) before revealing the finished ticket.

## Expected Outcome
- Flow becomes: search -> add -> form -> pick design -> printing screen -> finished ticket.
- The animation is brief and themed (film reel, ticket machine, or similar); exact concept to be decided in exploration.
- Respects the Reduce Motion accessibility setting.

## Affected Files
- `Nickelog/Features/Ticket/` (new: printing view)
- `Nickelog/Features/Log/LogFormView.swift` or the design-picker view (navigation hook)

## Risks / Notes
- Depends on NICK-4 (the picker step and finished ticket).
- A fake delay should stay short so it feels charming, not slow.
- Needs Xcode to design and verify the animation.
