# Links <repo>/<session name> -> <session_id> and shows the name in $html's header.
# Uses the latest /rename title in the transcript; earlier name links of this session are removed.
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
title=$([ -f "$transcript" ] && grep '"type":"custom-title"' "$transcript" | tail -1 | jq -r '.customTitle // empty')
name=$(printf '%s' "$title" | sed -E 's#[/:[:space:][:cntrl:]]+#-#g; s#^[-.]+##; s#-+$##')
if [ -n "$name" ]; then
  link="$root/$repo/$name"
  if { [ -e "$link" ] || [ -L "$link" ]; } && [ "$(readlink "$link")" != "$sid" ]; then
    link="$link-${sid:0:8}"
  fi
  for l in "$root/$repo"/*; do
    [ -L "$l" ] && [ "$(readlink "$l")" = "$sid" ] && [ "$l" != "$link" ] && rm "$l"
  done
  ln -sfn "$sid" "$link"

  esc=$(sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<<"$title")
  if ! grep -qF "<span class=\"name\">$esc</span>" "$html"; then
    awk -v title="<title>$esc · $repo $kind</title>" \
        -v header="<header><b>$repo</b><span class=\"name\">$esc</span><span>$sid</span><span>$kind</span></header>" \
      '/^<title>/ { print title; next } /^<header>/ { print header; next } { print }' "$html" > "$html.tmp" && mv "$html.tmp" "$html"
  fi
fi
