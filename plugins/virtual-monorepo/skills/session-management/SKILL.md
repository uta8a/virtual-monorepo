---
name: session-management
description: Create and operate AI-agent work inside a Virtual Monorepo Session, including delegating work to a subagent whose cwd is the created Session record.
---

# Session management

Use this workflow when starting, changing state, or finishing work.

1. Require the released `vmr` binary provided by the repository's Nix flake.
2. Create a Session with `vmr session create --slug <slug> --title <title>`.
3. Attach only required repositories and fetch each repository's configured
   default branch before creating its worktree:
   `vmr session repo attach <session> --repo <repository-id> --fetch`.
   If the fetch fails, stop instead of starting work from a stale local
   remote-tracking branch.
4. Resolve the Session record created in step 2 under
   `<virtual-monorepo-root>/workspace/sessions/records/<session-directory>`.
5. Start a subagent with that Session record as its cwd. Do not use a `vmr`
   command to start Codex or the subagent.
6. If the subagent launcher cannot set cwd before process startup, make the
   subagent's first action change to the Session record and register its
   existing Codex conversation before any task action:

   ```bash
   test -n "$CODEX_THREAD_ID"
   SESSION_CWD="$(pwd -P)"
   jq -n \
     --arg session_id "$CODEX_THREAD_ID" \
     --arg cwd "$SESSION_CWD" \
     '{session_id:$session_id,cwd:$cwd,hook_event_name:"SessionStart"}' |
     vmr hook receive --event SessionStart
   ```

   Run this only after changing to the canonical Session record. Stop if the
   thread ID is unavailable or registration fails. The receiver backfills the
   configured OTel lookback window and routes subsequent records by
   conversation ID.
7. Instruct the subagent to use only worktrees linked inside that Session
   record.
8. Change phase only with `vmr session start`, `pause`, `resume`, or `review`.
9. Before ending completed work, move the Session to `review` so `vmr`
   refreshes Git Evidence, then use the Session Report skill. Do not stop after
   deterministic generation: the agent must read the Session information
   sources, write the Report, validate it, show it to the user, and request
   approval.
10. Keep the Session in `review` while waiting. Approve the Report only after
   the user explicitly approves the displayed content.
11. Close only when the user intends to finalize an outcome:
   `vmr session close <session> --outcome <outcome>`.
12. Archive separately after preserving Git evidence.

Never edit shared clones, metadata, journal, or state/outcome links by hand.
Never treat a Codex `SessionEnd` event as Session close.
Never treat a `report.generation_requested` journal event as approval. It is a
request for the next agent-controlled finishing workflow; the CLI Hook does
not run an LLM or approve generated content.
Never use `project-root-session` as a Session slug or ID. It is a reserved
journal record for Codex started at the Virtual Monorepo root.
If a Hook reports an invalid cwd, stop the agent, persist nothing for that
cwd, and instruct the operator to restart Codex from the Virtual Monorepo
root.
