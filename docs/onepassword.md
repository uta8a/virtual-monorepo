# 1Password integration

Credential retrieval belongs to the released `vmr` CLI and is not implemented
in this repository. Git tracks only the example policy at
`workspace/policies/credentials.yaml.example`.

The real mapping is local and ignored:

```text
workspace/.vmr/credentials.yaml
```

Session metadata may store only a logical profile name such as
`credential_profile: github-pr`. It must never store a token, password,
cookie, vault name, item name, field name, 1Password secret reference, or
service-account token. `vmr` resolves logical names only in memory for the
minimum required command scope and never copies the mapping into evidence.
