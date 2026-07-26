# Virtual Monorepo Codex Plugin

This Codex-only Plugin delegates lifecycle event persistence to:

```text
vmr hook receive
```

Hooks are discovered from `hooks/hooks.json`. The Plugin stores no state
itself; the released `vmr` supplied by this repository's Nix flake must be on
`PATH`.

Start Codex directly from the Virtual Monorepo root with the repository-managed
profile. Plugin Hooks require the normal Codex review and trust step.

The manifest intentionally omits a `hooks` field because Codex discovers the
standard `hooks/hooks.json` path automatically. The repository marketplace at
`.agents/plugins/marketplace.json` publishes this Plugin from
`plugins/virtual-monorepo`.
