#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
failed=0

require_file() {
  if [[ ! -f "${root}/$1" ]]; then
    echo "missing required file: $1" >&2
    failed=1
  fi
}

for path in \
  README.md AGENTS.md LICENSE .gitignore flake.nix flake.lock repositories.yaml \
  repos/README.md workspace/AGENTS.md workspace/repositories.private.yaml \
  wiki/README.md
do
  require_file "${path}"
done

python3 - "${root}" <<'PY'
import pathlib
import subprocess
import sys
from urllib.parse import urlsplit

try:
    import yaml
except ImportError:
    raise SystemExit("error: PyYAML is required to validate repository manifests")

root = pathlib.Path(sys.argv[1])
manifest_paths = [
    root / "repositories.yaml",
    root / "workspace" / "repositories.private.yaml",
]
seen_ids = {}
seen_paths = {}

for manifest_path in manifest_paths:
    document = yaml.safe_load(manifest_path.read_text(encoding="utf-8"))
    if document.get("schema_version") != 1:
        raise SystemExit(f"error: unsupported schema_version in {manifest_path}")

    for repository in document.get("repositories", []):
        repository_id = repository["id"]
        repository_path = pathlib.PurePosixPath(repository["path"])
        expected_path = pathlib.PurePosixPath("repos") / repository_id

        if repository_id in seen_ids:
            raise SystemExit(
                f"error: duplicate repository id {repository_id!r} in "
                f"{seen_ids[repository_id]} and {manifest_path}"
            )
        if repository_path in seen_paths:
            raise SystemExit(
                f"error: duplicate repository path {str(repository_path)!r} in "
                f"{seen_paths[repository_path]} and {manifest_path}"
            )
        if repository_path != expected_path:
            raise SystemExit(
                f"error: repository {repository_id!r} must use path {expected_path}"
            )

        remote = repository["remote"]
        parsed = urlsplit(remote)
        if parsed.scheme and (parsed.username is not None or parsed.password is not None):
            raise SystemExit(
                f"error: URL userinfo is forbidden for repository {repository_id!r}"
            )

        clone_path = root / repository_path
        if clone_path.exists():
            if not (clone_path / ".git").exists():
                raise SystemExit(
                    f"error: existing repository path is not a normal clone: {clone_path}"
                )
            actual_remote = subprocess.run(
                ["git", "-C", str(clone_path), "config", "--get", "remote.origin.url"],
                check=True,
                capture_output=True,
                text=True,
            ).stdout.strip()
            if actual_remote != remote:
                raise SystemExit(
                    f"error: origin mismatch for {repository_id!r}: "
                    f"expected {remote!r}, got {actual_remote!r}"
                )

        seen_ids[repository_id] = manifest_path
        seen_paths[repository_path] = manifest_path
PY

if [[ "${failed}" -ne 0 ]]; then
  exit 1
fi

echo "static Virtual Monorepo verification passed"
