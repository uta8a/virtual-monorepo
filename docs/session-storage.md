# Session storage

Session records never move after creation:

```text
workspace/sessions/records/<date>--<ulid>--<slug>/
├── metadata.yaml
├── task.md
├── journal/
│   ├── events.jsonl
│   ├── checkpoints/
│   └── codex/<codex-session-id>/
│       ├── hooks.jsonl
│       ├── dialogue.jsonl
│       ├── tools.jsonl
│       ├── transcript.jsonl
│       ├── exec-events.jsonl
│       └── session.json
├── repos/<repository-id>/
├── evidence/
│   ├── git/<repository-id>/
│   └── tests/
├── report/{README.md,manifest.json,assets/}
├── proposals/{knowledge/,plugins/}
├── artifacts/manifest.yaml
└── runtime/
```

Worktrees and runtime directories are ignored. Redacted Codex JSONL, Git and
test evidence, Reports, and proposals are tracked by the private Workspace.

`workspace/sessions/records/project-root-session/` is a reserved journal-only
record for Codex launched with the Virtual Monorepo root as cwd. It contains
`journal/codex/<codex-session-id>/` logs but has no ULID, metadata, task,
repositories, phase/outcome links, Report, or lifecycle commands. Normal
Session creation must reject `project-root-session` as a slug or identifier.

Phase and outcome indexes are tracked relative symlinks:

```text
sessions/states/<phase>/<directory>    -> ../../records/<directory>
sessions/outcomes/<outcome>/<directory> -> ../../records/<directory>
```

Linux symlink support is required. `metadata.yaml` remains authoritative;
`vmr session reconcile` regenerates links and `--check` performs a read-only
consistency audit.

## Metadata invariants

`phase` is one of `created`, `active`, `paused`, `review`, `closed`.
`outcome` is null except for closed Sessions, where it is required.
`report.state` is `pending`, `draft`, `approved`, or `rejected`. Absolute paths
are forbidden.

Every created Session starts with at least this shape (timestamps and names are
generated values):

```yaml
schema_version: 1

id: 01K13A8M7XK9TQ2N4F5H6J7P8R
directory_name: 2026-07-25--01K13A8M7XK9TQ2N4F5H6J7P8R--otel-reporting
slug: otel-reporting
title: Build OpenTelemetry session reporting

created_at: 2026-07-25T00:15:20+09:00
updated_at: 2026-07-25T00:15:20+09:00

status:
  phase: created
  outcome: null
  reason: null

task:
  path: task.md
  source:
    type: manual
    reference: null

codex:
  session_ids: []
  model: null
  transcript_paths: []

repositories: []

report:
  path: report/README.md
  state: pending
  generated_at: null
  approved_at: null
  approved_hash: null
  current_hash: null
  human_edited: false
  last_edited_at: null

wiki_targets: {}

security:
  credential_profile: null
  egress_profile: null
  redaction_profile: default

storage:
  worktrees_present: false
  archived_at: null
```

Plugin proposals are YAML documents with `schema_version`, a proposal `id`,
`target: plugin`, `kind`, `problem`, `proposed_change`, evidence, required eval
scenarios, and `state: proposed`. Knowledge proposals use the adjacent
`proposals/knowledge/` directory.
