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

# note_read <chat file> <last line>: the readback reached this line of that chat. Only chat.sh writes it,
# once every part of a readback has been printed. A sleep moves a chat's mark only as far as this.
note_read() {
  local name; name=$(basename "$1")
  mkdir -p "$STATE"
  grep -v -F "$name " "$STATE/read" 2>/dev/null > "$STATE/read.tmp"
  echo "$name $2 $(date +%s)" >> "$STATE/read.tmp"
  mv "$STATE/read.tmp" "$STATE/read"
}

# read_lines <chat file name>: how far the last readback of that chat reached (0 = not read since the last sleep).
read_lines() {
  local n; n=$(grep -F "$1 " "$STATE/read" 2>/dev/null | tail -1 | cut -d' ' -f2)
  echo "${n:-0}"
}

# their_messages <file> <from line>: how many messages the person typed from that line on.
their_messages() {
  tail -n "+$2" "$1" 2>/dev/null | grep -v '"isMeta":true' \
    | LC_ALL=C grep -c -E '"role":"user","content":("|\[\{"type":"text")'
}

# PIECES and PIECE_SIZE: a hook's output is cut off near 10,000 characters, so the blocks the footing
# asks for travel in numbered pieces, one SessionStart hook each (settings.json runs pull.sh 1 to 6).
PIECES=6
PIECE_SIZE=9000

# pull_words: the desk words in the footing's "Pull on waking" slot, one per line, lowercase.
pull_words() {
  grep -i -m1 '^\*\*Pull on waking:\*\*' memory/FOOTING.md 2>/dev/null \
    | sed -E 's/^\*\*[^*]*\*\*[[:space:]]*//; s/[[:space:].]*$//' | tr ',' '\n' \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | tr 'A-Z' 'a-z' | grep -v '^$'
}

# block_for <word>: the block file a desk word opens, or nothing if the desk has no such row.
block_for() {
  local path
  path=$(awk -F'|' -v w="$1" '{k=$2; gsub(/^[ \t]+|[ \t]+$/,"",k); if (tolower(k)==w) {print $4; exit}}' memory/DESK.md 2>/dev/null | grep -o '`[^`]*`' | head -1 | tr -d '`')
  [ -z "$path" ] && return
  [ -f "$path" ] || path="memory/$path"
  echo "$path"
}

# is_first_chat: true only for a brain nobody has lived in yet (same test the start hook uses).
is_first_chat() {
  grep -q "first chat" memory/FOOTING.md 2>/dev/null || return 1
  local lived; lived=$(git log --format=%H -- memory 2>/dev/null | wc -l)
  [ "$lived" -le 2 ]
}

# pulled_text: every block the footing asks for, whole, one after another (the four boot files skipped,
# since they load on their own).
pulled_text() {
  local w path
  pull_words | while read -r w; do
    path=$(block_for "$w")
    [ -n "$path" ] && [ -f "$path" ] || continue
    case "$path" in memory/FOOTING.md|memory/DESK.md|memory/human/human.md|memory/self/persona.md) continue;; esac
    echo "===== \"$w\" ($path), whole ====="
    cat "$path"
    echo
    echo "===== end of \"$w\" ====="
    echo
  done
}

# split_pulled 0: how many pieces the pulled blocks need (0 if none). split_pulled <n>: piece n, cut at line ends.
split_pulled() {
  pulled_text | awk -v size="$PIECE_SIZE" -v want="$1" '
    { line=$0 "\n"; if (len > 0 && len + length(line) > size) { n++; len=0 } ; if (n+1 == want) printf "%s", line; len += length(line) }
    END { if (want == 0) print (len > 0 || n > 0) ? n+1 : 0 }'
}
