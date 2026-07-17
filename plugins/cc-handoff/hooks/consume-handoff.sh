#!/usr/bin/env bash
# SessionStart: if HANDOFF.md exists at the start of a fresh session, read it
# into context and delete it, so it can't be re-consumed on a later start.
# Only fires on "startup" (not "resume"/"clear"/"compact"), so continuing an
# existing session never deletes a HANDOFF.md written earlier in that same
# session. This only deletes the working-tree copy — if HANDOFF.md was
# already committed and pushed, the deletion still needs to be committed and
# pushed too, or the file will reappear (and be re-consumed) on machines that
# pull the old commit.
input=$(cat)
source=$(echo "$input" | jq -r '.source // ""')
case "$source" in
  startup) ;;
  *) exit 0 ;;
esac

cwd=$(echo "$input" | jq -r '.cwd // "."')
file="$cwd/HANDOFF.md"
[ -f "$file" ] || exit 0

content=$(cat "$file")
rm -f "$file"

preamble="A HANDOFF.md file from the previous session was found and has been consumed (deleted). Read it, continue from where the last session left off, and let the user know context was restored."

jq -n --arg preamble "$preamble" --arg content "$content" \
  '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": ($preamble + "\n\n---\n\n" + $content)}}'
