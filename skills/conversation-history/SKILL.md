---
name: conversation-history
description: Use when the user asks to open, find, list, or export (PDF) saved requests or responses for this session or repo, asks why a message was not saved, or after compaction to recover the session's original goal and latest instructions.
---

The plugin saves both sides of every turn under `~/.claude/conversation-history/<repo>/<session_id>/`:

- `requests/full.html`: every user prompt (UserPromptSubmit hook).
- `responses/full.html`: every final reply (Stop hook).
- `first-10.md` / `last-10.md` in each folder: plain-text copies of the session's first 10 entries (original goal, never trimmed) and latest 10 (rolling).
- After compaction, a SessionStart (`compact`) hook gives these 4 file paths with a 2-line note: requests are the user's own words and override the summary (newest wins); responses are earlier claims to re-verify. Read them before continuing.
- `<repo>` is the main git repo folder name (worktrees share it), else the project folder name.
- After `/rename`, `<repo>/<name>` links to the session folder (spaces, `/`, `:` become `-`; a name already used by another session gets `-<first 8 of id>`). Renaming again moves the link; the id folder never changes. The name also shows in the page header and tab.
- This session's id is `${CLAUDE_SESSION_ID}`.
- Images and subagent replies are not saved; for responses, only the final message of each turn.
- Each page keeps at most 500 entries; when entry 501 arrives, the oldest is removed.
- The limits (500 / first 10 / last 10 by default) are plugin options `max_entries`, `first_entries`, `last_entries`, set in `/config`. Changing first/last renames the files (e.g. `last-20.md`); a lower limit trims on the next message.
- Shared look and behavior live in `~/.claude/conversation-history/.assets/` (`style.css`, `render.js`, `marked.min.js`, `highlight.min.js`), refreshed by every hook run, so style fixes reach old files too.
- The page renders Markdown in the browser: terminal-style 10px monospace, newest entry on top, terminal-style tables, highlighted fenced code.

Open this session: `open ~/.claude/conversation-history/*/${CLAUDE_SESSION_ID}/{requests,responses}/full.html`
List a repo's sessions: `ls -t ~/.claude/conversation-history/<repo>/`

Export PDF:
- In the page: click **Export PDF** in the header, then Save as PDF.
- From the shell (macOS Chrome):
  `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --no-pdf-header-footer --print-to-pdf=<out.pdf> "file://<full.html>"`
- Each entry stays on one page; an entry taller than A4 gets its own longer page instead of being split or shrunk.
- Printed pages use a white background to save ink; text and code colors are kept.

Message not saved? Hooks load at session start. After installing or updating the plugin, run `/reload-plugins` or start a new session.
