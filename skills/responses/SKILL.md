---
name: responses
description: Use when the user asks to open, find, or list saved responses for this session or repo.
---

Every response is appended by the Stop hook to `~/.claude/responses/<repo>/<session_id>.html`.

- `<repo>` is the main git repo folder name (worktrees share it), else the project folder name.
- This session's id is `${CLAUDE_SESSION_ID}`.

Open this session: `open ~/.claude/responses/*/${CLAUDE_SESSION_ID}.html`
List a repo's sessions: `ls -t ~/.claude/responses/<repo>/`
