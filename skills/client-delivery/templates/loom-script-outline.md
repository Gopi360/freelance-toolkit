# Loom Walkthrough Script

## Recording Checklist (Before Hitting Record)

- [ ] Close all unnecessary tabs and notifications
- [ ] Open all relevant tabs in order (n8n, GHL, testing tool)
- [ ] Have test data ready to trigger a live demo
- [ ] Set Loom to record "Screen + Camera" (face builds trust)
- [ ] Keep it under 10 minutes (clients won't watch longer)

---

## Section 1: What We Built (60-90 seconds)

**Script:**

> "Hey [Client Name], it's Mit! I'm excited to walk you through
> everything we've built. Let me give you a quick overview."

- Show the system in action FIRST — trigger a test event and let them
  see the end result (e.g., a contact appearing in GHL with tags)
- Narrate what happened: "So what just happened is — a message came in,
  our AI qualified the lead, and it's now in your pipeline tagged as hot"

**Key point**: Show the VALUE before the mechanics. Client sees the
result, then wants to understand how.

---

## Section 2: How It Works (2-3 minutes)

**Script:**

> "Let me show you how this works under the hood."

- Open n8n and walk through the workflow visually (zoom to fit)
- Point at each major node group: "This section handles [X],
  this section does [Y]"
- DON'T explain every node — focus on the business logic
- Mention the error handling: "If anything goes wrong, you'll get
  a Slack message / email within minutes"

---

## Section 3: How to Set It Up (2-3 minutes)

**Script:**

> "If you ever need to set this up again or move it to a new account,
> here's what you'd do."

- Open the README and walk through the setup steps
- Show where the environment variables are configured
- Show the `.env.example` file: "These are all the keys you'd need"
- Mention: "Everything is in the README I've shared, so you can
  always reference it later"

---

## Section 4: How to Test (1-2 minutes)

**Script:**

> "Let me show you how to test that everything's working."

- Trigger a test event (live demo)
- Show the result in GHL / the destination system
- Show the n8n execution log: "You can always check here to see
  what happened with each message"

---

## Section 5: What If Something Breaks (1 minute)

**Script:**

> "If something goes wrong, here's what happens and what to do."

- Show the error notification (Slack message or email)
- Show the troubleshooting table in the README
- Mention: "Most common issue is [X], and the fix is [Y]"
- Remind them of support terms: "I'm available for the next [X weeks]
  for any bug fixes"

---

## Section 6: Next Steps & Close (30 seconds)

**Script:**

> "That's everything! To recap: the system is live and active.
> You'll get alerts if anything goes wrong. The README has all
> the setup details. And I'm here for the next [X weeks] if you
> need anything. Really enjoyed building this — let me know if
> you have any questions!"

---

## Pro Tips

- **Speed**: Talk at normal pace. Clients can watch at 1.5x if they want.
- **Mistakes**: If you mess up, just say "let me redo that" and keep going.
  Clients appreciate authenticity over polish.
- **Length**: If it's going over 10 minutes, split into 2 videos
  ("Part 1: Overview" and "Part 2: Setup Guide")
- **Thumbnail**: Pause at the "result" screen (e.g., GHL with the new lead)
  so the Loom thumbnail shows value
- **Share**: Send via Loom link, not attachment. Clients can comment with
  timestamps if they have questions.
