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
exit 0
