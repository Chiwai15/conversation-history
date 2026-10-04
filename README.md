# response-saver

Appends every assistant response to `~/.claude/responses/<repo>/<session>.html`.

- One folder per repo (worktrees share the main repo name), one file per session, so parallel agents never collide.
- Markdown, tables and code are rendered in the page itself (bundled `marked` + `highlight.js`, copied to `~/.claude/responses/.assets/`). Nothing extra to install, works offline.
- Requires `jq` and `git`.

## Install

```
/plugin marketplace add chiwai15/response-saver
/plugin install response-saver@response-saver
```

The Stop hook is active as soon as the plugin is installed. Ask to "open my saved responses" to use the `responses` skill.
