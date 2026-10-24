# PRD: Invite a friend to a planned screening with a link ("Save Them a Seat")

**Ticket:** NICK-16
**Status:** 🟡 In Progress
**Created:** 2026-10-24

---

## TL;DR
From a planned ticket, "Save Them a Seat" sends a friend one link. With Nickelog installed the link opens the app with an envelope that opens to reveal the ticket; without it, the link shows the ticket as an image and a link to the App Store. It is the part of Nickelog that feels like handing a friend a real ticket, and it is how the app spreads.

---

## Problem
You can plan a film (NICK-13), but only for yourself. There is no way to ask a friend to come along or to hand them the ticket, and nothing that makes the invitation feel special.

---

## Solution
A planned ticket gets a "Save Them a Seat" button that creates a link and opens the share sheet, so it can be sent in any app. One link works for everyone (no in-app "send to friends" for now).

- **Friend with Nickelog:** the link opens the app, an envelope opens to reveal the ticket, and the friend is asked whether to save it. Saving puts it in their own Coming Soon list.
- **Friend without Nickelog:** the link opens a simple page that shows the ticket as an image they can save, with a link to the App Store. If they install the app afterwards, they tap the link again.
- **Sender:** if the friend has an account and saves the ticket, the sender sees "Maya saved this". A friend without an account can't be detected.
- **Changing the plan:** after the sender edits the date or place of a ticket they sent, the app optionally asks "Send the new link?". When the friend opens the new link, the ticket they already saved is updated instead of a second copy being created.

The delight is the point: the invitation must feel old-fashioned and analog, like handing a friend a real ticket in an envelope, never like a generic app notification or a plain link preview. The envelope, the wording, the link preview and the web page all carry that voice.

---

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | Add an invitation record to the backend (the planned ticket's details, who sent it, and who saved it), set up through the Supabase work in NICK-2 | ⬜ Not started |
| 2 | Draw the planned ticket as an image and upload it when an invitation is created | ⬜ Not started |
| 3 | Add the "Save Them a Seat" button to the planned ticket's screen: it creates the invitation and its link and opens the share sheet | ⬜ Not started |
| 4 | Build the small web page for the link: the ticket image (saveable), a link to the App Store, and a link preview that shows the ticket when pasted into messages, in the old-theatre voice | ⬜ Not started |
| 5 | Make the link open Nickelog when it is installed, and load the invitation it points to | ⬜ Not started |
| 6 | Build the envelope-opening animation that reveals the ticket, with a Reduce Motion version | ⬜ Not started |
| 7 | Add the choice after the envelope opens: save the ticket to the friend's Coming Soon list, or leave it | ⬜ Not started |
| 8 | Show the sender "[Name] saved this" when a friend with an account saves the ticket | ⬜ Not started |
| 9 | After the sender edits the date or place of a sent plan, offer to send the new link; opening it updates the friend's saved ticket instead of adding a second one | ⬜ Not started |
| 10 | Regenerate the project, run the build and all tests, and check the whole flow end to end, including opening the link on a real iPhone with and without the app installed | ⬜ Not started |

**Status legend:**
- ⬜ Not started
- 🟡 In progress
- ✅ Done
- ❌ Blocked

---

## Out of Scope
- In-app "send to friends and followers" (needs the follow system, a later feature)
- Profiles, following and the feed (later tickets)
- Carrying an invitation across an app install (iOS can't do this automatically; the friend taps the link again)
- Copying or storing the real cinema's booking or QR code

---

## Files That Will Change
- Not scoped yet. Likely: a new invitation model and service in the app, `Nickelog/Features/Ticket/` (the planned ticket's screen, the envelope animation, the saved-ticket flow), the app's link handling in `Nickelog/App/` and `project.yml`, the Supabase tables and storage (NICK-2), and a separate small static web page outside the app.

---

## Open Questions
- This PRD was written from our conversation without a separate exploration pass, so it should get a `/explore-feature NICK-16` before building.
- **Needs first:** NICK-13 (planned tickets), NICK-2 (accounts and Supabase), and the paid Apple Developer account (opening links in the app).
- The domain name for the links and where the web page is hosted (a domain costs roughly $10 to $15 a year).
- Does the sender need to be signed in to send a link? Does a friend need an account to save a ticket, or can they save it on the phone without one? ("Maya saved this" only works with accounts.)
- What the friend sees if the invitation is later deleted or the date has passed, and whether links expire.
- Who sees the invitation page: anyone with the link can see the film, date and place, so privacy needs a decision.
- Whether one link can be saved by several friends, and how the sender sees several "saved" notices.
- The envelope's look and the page's design are not designed yet.
