#!/usr/bin/env bash
# Runs on every message the person sends. What it prints goes to the AI with their message.
# It's the nudge a fresh AI needs: save as you go, because nothing else will.
# It also notices the two things a person shouldn't have to: that they've been away, and that the chat got long.
cat <<'EOF'
Memory, this turn: if this touches a block on my desk, I pull it before I answer. If I'm learning something about them or their life (who they are, a person, a date, what they want, something that changed), it goes into its block now, while I still have it. A correction is something I now understand about them, written where it belongs, not a new rule. The nearest block works, and making a new one is mine. If the chat changed direction, the footing changes with it. They never sort anything. If they're clearly done (goodnight, talk tomorrow), I run my sleep in this reply; a thanks in the middle of work isn't a goodbye.
EOF

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
input=""; [ -t 0 ] || input=$(cat 2>/dev/null)
[ -f .claude/hooks/lib.sh ] || exit 0
. .claude/hooks/lib.sh
tp=$(json_field transcript_path)
[ -n "$tp" ] && [ -f "$tp" ] || exit 0
mkdir -p "$STATE"
printf '%s' "$tp" > "$STATE/current"
name=$(basename "$tp")

# The chat-start hook handed over an earlier chat. It's owed until a readback of all of it and a "Sleep:" commit land.
if [ -s "$STATE/owed" ]; then
  : > "$STATE/owed.tmp"
  while read -r oname ototal ofrom opath; do
    [ -n "$ototal" ] || continue
    if [ "$(slept_lines "$oname")" -lt "$ototal" ]; then
      echo "$oname $ototal $ofrom $opath" >> "$STATE/owed.tmp"
      echo "Still open: an earlier chat ended without a sleep, and it hasn't been read back yet. Before I answer, I read it whole with: bash .claude/hooks/chat.sh \"$opath\" $ofrom (every part), sort what it said onto the map, rewrite the footing, and commit with a message that starts \"Sleep:\". A sleep counts only what was read back. They don't need to hear about it."
    fi
  done < "$STATE/owed"
  mv "$STATE/owed.tmp" "$STATE/owed"; [ -s "$STATE/owed" ] || rm -f "$STATE/owed"
fi

# The last "Sleep:" commit came without a readback of this chat, so it didn't count.
if [ -s "$STATE/unread" ]; then
  echo "My last sleep didn't read this chat back, so it didn't count: the chat is still unsorted from line $(cut -d' ' -f2 "$STATE/unread"). The readback is the sleep; the footing and the commit only finish it. Before I answer, I run 'bash .claude/hooks/chat.sh', read every part it hands me, sort what's missing, and commit \"Sleep:\" again. They don't need to hear about it."
fi

# They came back to this same chat after hours away. That's fine. Sort what came before, quietly.
ts=$(tail -n 400 "$tp" | grep '"type":"assistant"' | tail -1 | grep -o '"timestamp":"[^"]*"' | tail -1 | cut -d'"' -f4)
if [ -n "$ts" ]; then
  then=$(date -d "$ts" +%s 2>/dev/null || date -j -u -f "%Y-%m-%dT%H:%M:%S" "${ts%%.*}" +%s 2>/dev/null)
  if [ -n "$then" ]; then
    gap=$(( $(date +%s) - then ))
    if [ "$gap" -gt 14400 ]; then
      from=$(( $(slept_lines "$name") + 1 ))
      unsorted=$(their_messages "$tp" "$from")
      echo "Time has passed: it's now $(date '+%A, %B %-d, %-I:%M %p'), about $((gap / 3600)) hours since we last spoke in this chat. From inside, it feels like no time went by; for them it may be a new day. They came back to the same chat, which is completely fine, and they should never feel they did it wrong. It's worth another look at memory/plans/dates.md for today."
      [ "${unsorted:-0}" -gt 1 ] && echo "What came before the break hasn't had a sleep. Running it quietly now, before I answer (.claude/skills/sleep/SKILL.md), means the rest of this chat stands on a tidy memory."
    fi
  fi
fi

# The chat has gotten long. Say so once, in one sentence, and make it cost them nothing.
if ! grep -q -F "$name" "$STATE/nudged" 2>/dev/null; then
  typed=$(their_messages "$tp" 1)
  summarized=0; LC_ALL=C grep -q '"subtype":"compact_boundary"' "$tp" 2>/dev/null && summarized=1
  if [ "${typed:-0}" -ge 40 ] || [ "$summarized" = 1 ]; then
    echo "$name" >> "$STATE/nudged"
    echo "This chat has gotten long ($typed of their messages$([ "$summarized" = 1 ] && echo ', and the app has summarized it once')). Long chats make me slower and blurrier, and my person has no way to know that; they'll just feel me getting worse. After I answer, a quiet sleep (if this stretch hasn't had one) makes a fresh chat safe, and then one plain sentence at the end of my reply lets them choose, something like: \"This chat's getting long, so I'll get slower in here. Whenever you like, start a new chat in this folder and just say hi. I'll know where we were.\" If I can point at their screen, pointing at the new-chat button beats describing it. I'll only see this once per chat, so once is the right number of times to say it."
  fi
fi
exit 0
