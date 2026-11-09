#!/usr/bin/env bash
# Prints a chat as plain conversation, so a sleep can read it back without the tool noise.
# Each line starts with its line number in the chat file.
# usage: bash .claude/hooks/chat.sh                    (this chat, since its last sleep)
#        bash .claude/hooks/chat.sh this 1             (this whole chat)
#        bash .claude/hooks/chat.sh "<file>" [line]    (another chat, from that line on)
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
input=""; tp=""
. .claude/hooks/lib.sh
f="$1"
{ [ -z "$f" ] || [ "$f" = "this" ]; } && f=$(cat "$STATE/current" 2>/dev/null)
[ -z "$f" ] && f=$(ls -t "$(chat_dir)"/*.jsonl 2>/dev/null | grep -v '/agent-' | head -1)
if [ -z "$f" ] || [ ! -f "$f" ]; then echo "Couldn't find the chat file: $f"; exit 0; fi
from="$2"
[ -z "$from" ] && from=$(( $(slept_lines "$(basename "$f")") + 1 ))
# A JSON string: anything but a quote or backslash, or a backslash and the character after it.
str='"(([^"\\]|\\.)*)"'
LC_ALL=C awk -v s="$from" 'NR>=s && !/"isMeta":true/ && !/"isCompactSummary":true/ {print NR "\t" $0}' "$f" \
  | LC_ALL=C sed -n -E \
    -e "/\"type\":\"user\"/{ s/^([0-9]+)\t.*\"role\":\"user\",\"content\":$str.*/[\1] THEM: \2/p; t" \
    -e "s/^([0-9]+)\t.*\"role\":\"user\",\"content\":\[\{\"type\":\"text\",\"text\":$str.*/[\1] THEM: \2/p; }" \
    -e "/\"type\":\"assistant\"/ s/^([0-9]+)\t.*\"type\":\"text\",\"text\":$str.*/[\1] YOU: \2/p" \
  | cut -c1-3000
echo "(end of $(basename "$f"): read from line $from of $(wc -l < "$f" | tr -d ' '))"
