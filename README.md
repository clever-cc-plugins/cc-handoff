<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/clever-cc-plugins/.github/main/assets/logo-dark.svg" />
    <img src="https://raw.githubusercontent.com/clever-cc-plugins/.github/main/assets/logo.svg" width="220" alt="clever [cc] plugins" />
  </picture>
</p>

# cc-handoff

Two Claude Code skills for handing work off between machines, distributed as a Claude Code plugin.

**`/handoff`** writes a concise `HANDOFF.md` summary before you switch machines or end a session — current state, modified files, test status, open TODOs, and key decisions.

**`/handoff-install`** wires the handoff convention into a project's `CLAUDE.md`, so any Claude Code session automatically checks for `HANDOFF.md` on resume and picks up right where the last session left off.

## At a glance

| Skill              | Use it when                                 | What it does                                                                                           |
| ------------------ | ------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `/handoff`         | Ending a session or switching machines      | Writes `HANDOFF.md` with current state, modified files, test status, open TODOs, and key decisions     |
| `/handoff-install` | Once per project, the first time you use it | Adds a `## Handoff` section to the project's `CLAUDE.md` so future sessions know to check for the file |

## Table of Contents

- [cc-handoff](#cc-handoff)
  - [At a glance](#at-a-glance)
  - [Table of Contents](#table-of-contents)
  - [What problem does this solve?](#what-problem-does-this-solve)
  - [Installation](#installation)
    - [Keeping skills current](#keeping-skills-current)
    - [Uninstalling](#uninstalling)
  - [Usage](#usage)
    - [`/handoff-install` — One-time setup per project](#handoff-install--one-time-setup-per-project)
    - [`/handoff` — Before ending a session](#handoff--before-ending-a-session)
    - [Resuming on another machine](#resuming-on-another-machine)
    - [Recommended workflow](#recommended-workflow)
  - [What `HANDOFF.md` looks like](#what-handoffmd-looks-like)
  - [Compatibility](#compatibility)
  - [Contributing](#contributing)
  - [License](#license)

## What problem does this solve?

Switching machines — laptop to desktop, local to a remote box, one collaborator to another — usually means losing the working context that only lived in a chat session: what you were mid-way through, which files are dirty, what's tested, and why you made the decisions you made. Re-deriving that from `git diff` and memory is slow and error-prone.

`cc-handoff` makes the handoff explicit and structured:

- **`/handoff`** captures a snapshot at the end of a session — only the sections that have content, written specifically enough to act on ("Login endpoint returns 401 because JWT secret is missing from `.env.example`", not "auth is broken").
- **`/handoff-install`** makes the pickup automatic: once installed, every future Claude Code session in that project knows to check for `HANDOFF.md` on start, read it, continue from where it left off, and delete it once the context is restored.

## Installation

Open Claude Code in any project and run:

```
/plugin marketplace add clever-cc-plugins/marketplace
/plugin install cc-handoff@clever-cc-plugins
```

That's it. Claude Code downloads the skills and makes `/handoff` and `/handoff-install` available immediately.

> **Note:** Auto-update for third-party marketplaces is off by default — see [Keeping skills current](#keeping-skills-current) to enable it.

### Keeping skills current

The plugin system checks for updates automatically on startup. For third-party marketplaces (like this one), auto-update is **off by default**. To enable it:

1. Run `/plugin` in Claude Code
2. Go to the **Marketplaces** tab
3. Turn on auto-update for `clever-cc-plugins/marketplace`

Once enabled, Claude Code updates the skills on startup whenever a new version is available.

### Uninstalling

To remove the plugin and the marketplace in one step:

```
/plugin marketplace remove clever-cc-plugins
```

Removing the marketplace automatically uninstalls any plugins installed from it. To remove only the plugin while keeping the marketplace:

```
/plugin uninstall cc-handoff@clever-cc-plugins
```

## Usage

Both skills are invoked explicitly — they don't trigger automatically from conversational hints, so a passing "let's wrap up" mid-task won't accidentally write a handoff file. Run them with their slash command when you actually mean it.

### `/handoff-install` — One-time setup per project

Run this once, in each project where you want handoff support:

```
/handoff-install
```

The skill will:

1. Check that the project has a `CLAUDE.md`. If not, it tells you and stops — handoff depends on a working project config.
2. Check whether a `## Handoff` section already exists. If so, it tells you and stops rather than duplicating it.
3. Add a `## Handoff` section to `CLAUDE.md`, placed after existing sections (before any Reference Documents section, if present). This section instructs every future session to check for `HANDOFF.md` on resume, read it, continue from where it left off, and delete it once restored.
4. Confirm what was changed.

### `/handoff` — Before ending a session

Whenever you're about to switch machines, end a session, or just want to save progress:

```
/handoff
```

The skill writes `HANDOFF.md` to the project root, capped at roughly 40 lines, containing only the sections that have real content:

- **Current State** — what was being worked on, how far it got, whether it's in a working state
- **Modified Files** — files changed this session that haven't been committed
- **Test Status** — last known test results: what passes, what fails, what's untested
- **Open TODOs** — concrete next steps, in priority order
- **Key Decisions** — non-obvious decisions made this session and why

After writing the file, it reminds you to commit and push before switching machines — `HANDOFF.md` only helps the next session if it actually made it to the remote.

### Resuming on another machine

Pull the latest commit and start Claude Code as usual. If `/handoff-install` has been run in this project, the resumed session already knows the convention: it checks for `HANDOFF.md`, reads it first, continues from where the last session left off, and deletes the file once the context is confirmed restored.

### Recommended workflow

```
Once per project:  /handoff-install         ← Wire the convention into CLAUDE.md

Every session:      ... do the work ...
End of session:     /handoff                ← Snapshot state to HANDOFF.md
                     git add -A && git commit && git push

New machine:         git pull
                     ... Claude reads HANDOFF.md automatically and continues ...
```

## What `HANDOFF.md` looks like

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

`HANDOFF.md` is meant to be short-lived: written at the end of one session, read and deleted at the start of the next. It is not meant to be a permanent changelog — commit it if you like, but don't be surprised when it disappears after the next session resumes.

## Compatibility

- Works with any programming language, framework, or project type — the skills only read and write Markdown files.
- Requires Claude Code (CLI or VS Code extension).
- `/handoff-install` requires an existing `CLAUDE.md` in the target project. Run `/cc-config-init` (from the [cc-config](https://github.com/clever-cc-plugins/cc-config) plugin) first if the project doesn't have one yet.

## Contributing

Issues and pull requests are welcome. If you've found a best practice that isn't covered, or a section `HANDOFF.md` should include, please open an issue.

## License

[MIT](LICENSE)

---

<p align="center">
  Part of the <a href="https://github.com/clever-cc-plugins">clever-cc-plugins</a> family · <a href="https://github.com/clever-cc-plugins/marketplace">marketplace</a> · <a href="https://github.com/clever-cc-plugins/cc-config">cc-config</a> · <a href="https://github.com/clever-cc-plugins/cc-content">cc-content</a> · <a href="https://github.com/clever-cc-plugins/cc-chime">cc-chime</a>
</p>
