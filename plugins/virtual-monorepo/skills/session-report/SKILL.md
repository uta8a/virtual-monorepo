---
name: session-report
description: Generate, review, and approve a Virtual Monorepo Session Report.
---

# Session Report

Use this workflow before an agent ends completed Session work and whenever a
SessionEnd journal event requests Report generation:

1. Run `vmr report generate <session>` to build a deterministic draft from
   task, metadata, journal, redacted dialogue and tool logs, Git Evidence, and
   test Evidence. Use `--replace` only when replacement is intended and the
   existing Report will be preserved in history.
2. Read the generated draft and its linked Session information sources. Do
   not use the raw Codex transcript as the sole source.
3. Replace deterministic placeholders with evidence-backed content. State
   gaps explicitly; never claim a test, merge, release, or deployment that
   the Session information sources do not support.
4. Review every required section below and run
   `vmr report validate <session>`.
5. Show the complete validated Report to the user and ask whether to approve
   it. Keep the Report and Session unapproved while waiting.

Review these required sections:

1. Goal
2. Result
3. Repositories
4. Changes
5. Verification
6. Failures and Retries
7. Decisions
8. Reusable Lessons
9. Plugin Candidates
10. Remaining Risks
11. Evidence

After explicit user approval, approve only through
`vmr report approve <session>`, then confirm that the current and approved
hashes match. Never auto-approve because generation or validation succeeded.

Convert reusable knowledge and Plugin improvements to proposals; do not
directly edit a Wiki or Plugin.
