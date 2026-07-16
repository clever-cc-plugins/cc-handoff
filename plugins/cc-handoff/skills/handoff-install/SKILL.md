---
name: handoff-install
description: Add handoff support to the current project. Use when the user says install handoff, set up handoff, add handoff to this project, or enable handoff.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Grep
---

# Install Handoff Support

Add the following section to the project's CLAUDE.md. Place it after existing sections,
before any Reference Documents section if one exists.

## Section to add

```
## Handoff

Before ending a session, the user may invoke `/handoff` to create a machine-transfer summary.
When resuming work, always check if HANDOFF.md exists in the project root. If it does, read it
first and continue from where it left off. After confirming the context is restored, delete the file.
```

## Rules

- If CLAUDE.md does not exist, tell the user and stop. Handoff depends on a working project config.
- If a Handoff section already exists in CLAUDE.md, tell the user and stop.
- After adding the section, confirm what was changed.
