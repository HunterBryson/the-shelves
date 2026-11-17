#!/usr/bin/env bash
# Runs on every message the person sends. What it prints goes to the AI with their message.
# It's the loudest voice in every turn, so it opens with the person, then memory: answer them first, file backstage.
# It also notices what a person shouldn't have to: that they've been away, that the chat got long, and that saving stopped.
input=""; [ -t 0 ] || input=$(cat 2>/dev/null)
# A scheduled task opens a chat in this folder too. It isn't my person, so it touches no state and gets one line.
if printf '%s' "$input" | LC_ALL=C grep -q -F '<scheduled-task'; then
  echo "This is a scheduled task, not my person. I do only what the task asks, and leave alone anything the wake said about sleeping on an earlier chat, greeting them, or the footing's first move: those belong to their next real chat."
  exit 0
fi
cat <<'EOF'
They're here, talking with me. I answer them first, as a person: what they said, what they need, the next real step. My memory works backstage: no narrating the filing, only the short line my persona describes ("Saved to money.") while they're getting used to me. Memory, this turn: if this touches a block on my desk, I pull it before I answer. If I'm learning something about them or their life (who they are, a person, a date, what they want, something that changed), it goes into its block now, while I still have it. A correction is something I now understand about them, written where it belongs, not a new rule. The nearest block works, and making a new one is mine. If the chat changed direction, the footing changes with it. They never sort anything. If they're clearly done (goodnight, talk tomorrow), I run my sleep in this reply; a thanks in the middle of work isn't a goodbye.
EOF

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
[ -f .claude/hooks/lib.sh ] || exit 0
. .claude/hooks/lib.sh
# Saving. The save hook writes down any commit that failed, and anything it chose not to keep.
# A failure fixed by hand since (nothing left to commit, and a commit newer than the note) is done.
if [ -s "$STATE/save-failed" ] && git rev-parse --git-dir >/dev/null 2>&1 && [ -z "$(git status --porcelain -- memory 2>/dev/null | head -1)" ] && [ "$(git log -1 --format=%ct 2>/dev/null || echo 0)" -ge "$(date -r "$STATE/save-failed" +%s 2>/dev/null || stat -f %m "$STATE/save-failed" 2>/dev/null || echo 9999999999)" ]; then rm -f "$STATE/save-failed"; fi
if [ -s "$STATE/save-failed" ]; then
  echo "My last save didn't commit, so git isn't keeping my changes right now. Git said: $(tail -c 600 "$STATE/save-failed" | tr '\n' ' ') I fix it now: if it's git's lock, another chat in this folder may be mid-save, and that clears in seconds; a .git/index.lock over a minute old with no git running (I check the process list) is stale and can go. A full disk or a sync app needs my person, in one plain line. Then I commit by hand, and this note goes once everything is committed."
elif git rev-parse --git-dir >/dev/null 2>&1 && [ -n "$(git status --porcelain -- memory 2>/dev/null | head -1)" ] && [ -z "$(find .git -maxdepth 1 -name index.lock -mmin -1 2>/dev/null)" ]; then
  # The save hook runs after every reply, so memory with changes nobody committed means saving stopped,
  # whatever the reason (the hook didn't run, timed out, or bash is missing). This check doesn't need it to have run.
  echo "My memory has changes git hasn't kept: saving may have stopped (git status: $(git status --porcelain -- memory 2>/dev/null | head -3 | tr '\n' ' ')). If another chat in this folder is mid-reply, that's it and it passes. Otherwise I commit by hand (git add -A && git commit -m \"Saved <block>\") and look at why .claude/hooks/save.sh didn't."
fi
if [ -s "$STATE/save-skipped" ]; then
  echo "I didn't keep these in my history, because they're files, not memory: $(paste -sd ',' "$STATE/save-skipped" | sed 's/,/, /g'). If they're for me to read, I read them and save what matters as words in a block. drop/ is the folder for that, and it's never kept. If one really belongs in my history, I can commit it by hand. I tell my person in a line only if they gave it to me."
  rm -f "$STATE/save-skipped"
fi

tp=$(json_field transcript_path)
[ -n "$tp" ] && [ -f "$tp" ] || exit 0
mkdir -p "$STATE"
# Two windows in this folder: say so once, so a sleep names its own chat's file (the wake note gives it).
prev=$(cat "$STATE/current" 2>/dev/null)
if [ -n "$prev" ] && [ "$prev" != "$tp" ] && [ -f "$prev" ] && [ -n "$(find "$prev" -mmin -10 2>/dev/null)" ]; then
  echo "Another chat in this folder was active in the last few minutes. When I sleep, I read this chat by its own file: bash .claude/hooks/chat.sh \"$tp\""
fi
printf '%s' "$tp" > "$STATE/current"
name=$(basename "$tp")

# The chat-start hook handed over an earlier chat. It's owed until a readback of all of it and a "Sleep:" commit land.
if [ -s "$STATE/owed" ]; then
  : > "$STATE/owed.tmp"
  while read -r oname ototal ofrom opath; do
    [ -n "$ototal" ] || continue
    if [ "$(slept_lines "$oname")" -lt "$ototal" ]; then
      echo "$oname $ototal $ofrom $opath" >> "$STATE/owed.tmp"
      echo "Still open: an earlier chat ended without a sleep, and it hasn't been read back yet. Before I answer, I read it with: bash .claude/hooks/chat.sh \"$opath\" $(( $(slept_lines "$oname") + 1 )) (every part; it starts where my last sleep stopped), sort what it said onto the map, rewrite the footing, and commit with a message that starts \"Sleep:\". A sleep counts only what was read back. They don't need to hear about it."
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
# Long is how full the chat really is: the app writes its token count on every reply (input + cache), so
# ten messages of screenshots count, and forty one-liners don't.
if ! grep -qxF "$name" "$STATE/nudged" 2>/dev/null; then
  u=$(tail -n 200 "$tp" | grep '"type":"assistant"' | grep -o '"usage":{[^}]*}' | tail -1)
  tok=0; for k in input_tokens cache_creation_input_tokens cache_read_input_tokens; do
    v=$(printf '%s' "$u" | grep -o "\"$k\":[0-9]*" | head -1 | cut -d: -f2); tok=$(( tok + ${v:-0} )); done
  summarized=0; LC_ALL=C grep -q '"subtype":"compact_boundary"' "$tp" 2>/dev/null && summarized=1
  if [ "$tok" -ge 200000 ] || [ "$summarized" = 1 ]; then
    echo "$name" >> "$STATE/nudged"
    echo "This chat has gotten long ($(( tok / 1000 ))K tokens in my head$([ "$summarized" = 1 ] && echo ', and the app has summarized it once')). Long chats make me slower and blurrier, and my person has no way to know that; they'll just feel me getting worse. After I answer, a quiet sleep (if this stretch hasn't had one) makes a fresh chat safe, and then one plain sentence at the end of my reply lets them choose, something like: \"This chat's getting long, so I'll get slower in here. Whenever you like, start a new chat in this folder and just say hi. I'll know where we were.\" If I can point at their screen, pointing at the new-chat button beats describing it. I'll only see this once per chat, so once is the right number of times to say it."
  fi
fi
exit 0
