# Logging and evidence

For each Codex session, `vmr` writes under:

```text
journal/codex/<codex-session-id>/
  otel.jsonl
  transcript.jsonl
  exec-events.jsonl
  session.json
```

All JSONL appends must be atomic enough to preserve one JSON object per line.
For a normal Session, `journal/events.jsonl` is a separate append-only
business history with monotonic sequence numbers. The reserved
`project-root-session` contains only root Codex telemetry and response logs;
it has no business-history lifecycle.

Before any write, a shared `vmr` pipeline redacts OTel inputs, then
enforces size limits. A truncated value records `truncated`, `original_size`,
and the SHA-256 digest of the original bytes. Redaction and truncation are not
implemented independently in each Hook.

The destination record is selected only by canonical cwd: the Virtual
Monorepo root maps to `workspace/sessions/records/project-root-session`, while
a Session record cwd maps to itself. An invalid cwd produces no log write and
causes the Hooks to stop agent work until Codex is restarted from the Virtual
Monorepo root.

Legacy `dialogue.jsonl` and `tools.jsonl` remain readable for older Sessions.

Git evidence records status, patch, diff stat, commits, and capture metadata
per attached repository. Test evidence is stored separately. Reports use these
stable records plus task, metadata, journal, dialogue, and tools—not raw
transcript alone.
