---
name: wiki-curation
description: Stage approved Virtual Monorepo Session Reports into one or more LLM Wikis.
---

# Wiki curation

1. Confirm the Report state is `approved`.
2. List and validate Wiki instances with `vmr wiki list` and
   `vmr wiki validate`.
3. Stage explicitly with `vmr wiki stage <wiki-id> <session>`, or use
   `--all-matching` only when reviewed labels select the intended Wikis.
4. Confirm the report hash prevents duplicate staging to the same Wiki.
5. Review pending material before `vmr wiki ingest <wiki-id>`.

The Workspace Report remains authoritative. Staging copies it and a manifest
into each selected Wiki. A single approved Report may target multiple Wikis.
