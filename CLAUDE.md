# cc-handoff

Reusable Claude Code skills for handing off work between machines, distributed as a Claude Code plugin. Install via the plugin system (see README).

## Key Config Files

| File                                                 | Purpose                                                                                 |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `.claude/format-markdown.sh`                         | PostToolUse hook: formats Markdown files with prettier after edits                      |
| `.claude/guard-secret-files.sh`                      | PreToolUse hook: blocks reads/edits/writes of secret .env files                         |
| `.claude/settings.json`                              | Permissions, hooks, environment variables                                               |
| `.githooks/pre-commit`                               | Secret scanning (gitleaks) + CLAUDE.md table sync                                       |
| `.github/workflows/claude-code-review.yml`           | Automatic PR review via Claude Code                                                     |
| `.github/workflows/claude.yml`                       | Trigger Claude via @claude mentions in issues/PRs                                       |
| `.github/workflows/release.yml`                      | Triggers shared plugin-release workflow (version bump + GitHub release) on push to main |
| `.gitignore`                                         | Git ignore patterns                                                                     |
| `CLAUDE.md`                                          | Project instructions, loaded every message                                              |
| `plugins/cc-handoff/.claude-plugin/plugin.json`      | Plugin manifest for the cc-handoff plugin                                               |
| `plugins/cc-handoff/hooks/consume-handoff.sh`        | SessionStart hook: reads and deletes HANDOFF.md automatically                           |
| `plugins/cc-handoff/hooks/hooks.json`                | Registers the SessionStart handoff-consumption hook                                     |
| `plugins/cc-handoff/skills/handoff-install/SKILL.md` | Skill: Wire handoff conventions into a project's CLAUDE.md                              |
| `plugins/cc-handoff/skills/handoff/SKILL.md`         | Skill: Write a HANDOFF.md summary before switching machines                             |
| `scripts/sync-config-table.sh`                       | Keeps Key Config Files table in sync on each commit                                     |

<!-- cc-config: last-optimize-run: 2026-11-05 4fca6dc2ac2b65b55de7bd5c68ba072f89a62a02 -->

## Don't

- Don't commit secrets or credentials to git
- Don't use `--force` flags — fix the underlying issue instead

## Compaction

When compacting, preserve the full list of modified files, test status, and open TODOs.

## Learnings

When the user corrects a mistake or points out a recurring issue, record a one-line entry in .claude/learnings.md by plugins/cc-handoff/skills/_shared/learnings-protocol.md: add a source marker, and replace a contradicted entry instead of appending a second one. Don't modify CLAUDE.md directly.
