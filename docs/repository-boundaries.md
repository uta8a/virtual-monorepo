# Repository boundaries

The outer public repository owns:

```text
README.md
AGENTS.md
LICENSE
.gitignore
flake.nix
flake.lock
repositories.yaml
docs/**
.agents/plugins/marketplace.json
plugins/**
scripts/**
repos/README.md
workspace/AGENTS.md
wiki/README.md
```

The private Workspace repository owns everything below `workspace/` except
`AGENTS.md`. Its own ignore file excludes Session worktrees, runtime state, and
credentials while retaining redacted JSONL evidence, metadata, Reports,
proposals, state/outcome symlinks, and the private repository declaration
`repositories.private.yaml`.

The private Wiki repository owns everything below `wiki/` except `README.md`,
including `catalog.yaml` and each Wiki instance.

Nested `.git/` directories are intentional. The public ignore rules are the
enforcement boundary; verify them with `git check-ignore` and the index checks
in `scripts/verify.sh`.
