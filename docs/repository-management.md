# Repository management

`repositories.yaml` is the public source of truth.
`workspace/repositories.private.yaml` is the private source of truth and is
tracked by the private Workspace repository. `vmr` loads both manifests as one
repository set. An ID or normalized path appearing more than once, whether
within one file or across both, is an error; no implicit override is allowed.

The private manifest uses the same schema:

```yaml
schema_version: 1

repositories:
  - id: private-repository
    remote: https://github.com/example/private-repository.git
    path: repos/private-repository
    default_branch: main
```

Token-bearing URLs and URL userinfo remain forbidden. The manifest may reveal
private repository names and therefore must never be copied into the public
repository.

For each entry, `vmr init` must:

1. load public and private manifests and validate globally unique IDs and paths
   shaped as `repos/<id>`;
2. reject URL userinfo and token-bearing remotes;
3. create an ordinary clone when the path is absent;
4. verify that an existing path is a Git repository;
5. compare its canonical `origin` with the configured remote;
6. stop on mismatch without changing the remote or deleting content.

Session worktrees are created from those ordinary clones:

```bash
git -C repos/<id> worktree add \
  -b vmr/<session-ulid>/<id> \
  workspace/sessions/records/<session-directory>/repos/<id> \
  origin/<default-branch>
```

Only the linked Session worktree is removed during archive. The shared clone
remains.
