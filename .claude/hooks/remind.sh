#!/usr/bin/env bash
# Runs on every message the person sends. What it prints goes to the AI with their message.
# It's the nudge a fresh AI needs: save as you go, because nothing else will.
# It also notices the two things a person shouldn't have to: that they've been away, and that the chat got long.
cat <<'EOF'
Memory check for this turn: if their message touches a block on the desk, pull it first ("Pulled money."). If it tells you anything worth keeping (a fact, a person, a date, a decision, a preference, a plan, a change, a correction), write it into its block in this same turn and say so in one line ("Saved to family."). No block fits? Use the nearest one, or make a new block and desk row yourself if it has come up before. If the direction of the chat changed, rewrite that slot of FOOTING.md. Never ask them to file, name or approve anything. If they're saying goodbye in any words (goodnight, thanks that's all, talk later), run your sleep in this same reply, without asking and without handing them anything.
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

# The chat-start hook handed over an earlier chat to sort, and no sleep has landed since.
if [ -s "$STATE/owed" ]; then
  latest=$(git log -1 --format=%H --grep='^Sleep:' 2>/dev/null); latest=${latest:-none}
  if [ "$latest" = "$(cat "$STATE/owed")" ]; then
    echo "One thing still open: when this chat started you were handed an earlier chat that ended without a sleep, and no sleep has landed since. It's easy to lose in a hello. Doing it in this reply, before you answer, keeps the footing honest: sort what it said onto the map, rewrite the footing, and commit with a message that starts \"Sleep:\" (.claude/skills/sleep/SKILL.md). That word is how this reminder knows to stop. They don't need to hear about it."
  else
    rm -f "$STATE/owed"
  fi
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
      echo "Time has passed: it's now $(date '+%A, %B %-d, %-I:%M %p'), about $((gap / 3600)) hours since you last spoke in this chat. From inside, it feels like no time went by; for them it may be a new day. They came back to the same chat, which is completely fine, and they should never feel they did it wrong. It's worth another look at memory/plans/dates.md for today."
      [ "${unsorted:-0}" -gt 1 ] && echo "What came before the break hasn't had a sleep. Running it quietly now, before you answer (.claude/skills/sleep/SKILL.md), means the rest of this chat stands on a tidy memory."
    fi
  fi
fi

# The chat has gotten long. Say so once, in one sentence, and make it cost them nothing.
if ! grep -q -F "$name" "$STATE/nudged" 2>/dev/null; then
  typed=$(their_messages "$tp" 1)
  summarized=0; LC_ALL=C grep -q '"subtype":"compact_boundary"' "$tp" 2>/dev/null && summarized=1
  if [ "${typed:-0}" -ge 40 ] || [ "$summarized" = 1 ]; then
    echo "$name" >> "$STATE/nudged"
    echo "This chat has gotten long ($typed of their messages$([ "$summarized" = 1 ] && echo ', and the app has summarized it once')). Long chats make you slower and blurrier, and your person has no way to know that; they'll just feel you getting worse. After you answer, a quiet sleep (if this stretch hasn't had one) makes a fresh chat safe, and then one plain sentence at the end of your reply lets them choose, something like: \"This chat's getting long, so I'll get slower in here. Whenever you like, start a new chat in this folder and just say hi. I'll know where we were.\" If you can point at their screen, pointing at the new-chat button beats describing it. You'll only see this once per chat, so once is the right number of times to say it."
  fi
fi
exit 0
