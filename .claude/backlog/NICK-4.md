---
id: NICK-4
title: Rebuild TicketView in SwiftUI from the design hand-off
type: feature
status: backlog
created: 2026-10-17
---

## What
Replace the placeholder `TicketView` with a native SwiftUI recreation of the locked ticket design in `Design/ticket-and-logo/handoff.md`.

## Expected Outcome
- Ticket renders at the 1300x640 reference aspect ratio (~2.03:1) with the six-notch outline as a custom `Shape`, scaling proportionally.
- Main body and stub layouts match the hand-off: title, release year, bordered date/location box, dashed divider with star ornament, italic review; stub with rotated "ADMIT ONE", serial, "5¢", and NICKELOG wordmark.
- Decorative details present: double-rule border, corner stars, diagonal-stripe accent, paper texture overlay (tiled PNG).
- Three palette variants (A burgundy, B amber, C blue) implemented as swappable themes, with one chosen as the V1 default.
- Required fonts bundled and registered; long titles, reviews, and locations reflow without clipping.
- Optional location hides gracefully when blank.

## Affected Files
- `Nickelog/Features/Ticket/TicketView.swift` (rewrite; likely split into shape, theme, and card files)
- `Nickelog/Models/Ticket.swift` (add release year; serial derived from ticket count)
- `Nickelog/Features/Log/LogFormView.swift` (pass release year into the ticket)
- `Nickelog/Resources/Fonts/` (new: bundled font files)
- `Nickelog/Resources/` (paper texture PNG, from `Design/ticket-and-logo/paper-texture-A.png`)
- `project.yml` (register fonts under UIAppFonts, include new resources, then re-run `xcodegen generate`)

## Risks / Notes
- Full Xcode is not installed yet, so the code can only be syntax-checked until then. Expect visual fix-up once it can be previewed.
- `Ticket` has no release year or serial number today; decide whether serial is stored or derived (shared question with NICK-2).
- Hand-off mentions `*.dc.html` filenames but the files are `ticket-concepts.html` and `logo-concepts.html`; texture is already exported as `paper-texture-A.png`.
- 11 Google Fonts must be downloaded and their licenses (OFL) are fine for bundling.
- Image export for camera roll and Instagram sharing is a separate follow-up (`ImageRenderer`); keep the card renderable at arbitrary size to support it.
- NICK-1 (flipbook paging in Collection) will reuse this view at collection size.
