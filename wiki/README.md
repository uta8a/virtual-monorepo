# Private LLM Wiki root

This directory is the root of the private `uta8a/llm-wiki` repository. The
outer public repository owns only this README; it must never own actual Wiki
data.

Each child directory is an independent LLM Wiki instance. The private
`catalog.yaml` is the source of truth for Wiki IDs and paths. Approved Session
Reports from the private Workspace are copied into one or more Wiki instances
as immutable staging inputs. Do not add real Wiki data to the public
repository.
