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
  local n; n=$(awk -v k="$1" '$1 == k' "$STATE/slept" 2>/dev/null | tail -1 | cut -d' ' -f2)
  echo "${n:-0}"
}

# note_read <chat file> <last line>: the readback reached this line of that chat. Only chat.sh writes it,
# once every part of a readback has been printed. A sleep moves a chat's mark only as far as this.
note_read() {
  local name; name=$(basename "$1")
  mkdir -p "$STATE"
  awk -v k="$name" '$1 != k' "$STATE/read" 2>/dev/null > "$STATE/read.tmp"
  echo "$name $2 $(date +%s)" >> "$STATE/read.tmp"
  mv "$STATE/read.tmp" "$STATE/read"
}

# read_lines <chat file name>: how far the last readback of that chat reached (0 = not read since the last sleep).
read_lines() {
  local n; n=$(awk -v k="$1" '$1 == k' "$STATE/read" 2>/dev/null | tail -1 | cut -d' ' -f2)
  echo "${n:-0}"
}

# their_messages <file> <from line>: how many messages the person sent from that line on. talk.awk decides what's
# theirs: every piece of a message is read (pictures and the first message's app reminders included), and the
# app's own messages (task notices, command output, scheduled-task prompts) don't count as them.
their_messages() {
  LC_ALL=C awk -f .claude/hooks/talk.awk -v mode=count -v from="$2" "$1" 2>/dev/null || echo 0
}

# owed_scan <chat files...>: one line per chat, "<their messages since its last sleep> <file name>", in the
# order given, skipping scheduled-task runs (they aren't talks with my person). One awk pass over every file:
# a pipeline per file is slow to start on Windows, and the start hook only has 10 seconds.
owed_scan() {
  [ "$#" -gt 0 ] || return 0
  LC_ALL=C awk -f .claude/hooks/talk.awk -v mode=count -v slept="$STATE/slept" "$@"
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
# since they load on their own, and a block two words point to sent once).
pulled_text() {
  local w path seen=" "
  while read -r w; do
    path=$(block_for "$w")
    [ -n "$path" ] && [ -f "$path" ] || continue
    case "$path" in memory/FOOTING.md|memory/DESK.md|memory/human/human.md|memory/self/persona.md) continue;; esac
    case "$seen" in *" $path "*) continue;; esac
    seen="$seen$path "
    echo "===== \"$w\" ($path), whole ====="
    cat "$path"
    echo
    echo "===== end of \"$w\" ====="
    echo
  done < <(pull_words)
}

# split_pulled 0: how many pieces the pulled blocks need (0 if none). split_pulled <n>: piece n.
# Pieces are cut at whole blocks, so each piece makes sense alone however they arrive: a block starts a new
# piece when it won't fit in what's left of this one. Only a block bigger than a piece is cut, at line ends,
# and each piece it continues into says so.
split_pulled() {
  pulled_text | awk -v size="$PIECE_SIZE" -v want="$1" '
    function emit(t) { if (n + 1 == want) printf "%s", t; len += length(t) }
    function flush(   i, line) {
      if (blen == 0) return
      if (len > 0 && len + blen > size) { n++; len = 0 }
      for (i = 1; i <= bn; i++) {
        line = b[i] "\n"
        if (len > 0 && len + length(line) > size) { n++; len = 0; emit("(" bname ", continued from the piece before)\n") }
        emit(line)
      }
      bn = 0; blen = 0
    }
    /^===== "/ && !/^===== end of / { flush(); bname = $0; sub(/^===== /, "", bname); sub(/ \(.*/, "", bname) }
    { b[++bn] = $0; blen += length($0) + 1 }
    END { flush(); if (want == 0) print (len > 0 || n > 0) ? n + 1 : 0 }'
}
