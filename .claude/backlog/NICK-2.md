---
id: NICK-2
title: Design Supabase schema, security rules, and sign-in setup (V1)
type: feature
status: backlog
created: 2026-10-17
---

## What
Design the V1 backend: database tables, row-level security rules, and auth configuration for Supabase. Backend design only, no Swift wiring.

## Expected Outcome
- A Supabase project exists (free tier) with `profiles` and `tickets` tables matching VISION.md §8.5, created via SQL migration files checked into the repo.
- Row-level security guarantees each user can only read and write their own rows.
- Sign in with Apple is configured as the auth provider. Google sign-in is optional and deferred.
- Supabase URL and anon key are placeholders in `Config/Secrets.xcconfig.example` (already templated), ready for the app.
- Wiring `TicketStore` to Supabase is a separate follow-up ticket.

## Affected Files
- `supabase/migrations/*.sql` (new): schema and RLS policies
- `Config/Secrets.xcconfig.example`: confirm SUPABASE_URL / SUPABASE_ANON_KEY placeholders
- `README.md`: short backend setup section
- (follow-up, not this ticket) `Nickelog/Services/TicketStore.swift`, `project.yml`

## Risks / Notes
- No Supabase project exists yet; creating one is a manual step for the user.
- Sign in with Apple needs a paid Apple Developer account ($99/yr) to configure fully, and that must be set up before auth can be tested.
- V1 only: do not design `follows` or public-profile fields yet (VISION.md V2). Leave room so adding them is additive.
- Serial number is the user's personal ticket count; decide whether it is derived (count of rows) or stored, so deleting a ticket doesn't create duplicates or gaps.
- Free-tier Supabase projects pause after about a week of inactivity.
