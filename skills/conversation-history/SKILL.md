---
name: conversation-history
description: Use when the user asks to open, find, list, or export (PDF) saved requests or responses for this session or repo, or asks why a message was not saved.
---

The plugin saves both sides of every turn under `~/.claude/conversation-history/<repo>/<session_id>/`:

- `requests/index.html`: every user prompt (UserPromptSubmit hook).
- `responses/index.html`: every final reply (Stop hook).
- `<repo>` is the main git repo folder name (worktrees share it), else the project folder name.
- This session's id is `${CLAUDE_SESSION_ID}`.
- Images and subagent replies are not saved; for responses, only the final message of each turn.
- Each page keeps at most 500 entries (`max_entries` in `scripts/save.sh`); when entry 501 arrives, the oldest is removed.
- Shared look and behavior live in `~/.claude/conversation-history/.assets/` (`style.css`, `render.js`, `marked.min.js`, `highlight.min.js`), refreshed by every hook run, so style fixes reach old files too.
- The page renders Markdown in the browser: terminal-style 10px monospace, newest entry on top, terminal-style tables, highlighted fenced code.

Open this session: `open ~/.claude/conversation-history/*/${CLAUDE_SESSION_ID}/{requests,responses}/index.html`
List a repo's sessions: `ls -t ~/.claude/conversation-history/<repo>/`

Export PDF:
- In the page: click **Export PDF** in the header, then Save as PDF.
- From the shell (macOS Chrome):
  `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --no-pdf-header-footer --print-to-pdf=<out.pdf> "file://<index.html>"`
- Each entry stays on one page; an entry taller than A4 gets its own longer page instead of being split or shrunk.
- Printed pages use a white background to save ink; text and code colors are kept.

Message not saved? Hooks load at session start. After installing or updating the plugin, run `/reload-plugins` or start a new session.
