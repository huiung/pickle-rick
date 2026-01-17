#!/bin/bash
# Session initialization for Pickle Rick plugin
# This runs when a new Claude Code session starts

STATE_FILE=".claude/pickle-loop.local.md"

# Check for existing active loop
if [[ -f "$STATE_FILE" ]]; then
  FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE" | head -10)
  ACTIVE=$(echo "$FRONTMATTER" | grep '^active:' | sed 's/active: *//' | tr -d ' ')

  if [[ "$ACTIVE" == "true" ]]; then
    ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//' | tr -d ' ')
    MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//' | tr -d ' ')

    # Notify about existing loop
    echo "{\"systemMessage\": \"Note: An active Pickle Rick loop was found (iteration ${ITERATION}/${MAX_ITERATIONS}). Use /eat-pickle to stop it or continue working on the task.\"}"
    exit 0
  fi
fi

# No active loop, silent exit
exit 0