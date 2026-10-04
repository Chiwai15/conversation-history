# conversation-history

Saves every user request and assistant response to `~/.claude/conversation-history/<repo>/<session>/`:

```
<repo>/<session>/requests/index.html    user prompts
<repo>/<session>/responses/index.html   final replies
```

- One folder per repo (worktrees share the main repo name), one folder per session, so parallel agents never collide.
- Keeps the latest 500 entries per page; older ones are removed automatically.
- **Export PDF** button in the page header: one entry per page (never split), same style as the page. An entry taller than A4 gets its own longer page instead of being shrunk.
- Markdown, tables and code are rendered in the page itself (bundled `marked` + `highlight.js`, copied to `~/.claude/conversation-history/.assets/`). Nothing extra to install, works offline.
- Requires `jq` and `git`.

## Install

```
/plugin marketplace add chiwai15/response-saver
/plugin install conversation-history@conversation-history
```

The hooks are active as soon as the plugin is installed. Ask to "open my conversation history" to use the `conversation-history` skill.
