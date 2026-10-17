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
xcodebuild -project Nickelog.xcodeproj -scheme Nickelog -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests (unit + UI)
xcodebuild -project Nickelog.xcodeproj -scheme Nickelog -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single unit test
xcodebuild -project Nickelog.xcodeproj -scheme Nickelog -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:NickelogTests/TicketStoreTests/testAddInsertsAtFront test
```

In practice, opening `Nickelog.xcodeproj` in Xcode and using Cmd-R / Cmd-U is the normal workflow; the `xcodebuild` invocations above are for scripting/CI.

**The `.xcodeproj` is generated, not hand-edited.** Whenever Swift files are added, removed, or renamed, or build settings change, edit `project.yml` and re-run `xcodegen generate` — do not add files via Xcode's project navigator alone, since that state isn't captured in `project.yml` and will be lost on the next regenerate.

## Architecture

Native iOS app, Swift + SwiftUI, iOS 17+, no external dependencies yet. Full product context (why native, why iOS-first, data model, roadmap) is in [VISION.md](VISION.md) — read it for product rationale before making architectural changes; this file only covers code structure.

**Current state: early scaffold.** The core loop is wired end-to-end (search → log → ticket → collection) but with placeholder persistence and placeholder ticket visuals — both called out explicitly in the source as temporary.

### Flow and layering

```
NickelogApp (@main)
  → owns the single TicketStore, injected via .environmentObject
  → RootView: TabView { CollectionView, SearchView }

SearchView --(TMDBService.searchMovies)--> Movie results
  --navigationDestination--> LogFormView(movie)
    --on submit, builds a Ticket, calls ticketStore.add--> TicketView(ticket)

CollectionView reads ticketStore.tickets --navigationDestination--> TicketView(ticket)
```

- `Features/` is one folder per screen, each a single `View` file — there's no separate ViewModel layer; state lives in `@State` on the view or in the shared `TicketStore`.
- `Models/` (`Movie`, `Ticket`) are plain `Codable`/`Identifiable`/`Hashable` structs used both as TMDB DTOs (`Movie`) and as the app's persisted record (`Ticket`) — no separate DTO/domain-model split.
- `Services/TicketStore` is an in-memory `@MainActor` `ObservableObject` — a deliberate placeholder for Supabase-backed persistence (VISION.md §7.2/§7.6). It's kept as an `ObservableObject` specifically so the swap won't require UI-layer changes; new persistence-touching code should go through `TicketStore`'s methods rather than adding a parallel storage path.
- `Services/TMDBService` reads `TMDB_API_KEY` from `Info.plist` (populated at build time from `Config/Secrets.xcconfig` via `project.yml`'s `info.properties.TMDB_API_KEY`) — never hardcode the key in Swift source.
- `TicketView` is currently a placeholder layout (see its doc comment). A locked, high-fidelity design hand-off exists at [`Design/ticket-and-logo/`](Design/ticket-and-logo/handoff.md) (notched-outline `Shape` geometry, three palette variants, fonts, ticket copy spec) — `TicketView` should be rebuilt natively against that spec (SwiftUI `Shape`/`Path`/`Text`, per VISION.md §8.4) rather than the current placeholder styling.

### Secrets

`Config/Secrets.xcconfig` is gitignored; only `Config/Secrets.xcconfig.example` is committed. New secrets follow the same pattern: add the placeholder key to the `.example` file and wire it through `project.yml`'s `info.properties` if it needs to reach the app bundle at runtime.
