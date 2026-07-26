# Codex integration

Codex is the only supported coding agent. A human starts it directly from the
Virtual Monorepo root:

```text
cd <absolute-virtual-monorepo-root>
vmr otel serve
codex --profile virtual-monorepo
```

`vmr` never launches Codex. After `vmr session create`, the session-management
Skill starts a subagent with the newly created
`workspace/sessions/records/<session-directory>` as its cwd.

Each Plugin is a thin adapter registered by
`.agents/plugins/marketplace.json`. The initial
`plugins/virtual-monorepo` Plugin pipes the SessionStart, PreCompact,
PostCompact, and SessionEnd lifecycle Hook JSON
stdin to `vmr hook receive --event <event>`; the CLI owns cwd-based record lookup,
validation, Session association, checkpoints, transcript snapshots, and Hook
output. Prompt, tool, approval, and Stop events are collected through Codex
OpenTelemetry instead of per-call Hooks.

The cwd selects the journal record:

- The Virtual Monorepo root selects the reserved
  `workspace/sessions/records/project-root-session`.
- `workspace/sessions/records/<session-directory>` selects that Session.

`project-root-session` exists only to retain root Codex telemetry and response
logs. It is not a lifecycle-managed Session and must never be supplied to
`vmr session` commands.

Every other cwd, including the `project-root-session` persistence directory,
is invalid. Hooks fail closed without writing and instruct the operator to
stop Codex, change cwd to the Virtual Monorepo root, and restart Codex there.

Stable analysis inputs are `otel.jsonl` and `session.json`. Legacy
`dialogue.jsonl` and `tools.jsonl` remain Report fallbacks.
`transcript.jsonl` is supplementary evidence only: its
undocumented internal fields are not a public or stable API. `codex exec`
events, when used, are kept separately as `exec-events.jsonl`.

`scripts/bootstrap.sh` installs the OTel settings as the user-level Codex
profile `~/.codex/virtual-monorepo.config.toml`. Project `.codex/config.toml`
cannot override telemetry routing. The profile is repository-managed, so each
bootstrap run replaces it with `config/codex/virtual-monorepo.config.toml` and
sets file mode `0600`.

Plugin Hook trust remains in Codex's normal review flow. The adapter never
auto-approves permission requests or auto-continues after `Stop`.

The SessionEnd Hook records a Report work request but cannot run an LLM within
its timeout. Before completed work ends, the Session skills perform the
agent-controlled finishing workflow: refresh Evidence, generate and fill the
Report from Session information sources, validate and display it, and wait for
explicit user approval.
