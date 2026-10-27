---
description: Summarize the previous workday's commits for stand-up, calling out what affects the UX side and the BE team
argument-hint: "[git date, e.g. 'last monday' or '3 days ago']"
---

Write my stand-up from the commits since the previous workday (or since `$ARGUMENTS`, when given -- pass it to `--since` as-is).

## Gather

- The default window is relative to now, not pinned to a time of day: `--since='3 days ago'` on a Monday, `--since='1 day ago'` any other day. Get the weekday with `date +%u` (1 = Monday) rather than guessing, pass the relative string to git as-is, and state that string in the first line of the output.
- `git log --all --no-merges --since=<window> --format='%h %an %ad%n%B' --date=short --name-only` -- every author, every branch. My commits are the stand-up; teammates' commits are context (say whose they are), since stand-up is where I hear about them too. A commit on an unmerged branch counts, but say which branch (`git branch -a --contains <hash>`).
- Read the commit bodies, not just subjects; that is where "until the BE ships X" and "the UI can now show Y" live. Read a diff only when the body leaves the effect on another team unclear.
- Learn who owns what in this repo before classifying. Check the docs that already say so: `CLAUDE.md`, a contributing or handoff guide, `CODEOWNERS`. Skim them for ownership boundaries only, and don't explore the codebase beyond that. If they don't settle it, judge from the file paths and say in the output that you did.

## Classify

For each commit, decide whether it affects someone outside the person who wrote it. The two audiences are the UX side (whoever designs or builds what users see) and the BE team (whoever owns the server, API or data this repo talks to). If this repo is itself the backend, read "BE team" as the people who consume its API.

- **UX:** a change to what users see or how they move through it -- wording, states, layout, a flow -- especially where nobody touched that screen directly; a new piece of data, state or shared component the UI can now use; a change to a design token, style or component library.
- **BE team:** a change to what this repo sends or expects across the API boundary -- request or payload shape, endpoints, schemas, contracts; a workaround or placeholder standing in for something the backend hasn't shipped yet ("until the BE...", a hardcoded limit, a TODO naming them); a backend bug found or reported; a request written for them; a new reliance on backend behavior.
- **Neither:** internal refactors, tests, tooling, docs. These collapse into one line at the end.

If a commit doesn't clearly fit, ask whether someone on either team would be surprised to learn about it next week. If so, call it out.

## Write

Plain text I can read aloud or paste into chat, no tables:

1. **Window** -- one line.
2. **Highlights** -- 3-5 bullets of my own work, outcome-first ("the dashboard shows partial outages", not "edited dashboard.jsx"). Fold a series of commits for one feature into one bullet.
3. **For UX** -- what they should know or can now use, each with the commit hash. Omit the section if there is nothing.
4. **For BE** -- what they need to do, what we're waiting on, what we changed that touches their contract. Lead with anything that blocks us or that they need to act on. Omit the section if there is nothing.
5. **Also** -- one line naming the remaining work by area.

Keep it short: this is a two-minute stand-up, not a changelog. If the window has no commits, say so and offer to widen it.
