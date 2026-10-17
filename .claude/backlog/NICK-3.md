---
id: NICK-3
title: Get a TMDB API key and add it to Secrets.xcconfig
type: chore
status: done
created: 2026-10-17
---

## What
Register for a free TMDB API key and put it in the local, gitignored `Config/Secrets.xcconfig` so movie search works.

## Expected Outcome
- `TMDB_API_KEY` in `Config/Secrets.xcconfig` is a real key, not the `your_tmdb_api_key_here` placeholder.
- A test request to TMDB's search endpoint with the key returns results (can be verified from the command line without Xcode).
- Searching in the app returns movies instead of the "Add a TMDB API key" message.

## Affected Files
- `Config/Secrets.xcconfig` (local, gitignored; manual step by the user)
- `Config/Secrets.xcconfig.example` (no change expected)

## Risks / Notes
- Use the "API Key" value from themoviedb.org/settings/api, not the longer "API Read Access Token".
- Never paste the key into chat or commit it. The file is gitignored.
- TMDB's free tier is non-commercial and requires attribution to TMDB inside the app. Revisit licensing if Nickelog adds paid premium templates.
- The in-app search can only be tested once Xcode is installed; the key itself can be verified now with a curl request.

## Resolution (2026-10-17)
- Key obtained and stored in the local, gitignored `Config/Secrets.xcconfig`.
- Verified from the command line: a TMDB search request returned HTTP 200 with results.
- Remaining: confirm search works inside the app once Xcode is installed.
- Reminder: the key was issued under TMDB's non-commercial certification. Get TMDB approval or a commercial license before any public or paid release.
