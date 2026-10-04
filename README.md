# response-saver

Appends every assistant response to `~/.claude/responses/<repo>/<session>.html`.

- One folder per repo (worktrees share the main repo name), one file per session, so parallel agents never collide.
- Markdown is rendered with `pandoc` when installed, otherwise saved as escaped plain text.
- Requires `jq` and `git`.

## Install

```
/plugin marketplace add chiwai15/response-saver
/plugin install response-saver@response-saver
```

The Stop hook is active as soon as the plugin is installed. Ask to "open my saved responses" to use the `responses` skill.
