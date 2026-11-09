#!/usr/bin/env bash
# Marks every chat in this folder as slept, up to where each one is right now.
# save.sh runs it by itself when a "Sleep:" commit lands, so the AI never has to remember to.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
input=""; tp=""
. .claude/hooks/lib.sh
dir=$(chat_dir)
ls "$dir"/*.jsonl >/dev/null 2>&1 || exit 0
mkdir -p "$STATE"
: > "$STATE/slept.tmp"
for f in "$dir"/*.jsonl; do
  case "$(basename "$f")" in agent-*) continue;; esac
  echo "$(basename "$f") $(wc -l < "$f" | tr -d ' ') $(date +%s)" >> "$STATE/slept.tmp"
done
mv "$STATE/slept.tmp" "$STATE/slept"
exit 0
