---
id: NICK-13
title: Movie invitations: plan a screening and send a friend an animated ticket invite
type: feature
status: backlog
created: 2026-10-19
---

## What
Let a user plan a movie before it screens (movie, date, time, place), then send it to a friend they are going with as an invitation.

## Expected Outcome
- You search a movie and enter the plan details (date, time, location), even if you booked the real ticket elsewhere (for example AMC with its own QR code).
- You share it with a friend, who receives an animated invitation in the app: an envelope opens and reveals the ticket.
- Planned: V2. A new concept beside the existing "log after you've seen it" flow.

## Affected Files
- Not scoped yet. Likely a new `Features/Invite/` area, a new planned-screening model, and sharing and accounts through the cloud work (NICK-2).

## Risks / Notes
- Needs accounts and a way to reach a friend (link, contact, or in-app), so it depends on NICK-2 and on the social work in VISION.md.
- Open questions for exploration: does the planned screening turn into a normal logged ticket afterwards? What does a friend without the app see? Is the invitation ticket a new design?
- Do not show or store the real cinema's QR code or booking data unless that is decided deliberately.
