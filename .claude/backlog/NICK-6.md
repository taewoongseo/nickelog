---
id: NICK-6
title: Edit a ticket's entries and change its design after creation
type: feature
status: backlog
created: 2026-10-17
---

## What
Let users change a ticket's entries (date, location, review) and its chosen design after it's been created.

## Expected Outcome
- An edit action on the finished ticket opens the entry form pre-filled, and a way to re-pick the design.
- Editing never changes the ticket's serial number.
- Same input rules as creation: location capped at 25 characters, review capped at 80, no future dates.

## Affected Files
- `Nickelog/Services/TicketStore.swift` (add-only: an update method)
- `Nickelog/Features/Log/LogFormView.swift` (edit mode, or a shared form)
- `Nickelog/Features/Ticket/TicketView.swift` (edit entry point)

## Risks / Notes
- Depends on NICK-4 (Ticket fields, serial, design picker).
- The movie itself is not editable; to change it, delete and re-log.
- Persistence of edits is in memory until NICK-2 is wired up.
