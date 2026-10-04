# Claude Code Conversation History: keep context after compaction

[![CI](https://github.com/Chiwai15/conversation-history/actions/workflows/ci.yml/badge.svg)](https://github.com/Chiwai15/conversation-history/actions/workflows/ci.yml)
[![Version](https://img.shields.io/github/v/release/Chiwai15/conversation-history)](https://github.com/Chiwai15/conversation-history/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/Chiwai15/conversation-history?style=social)](https://github.com/Chiwai15/conversation-history/stargazers)

A Claude Code plugin that saves every prompt and reply of every session as pages that look just like Claude Code's terminal output, and makes Claude re-read your own words after compaction, so it doesn't lose your instructions or your original goal.

![Browsing a saved session and exporting it to PDF](docs/conversation-history-demo.gif)

**Demo:** [sample Export PDF of a real session](docs/conversation-history-demo.pdf)

## The problem

In a long Claude Code session the context window fills up, and Claude Code compacts it (auto-compact or `/compact`): the earlier conversation is replaced with a summary. That summary can drop or reword:

- your exact instructions and constraints
- the original goal of the session
- decisions already made

After compaction Claude works from the summary, so it can forget what you asked, redo finished work, or drift from the plan.

## The solution

- **Saves the verbatim conversation** outside the context: every user request and every final assistant response, per repo and per session.
- **Recalls it after compaction**: a hook hands Claude the session's first 10 messages (the original goal) and last 10 (the latest work), with a rule: your requests override the summary (newest wins on conflict); earlier responses are claims to re-verify.
- **Looks like Claude Code in your terminal**: each session is a browsable HTML page styled like Claude Code's terminal output, with the same monospace text, `●` reply markers, terminal-style tables and highlighted code, plus a one-click **Export PDF** in the same style.

## Install

In Claude Code:

```
/plugin marketplace add chiwai15/conversation-history
/plugin install conversation-history@conversation-history
```

The hooks are active as soon as the plugin is installed. Ask Claude to "open my conversation history" to use the `conversation-history` skill.

## What gets saved

Everything goes to `~/.claude/conversation-history/<repo>/<session>/`:

```
<repo>/<session>/requests/full.html     user prompts
<repo>/<session>/responses/full.html    final replies
<repo>/<session>/{requests,responses}/first-10.md, last-10.md   plain-text recall files
```

- One folder per repo (worktrees share the main repo name), one folder per session, so parallel agents never collide.
- `/rename` a session and `<repo>/<name>` links to its folder; renaming again moves the link, and the name shows in the page header.
- Keeps the latest 500 entries per page; older ones are removed automatically.
- All three limits (500, first 10, last 10) can be changed in `/config`. Each applies to requests and responses separately; a lowered limit takes effect on the next message.
- **Export PDF** button in the page header: one entry per page (never split), same style as the page. An entry taller than A4 gets its own longer page instead of being shrunk.
- Markdown, tables and code are rendered in the page itself (bundled `marked` + `highlight.js`, copied to `~/.claude/conversation-history/.assets/`). Nothing extra to install, works offline.

## Requirements

- macOS or Linux with `bash`
- `jq` (required; without it nothing is saved)
- `git` (optional; used to name the repo folder, otherwise the project folder name is used)

## Privacy

Everything stays on your machine under `~/.claude/conversation-history/`. The plugin makes no network requests. Saved pages contain whatever you typed, including any secrets you pasted, so treat the folder like your shell history.

## Update and uninstall

```
claude plugin marketplace update conversation-history
claude plugin update conversation-history@conversation-history
claude plugin uninstall conversation-history@conversation-history
```

Restart Claude Code (or run `/reload-plugins`) after updating. Uninstalling keeps your saved history; delete `~/.claude/conversation-history/` to remove it.

## Troubleshooting

- **Nothing is saved**: hooks load at session start. Run `/reload-plugins` or start a new session, and check that `jq` is installed.
- **Old pages still look old**: styles are shared from `~/.claude/conversation-history/.assets/` and refresh on your next message.
- **What is not saved**: images, subagent replies, and intermediate messages; only the final reply of each turn is kept.

## Feedback and support

Found a bug or have an idea? [Open an issue](https://github.com/Chiwai15/conversation-history/issues/new/choose); suggestions and feedback are welcome.

If this plugin saved your context, a ⭐ on [GitHub](https://github.com/Chiwai15/conversation-history) helps other Claude Code users find it.

## License

[MIT](LICENSE)
