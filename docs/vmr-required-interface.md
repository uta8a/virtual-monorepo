# Required `vmr` interface

## Released implementation

The released `uta8a/vmr` binary is pinned by `flake.nix`, including the
GitHub Release version and SHA-256 hash for every supported host. The outer
public repository contains no Go code and has no fallback through `go run` or
`go install ...@main`.

The repository marketplace is `.agents/plugins/marketplace.json`. Each entry
points to an independent Plugin under `plugins/<plugin-name>`. The pinned
release validates this multi-Plugin layout.

## Global and repository commands

```text
vmr version
vmr init
vmr validate
vmr repo list
vmr repo clone
vmr repo status
```

`init` finds the root, validates and clones ordinary repositories, initializes
or verifies the nested private repositories without destroying files, creates
Workspace/Wiki structure, validates the Plugin marketplace, every registered
Plugin, and the Wiki catalog, and
reconciles links. Repeated execution is safe. Duplicate repository IDs or
paths, public/private implicit overrides, URL userinfo, and mismatched origins
are hard errors.

Repository discovery reads both:

```text
repositories.yaml
workspace/repositories.private.yaml
```

The private file is optional for a Workspace that has no private clones.
When present, it uses the same schema as the public file. Validation occurs
over the combined set before cloning anything, so an ID or normalized path
collision cannot partially initialize the repository set.

## Session commands

```text
vmr session create --slug <slug> --title <title>
vmr session list [--phase <phase>]
vmr session show <session>
vmr session start <session>
vmr session pause <session> --reason <reason>
vmr session resume <session>
vmr session review <session>
vmr session close <session> --outcome <outcome>
vmr session archive <session>
vmr session reconcile [--check]
vmr session validate <session>
vmr session repo attach <session> --repo <repository-id> --fetch
vmr session repo status <session>
vmr session repo remove <session> --repo <repository-id>
```

Session IDs are full ULIDs; lookups may accept an unambiguous ID or directory
locator but must resolve to the ULID primary key. Create normalizes the slug,
uses Asia/Tokyo, initializes the complete record and appends
`session.created`. State transitions atomically update metadata, append a
journal event, and reconcile tracked relative symlinks.

`reconcile --check` is read-only and verifies metadata/phase and
metadata/outcome agreement, no dangling links, one phase per Session,
outcome only and always for closed Sessions, and relative link targets.

Archive captures Git evidence before removing linked worktrees and appends
`session.archived`.

## Hook command

```text
vmr hook receive --event <event>
```

The Codex-specific command group is removed. A human starts Codex directly at
the Virtual Monorepo root; `vmr` is an agent-facing control plane and never
launches Codex.

`hook receive` reads exactly one Codex Hook JSON value from stdin, resolves the
record from the payload cwd, performs centralized redaction and truncation,
writes the event, updates metadata/journal where required, and returns only
the Hook output schema supported for that event.

If cwd is `workspace/sessions/records/<session-directory>`, the receiver uses
that Session. If cwd is the Virtual Monorepo root, it uses the reserved
`workspace/sessions/records/project-root-session` journal record.
`project-root-session` itself is not a valid cwd.

Any other cwd is an invalid safety state. The receiver must persist nothing,
block the current or next agent action where the Hook output schema permits,
and return an instruction to stop Codex temporarily. The instruction must ask
the operator to change cwd to the canonical Virtual Monorepo root and start
Codex there before resuming work. For events without a blocking output, the
receiver exits unsuccessfully after emitting the same actionable diagnostic;
the next block-capable Hook must continue to stop work until cwd is valid.

`project-root-session` is not a normal Session, cannot be
created, selected, transitioned, closed, archived, or used as a slug or ID,
and is excluded from normal Session listings and indexes.

Required journal types are:

```text
session.created
session.phase_changed
session.closed
session.archived
repository.attached
repository.worktree_created
repository.worktree_removed
codex.session_started
codex.session_ended
codex.compacted
report.generated
report.approved
wiki.staged
wiki.ingested
```

SessionEnd must finish within the configured three-second Hook limit. It
records evidence and draft generation requests for a later agent-controlled
finishing workflow, but does not synchronously run an LLM, generate or approve
a Report, or close a Session.

## Report commands

```text
vmr report generate <session>
vmr report validate <session>
vmr report approve <session>
vmr report status <session>
```

The Report at `report/README.md` has Goal, Result, Repositories, Changes,
Verification, Failures and Retries, Decisions, Reusable Lessons, Plugin
Candidates, Remaining Risks, and Evidence sections. Generation consumes stable
redacted inputs and writes a content hash and manifest. The Session Report
Skill requires the agent to ground every section in Session information
sources, validate and display the result, and request user approval. Approval
is explicit and never follows automatically from generation or validation.

Plugin and Knowledge candidates are proposals under the Session. Plugin
proposals follow the Session -> Proposal -> improvement Session -> dedicated
worktree -> eval -> human review flow.

## Wiki commands

```text
vmr wiki list
vmr wiki validate
vmr wiki stage <wiki-id> <session>
vmr wiki stage --all-matching <session>
vmr wiki pending <wiki-id>
vmr wiki ingest <wiki-id>
vmr wiki ingest --all
```

Only approved Reports stage by default. Staging is hash-idempotent, copies a
Report and manifest into one or more Wiki instances, updates per-Wiki metadata,
and appends `wiki.staged`. Ingest records completion without deleting the
Workspace source.
