# Virtual Monorepo Codex Plugin

This Codex-only Plugin provides Session management, Session Report, and Wiki
curation skills. Its lifecycle Hooks are discovered from
`hooks/hooks.json` and delegate all persistence to:

```text
vmr hook receive
```

The Plugin stores no state itself. A released, version-pinned `vmr` must be on
`PATH`. Start Codex directly from the Virtual Monorepo root with `codex`.
Session work is delegated to a subagent whose cwd is the Session record.
Plugin Hooks require the normal Codex review/trust step.

Before completed Session work ends, the Session skills refresh Evidence,
generate and evidence-ground a Report, validate it, display it, and request
explicit user approval. The SessionEnd Hook only records a work request; it
does not run an LLM, approve a Report, or close a Session.

The manifest intentionally omits a `hooks` field because the installed Codex
version discovers the standard path automatically. The repository marketplace
at `.agents/plugins/marketplace.json` publishes this Plugin from
`plugins/virtual-monorepo`; additional Plugins can be registered alongside it.
