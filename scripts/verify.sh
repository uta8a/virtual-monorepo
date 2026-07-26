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
  config/codex/virtual-monorepo.config.toml \
  repos/README.md workspace/AGENTS.md workspace/repositories.private.yaml \
  wiki/README.md .agents/plugins/marketplace.json plugins/README.md \
  plugins/virtual-monorepo/.codex-plugin/plugin.json \
  plugins/virtual-monorepo/hooks/hooks.json
do
  require_file "${path}"
done

python3 -m json.tool "${root}/.agents/plugins/marketplace.json" >/dev/null
python3 -m json.tool \
  "${root}/plugins/virtual-monorepo/.codex-plugin/plugin.json" >/dev/null
python3 -m json.tool \
  "${root}/plugins/virtual-monorepo/hooks/hooks.json" >/dev/null

python3 - "${root}/config/codex/virtual-monorepo.config.toml" <<'PY'
import pathlib
import sys
import tomllib

config = tomllib.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
otel = config.get("otel", {})
exporter = otel.get("exporter", {})
http = exporter.get("otlp-http", {}) if isinstance(exporter, dict) else {}

if otel.get("environment") != "local":
    raise SystemExit("error: Codex OTel environment must be local")
if otel.get("log_user_prompt") is not True:
    raise SystemExit("error: Codex OTel user prompt logging must be explicit")
if http.get("endpoint") != "http://127.0.0.1:4318/v1/logs":
    raise SystemExit("error: Codex OTel endpoint must use the loopback VMR receiver")
if http.get("protocol") != "json":
    raise SystemExit("error: Codex OTel protocol must be json")
PY

if rg -n 'vmr codex' \
  "${root}/docs" \
  "${root}/plugins" \
  "${root}/workspace/AGENTS.md"; then
  echo "removed vmr codex interface is still referenced" >&2
  failed=1
fi

if ! rg -q 'project-root-session' \
  "${root}/plugins/virtual-monorepo/skills/session-management/SKILL.md" ||
   ! rg -q 'project-root-session' "${root}/workspace/AGENTS.md"; then
  echo "reserved project-root-session guidance is missing" >&2
  failed=1
fi

if ! rg -q 'invalid cwd' "${root}/docs/codex-hooks.md" ||
   ! rg -q 'stop Codex' "${root}/workspace/AGENTS.md"; then
  echo "invalid cwd fail-closed guidance is missing" >&2
  failed=1
fi

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

for path in repos/example workspace/private-example wiki/private-example; do
  if ! git -C "${root}" check-ignore -q "${path}"; then
    echo "public ignore boundary does not cover ${path}" >&2
    failed=1
  fi
done

if git -C "${root}/workspace" check-ignore -q AGENTS.md &&
   git -C "${root}/wiki" check-ignore -q README.md; then
  :
else
  echo "nested repository ownership marker is not ignored" >&2
  failed=1
fi

if find "${root}" \
  \( -path "${root}/.git" -o -path "${root}/repos" -o \
     -path "${root}/workspace" -o -path "${root}/wiki" \) -prune -o \
  \( -name go.mod -o -path '*/cmd' -o -path '*/internal' \) -print |
  grep -q .; then
  echo "forbidden in-repository CLI implementation found" >&2
  failed=1
fi

if [[ "${failed}" -ne 0 ]]; then
  exit 1
fi

echo "static Virtual Monorepo verification passed"
