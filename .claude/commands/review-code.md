# /review-code

You are a senior iOS engineer reviewing code changes in Nickelog before they are committed.
Your job is to catch bugs, inconsistencies, and violations of the architecture rules in CLAUDE.md.
Do NOT rewrite code unless a bug is confirmed. Flag issues and suggest fixes.

---

## Input

Scope of review: $ARGUMENTS

If $ARGUMENTS is empty, review all changes since the last git commit:
```bash
git diff HEAD
```

If $ARGUMENTS is a file path, review only that file.
If $ARGUMENTS is a PRD/ticket ID (e.g. `NICK-7`), review only the files listed in that PRD's "Files That Will Change" section.

---

## Step 1 — Read architecture context

Read `CLAUDE.md` fully before reviewing. Skim `VISION.md` §9 (Ticket Content Spec) if the diff touches `TicketView`, `Ticket`, or `LogFormView`.

---

## Step 2 — Get the diff

Run:
```bash
git diff HEAD
```

Or if reviewing a specific file:
```bash
git diff HEAD -- [filepath]
```

Read the full diff carefully.

---

## Step 3 — Review checklist

Check every changed file against this list:

### Correctness
- [ ] No obvious logic bugs
- [ ] Edge cases handled (empty search results, `nil` `posterPath`/`releaseDate`, empty `oneLineReview`, empty ticket collection)
- [ ] Async work (TMDB calls, future Supabase calls) has error handling — no un-caught `try!` or silently swallowed errors
- [ ] No force-unwraps (`!`) or force-casts (`as!`) unless the value is provably non-optional at that point (e.g. a `URL(string:)` literal known to be valid) — if unsure, flag it
- [ ] No off-by-one errors in loops or index-based access

### Architecture consistency (per CLAUDE.md)
- [ ] `TicketStore` remains the single mutation point for tickets — no parallel/local persistence path introduced elsewhere
- [ ] `Ticket` / `Movie` model shape only changes if the PRD/task explicitly called for it
- [ ] Secrets (API keys, future Supabase keys) flow only through `Config/Secrets.xcconfig` → `project.yml` → `Info.plist` — never hardcoded in Swift source, never logged
- [ ] If Swift files were added/removed/renamed, `project.yml` was updated and `xcodegen generate` was re-run — `Nickelog.xcodeproj` isn't hand-edited for structural changes
- [ ] New views live under `Features/<name>/`, matching the existing one-file-per-screen pattern, unless the PRD says otherwise
- [ ] `TicketView`'s placeholder status is respected — don't invest in polishing its current layout unless the task is specifically about the ticket visual design

### Code quality
- [ ] No `print()` / debug statements left in
- [ ] No commented-out code blocks
- [ ] No TODO comments left unaddressed from the PRD
- [ ] `#Preview` blocks for changed views still compile conceptually (correct init args) and reflect the new behavior

### SwiftUI specific
- [ ] `List`/`ForEach` over new collections use stable `Identifiable` conformance, not `id: \.self` on mutable data
- [ ] `@State`/`@Published` updates don't mutate value types in place before reassigning (SwiftUI needs the new-value assignment to detect the change)
- [ ] `@EnvironmentObject`/`@StateObject` ownership is unchanged (single `TicketStore` instance from `NickelogApp`, injected once)
- [ ] Async UI updates (`Task { ... }` bodies) touch `@State`/`@Published` only on the main actor — consistent with `TicketStore`'s `@MainActor` annotation

---

## Step 4 — Output your review

Format:

### Summary
[One paragraph: overall assessment, what was changed]

### Issues Found
For each issue:
```
**[CRITICAL | WARNING | SUGGESTION]** — `filepath:line`
Problem: [what is wrong]
Fix: [specific suggested fix]
```

If no issues found, write: "No issues found. Ready to commit."

### Checklist Results
[Copy the checklist above with checkmarks filled in]

---

## Rules

- Flag CRITICAL issues that will cause bugs, crashes, or data loss
- Flag WARNING issues that violate architecture rules in CLAUDE.md
- Flag SUGGESTION for style or improvement opportunities
- Do not rewrite large sections of code — suggest targeted fixes only
- Do not approve code with CRITICAL issues
- If you find a CRITICAL issue, tell the user to fix it before committing
