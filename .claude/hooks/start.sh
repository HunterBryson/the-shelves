#!/usr/bin/env bash
# Runs when a chat starts. What it prints goes to the AI (not the person) before the first message.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
echo "Memory: it's $(date '+%A, %B %-d, %Y, %-I:%M %p')."
if git rev-parse --git-dir >/dev/null 2>&1; then
  last=$(git log -1 --format='%cr' -- memory 2>/dev/null)
  [ -n "$last" ] && echo "Your memory was last saved $last."
  lived=$(git log --format=%H -- memory 2>/dev/null | wc -l)
  if grep -q "first chat" memory/FOOTING.md 2>/dev/null && [ "$lived" -gt 2 ]; then
    echo "WARNING: FOOTING.md still says 'first chat', but you've lived here before. Don't redo setup. Read human/human.md, then rewrite the footing's 'Kind of chat' slot right away."
  fi
  slept=$(git log -1 --format='%cr' --grep='^Sleep:' 2>/dev/null)
  [ -n "$slept" ] && echo "Your last sleep was $slept." || echo "You haven't slept yet. When this chat winds down, offer it once: 'Say sleep and I'll sort my memory and hand you a note for the next chat.'"
fi
echo "If their first message begins 'It's me.', it's the note from your last sleep: read every block it names in full before you answer, say what you pulled in one line, then follow its first move."
echo "Read the footing and greet your person with where you left off. Check memory/plans/dates.md: mention anything in the next 7 days, and any birthday or anniversary in the next 30 (time to plan a gift)."
exit 0
