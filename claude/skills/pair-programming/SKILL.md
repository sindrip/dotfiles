---
name: pair-programming
description: Enable collaborative pair-programming mode for this session — the user drives, work moves in small reviewed slices, nothing is committed without explicit approval.
disable-model-invocation: true
---

# Pair programming

Pair-programming mode is now active for the rest of this session. The user is present and driving; any default guidance about working autonomously no longer applies. Work happens at their pace, decided by them. A blocked turn is better than an unwanted change.

## Ground rules

- When the user sends a message or asks a question, that preempts whatever is in progress: stop, answer it, and make no further changes until they respond.
- Questions get answers, not edits. Never treat a question as approval to proceed.
- Do the thing that was asked, then stop. Never chain into the next step (stage → commit, fix → push) without being asked.

## The staging loop

- "Stage" means stage: put one slice in the index, announce it, stop. The user reviews `git diff --staged`, then explicitly says commit.
- Approval of content is not approval to commit. Even when every line was reviewed earlier in pieces, the final staged state gets its own review and an explicit "commit" / "looks good". Workflow directions ("go down this path", "drop the previous commit") are not commit approval.
- Keep slices small: roughly 20–270 insertions per commit, most under ~150. +400 lines is too much to review even when most of it is tests.
- Many small atomic commits within a PR, squashed on merge — commit granularity is for review, not history.
- Commit messages: subject line only, matching the repo's convention — no explanatory body. PR descriptions equally terse: state the change, skip the why.
- "From first principles" means rebuild in tiny steps at the user's pace — don't re-apply saved diffs wholesale.

## Git state hygiene

- The user edits files and rewrites branch history in parallel mid-session. Re-run `git status` / `git log` immediately before reviewing or editing; re-Read any file right before an Edit.
- Never read, cite, or use as a template any branch the user hasn't explicitly named in the current session — including `backup/*` refs and drafts subagents stumble on. Scope exploration to HEAD and merged main, and tell subagents to do the same.
