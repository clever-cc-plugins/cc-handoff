<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/clever-cc-plugins/.github/main/assets/logo-dark.svg" />
    <img src="https://raw.githubusercontent.com/clever-cc-plugins/.github/main/assets/logo.svg" width="220" alt="clever [cc] plugins" />
  </picture>
</p>

# <img src="assets/icon.svg" width="40" height="40" align="top" alt="" />&nbsp;cc-handoff

A [Claude Code](https://claude.ai/code) plugin with two skills for handing work off between machines and sessions.

**`/cc-handoff:handoff`** writes a concise `HANDOFF.md` before you switch machines or end a session. It covers the current state, modified files, test status, open TODOs, and key decisions.

**`/cc-handoff:handoff-install`** documents the handoff convention in a project's `CLAUDE.md`. Pickup works without it: a plugin hook checks for `HANDOFF.md` at the start of every fresh session and continues where the last session stopped.

## At a Glance

| Skill                         | Use it when                                                | What it does                                                                                                                                    |
| ----------------------------- | ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `/cc-handoff:handoff`         | Ending a session or switching machines                     | Writes `HANDOFF.md` with the current state, modified files, test status, open TODOs, and key decisions                                          |
| `/cc-handoff:handoff-install` | You want the convention documented in a project (optional) | Adds a `## Handoff` section to the project's `CLAUDE.md` that documents the convention. The plugin hook handles the actual reading and deleting |

## Table of Contents

- [cc-handoff](#cc-handoff)
  - [At a Glance](#at-a-glance)
  - [Table of Contents](#table-of-contents)
  - [What Problem Does This Solve?](#what-problem-does-this-solve)
  - [Installation](#installation)
    - [Keeping Skills Current](#keeping-skills-current)
    - [Uninstalling](#uninstalling)
  - [Usage](#usage)
    - [`/cc-handoff:handoff-install`: One-Time Setup per Project](#cc-handoffhandoff-install-one-time-setup-per-project)
    - [`/cc-handoff:handoff`: Before Ending a Session](#cc-handoffhandoff-before-ending-a-session)
    - [Resuming on Another Machine](#resuming-on-another-machine)
    - [Recommended Workflow](#recommended-workflow)
  - [What `HANDOFF.md` Looks Like](#what-handoffmd-looks-like)
  - [Compatibility](#compatibility)
  - [Contributing](#contributing)
  - [License](#license)

## What Problem Does This Solve?

Switching machines (laptop to desktop, local to a remote box, one collaborator to another) usually means losing the working context that only lived in a chat session. What were you in the middle of? Which files are dirty? What's tested? Why did you decide what you decided? Future you will read the answer at 8 a.m. with no idea why `auth.ts` is open in four tabs, and rebuilding it from `git diff` and memory is slow and error-prone.

`cc-handoff` makes the handoff explicit and structured:

- **`/cc-handoff:handoff`** captures a snapshot at the end of a session. It includes only the sections that have content, and it's specific enough to act on ("Login endpoint returns 401 because JWT secret is missing from `.env.example`", not "auth is broken").
- A plugin hook makes the pickup automatic. At the start of every fresh session, it checks for `HANDOFF.md`, loads the contents into context, and deletes the file, so the next session on the same machine doesn't consume it a second time.

## Installation

Open Claude Code in any project and run:

```
/plugin marketplace add clever-cc-plugins/marketplace
/plugin install cc-handoff@clever-cc-plugins
```

Both skills, `/cc-handoff:handoff` and `/cc-handoff:handoff-install`, are available immediately.

### Keeping Skills Current

Auto-update is off by default for third-party marketplaces. To switch it on:

1. Run `/plugin` in Claude Code
2. Open the **Marketplaces** tab
3. Toggle auto-update for `clever-cc-plugins/marketplace`

Once it's on, Claude Code updates the skills on startup whenever a new version is available.

### Uninstalling

```
/plugin uninstall cc-handoff@clever-cc-plugins
```

To remove the marketplace as well (this uninstalls every plugin you installed from it):

```
/plugin marketplace remove clever-cc-plugins
```

## Usage

You invoke both skills explicitly. They don't trigger from conversational hints, so a passing "let's wrap up" in the middle of a task won't write a handoff file by accident. Run the slash command when you mean it.

### `/cc-handoff:handoff-install`: One-Time Setup per Project

This step is optional. Run it once in each project where you want the convention written down:

```
/cc-handoff:handoff-install
```

The skill will:

1. Check that the project has a `CLAUDE.md`. If not, it tells you and stops, because handoff documentation needs a working project config.
2. Check whether a `## Handoff` section already exists. If so, it tells you and stops instead of duplicating the section.
3. Add a `## Handoff` section to `CLAUDE.md`, placed after the existing sections (before any Reference Documents section, if present). The section documents the convention: a plugin hook loads `HANDOFF.md` into context and deletes it at session start, and Claude continues where the last session stopped.
4. Confirm what changed.

### `/cc-handoff:handoff`: Before Ending a Session

Run it whenever you're about to switch machines, end a session, or just want to save progress:

```
/cc-handoff:handoff
```

The skill writes `HANDOFF.md` to the project root, capped at roughly 40 lines, with only the sections that have real content:

- **Current State:** what you were working on, how far it got, and whether it's in a working state
- **Modified Files:** files changed in this session that haven't been committed
- **Test Status:** the last known test results, covering what passes, what fails, and what's untested
- **Open TODOs:** concrete next steps in priority order
- **Key Decisions:** non-obvious decisions from this session, and why you made them

After writing the file, the skill reminds you to commit and push before you switch machines. `HANDOFF.md` only helps the next session if it reached the remote.

### Resuming on Another Machine

Pull the latest commit and start Claude Code as usual. A plugin hook checks for `HANDOFF.md` when a fresh session starts, loads it into context, and deletes it. Resumed sessions are left alone, and no per-project setup is required. Claude continues where the last session stopped and tells you that context was restored.

The hook only deletes the local working-tree copy. If you committed `HANDOFF.md`, commit and push the deletion too (`git add -A && git commit -m "chore: consume handoff" && git push`). Otherwise the file reappears the next time this or another machine pulls that commit, and a session consumes it again.

### Recommended Workflow

```
Once per project:  /cc-handoff:handoff-install    # optional: document the convention in CLAUDE.md

Every session:     ... do the work ...
End of session:    /cc-handoff:handoff            # snapshot the state to HANDOFF.md
                   git add -A && git commit && git push

New machine:       git pull
                   ... the plugin hook reads HANDOFF.md at startup and you carry on ...
```

## What `HANDOFF.md` Looks Like

```markdown
# Handoff

## Current State

Login flow refactor is halfway done. `POST /auth/login` now issues JWTs;
`POST /auth/refresh` still uses the old session-cookie logic and needs
the same refactor.

## Modified Files

- src/auth/login.ts
- src/auth/session.ts (not yet updated)
- tests/auth/login.test.ts

## Test Status

`npm test -- auth/login` passes (12/12). `auth/session` tests not touched yet
and will fail against the new JWT flow.

## Open TODOs

1. Refactor `POST /auth/refresh` to issue JWTs instead of session cookies
2. Update `tests/auth/session.test.ts` to match
3. Remove the now-unused `express-session` dependency

## Key Decisions

Chose short-lived (15 min) access tokens + refresh tokens over long-lived
JWTs, to keep revocation possible without a server-side session store.
```

`HANDOFF.md` is short-lived by design. One session writes it, and the next session reads and deletes it. It's no permanent changelog. You can commit it if you like, but don't be surprised when it disappears after the next session resumes.

## Compatibility

- Works with any programming language, framework, or project type, because the skills only read and write Markdown files.
- Requires Claude Code (CLI or IDE extension).
- `/cc-handoff:handoff-install` needs an existing `CLAUDE.md` in the target project. If the project doesn't have one yet, run `/cc-config:bootstrapping-config` (from the [cc-config](https://github.com/clever-cc-plugins/cc-config) plugin) first.

## Contributing

Issues and pull requests are welcome. If you've found a best practice that isn't covered, or a section `HANDOFF.md` should include, please open an issue first so we can agree on the approach.

## License

[MIT](LICENSE), Copyright (c) 2026 Michael van Laar

---

<p align="center">
  Part of the <a href="https://github.com/clever-cc-plugins">clever-cc-plugins</a> family · <a href="https://github.com/clever-cc-plugins/marketplace">marketplace</a> · <a href="https://github.com/clever-cc-plugins/cc-config">cc-config</a> · <a href="https://github.com/clever-cc-plugins/cc-concept">cc-concept</a> · <a href="https://github.com/clever-cc-plugins/cc-content">cc-content</a> · <a href="https://github.com/clever-cc-plugins/cc-career">cc-career</a> · <a href="https://github.com/clever-cc-plugins/cc-coach">cc-coach</a> · <a href="https://github.com/clever-cc-plugins/cc-chime">cc-chime</a> · <a href="https://github.com/clever-cc-plugins/cc-chef">cc-chef</a>
</p>
