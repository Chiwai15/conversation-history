# shellcheck shell=bash disable=SC2034,SC2154  # sourced: variables come from the caller
# Sets $repo, $sid and $session_dir from the hook input in $input.
sid=$(jq -r .session_id <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
cwd=${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}
git_dir=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
repo=$(basename "$([ -n "$git_dir" ] && dirname "$git_dir" || echo "$cwd")")
root="$HOME/.claude/conversation-history"
session_dir="$root/$repo/$sid"
