# Codex Plugins

Each child directory is an independent Codex Plugin. Every Plugin must contain
`.codex-plugin/plugin.json`, and its directory name must match the manifest
`name`.

The repository marketplace is `.agents/plugins/marketplace.json`. Register
Plugins there in display order with a local source path of
`./plugins/<plugin-name>`. Keep each entry's installation policy,
authentication policy, and category explicit.
