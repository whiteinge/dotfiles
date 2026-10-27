#!/bin/sh
# PreToolUse hook: refuse tool calls whose input carries a private email
# address. Addresses come from a list kept out of version control, one per
# line; blank lines and #-comments are ignored.
list=${CLAUDE_PRIVATE_EMAILS:-$HOME/.claude/private-emails}
[ -r "$list" ] || exit 0

patterns=$(sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$list")
[ -n "$patterns" ] || exit 0

input=$(cat)
# Decode %40 so URL-encoded addresses match too.
printf '%s' "$input" | jq -r '.tool_input | tostring' | sed 's/%40/@/gI' \
  | grep -qiF -e "$patterns" || exit 0

case $(printf '%s' "$input" | jq -r .tool_name) in
  Bash) decision=ask ;;   # local uses (git log --author=...) are legit
  *)    decision=deny ;;
esac
jq -n --arg d "$decision" '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: $d,
  permissionDecisionReason: "Tool input contains one of the user'"'"'s private email addresses. Use an @example.com address, or ask the user for a throwaway alias."}}'
