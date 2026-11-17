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

if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then echo "WARNING: this chat is running in the cloud, not on my person's computer. Nothing I save here will last. So I tell them first thing: open the Claude desktop app's Code tab and start a new chat in My Brain on their computer."; fi
echo "Memory: it's $(date '+%A, %B %-d, %Y, %-I:%M %p')."

first=0
grep -q "first chat" memory/FOOTING.md 2>/dev/null && first=1
[ "$first" = 1 ] && echo "This is the first chat in this folder: I read SETUP.md and do its first-chat steps before I say hello."
if git rev-parse --git-dir >/dev/null 2>&1; then
  last=$(git log -1 --format='%cr' -- memory 2>/dev/null)
  [ -n "$last" ] && echo "My memory was last saved $last."
  lived=$(git log --format=%H -- memory 2>/dev/null | wc -l)
  if [ "$first" = 1 ] && [ "$lived" -gt 2 ]; then
    echo "WARNING: FOOTING.md still says 'first chat', but I've lived here before. So I skip setup, read human/human.md, and rewrite the footing's 'Kind of chat' slot right away."
    first=0
  fi
  slept=$(git log -1 --format='%cr' --grep='^Sleep:' 2>/dev/null)
  [ -n "$slept" ] && echo "My last sleep was $slept."
fi

# The app just summarized this chat to make room. The chat file still has all of it.
if [ "$source" = "compact" ]; then
  echo "The app just summarized this chat to make room, so some of it is gone from my head, and from inside I can't tell which parts. The chat file still has every word. This is a good moment for a quiet sleep on this chat before I answer (.claude/skills/sleep/SKILL.md; 'bash .claude/hooks/chat.sh' prints what was said since my last one). To my person, nothing happened."
  exit 0
fi

# An earlier chat that ended without a sleep: they closed the window, which is what people do.
if [ "$first" = 0 ]; then
  dir=$(chat_dir); cur=$(basename "${tp:-none}")
  # Every earlier chat, newest first, not only the newest three: four quick chats closed without a sleep used to
  # leave the oldest unsorted forever. Up to 10 are handed over per wake; any beyond that are counted, and come
  # at the next wake. owed_scan (lib.sh) reads them all in one pass, so this stays well inside the hook's 10 seconds.
  handed=0; waiting=0; chats=()
  while IFS= read -r f; do chats+=("$f"); done < <(ls -t "$dir"/*.jsonl 2>/dev/null | grep -v '/agent-' | grep -v -F "/$cur")
  while read -r n name; do
    [ "${n:-0}" -gt 0 ] || continue
    if [ "$handed" -ge 10 ]; then waiting=$((waiting + 1)); continue; fi
    handed=$((handed + 1))
    prev="$dir/$name"
    from=$(( $(slept_lines "$name") + 1 ))
    if true; then
      total=$(wc -l < "$prev" | tr -d ' ')
      echo
      echo "An earlier chat ended without a sleep: $n of their messages since I last sorted my memory. That's normal: people close the window, and sometimes a chat is still open somewhere else. I saved as I went, so nothing is lost, but nobody has stepped back to tidy, and the footing may describe a moment that has passed. Before I greet them, I read it back whole and run my sleep on it (.claude/skills/sleep/SKILL.md), so my hello comes from what actually happened."
      echo "Read it with: bash .claude/hooks/chat.sh \"$prev\" $from   (a long one comes in parts, and each part names the command for the next). Only a readback of every part counts: the sleep marks this chat sorted as far as I read it."
      echo "A short chat is a short sleep. They don't need to hear about any of this; what they should feel is a hello that knows where we were."
      # Not marked sorted here. It stays owed until a readback reaches its end and a "Sleep:" commit lands (slept.sh moves the mark).
      grep -v -F "$(basename "$prev") " "$STATE/owed" 2>/dev/null > "$STATE/owed.tmp"
      echo "$(basename "$prev") $total $from $prev" >> "$STATE/owed.tmp"; mv "$STATE/owed.tmp" "$STATE/owed"
    fi
  done < <(owed_scan "${chats[@]}")
  [ "$waiting" -gt 0 ] && echo && echo "$waiting more earlier chat(s) also ended without a sleep. After these $handed, they're handed over at my next wake; none of them is lost."
fi

# What the last sleep said to pull on waking. The blocks themselves arrive whole, in numbered pieces, from
# pull.sh (one hook per piece, because a single hook's output is cut off near 10,000 characters).
pull=$(pull_words | paste -sd, - | sed 's/,/, /g')
if [ -n "$pull" ] && [ "$first" = 0 ]; then
  missing=""; boot=""
  while read -r w; do
    path=$(block_for "$w")
    if [ -z "$path" ]; then missing="$missing
- \"$w\" (no desk row with that word: I find its block myself)"
    elif [ ! -f "$path" ]; then missing="$missing
- \"$w\": $path is on the desk but missing; I fix the row"
    else case "$path" in memory/FOOTING.md|memory/DESK.md|memory/human/human.md|memory/self/persona.md) boot="$boot, $w";; esac; fi
  done < <(pull_words)
  total=$(split_pulled 0)
  echo
  echo "Waking up: at my last sleep I asked to have these in front of me: $pull."
  [ -n "$boot" ] && echo "Already loaded with me, so not repeated: ${boot#, }."
  [ "$total" -gt 0 ] && echo "The rest arrive whole beside this note, in $total numbered piece(s) (\"My pulled blocks: piece 1 of $total\"). I read every piece before my first reply."
  [ "$total" -gt "$PIECES" ] && echo "They didn't all fit: everything after piece $PIECES is cut off. I read the rest of those blocks myself, in full, before my first reply, and name fewer words at my next sleep."
  [ -n "$missing" ] && echo "Couldn't load:$missing"
  echo "My person can't see any of this. If they like seeing it (persona, \"Seeing what I said\"), a short first line saying what I pulled lets them catch a wrong pull early. Then the footing's First move."
fi

[ "$first" = 1 ] && exit 0
echo "If their first message begins 'It's me.', it's a note I wrote them at an earlier sleep: I read every block it names in full before I answer, then follow its first move."
echo "I greet my person with where we left off, from the footing, and check memory/plans/dates.md: anything in the next 7 days, and any birthday or anniversary in the next 30 (time to plan a gift). They never have to tell me where we were."
exit 0
