#!/usr/bin/env bash
# Prints a chat as plain conversation, so a sleep can read it back without the tool noise.
# Each line starts with its line number in the chat file.
# usage: bash .claude/hooks/chat.sh                    (this chat, since its last sleep)
#        bash .claude/hooks/chat.sh this 1             (this whole chat)
#        bash .claude/hooks/chat.sh "<file>" [line]    (another chat, from that line on)
#        a part number at the end reads the next part of a long readback: chat.sh this "" 2
# A long readback comes in parts, because the app shows only a short preview of anything past about 30,000
# characters. Once every part has been printed, it notes how far the readback reached; a sleep counts only that.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
input=""; tp=""
. .claude/hooks/lib.sh
# PREVIEW=1: only counting or peeking, so nothing it reads counts as a readback.
[ -n "${PREVIEW:-}" ] && STATE="$STATE/preview"
f="$1"
{ [ -z "$f" ] || [ "$f" = "this" ]; } && f=$(cat "$STATE/current" 2>/dev/null)
[ -z "$f" ] && f=$(ls -t "$(chat_dir)"/*.jsonl 2>/dev/null | grep -v '/agent-' | head -1)
if [ -z "$f" ] || [ ! -f "$f" ]; then echo "Couldn't find the chat file: $f"; exit 0; fi
from="$2"
[ -z "$from" ] && from=$(( $(slept_lines "$(basename "$f")") + 1 ))
part="${3:-1}"
key="$(basename "$f") $from"
mkdir -p "$STATE"
# Part 1 (or another chat or starting line) makes the readback fresh; later parts read the same text.
if [ "$part" = 1 ] || [ "$(head -1 "$STATE/readback.key" 2>/dev/null)" != "$key" ]; then
  part=1
  # A JSON string: anything but a quote or backslash, or a backslash and the character after it.
  str='"(([^"\\]|\\.)*)"'
  LC_ALL=C awk -v s="$from" 'NR>=s && !/"isMeta":true/ && !/"isCompactSummary":true/ {print NR "\t" $0}' "$f" \
    | LC_ALL=C sed -n -E \
      -e "/\"type\":\"user\"/{ s/^([0-9]+)\t.*\"role\":\"user\",\"content\":$str.*/[\1] THEM: \2/p; t" \
      -e "s/^([0-9]+)\t.*\"role\":\"user\",\"content\":\[\{\"type\":\"text\",\"text\":$str.*/[\1] THEM: \2/p; t" \
      -e "s/^([0-9]+)\t.*\"role\":\"user\",\"content\":\[(\{\"type\":\"image\",\"source\":\{[^}]*\}\},)+\{\"type\":\"text\",\"text\":$str.*/[\1] THEM: [picture] \3/p; }" \
      -e "/\"type\":\"assistant\"/ s/^([0-9]+)\t.*\"type\":\"text\",\"text\":$str.*/[\1] YOU: \2/p" \
    | awk '{ if (length($0) > 3000) print substr($0, 1, 3000) " ...(cut here: the rest of this message is at this line of the chat file)"; else print }' \
    | awk -v size=24000 '{ if (len > 0 && len + length($0) + 1 > size) { n++; len=0 }; print (n+1) "\t" $0; len += length($0) + 1 }' > "$STATE/readback.txt"
  printf '%s\n%s\n' "$key" "$(wc -l < "$f" | tr -d ' ')" > "$STATE/readback.key"
  : > "$STATE/readback.seen"
fi
total=$(sed -n 2p "$STATE/readback.key")
parts=$(tail -1 "$STATE/readback.txt" 2>/dev/null | cut -f1); parts=${parts:-1}
grep "^$part	" "$STATE/readback.txt" | cut -f2-
echo "$part" >> "$STATE/readback.seen"
if [ "$(sort -u "$STATE/readback.seen" | wc -l | tr -d ' ')" -ge "$parts" ]; then
  [ -z "${PREVIEW:-}" ] && note_read "$f" "$total"
  echo "(end of $(basename "$f"): read from line $from to $total, all of it)"
else
  echo "(part $part of $parts. Next: bash .claude/hooks/chat.sh \"$f\" $from $(( part + 1 )). A sleep counts this readback only once every part is read.)"
fi
