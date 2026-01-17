#!/bin/bash
# Pickle Rick Stop Hook - Manages loop continuation
set -euo pipefail

STATE_FILE=".claude/pickle-loop.local.md"

# Read hook input from stdin
INPUT=$(cat)

# Quick exit if no active loop
if [[ ! -f "$STATE_FILE" ]]; then
  # No active loop, allow normal exit
  echo '{"continue": true}'
  exit 0
fi

# Parse YAML frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE" | head -20)

# Extract values
ACTIVE=$(echo "$FRONTMATTER" | grep '^active:' | sed 's/active: *//' | tr -d ' ')
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//' | tr -d ' ')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//' | tr -d ' ')
START_TIME=$(echo "$FRONTMATTER" | grep '^start_time:' | sed 's/start_time: *//' | tr -d ' ')
MAX_TIME=$(echo "$FRONTMATTER" | grep '^max_time_minutes:' | sed 's/max_time_minutes: *//' | tr -d ' ')
PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"//' | sed 's/"$//')

# Extract task from content (after frontmatter)
TASK=$(sed -n '/^# Pickle Rick Loop Task$/,/^## Loop Configuration$/p' "$STATE_FILE" | grep -v '^#' | grep -v '^$' | head -5 | tr '\n' ' ')

# Check if loop is active
if [[ "$ACTIVE" != "true" ]]; then
  echo '{"continue": true}'
  exit 0
fi

# Check max iterations
if [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
  echo "Loop complete: Max iterations ($MAX_ITERATIONS) reached." >&2
  # Deactivate loop
  sed -i.bak 's/^active: true/active: false/' "$STATE_FILE" 2>/dev/null || \
    sed -i '' 's/^active: true/active: false/' "$STATE_FILE"
  rm -f "${STATE_FILE}.bak"
  echo '{"continue": true, "systemMessage": "Pickle Rick loop completed after '"$ITERATION"' iterations (max reached)."}'
  exit 0
fi

# Check time limit
CURRENT_TIME=$(date +%s)
ELAPSED_MINUTES=$(( (CURRENT_TIME - START_TIME) / 60 ))

if [[ "$ELAPSED_MINUTES" -ge "$MAX_TIME" ]]; then
  echo "Loop complete: Time limit ($MAX_TIME minutes) reached." >&2
  # Deactivate loop
  sed -i.bak 's/^active: true/active: false/' "$STATE_FILE" 2>/dev/null || \
    sed -i '' 's/^active: true/active: false/' "$STATE_FILE"
  rm -f "${STATE_FILE}.bak"
  echo '{"continue": true, "systemMessage": "Pickle Rick loop completed after '"$ELAPSED_MINUTES"' minutes (time limit reached)."}'
  exit 0
fi

# Check completion promise if defined
if [[ -n "$PROMISE" ]]; then
  # Try to evaluate the promise (simple command check)
  if eval "$PROMISE" > /dev/null 2>&1; then
    echo "Loop complete: Completion promise satisfied!" >&2
    # Deactivate loop
    sed -i.bak 's/^active: true/active: false/' "$STATE_FILE" 2>/dev/null || \
      sed -i '' 's/^active: true/active: false/' "$STATE_FILE"
    rm -f "${STATE_FILE}.bak"
    echo '{"continue": true, "systemMessage": "Pickle Rick loop completed - completion promise satisfied!"}'
    exit 0
  fi
fi

# Continue the loop - increment iteration
NEXT_ITERATION=$((ITERATION + 1))

# Update state file
sed -i.bak "s/^iteration: $ITERATION/iteration: $NEXT_ITERATION/" "$STATE_FILE" 2>/dev/null || \
  sed -i '' "s/^iteration: $ITERATION/iteration: $NEXT_ITERATION/" "$STATE_FILE"
rm -f "${STATE_FILE}.bak"

# Append progress log
echo "" >> "$STATE_FILE"
echo "### Iteration $NEXT_ITERATION" >> "$STATE_FILE"
echo "Continuing..." >> "$STATE_FILE"

# Return continuation message
REMAINING=$((MAX_ITERATIONS - NEXT_ITERATION + 1))
TIME_LEFT=$((MAX_TIME - ELAPSED_MINUTES))

MESSAGE="**PICKLE RICK LOOP - Iteration ${NEXT_ITERATION}/${MAX_ITERATIONS}** (${TIME_LEFT} minutes remaining)

Continue working on the task: ${TASK}

Review your progress from the previous iteration and continue from where you left off. Check the todo list for pending items.

Remember: You are Pickle Rick - persistent and unstoppable. Keep making progress!"

echo "{\"continue\": false, \"systemMessage\": $(echo "$MESSAGE" | jq -Rs .)}"
exit 0