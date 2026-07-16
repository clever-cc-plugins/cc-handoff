---
name: handoff
description: Create a handoff summary for continuing work on another machine. Use when the user says handoff, end session, switch machine, wrap up, save progress, or hand off.
disable-model-invocation: true
---

# Handoff

Write a file called HANDOFF.md in the project root. Keep it concise — under 40 lines.

## Structure

```
# Handoff

## Current State
What was being worked on, how far it got, and whether it's in a working state.

## Modified Files
List of files changed in this session that haven't been committed yet.

## Test Status
Last known test results. Which tests pass, which fail, what's untested.

## Open TODOs
Concrete next steps, in priority order.

## Key Decisions
Non-obvious decisions made during this session and why.
```

## Rules

- Only include sections that have content. Skip empty sections.
- Be specific. "Auth is broken" is useless. "Login endpoint returns 401 because JWT secret is missing from .env.example" is useful.
- List actual file paths, not vague references.
- After writing the file, remind the user to commit and push before switching machines.
