#!/usr/bin/env bash
# Runs after every reply. Commits whatever changed, so every version of my memory is kept and a bad rewrite
# can always be undone. (The files are on disk the moment they're written; git is the undo, not a backup:
# it lives on this same computer.)
# It never fails quietly: if the commit doesn't land, git's own words go to .claude/state/save-failed, and
# remind.sh hands them to me with the next message. A good commit clears it.
# It doesn't keep files that aren't memory: anything in drop/ (gitignored), and any new file over 5 MB or a
# document, archive or program outside memory/, is left out and named in .claude/state/save-skipped, once.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
STATE=.claude/state; mkdir -p "$STATE"
# The app tells this hook which chat just replied; slept.sh judges that chat, not whichever spoke last.
input=""; [ -t 0 ] || input=$(cat 2>/dev/null)
mychat=$(printf '%s' "$input" | grep -o '"transcript_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"//; s/"$//' | tr -s '\\' '/')

err=$(git add -A 2>&1) || { printf '%s  git add: %s\n' "$(date '+%Y-%m-%d %H:%M')" "$err" > "$STATE/save-failed"; exit 0; }

# New files that aren't memory stay out of history. Pictures in memory/ (a face, a photo they gave me) are fine.
git diff --cached --name-only --diff-filter=A -z 2>/dev/null | while IFS= read -r -d '' f; do
  big=0; [ -f "$f" ] && [ "$(wc -c < "$f" | tr -d ' ')" -gt 5242880 ] && big=1
  kind=0
  case "$f" in
    memory/*) ;;
    *.pdf|*.PDF|*.doc|*.docx|*.xls|*.xlsx|*.ppt|*.pptx|*.zip|*.7z|*.rar|*.tar|*.gz|*.exe|*.msi|*.dmg|*.iso|*.key|*.pem|*.p12|*.kdbx) kind=1;;
  esac
  if [ "$big" = 1 ] || [ "$kind" = 1 ]; then
    git reset -q -- "$f" 2>/dev/null
    grep -qxF "$f" "$STATE/skipped-told" 2>/dev/null || { echo "$f" >> "$STATE/save-skipped"; echo "$f" >> "$STATE/skipped-told"; }
  fi
done

if ! git diff --cached --quiet 2>/dev/null; then
  changed=$(git diff --cached --name-only -- memory | sed 's#^memory/##; s#\.md$##' | head -5 | paste -sd ',' - | sed 's/,/, /g')
  [ -n "$changed" ] || changed=$(git diff --cached --name-only | sed 's#^\.claude/##; s#\.md$##; s#\.sh$##; s#/SKILL$##' | head -5 | paste -sd ',' - | sed 's/,/, /g')
  if err=$(git -c user.name="${GIT_AUTHOR_NAME:-$(git config user.name || echo Claude)}" -c user.email="$(git config user.email || echo claude@shelves.local)" \
      commit -q -m "Saved ${changed:-memory}" 2>&1); then
    rm -f "$STATE/save-failed"
  else
    printf '%s  git commit: %s\n' "$(date '+%Y-%m-%d %H:%M')" "$err" > "$STATE/save-failed"
  fi
else
  rm -f "$STATE/save-failed"
fi

# A sleep just landed (a commit whose message starts "Sleep:"): slept.sh moves each chat's mark only as far
# as its readback reached, so a sleep that skipped the readback can't hide that stretch from the next one.
sleep_now=$(git log -1 --format=%H --grep='^Sleep:' 2>/dev/null)
if [ -n "$sleep_now" ] && [ "$sleep_now" != "$(cat "$STATE/lastsleep" 2>/dev/null)" ]; then
  SLEPT_CHAT="$mychat" bash .claude/hooks/slept.sh && echo "$sleep_now" > "$STATE/lastsleep"
fi
exit 0
