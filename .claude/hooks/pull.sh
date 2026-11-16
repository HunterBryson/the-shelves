#!/usr/bin/env bash
# Runs when a chat starts, once per piece (settings.json runs it with 1, 2, 3 ... up to PIECES in lib.sh).
# It prints piece N of the blocks the footing's "Pull on waking" names, whole. A single hook's output is
# cut off near 10,000 characters, which is why they travel in pieces instead of inside start.sh.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
input=""; [ -t 0 ] || input=$(cat 2>/dev/null)
. .claude/hooks/lib.sh
n="${1:-1}"
[ "$(json_field source)" = "compact" ] && exit 0
is_first_chat && exit 0
[ "$n" -le "$PIECES" ] 2>/dev/null || exit 0
total=$(split_pulled 0)
[ "$n" -le "$total" ] || exit 0
echo "(My pulled blocks: piece $n of $total. Pieces can arrive out of order; read them by number.)"
split_pulled "$n"
exit 0
