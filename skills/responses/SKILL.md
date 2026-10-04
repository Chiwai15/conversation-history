---
name: responses
description: Use when the user asks to open, find, list, or export (PDF) saved responses for this session or repo, or asks why a response was not saved.
---

The plugin's Stop hook appends every final reply to `~/.claude/responses/<repo>/<session_id>.html`.

- `<repo>` is the main git repo folder name (worktrees share it), else the project folder name.
- This session's id is `${CLAUDE_SESSION_ID}`.
- Only the final message of each turn is saved; user prompts, images, and subagent replies are not.
- Shared look and behavior live in `~/.claude/responses/.assets/` (`style.css`, `render.js`, `marked.min.js`, `highlight.min.js`), refreshed by every hook run, so style fixes reach old files too.
- The page renders Markdown in the browser: terminal-style 10px monospace, newest reply on top, terminal-style tables, highlighted fenced code.

Open this session: `open ~/.claude/responses/*/${CLAUDE_SESSION_ID}.html`
List a repo's sessions: `ls -t ~/.claude/responses/<repo>/`

Export PDF:
- In the page: click **Export PDF** in the header, then Save as PDF.
- From the shell (macOS Chrome):
  `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --no-pdf-header-footer --print-to-pdf=<out.pdf> "file://<session.html>"`
- Each reply stays on one page; a reply taller than A4 gets its own longer page instead of being split or shrunk.

Reply not saved? Hooks load at session start. After installing or updating the plugin, run `/reload-plugins` or start a new session.
