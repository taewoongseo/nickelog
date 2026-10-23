---
id: NICK-14
title: Photo on the back of the ticket, revealed with a flip
type: feature
status: backlog
created: 2026-10-19
---

## What
Let a user optionally attach a photo (for example themselves or their family in the theater) that sits on the back of a ticket, and flip the ticket over to see it.

## Expected Outcome
- When logging a ticket, or editing it later, the user can optionally add a photo.
- In the Ticket Book, tapping a ticket plays a flip animation and shows the photo on its back.
- A ticket with no photo keeps working as it does today.

## Affected Files
- `Nickelog/Models/Ticket.swift`: a place to remember the photo
- `Nickelog/Features/Log/LogFormView.swift`: optional photo picker
- `Nickelog/Features/Ticket/` (new back-of-ticket view and the flip) and `TicketView.swift`
- `Nickelog/Features/Collection/TicketBookView.swift`: how tapping interacts with the flip
- `Nickelog/Services/TicketStore.swift`: photo storage once persistence exists

## Risks / Notes
- Tapping the open ticket in the Ticket Book currently opens the ticket screen (NICK-1). Where the flip happens needs deciding: on the ticket screen, or in place in the book.
- Photos need real storage and upload, so this depends on the cloud work (NICK-2) and storage space.
- Photo library permission and privacy (photos of people, possibly children).
- The back needs a design: how the photo is framed and cropped to look like the back of a ticket.
- Interacts with Edit (NICK-6) and with sharing the ticket as an image later.
