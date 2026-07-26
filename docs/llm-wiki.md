# LLM Wiki

`wiki/` is one private repository containing multiple independent Wiki
instances. `catalog.yaml` is authoritative. Each `wiki/<id>/wiki.yaml` selects
approved Session Reports and defines relative raw, generated, and site paths.

Staging copies the Workspace Report rather than moving it:

```text
workspace/.../report/README.md
  -> wiki/<wiki-id>/raw/reports/<session-directory>.md
```

The adjacent manifest records schema version, Wiki ID, Session ULID, a
`sha256:` report hash, and the Asia/Tokyo staging timestamp. The same hash is
not staged twice to one Wiki. One approved Report may be staged independently
to multiple Wiki IDs, with per-Wiki status stored in
`metadata.yaml#wiki_targets`.

Ingestion reads only staged content. Workspace absolute paths are never stored
in Wiki configuration; resolution begins at the Virtual Monorepo root.
