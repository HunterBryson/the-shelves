#!/usr/bin/env bash
# Runs on every message the person sends. What it prints goes to the AI with their message.
# It's the one nudge a fresh AI needs: save as you go, because nothing else will.
cat <<'EOF'
Memory check for this turn: if their message touches a block on the desk, pull it first ("Pulled money."). If it tells you anything worth keeping (a fact, a person, a date, a decision, a preference, a plan, a change, a correction), write it into its block in this same turn and say so in one line ("Saved to family."). No block fits? Use the nearest one, or make a new block and desk row yourself if it has come up before. If the direction of the chat changed, rewrite that slot of FOOTING.md. Never ask them to file, name or approve anything.
EOF
exit 0
