#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
codex_profile_source="${root}/config/codex/virtual-monorepo.config.toml"
codex_dir="${CODEX_HOME:-${HOME}/.codex}"
codex_profile="${codex_dir}/virtual-monorepo.config.toml"

if [[ -z "${IN_NIX_SHELL:-}" ]]; then
  echo "error: bootstrap requires the pinned Nix environment; run: nix develop" >&2
  exit 1
fi

if ! command -v vmr >/dev/null 2>&1; then
  echo "error: vmr is not on PATH; enter the Nix environment with: nix develop" >&2
  exit 1
fi

cd -- "${root}"
vmr init

profile_action="installed"
if [[ -e "${codex_profile}" ]]; then
  if cmp -s -- "${codex_profile_source}" "${codex_profile}"; then
    profile_action="verified"
  else
    profile_action="updated"
  fi
fi

mkdir -p -- "${codex_dir}"
install -m 0600 -- "${codex_profile_source}" "${codex_profile}"

echo "${profile_action} Codex profile: ${codex_profile}"
echo "start the receiver with: vmr otel serve"
echo "start Codex with: codex --profile virtual-monorepo"
