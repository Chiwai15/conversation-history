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
cp -f "$(dirname "$0")"/../assets/* "$root/.assets/"

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
<link rel="stylesheet" href="../.assets/style.css">
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
    document.querySelectorAll("pre code[class*=\"language-\"]").forEach(el => hljs.highlightElement(el));
  });
</script>
HEAD
    printf '<title>%s</title>\n</head>\n<body>\n<header><b>%s</b><span>%s</span></header>\n<main>\n' "$repo" "$repo" "$sid"
  } > "$html"
fi

body=$(sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<<"$txt")
printf '<section><time>%s</time>\n<pre>%s</pre>\n</section>\n<hr>\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$body" >> "$html"
