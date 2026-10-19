---
id: NICK-8
title: Restyle Search ("Log a Movie") with all states, and fix stale search results
type: feature
status: backlog
created: 2026-10-19
---

## What
Apply the designed Search screen (`Design/screens/handoff.md` §3): large title "Log a Movie", caption "WHAT DID YOU SEE?", a capsule search field, poster-thumbnail result rows, and every state. Includes fixing the existing bug where older searches can overwrite newer results.

## Expected Outcome
- Initial state: centered "Search a film you watched." and "Give it a one-line verdict and Nickelog prints you a ticket."
- Results: rows at least 82pt tall with a 44×66 poster thumbnail (grey placeholder until the TMDB image loads), title, year (or italic "Year unknown"), and a chevron; hairline divider under the text only.
- Updating (every keystroke): previous rows stay at 0.55 opacity with a 2pt red bar sweeping under the field; no spinner, no blank screen, no reordering animation.
- No results: "No picture by that name." and "Check the spelling, or try the original title."
- Offline: "The projector's dark." with a Try Again button, distinct from other errors.
- Missing API key (developer builds only): a plain "TMDB API key missing" card.
- Search results always reflect the latest query: stale or out-of-order responses never replace newer ones, and in-flight requests for old queries are cancelled.
- Reduce Motion: the sweeping bar becomes static.
- TMDB attribution is intentionally not on this screen (it lives in About, see NICK-12).

## Affected Files
- `Nickelog/Features/Search/SearchView.swift` (restyle, states, cancellation)
- `Nickelog/Services/TMDBService.swift` (distinguish offline from other errors)
- `NickelogTests/` (latest query wins; error classification)

## Risks / Notes
- Depends on NICK-7.
- The bug: `SearchView` starts a new request on every keystroke and never cancels older ones, so a slow response for "Ja" can overwrite the results for "Jaws". A UI test hit this by tapping a stale result.
- Offline detection needs `URLError` handling; "Try Again" must re-run the current query.
- Poster loading needs caching behavior decided (AsyncImage versus a small cache) and respects TMDB image URLs only.
- Search uses a custom capsule field rather than the native `.searchable`, which changes keyboard and focus behavior.
