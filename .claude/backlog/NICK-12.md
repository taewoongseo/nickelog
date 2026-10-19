---
id: NICK-12
title: About screen with TMDB attribution, and launch screen
type: feature
status: backlog
created: 2026-10-19
---

## What
Add an About area that carries the required TMDB attribution and the open-source licenses, plus a launch screen using the wordmark. The attribution is a license requirement and was deliberately removed from the Search screen.

## Expected Outcome
- An About screen reachable from the app (via the account/settings entry) showing exactly: "This product uses the TMDB API but is not endorsed or certified by TMDB."
- Font and other third-party licenses shown (content already in `THIRD_PARTY_LICENSES.md`), and the app version.
- A launch screen using the Limelight "Nickelog" wordmark.

## Affected Files
- `Nickelog/Features/` (new About screen folder)
- `Nickelog/App/RootView.swift` or the Collection header (entry point)
- `project.yml` (launch screen configuration)

## Risks / Notes
- **Not designed yet.** The hand-off lists About/Settings and the launch screen as open items. Needs a design, or a plain interim About screen can satisfy the attribution requirement.
- The attribution must be in place before any public release or TestFlight beyond personal testing.
- The Collection header's account (person) button needs a destination; account management, sign-in, and delete-account belong with the NICK-2 follow-up work.
- TMDB is currently used under a non-commercial certification; commercial or paid release needs TMDB approval first.
