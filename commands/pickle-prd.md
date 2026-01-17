---
description: Interactively draft a Product Requirements Document (PRD) before starting a Pickle Rick loop
argument-hint: "[project description]"
allowed-tools: Bash(*), Read, Write, Edit, AskUserQuestion
---

# Pickle Rick PRD Drafter

Creating a Product Requirements Document for your project.

## Project Overview

**Initial Description:** $ARGUMENTS

## Gathering Requirements

I'll help you define clear requirements before starting the autonomous loop.

### Step 1: Clarify Scope

Use AskUserQuestion to gather:

1. **Project Type**
   - question: "What type of project is this?"
   - header: "Type"
   - options:
     - New Feature (Building something from scratch)
     - Bug Fix (Fixing existing functionality)
     - Refactor (Improving code without changing behavior)
     - Enhancement (Adding to existing feature)

2. **Success Criteria**
   - question: "How will we know the task is complete?"
   - header: "Done When"
   - options:
     - Tests Pass (All tests must pass)
     - Manual Verification (User will verify)
     - Specific Output (Defined output expected)
     - Code Review Ready (Ready for review)

3. **Constraints**
   - question: "Are there any constraints to consider?"
   - header: "Constraints"
   - multiSelect: true
   - options:
     - Time Sensitive (Need quick solution)
     - Backward Compatible (Must not break existing)
     - Performance Critical (Speed matters)
     - No External Dependencies (Keep it simple)

### Step 2: Define Deliverables

Based on the answers, create a clear list of:
- Required changes
- Files to modify/create
- Tests to write
- Documentation updates

### Step 3: Generate PRD

Write the PRD to `.claude/pickle-prd.md` with the following structure:

```markdown
---
project: [Project Name]
type: [Project Type]
created: [Timestamp]
---

# Product Requirements Document

## Overview
[Project description]

## Success Criteria
[How we know it's done]

## Deliverables
- [ ] [Deliverable 1]
- [ ] [Deliverable 2]
...

## Constraints
[List constraints]

## Technical Approach
[High-level approach]
```

### Step 4: Confirm and Start

After the PRD is created, ask if the user wants to start the Pickle Rick loop with:
`/pickle "Complete the task defined in .claude/pickle-prd.md"`