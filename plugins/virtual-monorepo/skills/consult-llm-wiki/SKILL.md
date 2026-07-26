---
name: consult-llm-wiki
description: Consult generated Virtual Monorepo LLM Wiki knowledge before answering or acting. Use only when the user explicitly asks to consult, reference, read, or use the LLM Wiki, including requests such as 「LLM Wikiを参照して〇〇して」 or “use the LLM Wiki”; do not use for ordinary tasks that merely relate to Virtual Monorepo.
---

# Consult LLM Wiki

1. Confirm that the current user request explicitly asks to use the LLM Wiki.
   An explicit `$consult-llm-wiki` invocation also qualifies. Otherwise, do
   not read Wiki content.
2. Read `wiki/catalog.yaml` from the Virtual Monorepo root and select the
   enabled Wiki whose topic fits the request. Prefer `virtual-monorepo` when
   the request names no Wiki and concerns this repository.
3. Read `<wiki-path>/generated/README.md` as the entry point. Follow only the
   links relevant to the task; do not load the entire Wiki by default.
4. Use generated pages as background knowledge, while treating their linked
   staged Reports as the evidence boundary. Read a source Report only when a
   claim needs verification or the generated page is ambiguous.
5. Perform the requested task using the retrieved knowledge. Distinguish Wiki
   facts from new inference, and cite the relevant local Wiki pages in the
   response.

Keep consultation read-only. Do not stage Reports, run ingestion, or edit Wiki
files unless the user separately asks to update the Wiki. If the selected Wiki
or entry point is missing, say so and continue from other available context.
