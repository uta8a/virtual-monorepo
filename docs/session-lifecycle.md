# Session lifecycle

The full 26-character ULID is the Session primary key. The directory name is a
display locator:

```text
YYYY-MM-DD--ULID--slug
```

Dates and timestamps use `Asia/Tokyo`. Slugs are lowercase ASCII, contain only
letters, digits, and hyphens, collapse repeated hyphens, and trim leading or
trailing hyphens.

Allowed transitions are:

```text
created -> active
active  -> paused | review
paused  -> active | review
review  -> active | closed
```

Version 1 never reopens `closed`. Only
`vmr session close <session> --outcome <outcome>` closes a Session, sets one of
`succeeded`, `partial`, `failed`, `abandoned`, or `superseded`, and finalizes
the Report. `SessionEnd` is not close.

Before an agent finishes completed work, the Session workflow enters `review`,
refreshes Git Evidence, generates a deterministic Report draft, and has the
LLM fill every required section from Session information sources. The agent
validates and displays the complete Report, then waits for explicit user
approval. Generation and validation never imply approval.

`SessionEnd` records `report.generation_requested` for a later agent-controlled
finishing workflow. The three-second Hook does not synchronously run an LLM,
approve a Report, close a Session, or set an outcome.

Archive is separate: it captures Git evidence, removes linked worktrees,
records `storage.archived_at`, and retains metadata, journal, evidence, and
Reports.

`metadata.yaml` stores current state. `journal/events.jsonl` is append-only
history with monotonic `seq`, including session, repository, Codex,
compaction, Report, and Wiki events documented in
`vmr-required-interface.md`.
