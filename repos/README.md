# Shared repository clones

`vmr init` creates ordinary (non-bare) clones in this directory.
`../repositories.yaml` is the source of truth for public clone targets.
Everything here except this README is ignored by the outer public repository.

These clones are not disposable caches: they are the persistent shared sources
from which `vmr` creates linked worktrees directly under each Session's
`repos/` directory. Do not edit a shared clone, and do not manually move a
repository that has active linked worktrees. Add or remove repositories through
`vmr`; it must stop rather than rewrite a mismatched `origin` or delete an
existing directory.

Private repository declarations belong in
`../workspace/repositories.private.yaml`, where duplicate IDs or paths across
the public and private lists must be rejected rather than implicitly
overridden.
