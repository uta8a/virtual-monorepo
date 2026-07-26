# Codex Hooks

The Plugin configures only four lifecycle events:

| Hook | Delegated behavior |
| --- | --- |
| `SessionStart` | bind Codex ID, write `session.json`, journal start, return Session context |
| `PreCompact` | create checkpoint and best-effort transcript snapshot |
| `PostCompact` | update transcript path and journal compaction |
| `SessionEnd` | record end, snapshot transcript, request evidence/Report work |

Prompt, tool, approval, and Stop telemetry comes from Codex OpenTelemetry.
`SessionEnd` has a three-second Hook timeout and may
only enqueue/request heavy work; it must not perform synchronous LLM Report
generation, close the Session, or set an outcome.

Codex passes Hook JSON on stdin. The current documented common fields include
`session_id`, `transcript_path`, `cwd`, `hook_event_name`, and `model`, with
`turn_id` on turn-scoped events. The transcript format itself is explicitly
unstable.

## Required adapter behavior

On `SessionStart`, `vmr` resolves the record from the Hook payload's canonical
cwd. The Virtual Monorepo root maps to the reserved `project-root-session`;
an immediate child of `workspace/sessions/records/` maps to that Session
record. Symlink escapes, nested paths, and unrelated cwd values are rejected.
For a normal Session, `vmr` registers the Codex session ID, writes
`session.json`, and returns additional context containing the task, phase,
attached worktrees, and Report path. A closed Session is rejected or surfaced
with an unmistakable warning.

An invalid cwd is fail-closed. No telemetry, response, metadata, or journal
write may occur. A block-capable Hook returns a blocking decision with an
operator-facing message equivalent to:

```text
Stop Codex temporarily. Change cwd to <virtual-monorepo-root>, start Codex
there, and resume the work from the root session.
```

For a non-block-capable event, the adapter exits unsuccessfully with the same
message, and later block-capable events keep work stopped. The reserved
`project-root-session` directory is a persistence target only and is not a
valid cwd.

`PreCompact` writes a checkpoint with Codex session ID, turn ID, reason, and a
best-effort transcript snapshot. `PostCompact` records completion, updates a
changed transcript path, and appends `codex.compacted`.

`SessionEnd` records the final event,
snapshots an available transcript, and requests Git Evidence refresh and draft
Report generation before appending `codex.session_ended`. The request is a
journal signal for the next agent-controlled finishing workflow. The Hook does
not synchronously run an LLM or generate, approve, or close anything.

For `project-root-session`, Hooks record root-level telemetry and responses
but do not emit lifecycle events, mutate Session metadata, generate a Report,
or participate in phase/outcome indexes.
