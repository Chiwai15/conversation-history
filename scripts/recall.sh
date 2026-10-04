#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

input=$(cat)
source "$(dirname "$0")/session-dir.sh"
files=$(ls "$session_dir"/requests/first-*.md "$session_dir"/requests/last-*.md "$session_dir"/responses/first-*.md "$session_dir"/responses/last-*.md 2>/dev/null)
[ -z "$files" ] && exit 0

echo "Verbatim history of this session, saved outside the compaction summary: first-* files hold the session's opening turns (original goal), last-* files the most recent turns (current work)."
echo "requests/ are the user's own words and override the summary (newest wins on conflict); responses/ are earlier assistant claims to re-verify. Read them before continuing:"
echo "$files"
