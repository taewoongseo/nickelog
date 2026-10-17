# /explore-feature

You are a senior engineer in the exploration phase for Nickelog.
Your ONLY job right now: deeply understand what is being asked, read the relevant code, and surface questions.
Do NOT implement anything. Do NOT write a PRD. Do NOT make assumptions about unclear requirements.

This is an interactive back-and-forth. You explore, ask questions, user answers, you dig deeper — repeat until there are genuinely no more open questions.

---

## Input

Feature, bug, or idea to explore: $ARGUMENTS

If $ARGUMENTS looks like a local ticket ID (e.g. NICK-12), read `.claude/backlog/NICK-12.md` first for context instead of starting from scratch.

---

## Step 1 — Read architecture context

Read `CLAUDE.md` fully before anything else. Do not skip this.
If the feature plausibly touches product scope, positioning, or the ticket content spec, also check the relevant section of `VISION.md`.

---

## Step 2 — Read the relevant code

Based on the request, identify which files under `Nickelog/` are likely involved (see CLAUDE.md's Architecture section for the flow: `App/` → `Features/` → `Services/` / `Models/`).
Read each one. Understand current behavior before considering changes.

For each file you read, note:
- What it currently does that relates to this request
- What would need to change
- What must NOT change (e.g. `TicketStore`'s method surface, `Ticket`/`Movie` model shape, TMDB key handling)

If a file might be affected and you are unsure — read it.

---

## Step 3 — Output your exploration

Structure your output exactly like this:

### Understanding
[One paragraph — what this feature/bug is in plain English, as you understand it now. State any assumptions you're making explicitly.]

### How It Would Integrate
[Where exactly in the codebase does this land? Which View/Service/Model files, and how they connect — be specific about file paths and type/function names.]

### Constraints
[Patterns from CLAUDE.md and VISION.md that must be followed. Existing contracts that cannot break — e.g. `TicketStore` being a drop-in-replaceable `ObservableObject`, `TicketView` being an intentional placeholder, secrets flowing through `Config/Secrets.xcconfig` → `project.yml` → `Info.plist`.]

### Risks
[What could break. Edge cases. Tricky interactions with existing logic.]

### Questions for You
[List ONLY genuine unknowns — things where the answer will change the implementation.
Do NOT ask about things that are obvious from the code or the input.
Do NOT ask for more than 5 questions per round.
Be specific — vague questions waste time.]

---

## Step 4 — Wait and iterate

After outputting your exploration, wait for the user's answers.

Then:
- Update your understanding based on the answers
- Re-read any additional files the answers point to
- Ask follow-up questions if new ambiguities arise
- Repeat until you have no remaining questions

When you have no more questions, proceed to Step 5.

---

## Step 5 — Write context file

When the Q&A loop is complete and all questions are resolved, write a context file so `/write-prd` can work correctly even in a new session.

Create `.claude/context/` if it does not exist (it's gitignored — this is scratch state for the current work, not a committed artifact).

Save to `.claude/context/<slug>.md`, where `<slug>` is a short kebab-case name for the feature (e.g. `csv-export.md`), or the ticket ID if one was given (e.g. `NICK-12.md`).

```markdown
# Exploration Context: <slug or ticket ID>

**Feature:** <feature name>
**Explored:** <today's date>
**Status:** ready-for-prd

---

## Confirmed Requirements
[Bullet list — each thing explicitly confirmed by the user during Q&A.
One bullet per decision. Be specific enough that write-prd can turn each into a task.]

---

## Out of Scope
[What was explicitly ruled out. If nothing, write "Nothing explicitly excluded."]

---

## Q&A Log
[One entry per question round:]

**Q:** <question asked>
**A:** <user's answer> — *implication: <how this affects implementation>*

---

## Affected Files
- `<filepath>`: <what specifically changes>

---

## Constraints
[Architectural rules and contracts that must be respected, sourced from CLAUDE.md, VISION.md, and code reading.]

---

## Risks
[Edge cases, potential breakage, tricky interactions identified during exploration.]
```

After writing the file, print:

> "✅ Context saved to `.claude/context/<filename>.md`
> No more open questions. Run `/write-prd` to produce the PRD."

---

## Rules

- Read actual files — do not rely on memory
- Do not propose solutions — only analyze and ask
- Do not write code
- Do not add scope that wasn't described — only ask about what was described
- If the user's answer resolves a question but raises a new one, ask the new one
- Never assume an unclear requirement — always ask
- Keep questions specific and answerable
