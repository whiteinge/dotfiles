#!/bin/bash
# Draw a graphviz diagram of the Git DAG
#
# Labels consist of the short SHA1 and any refs.
# Unreachable commits (ignoring the reflog) will be marked with an asterisk and
# drawn with dashed lines.
#
# Largely stolen from https://git.wiki.kernel.org/index.php/ExampleScripts
#
# Usage:
#   git graph-dag HEAD~10.. | dot -Tpng | display -antialias
#
# Accepts any range or arguments that git rev-list accepts.

set -e

if [[ -z $@ ]] ; then
    echo -e "Usage: git graph-dag HEAD~10.. | dot -Tpng | display -antialias"
    exit 1
fi

echo "digraph lattice {"

# Draw the DAG and connect parents
git rev-list --parents "$@" |
    while read commit parents
    do
        for p in $parents
        do
            echo "n$commit -> n$p"
        done
    done

# Make pretty labels with the short sha1 and any refs
git rev-list --pretty=format:"%H %h %d" "$@" | awk '
BEGIN {
    command = "git fsck --unreachable --no-reflogs | cut -d\" \" -f3"
    while (command | getline unr) unreachable[unr] = 1
    close(command)
}

!/^commit/ {
    refs = ""
    for (i=3; i<=NF; i++) refs = refs " " $i

    unreachable[$1] == 1 ? isunr = 1 : isunr = 0

    printf "n%s [shape=Mrecord, style=%s, label=\"{%s%s}\"]\n", \
        $1, \
        isunr == 1 ? "dashed" : "filled", \
        isunr == 1 ? "*" $2 : $2, \
        refs == "" ? "" : refs
}'

echo "}"
