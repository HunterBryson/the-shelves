#!/usr/bin/env bash
# A "Sleep:" commit just landed. Each chat's mark moves only as far as its readback reached (chat.sh notes
# that), so a sleep that skipped reading the chat back can't hide that stretch from the next sleep.
# save.sh runs this by itself, so the AI never has to remember to.
# Only chats in the readback list can move, so it walks just those (walking every chat in the folder grew
# slower with each one, inside save.sh's 20-second limit), plus the chat I'm in for the unread check.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
input=""; tp=""
. .claude/hooks/lib.sh
mkdir -p "$STATE"
# The chat that made this sleep: save.sh passes its own (SLEPT_CHAT), since another window may have spoken last.
curpath="${SLEPT_CHAT:-$(cat "$STATE/current" 2>/dev/null)}"; cur=$(basename "$curpath")
rm -f "$STATE/unread"

# Move each chat's mark as far as its readback reached.
if [ -s "$STATE/read" ]; then
  while read -r name got _; do
    [ -n "$name" ] && [ -n "$got" ] || continue
    was=$(slept_lines "$name")
    if [ "$got" -gt "$was" ]; then
      awk -v k="$name" '$1 != k' "$STATE/slept" 2>/dev/null > "$STATE/slept.tmp"
      echo "$name $got $(date +%s)" >> "$STATE/slept.tmp"
      mv "$STATE/slept.tmp" "$STATE/slept"
    fi
  done < "$STATE/read"
else
  # This sleep read nothing back at all. If the chat I'm in has talk since its mark, the sleep didn't count.
  # A sleep that read an earlier chat back did its job, so it isn't called out.
  if [ -z "${SLEPT_NO_UNREAD:-}" ] && [ -n "$cur" ] && [ -f "$curpath" ]; then
    was=$(slept_lines "$cur")
    [ "$(their_messages "$curpath" $(( was + 1 )))" -gt 0 ] && echo "$cur $(( was + 1 ))" > "$STATE/unread"
  fi
fi
rm -f "$STATE/read"
exit 0
