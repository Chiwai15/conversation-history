#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
command -v jq >/dev/null || exit 0
max_entries=${CLAUDE_PLUGIN_OPTION_MAX_ENTRIES:-500}
first_entries=${CLAUDE_PLUGIN_OPTION_FIRST_ENTRIES:-10}
last_entries=${CLAUDE_PLUGIN_OPTION_LAST_ENTRIES:-10}
max_entries=${max_entries%%.*} first_entries=${first_entries%%.*} last_entries=${last_entries%%.*}
kind=$1

input=$(cat)
# shellcheck source=session-dir.sh
source "$(dirname "$0")/session-dir.sh"
dir="$session_dir/$kind"
html="$dir/full.html"
mkdir -p "$dir" "$root/.assets"
cp -f "$(dirname "$0")"/../assets/* "$root/.assets/"
[ -f "$dir/index.html" ] && [ ! -f "$html" ] && mv "$dir/index.html" "$html"

if [ "$kind" = requests ]; then
  txt=$(jq -j '.prompt // empty' <<<"$input")
else
  txt=$(jq -j '.last_assistant_message // empty' <<<"$input")
fi
if [ -z "$txt" ] && [ "$kind" = responses ]; then
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
<link rel="stylesheet" href="../../../.assets/style.css">
<script src="../../../.assets/marked.min.js"></script>
<script src="../../../.assets/highlight.min.js"></script>
<script src="../../../.assets/render.js"></script>
HEAD
    printf '<title>%s %s</title>\n</head>\n<body>\n<header><b>%s</b><span>%s</span><span>%s</span></header>\n<main>\n' "$repo" "$kind" "$repo" "$sid" "$kind"
  } > "$html"
fi

# shellcheck source=session-name.sh
source "$(dirname "$0")/session-name.sh"

body=$(sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<<"$txt")
ts=$(date '+%Y-%m-%d %H:%M:%S')
printf '<section><time>%s</time>\n<pre>%s</pre>\n</section>\n' "$ts" "$body" >> "$html"

total=$(grep -c '^<section><time>' "$html")
extra=$(( total - max_entries ))
if [ "$extra" -gt 0 ]; then
  awk -v drop="$extra" '
    /^<section><time>/ && drop > 0 { skip = 1 }
    skip { if ($0 == "</section>") { skip = 0; drop--; after = 1 }; next }
    after && $0 == "<hr>" { after = 0; next }
    { after = 0; print }
  ' "$html" > "$html.tmp" && mv "$html.tmp" "$html"
fi

count_entries() { if [ -f "$1" ]; then grep -c '^<!-- entry -->$' "$1" || true; fi; }
entry=$(printf '<!-- entry -->\n### %s\n\n%s\n' "$ts" "$txt")
first="$dir/first-$first_entries.md"
last="$dir/last-$last_entries.md"
for f in "$dir"/first-*.md; do [ -f "$f" ] && [ "$f" != "$first" ] && mv "$f" "$first"; done
for f in "$dir"/last-*.md; do [ -f "$f" ] && [ "$f" != "$last" ] && mv "$f" "$last"; done
n=$(count_entries "$first")
if [ "${n:-0}" -gt "$first_entries" ]; then
  awk -v keep="$first_entries" '/^<!-- entry -->$/ { n++ } n <= keep' "$first" > "$first.tmp" && mv "$first.tmp" "$first"
fi
# Only while the first file still holds every message so far, so a raised limit never adds later turns.
[ "${n:-0}" -lt "$first_entries" ] && [ "${n:-0}" -eq $(( total - 1 )) ] && printf '%s\n\n' "$entry" >> "$first"
printf '%s\n\n' "$entry" >> "$last"
extra=$(( $(count_entries "$last") - last_entries ))
if [ "$extra" -gt 0 ]; then
  awk -v drop="$extra" '/^<!-- entry -->$/ { n++ } n > drop' "$last" > "$last.tmp" && mv "$last.tmp" "$last"
fi
