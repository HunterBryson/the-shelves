#!/usr/bin/env bash
# Prints a chat as plain conversation, so a sleep can read it back without the tool noise.
# Each line starts with its line number in the chat file. talk.awk decides what's them, what's me, and what's
# only the app (dropped): every piece of a message is read, so their words aren't lost behind a reminder the app
# put in front of them, and their own long messages come through whole (up to 20,000 characters; mine, 3,000).
# usage: bash .claude/hooks/chat.sh "<this chat's file>"   (the wake note names it; since its last sleep)
#        bash .claude/hooks/chat.sh "<file>" [line]          (from that line on)
#        bash .claude/hooks/chat.sh                          (the chat that last sent a message here)
#        a part number at the end reads the next part of a long readback: chat.sh "<file>" <line> 2
# A long readback comes in parts, because the app shows only a short preview of anything past about 30,000
# characters. As each part is read, the readback's reach moves to the end of the parts read so far, in order;
# a sleep counts only that, so a chat too long for one sleep is finished by the next, from where this one stopped.
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
  LC_ALL=C awk -f .claude/hooks/talk.awk -v mode=read -v from="$from" "$f" \
    | awk -v size=24000 '{ if (len > 0 && len + length($0) + 1 > size) { n++; len=0 }; print (n+1) "\t" $0; len += length($0) + 1 }' > "$STATE/readback.txt"
  printf '%s\n%s\n' "$key" "$(wc -l < "$f" | tr -d ' ')" > "$STATE/readback.key"
  : > "$STATE/readback.seen"
fi
total=$(sed -n 2p "$STATE/readback.key")
parts=$(tail -1 "$STATE/readback.txt" 2>/dev/null | cut -f1); parts=${parts:-1}
[ -s "$STATE/readback.txt" ] || echo "(nothing they or I said since line $from: only tools and the app)"
grep "^$part	" "$STATE/readback.txt" | cut -f2-
echo "$part" >> "$STATE/readback.seen"
# How far the readback reaches: every part from 1 up to the first one not read yet.
done_to=0; while grep -qx "$(( done_to + 1 ))" "$STATE/readback.seen"; do done_to=$(( done_to + 1 )); done
if [ "$done_to" -ge "$parts" ]; then
  [ -z "${PREVIEW:-}" ] && note_read "$f" "$total"
  echo "(end of $(basename "$f"): read from line $from to $total, all of it)"
else
  if [ "$done_to" -gt 0 ] && [ -z "${PREVIEW:-}" ]; then
    next=$(grep -m1 "^$(( done_to + 1 ))	" "$STATE/readback.txt" | cut -f2 | sed -E 's/^\[([0-9]+)\].*/\1/')
    [ -n "$next" ] && note_read "$f" "$(( next - 1 ))"
  fi
  echo "(part $part of $parts. Next: bash .claude/hooks/chat.sh \"$f\" $from $(( part + 1 )). A sleep counts what's been read so far, in order; the rest waits for the next part, or the next sleep.)"
fi
