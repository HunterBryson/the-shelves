#!/usr/bin/env bash
# A "Sleep:" commit just landed. Each chat's mark moves only as far as its readback reached (chat.sh notes
# that), so a sleep that skipped reading the chat back can't hide that stretch from the next sleep.
# save.sh runs this by itself, so the AI never has to remember to.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
input=""; tp=""
. .claude/hooks/lib.sh
dir=$(chat_dir)
ls "$dir"/*.jsonl >/dev/null 2>&1 || exit 0
mkdir -p "$STATE"
cur=$(basename "$(cat "$STATE/current" 2>/dev/null)")
rm -f "$STATE/unread"
for f in "$dir"/*.jsonl; do
  name=$(basename "$f"); case "$name" in agent-*) continue;; esac
  was=$(slept_lines "$name"); got=$(read_lines "$name")
  if [ "$got" -gt "$was" ]; then
    grep -v -F "$name " "$STATE/slept" 2>/dev/null > "$STATE/slept.tmp"
    echo "$name $got $(date +%s)" >> "$STATE/slept.tmp"
    mv "$STATE/slept.tmp" "$STATE/slept"
  elif [ "$name" = "$cur" ] && [ "$(their_messages "$f" $(( was + 1 )))" -gt 0 ]; then
    echo "$name $(( was + 1 ))" > "$STATE/unread"
  fi
done
rm -f "$STATE/read"
exit 0
