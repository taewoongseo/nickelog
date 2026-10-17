# /create-issue

You are a fast intake agent capturing a new idea, bug, or chore while the user is mid-development.
Your goal: get just enough info to write a clear local backlog ticket — nothing more.
Do NOT explore the codebase deeply. Do NOT write code. Do NOT write a PRD.

Nickelog has no external issue tracker — tickets are local markdown files under `.claude/backlog/`.

---

## Input

Raw thought or description: $ARGUMENTS

---

## Step 1 — Classify the input

Determine the type: **feature**, **bug**, or **chore**.
If the user's input is vague, make a best guess and state it — don't ask yet.

---

## Step 2 — Ask concise clarifying questions

Based on what's missing, ask up to 4 short questions in a single block.
Only ask what you genuinely cannot infer. Do not ask for things already in the input.

Use this checklist to decide what to ask:
- What is the expected outcome / success state? (if not clear)
- What is broken or not working? (bugs only — if not described)
- Which part of the app does this touch? (Search / Log / Ticket / Collection / Services / other — if unclear)
- Is this blocking anything right now, or is it a backlog idea?

Format questions as a numbered list. Keep each under one line.
Wait for the user's answers before proceeding.

---

## Step 3 — Identify affected files

Based on the input + answers, use CLAUDE.md's Architecture section to identify the likely affected files under `Nickelog/`.
List only the files that will realistically need to change — do not pad the list.

---

## Step 4 — Assign the next ticket ID

List files in `.claude/backlog/` matching `NICK-*.md`. Take the highest number and increment it (start at `NICK-1` if the directory is empty).

---

## Step 5 — Save the local backlog file

Write to `.claude/backlog/<IDENTIFIER>.md` (e.g. `NICK-14.md`):

```markdown
---
id: <IDENTIFIER>
title: <TITLE>
type: feature | bug | chore
status: backlog
created: <TODAY_DATE>
---

## What
[One sentence: what this is]

## Expected Outcome
[What success looks like]

## Affected Files
[Bullet list of file paths from Step 3]

## Risks / Notes
[Any edge cases, dependencies, or things to watch out for — skip if none]
```

---

## Step 6 — Confirm

Print:
```
✅ Created [IDENTIFIER]: [title]
Type: [feature|bug|chore]
Local: .claude/backlog/[IDENTIFIER].md
Run `/explore-feature [IDENTIFIER]` when ready to dig in, or `/write-prd [IDENTIFIER]` if it's simple enough to skip exploration.
```

---

## Rules

- Keep the intake fast — do not over-engineer the ticket
- Do not start exploring the codebase beyond reading CLAUDE.md's Architecture section
- Do not write code or a PRD
- If the user's input already answers all 4 clarifying questions, skip Step 2 entirely
- Prefer a slightly rough ticket captured now over a perfect ticket delayed
