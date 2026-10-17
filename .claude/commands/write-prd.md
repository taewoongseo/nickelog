# /write-prd

You are producing a minimal, clear PRD based on the full explore-feature conversation that just happened (or the saved context file, if resuming in a new session).
Your job: capture exactly what was decided — nothing more, nothing less.
Do NOT add scope that was not explicitly confirmed. Do NOT make implementation decisions that were not discussed.

Nickelog tracks work locally only — there is no external issue tracker. Every PRD lives under `.claude/backlog/`.

---

## Input

Optional: $ARGUMENTS can be an existing local ticket ID (e.g. `NICK-7`) or a feature slug.
If not provided, infer the ID/slug from the explore-feature conversation or from `.claude/context/*.md` (whichever is most recent and matches `status: ready-for-prd`).
If nothing can be determined, derive a short kebab-case slug from the feature name (e.g. `csv-export`).

---

## Step 1 — Determine the ticket ID

If $ARGUMENTS or the context file gives an existing ID (e.g. `NICK-7`), use it.

If this is a brand-new feature with no ID yet, assign the next one:
1. List files in `.claude/backlog/` matching `NICK-*.md`
2. Take the highest number and increment it (start at `NICK-1` if the directory is empty)

---

## Step 2 — Synthesize the conversation

Review the entire explore-feature exchange (or the `.claude/context/<slug>.md` file if resuming): the original request, your analysis, and all Q&A with the user.
Extract only what was explicitly confirmed or clarified.
If something was discussed but left unresolved, do NOT include it as a task.

---

## Step 3 — Write the PRD file

Write (or overwrite) `.claude/backlog/<TICKET_ID>.md`.

Use this exact template:

```markdown
# PRD: <Feature Name>

**Ticket:** <TICKET_ID>
**Status:** 🟡 In Progress
**Created:** <today's date>

---

## TL;DR
[One or two sentences. What this is and why it matters.]

---

## Problem
[What is currently broken or missing? Be concrete — describe user-visible behavior, not code.]

---

## Solution
[What will be built. High-level, plain English. No implementation details yet.]

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | [first small step] | ⬜ Not started |
| 2 | [second small step] | ⬜ Not started |
| ... | ... | ... |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
[Anything explicitly ruled out during exploration. If nothing was ruled out, write "Nothing explicitly excluded."]

---

## Files That Will Change
[List each file path and one line describing what changes]

---

## Open Questions
[Anything still unresolved. If none, write "None."]
```

---

## Step 4 — Break tasks correctly

Tasks must be:
- Small enough to complete in one focused session
- Ordered so each one is buildable on the previous
- Scoped to exactly what was discussed — no extras

Bad task: "Implement the feature"
Good task: "Add `templateID` variant handling to `TicketView`"

If you are unsure how to break a task down, write one coarser task rather than guessing at sub-tasks.

---

## Step 5 — Confirm

Print:
```
✅ PRD written: .claude/backlog/<TICKET_ID>.md
Tasks: <N> tasks, all ⬜ Not started
Run `/execute-prd .claude/backlog/<TICKET_ID>.md` to begin implementation.
```

---

## Rules

- Only include what was confirmed in the explore-feature exchange
- Do not add tasks for "nice to have" things not discussed
- Do not add error handling, tests, or refactors unless explicitly requested
- Keep each task description concrete enough that execute-prd can act on it without ambiguity
- Always overwrite the existing backlog file for a given ticket ID — never create a separate `-prd.md` file
