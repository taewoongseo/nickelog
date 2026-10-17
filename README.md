# Nickelog

Every movie you watch leaves behind a ticket. See [VISION.md](VISION.md) for the full product vision, competitive research, and naming rationale.

Native iOS app (Swift + SwiftUI), iOS-first — see VISION.md §8 for the technical approach and why Android is a later phase.

## Requirements

- **Full Xcode** (not just Command Line Tools) — install from the Mac App Store. Command Line Tools alone can't build/run/simulate this project.
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `brew install xcodegen`
- A [TMDB API key](https://www.themoviedb.org/settings/api) (free) for movie search

## Setup

1. Copy the secrets template and fill in your keys:
   ```
   cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig
   ```
   Edit `Config/Secrets.xcconfig` and set `TMDB_API_KEY` (Supabase keys can wait until the backend is wired up).

2. Generate the Xcode project (the `.xcodeproj` is gitignored and regenerated from `project.yml` — this keeps the repo diff-friendly instead of committing Xcode's binary project format):
   ```
   xcodegen generate
   ```

3. Open `Nickelog.xcodeproj` in Xcode and run on a simulator.

Whenever you add/remove/rename Swift files or change build settings, edit `project.yml` and re-run `xcodegen generate` rather than doing it by hand in Xcode — that keeps the project reproducible.

## Project structure

```
Nickelog/
  App/          — app entry point, root tab view
  Features/     — one folder per screen/flow (Search, Log, Ticket, Collection)
  Models/       — Movie, Ticket
  Services/     — TMDBService (movie search), TicketStore (in-memory for now — will move to Supabase per VISION.md §7.2/§7.6)
  Resources/    — Assets.xcassets
NickelogTests/     — unit tests
NickelogUITests/   — UI tests
Config/            — xcconfig files (Secrets.xcconfig is gitignored; commit only the .example)
project.yml        — XcodeGen project spec (source of truth for project structure)
VISION.md          — product vision, competitive research, roadmap
```

## Current state

Early scaffold: movie search (TMDB) → log form → placeholder ticket view → in-memory collection, wired end-to-end but with placeholder visuals. Final ticket design is being done separately (see VISION.md Phase 0) and will replace `TicketView`'s placeholder layout once ready.

## Claude Code workflow

This repo uses a set of custom slash commands under `.claude/commands/` for a consistent dev loop, with work tracked as local markdown tickets under `.claude/backlog/` (no external issue tracker):

```
/create-issue <idea>       — capture a bug/feature/chore as a local ticket (NICK-N)
/explore-feature <ticket>  — interactive Q&A to understand a feature before building
/write-prd <ticket>        — turn a resolved exploration into a task-by-task PRD
/execute-prd <path>        — implement the PRD's tasks one at a time
/review-code               — review the diff against CLAUDE.md's architecture rules
/commit                    — stage + commit with a conventional-commit message
/deploy                    — archive and upload a build to TestFlight
/update-issue <id> <state> — update a ticket's status
```

`/deploy` requires a one-time App Store Connect API key setup — see the instructions it prints, or `Config/appstore.env.example`.
