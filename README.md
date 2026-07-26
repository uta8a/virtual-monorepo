# Virtual Monorepo

A Codex-only Virtual Monorepo template. This public repository provides the
configuration, documentation, scripts, and Codex Plugins for coordinating work
across multiple repositories without combining their histories.

The released [`uta8a/vmr`](https://github.com/uta8a/vmr) binary is the control
plane. Its implementation does not live in this repository. Nix pins the
required GitHub Release and verifies the asset for each supported platform.

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

## Requirements

- Nix with flakes enabled
- Codex CLI
- Access to every private repository declared by the local Workspace

Do not install `vmr` separately or build it from `main`. `flake.nix` is the
source of truth for the released version and platform hashes; `flake.lock`
pins Nixpkgs.

## Initialize

Create a repository from this template, clone it, and enter its pinned
environment:

```bash
nix develop
vmr version
./scripts/bootstrap.sh
./scripts/install-plugin.sh
./scripts/verify.sh
```

`bootstrap.sh` initializes or validates the shared clones and nested private
repositories without replacing existing data. It also installs the
repository-managed Codex profile at
`~/.codex/virtual-monorepo.config.toml`, or below `$CODEX_HOME` when set. A
differing existing profile is never overwritten.

Run an individual command without entering an interactive development shell:

```bash
nix run .#vmr -- version
```

## Run Codex

Start the loopback OpenTelemetry receiver inside `nix develop`:

```bash
vmr otel serve
```

From another shell in the same Nix environment, start Codex at the Virtual
Monorepo root:

```bash
codex --profile virtual-monorepo
```

The profile sends Codex log events as OTLP/HTTP JSON to
`127.0.0.1:4318`. `vmr` redacts and bounds records before writing them to the
private Workspace. Starting Codex without this profile leaves the Virtual
Monorepo exporter disabled.

Use the installed Session-management Skill to create and operate task Sessions.
Session work happens in linked worktrees under the private Workspace, never in
the shared clones under `repos/`.

## Safety

- Keep all Virtual Monorepo state below this repository root.
- Never commit private Workspace or Wiki data to the outer repository.
- Never put credentials or URL userinfo in repository manifests.
- Store local credential mappings only in
  `workspace/.vmr/credentials.yaml`.
- Never persist tokens, passwords, 1Password secret references, or unredacted
  Codex events.
- Use released `vmr` commands for repository, Session, Report, and Wiki state
  transitions instead of editing generated state manually.

See [Security](docs/security.md) and
[1Password integration](docs/onepassword.md) for the persistence rules.
