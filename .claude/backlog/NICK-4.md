---
id: NICK-4
title: Rebuild TicketView in SwiftUI from the design hand-off
type: feature
status: backlog
created: 2026-10-17
---

## What
Replace the placeholder `TicketView` with a native SwiftUI recreation of the locked ticket design in `Design/ticket-and-logo/handoff.md`, with three user-selectable palettes and a design-picker step in the logging flow.

## Expected Outcome
- Ticket renders at the 1300x640 reference aspect ratio (~2.03:1) with the six-notch outline as a custom `Shape`, scaling proportionally. Shown in portrait with side margins (~24pt each side), not full-bleed and not rotated.
- Main body and stub layouts match the hand-off: title, release year, bordered date/location box, dashed divider with star ornament, italic review; stub with rotated "ADMIT ONE", serial, "5¢", and NICKELOG wordmark.
- Decorative details present: double-rule border, corner stars, diagonal-stripe accent, paper texture overlay.
- Three palettes (A burgundy, B amber, C blue) as themes. The user picks one in the flow: search -> add -> form -> pick design -> done. The picker shows the user's real ticket in each palette.
- `Ticket` gains: release year (optional), permanent serial number, optional location, and the chosen design (via `templateID`).
- Serial: assigned at ticket creation from a counter that only increases, never reused, never changed by edits. Gaps after deletes are fine. Rewatches are allowed; each ticket gets its own serial.
- Location: optional, capped at 25 characters at input; trimmed, newlines stripped, whitespace-only counts as blank. Blank location leaves its cell empty. At render the cell stays on one line and shrinks (down to ~80%) to fit.
- Title shrinks to fit. Review keeps the existing 80-character cap and wraps (design handles ~93 characters in 2-3 lines).
- Release year missing: the year line is simply empty. Date watched cannot be in the future.
- Required fonts bundled and registered; paper texture converted once to a neutral grayscale grain and multiplied over each palette's paper color.
- `LogFormView` no longer requires a location to enable "Print My Ticket".

## Affected Files
- `Nickelog/Features/Ticket/TicketView.swift` (rewrite; likely split into shape, theme, and card files)
- `Nickelog/Features/Log/LogFormView.swift` (pass release year, optional location, future-date limit, location cap, then continue to the design picker)
- `Nickelog/Features/Ticket/` (new: design-picker view, theme definitions)
- `Nickelog/Models/Ticket.swift` (add release year, serial number; location optional; design id)
- `Nickelog/Services/TicketStore.swift` (add-only: serial counter / assignment; existing `add`/`delete` surface unchanged)
- `Nickelog/Resources/Fonts/` (new: bundled font files)
- `Nickelog/Resources/` (neutral grayscale paper grain derived from `Design/ticket-and-logo/paper-texture-A.png`)
- `project.yml` (UIAppFonts under info.properties, include new resources, then `xcodegen generate`)
- `NickelogTests/` (serial counter, location sanitizing, year parsing)

## Out of Scope (separate tickets)
- Printing / loading animation screen (NICK-5)
- Editing a ticket's entries and changing its design afterward (NICK-6)
- Image export to camera roll and Instagram sharing
- Rotated landscape view of the ticket (possible later feature)
- Non-Latin text handling (Korean/Japanese/Chinese fall back to the system font; flagged, not solved)

## Risks / Notes
- Full Xcode is not installed yet, so nothing can be built or seen; expect a visual fix-up pass.
- Font PostScript names must match exactly or iOS silently falls back to the system font.
- Serial counter lives in `TicketStore` (in memory) for now; NICK-2 must persist it with the account or numbering restarts.
- Hand-off mentions `*.dc.html` filenames but the files are `ticket-concepts.html` and `logo-concepts.html`.
- 11 Google Fonts (OFL license) must be downloaded; fine to bundle.
- NICK-1 (flipbook paging in Collection) will reuse this card at collection size.
