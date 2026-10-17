# PRD: Edit or delete a ticket after creation

**Ticket:** NICK-6
**Status:** 🟡 In Progress
**Created:** 2026-10-17

---

## TL;DR
Let users edit a ticket's entries and design after it's been printed, or delete it. People misremember a venue, rewrite a review, or want a different look, and a ticket shouldn't be locked once created.

---

## Problem
Once a ticket is created nothing about it can be changed, and there is no way to delete one. `TicketStore` can only add and delete (and nothing in the app calls delete), and the ticket screen has no edit or delete option. A typo or a wrong movie means the ticket is stuck.

---

## Solution
The ticket screen gets two options, Edit and Delete.

**Edit** follows the same flow as logging, pre-filled with the ticket's current values: the details form (date, location, review), then the design picker, then the printing animation, then the updated ticket. The user can change the entries, the design, or both. The movie (title, year, poster) is locked. Edits keep the ticket's serial number and its position in the collection, and the ticket records when it was last edited separately from when it was created. The same input rules apply as when logging: location capped at 25 characters, review capped at 80, no future dates.

**Delete** asks for confirmation, then removes the ticket and returns to the collection. Deleting and re-logging is the way to fix a wrong movie.

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | Add an `updatedAt` field to `Ticket` (additive; `createdAt` unchanged) | ⬜ Not started |
| 2 | Add an update-by-id method to `TicketStore` that changes a ticket in place, keeps its position and serial, and sets `updatedAt` (existing `add`/`delete` unchanged) | ⬜ Not started |
| 3 | Make `TicketView` read the current ticket from the store by id so it never shows stale values after an edit | ⬜ Not started |
| 4 | Add Edit and Delete buttons to the ticket screen | ⬜ Not started |
| 5 | Add the delete confirmation, remove the ticket through `TicketStore`, and return to the collection | ⬜ Not started |
| 6 | Add an edit mode to the details form: pre-filled from an existing ticket, no movie selection required, same input rules as logging | ⬜ Not started |
| 7 | Open the design picker in the edit flow with the ticket's current design selected | ⬜ Not started |
| 8 | Wire the edit flow: details form, design picker, printing animation, then the updated ticket, saving through the store's update method | ⬜ Not started |
| 9 | Make `CollectionView` navigation stay consistent after an edit or a delete | ⬜ Not started |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
- The printing animation itself (NICK-5)
- Persisting edits and deletes beyond the app session (in memory until NICK-2)
- Sorting or reordering the collection by date (deferred)
- Swipe actions on collection rows (Edit and Delete live on the ticket screen only)
- Changing the movie on an existing ticket
- Image export and sharing

---

## Files That Will Change
- `Nickelog/Models/Ticket.swift`: add `updatedAt`
- `Nickelog/Services/TicketStore.swift`: add-only update-by-id method
- `Nickelog/Features/Ticket/TicketView.swift`: Edit and Delete buttons, delete confirmation, read the current ticket from the store
- `Nickelog/Features/Log/LogFormView.swift`: edit mode pre-filled from a ticket
- `Nickelog/Features/Ticket/` (design picker from NICK-4): pre-selected design in edit mode
- `Nickelog/Features/Collection/CollectionView.swift`: navigation consistency after edit and delete

---

## Open Questions
None. Dependencies: this ticket needs NICK-4 (the new `Ticket` fields, serial, design picker) and NICK-5 (the printing animation) first, and none of it can be built or tested until Xcode is installed. This PRD has no unit-test task because tests weren't requested during exploration.
