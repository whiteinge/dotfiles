#!/bin/zsh
# Given a range of commits, open the full diff of each commit as a separate
# file in Vim (for the nice syntax highlighting).
#
# Examples:
#
# Show diffs for all incoming upstream changes:
# git pagediffs ..@{u}
#
# Show diffs for all outgoing changes not yet pushed to origin (also excluding
# merges and a specific branch):
# git pagediffs origin/master.. --no-merges --not uninteresting_branch

setopt RC_EXPAND_PARAM
local -a revisions

revisions=( ${(f)$(git rev-list --reverse ${@})} )
[[ ${#revisions} -gt 0 ]] || exit 1

eval $EDITOR "<(git show -p --stat ${=revisions})"
