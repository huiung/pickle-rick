#!/bin/bash
# Stop the Pickle Rick loop gracefully
set -euo pipefail

STATE_FILE=".claude/pickle-loop.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "No active Pickle Rick loop found."
  exit 0
fi

# Read current state
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE" | head -10)
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//' | tr -d ' ')
ACTIVE=$(echo "$FRONTMATTER" | grep '^active:' | sed 's/active: *//' | tr -d ' ')

if [[ "$ACTIVE" != "true" ]]; then
  echo "Loop was already stopped."
  exit 0
fi

# Deactivate loop
sed -i.bak 's/^active: true/active: false/' "$STATE_FILE" 2>/dev/null || \
  sed -i '' 's/^active: true/active: false/' "$STATE_FILE"
rm -f "${STATE_FILE}.bak"

# Append termination note
echo "" >> "$STATE_FILE"
echo "## Loop Terminated" >> "$STATE_FILE"
echo "" >> "$STATE_FILE"
echo "Stopped manually via /eat-pickle at iteration $ITERATION." >> "$STATE_FILE"
echo "Timestamp: $(date)" >> "$STATE_FILE"

echo "Pickle Rick loop stopped after $ITERATION iteration(s)."
echo "State preserved in $STATE_FILE"