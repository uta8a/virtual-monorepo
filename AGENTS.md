# Codex instructions

This public repository is the configuration, documentation, and Plugin layer
for a Codex-only Virtual Monorepo. The released `uta8a/vmr` binary is its
control plane.

## Environment and implementation

- Nix with flakes enabled is required. Enter `nix develop` before running
  repository scripts or `vmr`.
- Treat `flake.nix` as the source of truth for the `vmr` GitHub Release version
  and platform hashes, and `flake.lock` as the Nixpkgs lock.
- Use only the released `vmr` binary supplied by the flake. Do not download an
  unverified binary, build from `main`, or add a CLI implementation here.
- Do not create `cmd/`, `internal/`, `go.mod`, an XDG state tree, or a bare
  repository store.
- Keep all Virtual Monorepo state under this repository root.

## Repository boundaries

- Treat `repos/` entries as persistent shared clones used as worktree sources.
  Never edit a shared clone directly.
- Treat `workspace/` and `wiki/` as nested private repository roots.
- The parent public repository owns only `workspace/AGENTS.md` inside
  `workspace/` and only `wiki/README.md` inside `wiki/`.
- Preserve all three public boundary markers: `repos/README.md`,
  `workspace/AGENTS.md`, and `wiki/README.md`.
- Public clone declarations belong in `repositories.yaml`. Private clone
  declarations belong in `workspace/repositories.private.yaml`; neither file
  may override duplicate IDs or paths from the other.
- Codex Plugins under `plugins/<plugin-name>/` are independent thin adapters.
  Keep persistence and state transitions in `vmr`, not in Plugin scripts or
  Skills.

## Safety and verification

- Use `vmr` for repository, Session, Report, and Wiki state changes. Do not
  manually rewrite generated records, links, journals, or nested repository
  state.
- Never commit tokens, credentials, credential mappings, vault/item/field
  names, 1Password secret references, or unredacted Codex events.
- Never put credentials or URL userinfo in repository manifests.
- Run `./scripts/verify.sh` from `nix develop` after changing public
  configuration, scripts, documentation, or Plugins.
- Do not commit, push, publish a release, change remotes, or approve actions
  unless the user explicitly requests that exact operation.
