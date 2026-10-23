# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Requires full Xcode (not just Command Line Tools) and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```bash
# First-time setup: copy secrets template and fill in TMDB_API_KEY
cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig

# Regenerate Nickelog.xcodeproj from project.yml (the .xcodeproj is gitignored)
xcodegen generate

# Build
xcodebuild -project Nickelog.xcodeproj -scheme Nickelog -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run all tests (unit + UI)
xcodebuild -project Nickelog.xcodeproj -scheme Nickelog -destination 'platform=iOS Simulator,name=iPhone 17' test

# Run a single unit test
xcodebuild -project Nickelog.xcodeproj -scheme Nickelog -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:NickelogTests/TicketStoreTests/testAddInsertsAtFront test
```

In practice, opening `Nickelog.xcodeproj` in Xcode and using Cmd-R / Cmd-U is the normal workflow; the `xcodebuild` invocations above are for scripting/CI.

**The `.xcodeproj` is generated, not hand-edited.** Whenever Swift files are added, removed, or renamed, or build settings change, edit `project.yml` and re-run `xcodegen generate` — do not add files via Xcode's project navigator alone, since that state isn't captured in `project.yml` and will be lost on the next regenerate.

## Architecture

Native iOS app, Swift + SwiftUI, iOS 17+, no external dependencies yet. Full product context (why native, why iOS-first, data model, roadmap) is in [VISION.md](VISION.md) — read it for product rationale before making architectural changes; this file only covers code structure.

**Current state: V1 core loop working, persistence still a placeholder.** The loop is wired end-to-end (search → log → pick design → ticket → collection) with the designed ticket in three palettes. Persistence is in memory only, a deliberate placeholder for Supabase.

### Flow and layering

```
NickelogApp (@main)
  → owns the single TicketStore, injected via .environmentObject
  → RootView: a TabView { CollectionView, SearchView } with its own bar hidden, plus the
    custom floating AppTabBar drawn over it (hidden on pushed screens and while the keyboard is up)

SearchView (owns the NavigationPath) --(TMDBService.searchMovies)--> Movie results
  --navigationDestination--> LogFormView(movie, onFinish)
    --"Pick a Design"--> TicketDesignPickerView(draft)
      --on pick, ticketStore.addAssigningSerial--> TicketView(ticket, onDone)
        --"Done" calls onFinish, which clears SearchView's path--> back to search

CollectionView reads ticketStore.tickets, shows the Ticket Book (or the empty, one-ticket, search state)
  --navigationDestination--> TicketView(ticket)
```

- `Features/` is one folder per screen, each a single `View` file — there's no separate ViewModel layer; state lives in `@State` on the view or in the shared `TicketStore`. The one exception is `DesignSystem/` (below), which holds code shared by every screen.
- `DesignSystem/` is the shared look, following the locked screens hand-off in `Design/screens/handoff.md` (local-only, not in the public repo). Colors are named tokens (`AppColor.ground`, `.ink`, `.red` and so on) whose values live in `Resources/Assets.xcassets/Colors`; the app is locked to light mode (`UIUserInterfaceStyle` in `project.yml`), and dark mode can later be added by giving each color set a dark appearance, with no code changes. Type is applied with `.appStyle(.label)` and the other `AppTextStyle` cases; they scale with Dynamic Type, with the caps labels, tab labels and counters capped at `xxxLarge`. Components live in `DesignSystem/Components/`: pill, icon, bordered-capsule and red-text buttons, `AppSearchField`, `FilterChip`, `DashedSlot`, `BrandImprint`, `ScreenHeader`, `AppBackButton`, and `AppTabBar`. Pushed screens use `.appBackButton("Previous screen")` (it replaces the system back button and keeps edge-swipe working; `.swipeBackDisabled()` turns the swipe off) and `.hidesTabBar()`. A screen can switch tabs through the `selectTab` environment value. Ticket colors and fonts are separate (`TicketTheme`) and never follow these tokens.
- `Models/` (`Movie`, `Ticket`) are plain `Codable`/`Identifiable`/`Hashable` structs used both as TMDB DTOs (`Movie`) and as the app's persisted record (`Ticket`) — no separate DTO/domain-model split. `TicketDesign` is the enum of the three designs (its raw value is stored in `Ticket.templateID`). `TicketInput` holds the input rules (location capped at 25 characters, trimmed, newlines turned into spaces, blank means `nil`; review capped at 80) and `Movie.releaseYear`.
- `Services/TicketStore` is an in-memory `@MainActor` `ObservableObject` — a deliberate placeholder for Supabase-backed persistence (VISION.md §8.2/§8.6). It's kept as an `ObservableObject` specifically so the swap won't require UI-layer changes; new persistence-touching code should go through `TicketStore`'s methods rather than adding a parallel storage path. Tickets get their permanent serial number from `addAssigningSerial(_:)`, which uses a counter that only increases (never reused after a delete); `nextSerialNumber` previews it. The plain `add(_:)` does not assign a serial, so app code should use `addAssigningSerial`.
- `Services/TMDBService` reads `TMDB_API_KEY` from `Info.plist` (populated at build time from `Config/Secrets.xcconfig` via `project.yml`'s `info.properties.TMDB_API_KEY`) — never hardcode the key in Swift source.
- The ticket is built natively in SwiftUI under `Features/Ticket/`, following the locked design hand-off in `Design/ticket-and-logo/handoff.md` (a local-only folder, not in the public repo). `TicketCard` is the layout (main body plus stub), sized by a scale factor from the 1300×640 reference in `TicketMetrics`; `NotchedTicketShape` is the six-notch outline; `TicketDecoration` holds the rules, hatched stripe, corner stars and `PaperGrainOverlay`; `TicketTheme` defines the three palettes and their fonts; `TicketDesignPickerView` is the design-choice step; `TicketView` frames the finished ticket. The bundled fonts live in `Resources/Fonts/` and are registered in `project.yml` under `UIAppFonts`. `TicketThemeTests` and `DesignSystemFontTests` fail if any font name doesn't load, since a wrong name silently falls back to the system font; `DesignSystemColorTests` does the same for a misspelled color name.
- The Ticket Book (`Features/Collection/`) groups tickets by month of date watched (`TicketGrouping`, the one place to change ordering) and lays each month out with `RiffleLayout`, a custom `Layout` where tickets overlap and only the open one is fully shown. `TicketBookView` makes the ticket crossing a fixed line the open one as you scroll (with a selection haptic); `OneTicketView`, `TicketBookLoadingView` (not yet shown by the app, waits for cloud sync) and the search state in `CollectionView` cover the other states. `TicketSearch` matches title, place and the one-line review only. Avoid iOS 18-only scroll APIs; the target is iOS 17.

### Secrets

`Config/Secrets.xcconfig` is gitignored; only `Config/Secrets.xcconfig.example` is committed. New secrets follow the same pattern: add the placeholder key to the `.example` file and wire it through `project.yml`'s `info.properties` if it needs to reach the app bundle at runtime.
