#!/usr/bin/env bash
# Shared by the hooks. Finds this folder's chat files and remembers which ones have had a sleep.
# Plain bash only: no node, no python, no jq.

STATE=".claude/state"

# json_field <name>: one string field out of the JSON the app hands a hook ($input).
# Windows paths arrive as C:\\Users\\..., so backslashes become forward slashes.
json_field() {
  printf '%s' "$input" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 \
    | sed -E 's/^"[^"]*"[[:space:]]*:[[:space:]]*"//; s/"$//' | tr -s '\\' '/'
}

# chat_dir: the folder where the app keeps this folder's chats, one .jsonl file per chat.
chat_dir() {
  if [ -n "$tp" ]; then dirname "$tp"; return; fi
  if [ -s "$STATE/current" ]; then dirname "$(cat "$STATE/current")"; return; fi
  local here; here=$(pwd -W 2>/dev/null || pwd)
  echo "$HOME/.claude/projects/$(printf '%s' "$here" | sed 's/[^A-Za-z0-9]/-/g')"
}

# slept_lines <chat file name>: how many lines of that chat the last sleep covered (0 = never slept).
slept_lines() {
  local n; n=$(grep -F "$1 " "$STATE/slept" 2>/dev/null | tail -1 | cut -d' ' -f2)
  echo "${n:-0}"
}

# mark_slept <chat file>: remember that this chat is sorted up to where it is right now.
mark_slept() {
  local name; name=$(basename "$1")
  mkdir -p "$STATE"
  grep -v -F "$name " "$STATE/slept" 2>/dev/null > "$STATE/slept.tmp"
  echo "$name $(wc -l < "$1" | tr -d ' ') $(date +%s)" >> "$STATE/slept.tmp"
  mv "$STATE/slept.tmp" "$STATE/slept"
}

# their_messages <file> <from line>: how many messages the person typed from that line on.
their_messages() {
  tail -n "+$2" "$1" 2>/dev/null | grep -v '"isMeta":true' \
    | LC_ALL=C grep -c -E '"role":"user","content":("|\[\{"type":"text")'
}
