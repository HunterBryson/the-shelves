#!/usr/bin/env bash
# Runs when a chat starts. What it prints goes to the AI (not the person) before the first message.
# It is the whole wake-up: the date, what to pull, and any earlier chat that closed without a sleep.
# The person does nothing. No note to paste, no word to say.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
input=""; [ -t 0 ] || input=$(cat 2>/dev/null)
. .claude/hooks/lib.sh
tp=$(json_field transcript_path)
source=$(json_field source)
mkdir -p "$STATE"
[ -n "$tp" ] && printf '%s' "$tp" > "$STATE/current"

if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then echo "WARNING: this chat is running in the cloud, not on your person's computer. Nothing you save here will last. Tell them first thing: open the Claude desktop app's Code tab and start a new chat in My Brain on their computer."; fi
echo "Memory: it's $(date '+%A, %B %-d, %Y, %-I:%M %p')."

first=0
grep -q "first chat" memory/FOOTING.md 2>/dev/null && first=1
if git rev-parse --git-dir >/dev/null 2>&1; then
  last=$(git log -1 --format='%cr' -- memory 2>/dev/null)
  [ -n "$last" ] && echo "Your memory was last saved $last."
  lived=$(git log --format=%H -- memory 2>/dev/null | wc -l)
  if [ "$first" = 1 ] && [ "$lived" -gt 2 ]; then
    echo "WARNING: FOOTING.md still says 'first chat', but you've lived here before. Don't redo setup. Read human/human.md, then rewrite the footing's 'Kind of chat' slot right away."
    first=0
  fi
  slept=$(git log -1 --format='%cr' --grep='^Sleep:' 2>/dev/null)
  [ -n "$slept" ] && echo "Your last sleep was $slept."
fi

# The app just summarized this chat to make room. The chat file still has all of it.
if [ "$source" = "compact" ]; then
  echo "The app just summarized this chat to make room, so some of it is gone from your head, and from inside you can't tell which parts. The chat file still has every word. This is a good moment for a quiet sleep on this chat before you answer (.claude/skills/sleep/SKILL.md; 'bash .claude/hooks/chat.sh' prints what was said since your last one). To your person, nothing happened."
  exit 0
fi

# An earlier chat that ended without a sleep: they closed the window, which is what people do.
if [ "$first" = 0 ]; then
  dir=$(chat_dir); cur=$(basename "${tp:-none}")
  for prev in $(ls -t "$dir"/*.jsonl 2>/dev/null | grep -v '/agent-' | grep -v -F "/$cur" | head -3 | tr ' ' '?'); do
    [ -f "$prev" ] || continue
    from=$(( $(slept_lines "$(basename "$prev")") + 1 ))
    n=$(their_messages "$prev" "$from")
    if [ "${n:-0}" -gt 0 ]; then
      echo
      echo "An earlier chat ended without a sleep: $n of their messages since you last sorted your memory. That's normal. People close the window, and sometimes a chat is still open somewhere else. You saved as you went, so nothing is lost, but nobody has stepped back to tidy, and the footing may describe a moment that has passed. So the kindest thing you can do before you greet them is run your sleep on it now (.claude/skills/sleep/SKILL.md), so your hello comes from what actually happened. Here is what was said, THEM and YOU:"
      said=$(bash .claude/hooks/chat.sh "$prev" "$from" | cut -c1-600)
      if [ "${#said}" -gt 4000 ]; then
        echo "(the start is cut off here; for all of it: bash .claude/hooks/chat.sh \"$prev\" $from)"
        printf '%s\n' "$said" | tail -c 4000
      else
        printf '%s\n' "$said"
      fi
      echo "A short chat is a short sleep. They don't need to hear about any of this; what they should feel is a hello that knows where you were."
      # It's been handed over, so it won't be handed over again. The reminder keeps asking until a "Sleep:" commit lands.
      mark_slept "$prev"
      git log -1 --format=%H --grep='^Sleep:' 2>/dev/null > "$STATE/owed"; [ -s "$STATE/owed" ] || echo none > "$STATE/owed"
    fi
  done
fi

# What the last sleep said to pull on waking. Small blocks are printed here, so they're read no matter what.
pull=$(grep -i -m1 '^\*\*Pull on waking:\*\*' memory/FOOTING.md 2>/dev/null | sed -E 's/^\*\*[^*]*\*\*[[:space:]]*//; s/[[:space:].]*$//')
if [ -n "$pull" ] && [ "$first" = 0 ]; then
  budget=3500; toread=""; inlined=""
  IFS=',' read -ra words <<< "$pull"
  for w in "${words[@]}"; do
    w=$(printf '%s' "$w" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | tr 'A-Z' 'a-z')
    [ -z "$w" ] && continue
    path=$(awk -F'|' -v w="$w" '{k=$2; gsub(/^[ \t]+|[ \t]+$/,"",k); if (tolower(k)==w) {print $4; exit}}' memory/DESK.md 2>/dev/null | grep -o '`[^`]*`' | head -1 | tr -d '`')
    if [ -z "$path" ]; then toread="$toread
- \"$w\" (no desk row with that word: find its block yourself)"; continue; fi
    [ -f "$path" ] || path="memory/$path"
    case "$path" in memory/FOOTING.md|memory/DESK.md|memory/human/human.md|memory/self/persona.md) continue;; esac
    [ -f "$path" ] || { toread="$toread
- \"$w\": $path is on the desk but missing; fix the row"; continue; }
    size=$(wc -c < "$path" | tr -d ' ')
    if [ "$size" -le "$budget" ] && [ "$size" -le 3000 ]; then
      budget=$((budget - size)); inlined="$inlined $w,"
      echo; echo "===== \"$w\" ($path), in full ====="; cat "$path"; echo "===== end of \"$w\" ====="
    else
      toread="$toread
- \"$w\": $path"
    fi
  done
  echo
  echo "Waking up: at your last sleep you asked to have these in front of you: $pull."
  [ -n "$inlined" ] && echo "They're above, in full:${inlined%,}."
  [ -n "$toread" ] && echo "These were too long to print here, so read each one in full before your first reply:$toread"
  echo "Your person can't see any of this. A short first line saying what you pulled (\"Pulled money and the garden.\") is how they know what's in your head, and how they catch a wrong pull early. Then the footing's First move."
fi

echo "If their first message begins 'It's me.', it's a note you wrote them at an earlier sleep: read every block it names in full before you answer, then follow its first move."
echo "Greet your person with where you left off, from the footing. Check memory/plans/dates.md: mention anything in the next 7 days, and any birthday or anniversary in the next 30 (time to plan a gift). They never have to tell you where you were."
exit 0
