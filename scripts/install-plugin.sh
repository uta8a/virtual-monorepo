#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${IN_NIX_SHELL:-}" ]]; then
  echo "error: Plugin installation requires the pinned Nix environment; run: nix develop" >&2
  exit 1
fi

if ! command -v vmr >/dev/null 2>&1; then
  echo "error: vmr is not on PATH; enter the Nix environment with: nix develop" >&2
  exit 1
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "error: codex is required to install Plugins" >&2
  exit 1
fi

marketplace_file="${root}/.agents/plugins/marketplace.json"
marketplace_name="$(
  python3 - "${marketplace_file}" <<'PY'
import json
import pathlib
import re
import sys

document = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
name = document.get("name", "")
if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name):
    raise SystemExit("error: invalid marketplace name")
print(name)
PY
)"

if ! codex plugin marketplace list --json |
  python3 -c '
import json
import pathlib
import sys

expected = pathlib.Path(sys.argv[1]).resolve()
document = json.load(sys.stdin)
raise SystemExit(0 if any(
    pathlib.Path(item["root"]).resolve() == expected
    for item in document.get("marketplaces", [])
) else 1)
' "${root}"
then
  codex plugin marketplace add "${root}"
fi

mapfile -t available_plugins < <(
  python3 - "${marketplace_file}" <<'PY'
import json
import pathlib
import re
import sys

document = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
for plugin in document.get("plugins", []):
    name = plugin.get("name", "")
    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name):
        raise SystemExit("error: invalid Plugin name")
    if plugin.get("policy", {}).get("installation") != "NOT_AVAILABLE":
        print(name)
PY
)

requested_plugins=("$@")
if [[ "${#requested_plugins[@]}" -eq 0 ]]; then
  requested_plugins=("${available_plugins[@]}")
fi

for plugin_name in "${requested_plugins[@]}"; do
  found=0
  for available_plugin in "${available_plugins[@]}"; do
    if [[ "${plugin_name}" == "${available_plugin}" ]]; then
      found=1
      break
    fi
  done
  if [[ "${found}" -ne 1 ]]; then
    echo "error: Plugin ${plugin_name} is not available in ${marketplace_name}" >&2
    exit 1
  fi
  codex plugin add "${plugin_name}@${marketplace_name}"
done
