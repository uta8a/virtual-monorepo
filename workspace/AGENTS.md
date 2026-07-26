# Codex instructions for the private workspace

`workspace/` is the root of the private
`uta8a/virtual-monorepo-workspace` repository. This `AGENTS.md` is the sole
exception: it is owned by the parent public repository and ignored by the
private repository.

- Start Codex only from the Virtual Monorepo root. Root-level Hook telemetry
  and responses belong to the reserved
  `sessions/records/project-root-session/journal/` record.
- For task work, create a Session and start a subagent with
  `sessions/records/<session-directory>` as its cwd.
- Resolve the current Session from the canonical cwd, never from an
  environment variable or a guessed path.
- Treat `project-root-session` as a reserved journal-only record, not a normal
  Session. Never pass it to `vmr session` commands or use it as a slug or ID.
- If a Hook reports an invalid cwd, stop work immediately. Ask the operator to
  stop Codex, change cwd to the Virtual Monorepo root, and start Codex there
  before resuming. Do not write telemetry or responses for the invalid cwd.
- Modify only linked worktrees belonging to that Session.
- Never edit shared clones directly under the top-level `repos/`.
- Do not manually alter Hook logs, state links, outcome links, or Session
  metadata; use the released `vmr` CLI for state changes.
- Redact before persistence. Never store tokens, passwords, cookies, vault,
  item or field names, 1Password secret URI references, or service-account
  tokens.
- Credential profiles are logical names only. Local mappings belong in the
  ignored `.vmr/credentials.yaml`.
- `SessionEnd` records evidence and requests a draft Report; it is not Session
  close and must not set an outcome.
- Generate a Report when work ends. Only approved Reports may be staged to a
  Wiki.
- Submit Plugin improvements as proposals; never modify the public Plugin
  directly from a Report.
