# /update-issue

You are updating a local backlog ticket's status for Nickelog.
This command is used after completing a phase of work (exploration done, PRD written, code complete, etc.)

Nickelog has no external issue tracker — this only updates the local file under `.claude/backlog/`.

---

## Input

Format: $ARGUMENTS should be: [ticket-id] [new-status]

Examples:
  /update-issue NICK-12 in-progress
  /update-issue NICK-12 done
  /update-issue NICK-12 cancelled

Valid statuses: backlog, todo, in-progress, in-review, done, cancelled

---

## Step 1 — Find the ticket

Look for `.claude/backlog/<ticket-id>.md`. If it doesn't exist, say so clearly and stop.

---

## Step 2 — Validate the status

Check the requested status against the valid list above. If it's not one of them, list the valid options and stop.

---

## Step 3 — Update the local backlog file

Update the `status:` field in the file's frontmatter to the new value. Leave everything else in the file unchanged — title, body, affected files, etc.

If the file is a PRD (has a `**Status:**` line rather than frontmatter, from `/write-prd`), map the status instead to the PRD's status line convention:
- `in-progress` → `🟡 In Progress`
- `done` → `✅ Complete`
- `cancelled` → `❌ Cancelled`
- others → leave the PRD status line as-is and only note the change in your confirmation output

---

## Step 4 — Confirm

Print:
```
✅ Updated [ticket-id]: [title] → [new status]
.claude/backlog/[ticket-id].md
```

---

## Rules

- Only update the status field — do not modify ticket title, body, or task list
- If ticket ID is not found, say so clearly and stop
- If status is invalid, list the valid options and stop
