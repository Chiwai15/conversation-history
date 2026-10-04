#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

input=$(cat)
sid=$(jq -r .session_id <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
cwd=${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}
git_dir=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
repo=$(basename "$([ -n "$git_dir" ] && dirname "$git_dir" || echo "$cwd")")
dir="$HOME/.claude/responses/$repo"
html="$dir/$sid.html"
mkdir -p "$dir"

txt=$(jq -j '.last_assistant_message // empty' <<<"$input")
if [ -z "$txt" ]; then
  txt=$(jq -js '[.[] | select(.type == "assistant")][-1].message.content | map(select(.type == "text").text) | join("\n")' \
    "$(jq -r .transcript_path <<<"$input")")
fi
[ -z "$txt" ] && exit 0

if [ ! -f "$html" ]; then
  {
    cat <<'HEAD'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body { margin: 0; background: #f8f8f8; color: #3b3b3b; font: 12px/1.2 Menlo, Monaco, "Courier New", monospace; }
  header { position: sticky; top: 0; background: #f8f8f8; border-bottom: 1px solid #e5e5e5; padding: 8px 20px; color: #666666; }
  header b { color: #d77757; }
  header span { margin-left: 2ch; }
  main { padding: 16px 20px 60px; max-width: 1400px; }
  h1, h2, h3, h4, h5, h6 { font-size: 1em; font-weight: bold; margin: 0 0 1.4em; }
  h1 { font-style: italic; text-decoration: underline; }
  p, ul, ol, pre, table, blockquote { margin: 0 0 1.4em; }
  ul { padding-left: 2ch; }
  ol { padding-left: 4ch; }
  ul { list-style: "- "; }
  li > ul, li > ol { margin: 0; }
  li > p { margin: 0; }
  strong { font-weight: bold; }
  a { color: inherit; }
  code, pre { font: inherit; }
  code { color: #5769f7; }
  pre { white-space: pre-wrap; }
  pre code { color: #5769f7; }
  pre.sourceCode code { color: #3b3b3b; }
  .kw, .cf, .im, .cn, .ex { color: #0451a5; }
  .st, .ch, .vs, .ss, .sc { color: #cd3131; }
  .dv, .bn, .fl, .co, .do, .an, .cv, .in, .wa { color: #107c10; }
  .bu, .at { color: #0598bc; }
  .dt { color: #0598bc; opacity: .7; }
  .fu { color: #949800; }
  .pp { color: #666666; }
  .sourceCode a { display: none; }
  blockquote { padding-left: 1ch; border-left: 2px solid #b3b3b3; font-style: italic; }
  table { border-collapse: collapse; }
  th, td { border: 1px solid #b3b3b3; padding: 0 1ch; text-align: left; }
  hr { border: 0; border-top: 1px dashed #b3b3b3; }
  time { display: block; color: #666666; margin-bottom: 1em; }
</style>
HEAD
    printf '<title>%s</title>\n</head>\n<body>\n<header><b>%s</b><span>%s</span></header>\n<main>\n' "$repo" "$repo" "$sid"
  } > "$html"
fi

if command -v pandoc >/dev/null; then
  body=$(pandoc -f gfm -t html <<<"$txt")
else
  body="<pre>$(sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<<"$txt")</pre>"
fi
printf '<section><time>%s</time>\n%s\n</section>\n<hr>\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$body" >> "$html"
