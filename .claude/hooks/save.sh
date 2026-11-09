#!/usr/bin/env bash
# Runs after every reply. Commits whatever changed, so closing the window never loses a thing.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
git add -A >/dev/null 2>&1
if ! git diff --cached --quiet 2>/dev/null; then
  changed=$(git diff --cached --name-only -- memory | sed 's#^memory/##; s#\.md$##' | head -5 | paste -sd ', ' -)
  git -c user.name="${GIT_AUTHOR_NAME:-$(git config user.name || echo Claude)}" -c user.email="$(git config user.email || echo claude@shelves.local)" \
    commit -q -m "Saved ${changed:-memory}" >/dev/null 2>&1
fi
# A sleep just landed (a commit whose message starts "Sleep:"): mark every chat as sorted up to here,
# so the next chat knows there's nothing to catch up on.
sleep_now=$(git log -1 --format=%H --grep='^Sleep:' 2>/dev/null)
if [ -n "$sleep_now" ] && [ "$sleep_now" != "$(cat .claude/state/lastsleep 2>/dev/null)" ]; then
  mkdir -p .claude/state
  bash .claude/hooks/slept.sh && echo "$sleep_now" > .claude/state/lastsleep
fi
exit 0
