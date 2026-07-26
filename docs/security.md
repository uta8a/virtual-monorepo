# Security

Private storage is not assumed safe. Every Hook payload, prompt, response,
transcript snapshot, command result, and derived artifact is redacted before
persistence.

The shared `vmr` redactor must at least detect Authorization headers, bearer
tokens, GitHub tokens, OpenAI API keys, AWS access keys, cookies, URL userinfo,
and 1Password secret references. Every replacement is exactly:

```text
[REDACTED]
```

The same pipeline bounds large values and stores size and SHA-256 metadata for
truncation. It must avoid putting the original secret-bearing value into
errors, temporary artifacts, or logs.

Remote URLs containing userinfo or token material are rejected.
PermissionRequest never implies approval. Hook logging is an audit aid, not a
complete enforcement boundary; hosted tools may not produce tool Hooks in all
Codex versions.
