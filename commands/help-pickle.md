---
description: Display help information for Pickle Rick commands
---

# Pickle Rick - Autonomous AI Loop Manager

**Version:** 1.0.0
**Based on:** [galz10/pickle-rick-extension](https://github.com/galz10/pickle-rick-extension)

## Overview

Pickle Rick is an autonomous AI loop manager that implements continuous agent loops for iterative task completion. Based on the "Ralph Wiggum technique" - where the AI persists through multiple iterations until the task is complete.

## Commands

### `/pickle [task] [options]`
Start an autonomous iterative loop to complete a task.

**Arguments:**
- `task` - Description of the task to complete (required)

**Options:**
- `--max-iterations N` - Maximum number of iterations (default: 5)
- `--max-time M` - Maximum time in minutes (default: 60)
- `--promise "criteria"` - Completion criteria to check each iteration

**Examples:**
```
/pickle "Fix all TypeScript errors in the project"
/pickle "Implement user authentication" --max-iterations 10
/pickle "Make all tests pass" --promise "npm test exits with code 0"
```

### `/eat-pickle`
Stop the current Pickle Rick loop gracefully. The current iteration will complete, but no further iterations will start.

### `/pickle-prd [description]`
Interactively draft a Product Requirements Document before starting a loop. Helps clarify scope, success criteria, and constraints.

**Example:**
```
/pickle-prd "Add dark mode to the application"
```

### `/help-pickle`
Display this help information.

## How It Works

1. **Start**: `/pickle "your task"` initializes the loop
2. **Execute**: Claude works on the task using available tools
3. **Check**: The Stop hook checks if task is complete
4. **Continue**: If not complete, the loop continues with context
5. **Finish**: Loop ends when task is complete, max iterations reached, or time expires

## Loop State

Loop state is stored in `.claude/pickle-loop.local.md`:
- Current iteration count
- Original task description
- Start time
- Completion promise (if set)

## Best Practices

**Good use cases:**
- Tasks with clear success criteria (tests pass, builds succeed)
- Iterative refinement (fix errors one by one)
- Code generation with verification
- Multi-step implementations

**Not recommended for:**
- Tasks requiring human judgment
- Ambiguous or open-ended requests
- Production debugging without safeguards

## Safety

- Always review changes made during autonomous loops
- Use `--max-iterations` to limit scope
- Use `/eat-pickle` to stop if needed
- Consider using in a sandboxed environment for risky operations

---
*"I'm Pickle Rick!" - The smartest AI in the multiverse*