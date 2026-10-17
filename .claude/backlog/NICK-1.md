---
id: NICK-1
title: Flipbook-style paging + haptics for Collection view
type: feature
status: backlog
created: 2026-07-04
---

## What
The Collection tab (home/landing tab, see grooming discussion — Collection-first, search filters own tickets only) should feel like physically flipping through a ticket stub collection book, not a plain scrolling list. As the user scrolls/flips through tickets, it should give the tactile buzz (haptic feedback) some iOS apps give per item as you page through, plus a visual flip/page-turn feel rather than a standard list scroll.

## Expected Outcome
Moving between tickets in the Collection view feels tactile: each "flip" to the next/previous ticket triggers haptic feedback (Taptic Engine), and the visual transition mimics turning a physical stub/page rather than a plain `List` scroll. Should hold up with large collections (many tickets), not just 2-3.

## Affected Files
- `Nickelog/Features/Collection/CollectionView.swift` — likely needs to move off a plain SwiftUI `List` onto a paging/carousel-style control
- Possibly a new custom view/transition component under `Nickelog/Features/Collection/`
- `Nickelog/Services/TicketStore.swift` — read-only consumer, not expected to change

## Risks / Notes
- Needs a visual/motion design pass before implementation — user is considering taking this to Claude Design first, undecided yet.
- Achieving a real page-flip feel likely means replacing the plain `List` with either a `TabView(.page)` style paging control or a custom `ScrollView` + transform-based flip effect, plus `UIImpactFeedbackGenerator`/`UINotificationFeedbackGenerator` wired to page-change events.
- Depends on the Collection-view grooming decisions from the same session (Collection as landing tab, in-collection search bar) — not yet written up as their own ticket.
