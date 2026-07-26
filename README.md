# Virtual Monorepo

A Codex-only Virtual Monorepo template. This public repository provides the
configuration and documentation for coordinating work across multiple
repositories without combining their histories.

The released [`uta8a/vmr`](https://github.com/uta8a/vmr) binary is the control
plane. Its implementation does not live in this repository.

## Repository model

The Virtual Monorepo keeps three data planes under one local root:

```text
repos/       persistent shared Git clones
workspace/   private Sessions, worktrees, evidence, Reports, and proposals
wiki/        private LLM Wiki data
```

The outer public repository owns the declarative configuration and three
boundary markers:

```text
repos/README.md
workspace/AGENTS.md
wiki/README.md
```

Everything else below `workspace/` and `wiki/` belongs to nested private Git
repositories. Files below `repos/` are shared worktree sources and must not be
edited directly.

Public clone declarations live in `repositories.yaml`. Private declarations
live in `workspace/repositories.private.yaml`. Repository IDs and paths must be
unique across both manifests.

See [Repository boundaries](docs/repository-boundaries.md) and
[Architecture](docs/architecture.md) for the ownership and storage model.

## Safety

- Keep all Virtual Monorepo state below this repository root.
- Never commit private Workspace or Wiki data to the outer repository.
- Never put credentials or URL userinfo in repository manifests.
- Store local credential mappings only in
  `workspace/.vmr/credentials.yaml`.
- Never persist tokens, passwords, 1Password secret references, or unredacted
  Codex events.

See [Security](docs/security.md) and
[1Password integration](docs/onepassword.md) for the persistence rules.
