#!/bin/bash
# Initialize Pickle Rick loop state
set -euo pipefail

ARGS="$*"
STATE_DIR=".claude"
STATE_FILE="${STATE_DIR}/pickle-loop.local.md"

# Parse arguments
MAX_ITERATIONS=5
MAX_TIME=60
PROMISE=""
TASK=""

# Simple argument parsing
while [[ $# -gt 0 ]]; do
  case $1 in
    --max-iterations)
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --max-time)
      MAX_TIME="$2"
      shift 2
      ;;
    --promise)
      PROMISE="$2"
      shift 2
      ;;
    *)
      # Accumulate task description
      if [ -z "$TASK" ]; then
        TASK="$1"
      else
        TASK="$TASK $1"
      fi
      shift
      ;;
  esac
done

# Remove quotes from task if present
TASK="${TASK%\"}"
TASK="${TASK#\"}"

# Validate task
if [ -z "$TASK" ]; then
  echo "Error: No task provided" >&2
  echo "Usage: /pickle \"task description\" [--max-iterations N] [--max-time M] [--promise \"criteria\"]" >&2
  exit 1
fi

# Create state directory
mkdir -p "$STATE_DIR"

# Get current timestamp
START_TIME=$(date +%s)

# Create state file
cat > "$STATE_FILE" << EOF
---
active: true
iteration: 1
max_iterations: ${MAX_ITERATIONS}
start_time: ${START_TIME}
max_time_minutes: ${MAX_TIME}
completion_promise: "${PROMISE}"
---

# Pickle Rick Loop Task

${TASK}

## Loop Configuration

- **Max Iterations:** ${MAX_ITERATIONS}
- **Max Time:** ${MAX_TIME} minutes
- **Started:** $(date -r ${START_TIME} 2>/dev/null || date -d @${START_TIME} 2>/dev/null || date)
${PROMISE:+- **Completion Promise:** ${PROMISE}}

## Progress Log

### Iteration 1
Starting...
EOF

echo "Pickle Rick loop initialized!"
echo "  Task: ${TASK}"
echo "  Max iterations: ${MAX_ITERATIONS}"
echo "  Max time: ${MAX_TIME} minutes"
[ -n "$PROMISE" ] && echo "  Completion promise: ${PROMISE}"
echo ""
echo "Use /eat-pickle to stop the loop."