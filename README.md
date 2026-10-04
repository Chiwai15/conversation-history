# conversation-history

Compaction replaces the conversation with a summary, and the summary can drop or reword the user's exact instructions and original goal. This plugin keeps the verbatim text outside the context and points the model back to it after compaction.

Saves every user request and assistant response to `~/.claude/conversation-history/<repo>/<session>/`:

```
<repo>/<session>/requests/full.html     user prompts
<repo>/<session>/responses/full.html    final replies
<repo>/<session>/{requests,responses}/first-10.md, last-10.md   plain-text recall files
```

- **After compaction**: a hook hands the model the 4 recall files (first 10 = original goal, last 10 = latest work), so it can re-read the user's own words instead of trusting the summary. Rule given to the model: requests override the summary (newest wins on conflict); responses are earlier claims to re-verify.

- One folder per repo (worktrees share the main repo name), one folder per session, so parallel agents never collide.
- `/rename` a session and `<repo>/<name>` links to its folder; renaming again moves the link, and the name shows in the page header.
- Keeps the latest 500 entries per page; older ones are removed automatically.
- All three limits (500, first 10, last 10) can be changed in `/config`. Each applies to requests and responses separately; a lowered limit takes effect on the next message.
- **Export PDF** button in the page header: one entry per page (never split), same style as the page. An entry taller than A4 gets its own longer page instead of being shrunk.
- Markdown, tables and code are rendered in the page itself (bundled `marked` + `highlight.js`, copied to `~/.claude/conversation-history/.assets/`). Nothing extra to install, works offline.
- Requires `jq` and `git`.

## Install

```
/plugin marketplace add chiwai15/conversation-history
/plugin install conversation-history@conversation-history
```

The hooks are active as soon as the plugin is installed. Ask to "open my conversation history" to use the `conversation-history` skill.
