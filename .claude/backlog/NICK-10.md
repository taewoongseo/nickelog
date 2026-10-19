---
id: NICK-10
title: Opened-ticket screen: Share Ticket, Save to Photos, Edit and Delete placement
type: feature
status: backlog
created: 2026-10-19
---

## What
Build the designed screen shown when a ticket is opened from the Ticket Book (`Design/screens/handoff.md` §2), including real image sharing and saving to Photos, which no ticket covers yet.

## Expected Outcome
- Nav bar: back "Ticket Book" (red) and the serial as the title ("No. 000112"). The tab bar hides.
- The ticket centered vertically at 354pt wide (24pt side margins).
- Below it: a full-width primary pill "Share Ticket" and a secondary pill "Save to Photos".
- Bottom row: "Edit" (left) and "Delete" (right, red), both 44pt bordered capsules. The actions themselves are built in NICK-6.
- **Share Ticket shares the ticket as an image** (today it shares plain text).
- **Save to Photos saves the ticket image** to the photo library, with a clear result and a graceful message if permission is denied.
- Transition from the collection: the tapped ticket lifts out and moves to centre (matched geometry).

## Affected Files
- `Nickelog/Features/Ticket/TicketView.swift` (layout, actions)
- `Nickelog/Services/` (new: render a ticket to an image with `ImageRenderer`, and save it to Photos)
- `project.yml` (photo library add-only usage description in Info.plist)
- `NickelogTests/` (image export produces the expected size)

## Risks / Notes
- Depends on NICK-7. The transition pairs with NICK-1; Edit and Delete actions and the delete confirmation belong to NICK-6 (the confirmation dialog is not designed yet).
- The finished-ticket screen right after printing (with "Done") is not designed yet and currently reuses this view; the two entry points may need different layouts.
- Export size and format are undecided (resolution, PNG versus JPEG); the later Instagram Stories composition (1080×1920) is a separate future ticket.
- `ImageRenderer` must reproduce fonts, the blended paper grain, and the notches correctly; verify the exported image against the on-screen ticket.
- Saving to Photos needs the add-only photo permission string, or the app will crash when saving.
