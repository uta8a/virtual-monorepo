# Architecture

The Virtual Monorepo is one local root with three sibling data planes:

```text
repositories.yaml --------------------+
                                      +-> repos/<id> ordinary clone
workspace/repositories.private.yaml --+          |
                                                 +-> workspace/sessions/records/<session>/repos/<id>

workspace/ -> Session state, redacted Codex evidence, Reports, proposals
wiki/      -> approved Report copies grouped into independent Wiki instances
plugins/   -> independent thin Codex adapters that delegate persistence to `vmr`
```

The public repository carries definitions and documentation. `workspace/` and
`wiki/` are nested private Git roots, not subdirectories containing another
repository directory. All local state remains below the Virtual Monorepo root;
XDG directories and bare repository stores are deliberately excluded.

Codex is started directly at this root. Hook persistence uses canonical cwd:
root activity is written to the reserved
`workspace/sessions/records/project-root-session/journal/`, while delegated
Session work is written under that Session record's `journal/`.

## Decisions made during bootstrap

- The public remote uses HTTPS, so both nested private remotes use HTTPS.
- Both private remotes were empty and were initialized locally on `main`
  without fetching, checking out, committing, or pushing.
- `uta8a/vmr` is distributed only as released binaries. `flake.nix` pins the
  release assets used by this repository; the CLI source is not part of the
  Virtual Monorepo template.
- The public initial repository list contains only the verified public
  `Pratiyush/llm-wiki` repository, whose default branch is `master`.
- Codex CLI 0.144.6 reports lifecycle Hooks as stable. The Plugin uses the
  documented default `hooks/hooks.json` discovery path and a minimal manifest.

## Safety invariants

Initialization is idempotent and non-destructive. An existing path must be a
Git repository with the configured `origin`; mismatch is an error. No command
may rewrite a remote, delete an existing directory, force-checkout content,
auto-commit, auto-push, or auto-approve.

The public manifest is loaded first and the private manifest second, but the
second file is additive only. Duplicate repository IDs or normalized paths
across either file are validation errors and never overrides.
