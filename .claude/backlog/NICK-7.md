# PRD: Design foundation: colors, type styles, shared components, custom tab bar and back button

**Ticket:** NICK-7
**Status:** ✅ Complete
**Created:** 2026-10-19

---

## TL;DR
Build the shared look every Nickelog screen will use (colors, type styles, buttons, search field, tab bar, back button) and lightly re-skin today's screens with it. Every later screen ticket builds on this, and without it the app looks like generic iOS next to the designed ticket.

---

## Problem
The ticket looks finished, but the screens around it use plain default iOS styling: white and gray backgrounds, system fonts, the stock tab bar, and the stock back button. There is no shared set of colors, type styles, or components, so each screen would have to invent its own look and the app would end up inconsistent.

---

## Solution
Create one shared design layer with named color tokens, named type styles, and a set of reusable components, following `Design/screens/handoff.md`. The app is locked to light mode for now; the colors are named tokens so dark values can be added later in one place. UI text scales with Dynamic Type (fixed heights become minimum heights; only the caps labels, tab labels, and counters are capped), while the ticket stays fixed-size.

Components: primary pill, secondary pill, icon button, bordered capsule button (Edit, and Delete in red), red text "Cancel" button, search field, chip, dashed slot, brand imprint ("NICKELOG ★ ADMIT ONE"), a screen header (large title, caps caption, trailing icon buttons), a custom back button (red, with the design's labels, with swipe-back still working), and a custom floating tab bar (Collection and Log a Movie) that hides on pushed screens.

The Bodoni Moda italic font the design uses is added and verified. Then the screens that exist today (Collection, Search, Log It, the design picker, the ticket screen) get a light re-skin using these pieces: cream background, new fonts, new buttons, custom back button, custom tab bar. Their layouts are not redesigned here; that belongs to NICK-1, NICK-8, NICK-9, and NICK-10.

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | Add the Bodoni Moda italic variable font, register it in `UIAppFonts`, run `xcodegen generate`, find its weight names, and add a test that every font name the design system uses loads | ✅ Done |
| 2 | Lock the app to light mode in `project.yml` (`UIUserInterfaceStyle`) | ✅ Done |
| 3 | Define the named color tokens (ground, surface, ink, ink2, muted, mutedSlip, hairline, hairlineSoft, divider, tan, red) with the light values from the hand-off, set up so dark values can be added later in one place | ✅ Done |
| 4 | Define the type styles (largeTitle, filmTitle, display, label, labelSmall, body, secondary, serial, slipEntry, slipReview) tied to Dynamic Type text styles, with the caps labels, tab labels, and counters capped at about `xxxLarge` | ✅ Done |
| 5 | Build the primary pill and secondary pill (minimum height 52pt, capsule) | ✅ Done |
| 6 | Build the icon button (44pt circle), the bordered capsule button (Edit, and Delete in red), and the red text "Cancel" button | ✅ Done |
| 7 | Build the search field (44pt capsule with magnifier and clear button) and the chip (34pt capsule, selected and unselected) | ✅ Done |
| 8 | Build the dashed slot and the brand imprint ("NICKELOG ★ ADMIT ONE") | ✅ Done |
| 9 | Build the screen header: large title, caps caption, and trailing icon buttons | ✅ Done |
| 10 | Build the custom back button (red, chevron, label text set per screen) and make sure swipe-back still works when the native back button is hidden | ✅ Done |
| 11 | Build the custom floating tab bar (surface at 88% with blur, hairlineSoft border, soft shadow, tan selected item, "Collection" and "Log a Movie") in `RootView`, hidden on pushed screens | ✅ Done |
| 12 | Re-skin the Collection screen's surface (cream background, header, fonts, empty-state button) without changing its layout | ✅ Done |
| 13 | Re-skin the Search screen's surface (background, title, search field, fonts) without changing its layout | ✅ Done |
| 14 | Re-skin the Log It form's surface (background, fonts, primary pill, back button "Search") without changing its layout | ✅ Done |
| 15 | Re-skin the design picker's surface (background, fonts, primary pill, back button) without changing its layout | ✅ Done |
| 16 | Re-skin the ticket screen's surface (background, buttons, back button), keeping the existing rule that no back button shows right after printing | ✅ Done |
| 17 | Regenerate the project, run the build and tests, and check every re-skinned screen on the simulator | ✅ Done |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
- Dark mode values and any dark appearance (deferred; the missing dark values for muted, mutedSlip, hairlineSoft, divider, and the dark red get decided later with the designer)
- Layout redesigns: the Collection riffle stack, Search result rows and states, the admission-slip form, and the opened-ticket screen (NICK-1, NICK-8, NICK-9, NICK-10)
- Screen-specific pieces: month header, riffle stack, slip fields, result row, search progress bar
- Screens not designed yet: the printing moment, the post-print finished ticket, the Edit flow, sign-in and username, About, and the launch screen
- A preview gallery of tokens and components (not requested)

---

## Files That Will Change
- `Nickelog/DesignSystem/` (new): color tokens, type styles, and all the components above
- `Nickelog/Resources/Fonts/` (new file) and `project.yml`: Bodoni Moda italic in `UIAppFonts`; light-mode lock
- `Nickelog/Resources/Assets.xcassets` (optional): color sets if the tokens live in the asset catalog
- `Nickelog/App/RootView.swift`: custom tab bar
- `Nickelog/Features/Collection/CollectionView.swift`, `Nickelog/Features/Search/SearchView.swift`, `Nickelog/Features/Log/LogFormView.swift`, `Nickelog/Features/Ticket/TicketDesignPickerView.swift`, `Nickelog/Features/Ticket/TicketView.swift`: surface re-skin and the custom back button
- `NickelogTests/`: a font-loading test for the new fonts

---

## Open Questions
None. Notes: hiding the native back button also disables swipe-back, so task 10 restores it. The custom tab bar loses some native behavior (accessibility traits, re-tap handling) and needs its hide-on-push logic built by hand. Some re-skin work will be redone when NICK-1, 8, 9, and 10 rebuild those screens; that was accepted so the foundation is visible now. The "document the new `DesignSystem/` folder in CLAUDE.md" step is not a task in this PRD, so it will need doing afterward.
