#!/usr/bin/env bash
set -euo pipefail

wiki_root="$(pwd -P)"
raw_reports="${wiki_root}/raw/reports"
generated="${wiki_root}/generated"

if [[ ! -d "${raw_reports}" || ! -d "${generated}" ]]; then
  echo "error: run from the virtual-monorepo Wiki directory" >&2
  exit 1
fi

exec codex exec \
  --ephemeral \
  --sandbox workspace-write \
  --skip-git-repo-check \
  --cd "${generated}" \
  "$(cat <<'PROMPT'
Curate the staged Virtual Monorepo Session Reports in ../raw/reports into this
generated/ directory.

Read every *.manifest.yaml and its matching *.md report. Treat those staged,
human-approved reports as the only factual sources. Preserve useful existing
pages, update them when the reports provide better information, merge
duplicates, and remove claims that are no longer supported. Do not modify
anything outside the current generated/ directory.

Create or update README.md as a compact map of the Wiki. Organize additional
Markdown pages by durable concepts rather than by session. Use relative links
between pages. For every non-obvious factual claim, add a relative source link
to the supporting report in ../raw/reports. Clearly mark uncertainty and do not
invent missing implementation details.

Write for a technically curious reader from first principles: begin with the
smallest useful mental model, explain why each mechanism exists, trace concrete
examples end to end, expose tradeoffs and failure modes, and prefer short,
precise sentences. Use equations, pseudocode, or diagrams only when they make
the mechanism easier to reason about. Keep the voice original; do not imitate
any living author's wording or persona.

Before finishing, check that all Markdown links resolve and that no absolute
workspace paths, credentials, secret references, or unredacted event payloads
appear in generated files.
PROMPT
)"
