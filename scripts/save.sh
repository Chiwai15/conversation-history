#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

input=$(cat)
sid=$(jq -r .session_id <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
cwd=${cwd:-${CLAUDE_PROJECT_DIR:-$PWD}}
git_dir=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
repo=$(basename "$([ -n "$git_dir" ] && dirname "$git_dir" || echo "$cwd")")
root="$HOME/.claude/responses"
dir="$root/$repo"
html="$dir/$sid.html"
mkdir -p "$dir" "$root/.assets"
cp -f "$(dirname "$0")"/../assets/*.js "$root/.assets/"

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
  p:has(+ ul), p:has(+ ol) { margin-bottom: 0; }
  strong { font-weight: bold; }
  a { color: inherit; }
  code, pre { font: inherit; }
  code { color: #5769f7; }
  pre { white-space: pre-wrap; }
  pre code { color: #5769f7; }
  pre code.hljs { color: #3b3b3b; }
  .hljs-keyword, .hljs-literal, .hljs-type, .hljs-selector-tag { color: #0451a5; }
  .hljs-string, .hljs-regexp, .hljs-char { color: #cd3131; }
  .hljs-number, .hljs-comment, .hljs-quote { color: #107c10; }
  .hljs-built_in, .hljs-attr, .hljs-attribute, .hljs-variable { color: #0598bc; }
  .hljs-title, .hljs-section { color: #949800; }
  .hljs-meta { color: #666666; }
  blockquote { padding-left: 1ch; border-left: 2px solid #b3b3b3; font-style: italic; }
  table { border-collapse: collapse; }
  th, td { border: 1px solid #b3b3b3; padding: 0 1ch; text-align: left; }
  hr { border: 0; border-top: 1px dashed #b3b3b3; }
  time { display: block; color: #666666; margin-bottom: 1em; }
  .md { position: relative; padding-left: 2ch; }
  .md::before { content: "●"; position: absolute; left: 0; }
</style>
<script src="../.assets/marked.min.js"></script>
<script src="../.assets/highlight.min.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", () => {
    const esc = s => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    marked.use({ renderer: { html: t => esc(t.text) } });
    document.querySelectorAll("section > pre").forEach(el => {
      const md = document.createElement("div");
      md.className = "md";
      md.innerHTML = marked.parse(el.textContent);
      el.replaceWith(md);
    });
    hljs.highlightAll();
  });
</script>
HEAD
    printf '<title>%s</title>\n</head>\n<body>\n<header><b>%s</b><span>%s</span></header>\n<main>\n' "$repo" "$repo" "$sid"
  } > "$html"
fi

body=$(sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<<"$txt")
printf '<section><time>%s</time>\n<pre>%s</pre>\n</section>\n<hr>\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$body" >> "$html"
