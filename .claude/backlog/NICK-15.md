---
id: NICK-15
title: Custom folders to organize tickets
type: feature
status: backlog
created: 2026-10-19
---

## What
Let a user create their own folders with custom names (for example "with family", "with my girlfriend", "in New York") to organize tickets.

## Expected Outcome
- The user can create, name, and delete folders, and put tickets into them.
- The user can look at the tickets in a folder.
- Planned for later, after the cloud sign-in work.

## Affected Files
- Not scoped yet. Likely `Nickelog/Models/` (a folder model and a link from the ticket), `Nickelog/Services/TicketStore.swift`, and the Collection screens.

## Risks / Notes
- Open for exploration: whether a ticket can be in more than one folder (undecided).
- Open for exploration: the folder design and where folders appear in the Ticket Book (undecided; to be worked out later).
- Folders need to be saved with the account, so this comes after NICK-2.
- Interacts with search in the Ticket Book (NICK-1): should folders be searchable or filterable?
