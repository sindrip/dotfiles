#!/usr/bin/env bash
# Claude Code status line: model name, context used tokens (%), session (5h) usage % + reset time, project dir

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')

# Abbreviate a token count: thousands as Nk, millions as Nm
abbrev_tokens() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) { v = n / 1000000; fmt = (v == int(v)) ? "%dm" : "%.1fm"; printf fmt, v }
    else if (n >= 1000) { v = n / 1000; fmt = (v == int(v)) ? "%dk" : "%.1fk"; printf fmt, v }
    else printf "%d", n
  }'
}

used_tokens=$(printf '%s' "$input" | jq -r '((.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0))')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  context="$(abbrev_tokens "$used_tokens") ($(printf '%.0f' "$used_pct")%)"
fi

session_pct=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
resets_at=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$resets_at" ]; then
  now=$(date +%s)
  remaining=$(( resets_at - now ))
  if [ "$remaining" -gt 0 ]; then
    hours=$(( remaining / 3600 ))
    minutes=$(( (remaining % 3600) / 60 ))
    if [ "$hours" -gt 0 ]; then
      reset_str="${hours}h${minutes}m"
    else
      reset_str="${minutes}m"
    fi
  fi
fi
if [ -n "$session_pct" ]; then
  session=$(printf '%.0f%%' "$session_pct")
  [ -n "$reset_str" ] && session="$session ($reset_str)"
fi

dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$dir" ]; then
  project=$(basename "$dir")
fi

out="$model"
[ -n "$context" ] && out="$out | $context"
[ -n "$session" ] && out="$out | $session"
[ -n "$project" ] && out="$out | $project"

printf '%s' "$out"
