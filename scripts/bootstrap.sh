#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

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
