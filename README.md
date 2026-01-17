# Pickle Rick - Claude Code Plugin

**Autonomous AI Loop Manager for Claude Code**

A port of [galz10/pickle-rick-extension](https://github.com/galz10/pickle-rick-extension) (Gemini CLI) to Claude Code plugin format.

## Overview

Pickle Rick implements the "Ralph Wiggum technique" - continuous AI agent loops that persist until task completion. The AI works iteratively on a task, with each iteration building on the previous one's progress.

## Installation

Claude Code에서 다음 명령어를 실행하세요:

```bash
/plugin marketplace add huiung/pickle-rick

/plugin install pickle-rick@huiung/pickle-rick
```
## Commands

### `/pickle [task] [options]`
Start an autonomous loop to complete a task.

**Options:**
- `--max-iterations N` - Max iterations (default: 5)
- `--max-time M` - Max time in minutes (default: 60)
- `--promise "cmd"` - Shell command that returns 0 when task is complete

**Examples:**
```bash
/pickle "Fix all TypeScript errors"
/pickle "Implement user auth" --max-iterations 10
/pickle "Make tests pass" --promise "npm test"
```

### `/eat-pickle`
Stop the current loop gracefully.

### `/pickle-prd [description]`
Interactively create a PRD before starting a loop.

### `/help-pickle`
Show help information.

## How It Works

1. `/pickle` creates a state file at `.claude/pickle-loop.local.md`
2. Claude works on the task using all available tools
3. When Claude finishes an iteration, the Stop hook intercepts
4. The hook checks: iteration count, time elapsed, completion promise
5. If not done, it continues with context from previous iteration
6. Loop ends when: task complete, max iterations, time limit, or `/eat-pickle`

## Directory Structure

```
pickle-rick/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── pickle.md            # Main loop command
│   ├── eat-pickle.md        # Stop command
│   ├── pickle-prd.md        # PRD drafter
│   └── help-pickle.md       # Help
├── hooks/
│   └── hooks.json           # Hook configuration
├── scripts/
│   ├── init-loop.sh         # Initialize loop state
│   ├── stop-hook.sh         # Stop hook logic
│   ├── stop-loop.sh         # Manual stop
│   └── session-init.sh      # Session startup
├── skills/
│   └── pickle-persona/
│       └── SKILL.md         # Persona skill
└── README.md
```

## State File Format

The loop state is stored in `.claude/pickle-loop.local.md`:

```yaml
---
active: true
iteration: 1
max_iterations: 5
start_time: 1705500000
max_time_minutes: 60
completion_promise: "npm test"
---

# Pickle Rick Loop Task

Your task description here...
```

## Best Practices

**Good Use Cases:**
- Tasks with clear success criteria (tests pass, builds succeed)
- Iterative refinement (fix errors one by one)
- Multi-step implementations with verification
- Code generation with testing

**Not Recommended:**
- Tasks requiring human judgment
- Ambiguous or open-ended requests
- Production operations without safeguards

## Safety Considerations

- Review all changes made during autonomous loops
- Use `--max-iterations` and `--max-time` to limit scope
- Use `/eat-pickle` to stop if the AI goes off track
- Consider sandboxed environments for risky operations

## Differences from Gemini CLI Version

| Feature | Gemini CLI | Claude Code |
|---------|------------|-------------|
| Command format | TOML | Markdown + YAML |
| Hook type | AfterAgent | Stop |
| State file | JSON | Markdown with YAML |
| Interactive | Limited | AskUserQuestion tool |

## License

Apache 2.0 (same as original)

---

*"Wubba lubba dub dub!" - I'm Pickle Rick!*
