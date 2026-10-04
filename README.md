# conversation-history

Saves every user request and assistant response to `~/.claude/conversation-history/<repo>/<session>/`:

```
<repo>/<session>/requests/index.html    user prompts
<repo>/<session>/responses/index.html   final replies
<repo>/<session>/{requests,responses}/first-10.md, last-10.md   plain-text recall files
```

- **After compaction**: a hook hands the model the 4 recall files (first 10 = original goal, last 10 = latest work), so it can re-read the user's own words instead of trusting the summary.

- One folder per repo (worktrees share the main repo name), one folder per session, so parallel agents never collide.
- `/rename` a session and `<repo>/<name>` links to its folder; renaming again moves the link, and the name shows in the page header.
- Keeps the latest 500 entries per page; older ones are removed automatically.
- **Export PDF** button in the page header: one entry per page (never split), same style as the page. An entry taller than A4 gets its own longer page instead of being shrunk.
- Markdown, tables and code are rendered in the page itself (bundled `marked` + `highlight.js`, copied to `~/.claude/conversation-history/.assets/`). Nothing extra to install, works offline.
- Requires `jq` and `git`.

## Install

```
/plugin marketplace add chiwai15/conversation-history
/plugin install conversation-history@conversation-history
```

The hooks are active as soon as the plugin is installed. Ask to "open my conversation history" to use the `conversation-history` skill.
