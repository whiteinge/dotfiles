#!/usr/bin/env zsh
# Use vimdiff to quickly go through Git merge conflicts.
# 
# Save your changes to the LOCAL file. MERGED will be updated if
# vimdiff exits cleanly. Use :cq to abort.
# 
# Put the following in your ~/.gitconfig
#
# [mergetool "vimdiffconflicts"]
#     cmd = unmerge.sh $BASE $LOCAL $REMOTE $MERGED
#     trustExitCode = true

if [[ -z $@ || $# != "5" ]] ; then
    echo -e "Usage: $0 \$BASE \$LOCAL \$REMOTE \$MERGED"
    exit 1
fi

cmd=$1
BASE=$2
LOCAL=$3
REMOTE=$4
MERGED=$5

sed -e '/<<<<<<</,/=======/d' -e '/>>>>>>>/d' $MERGED > $LOCAL
sed -e '/=======/,/>>>>>>>/d' -e '/<<<<<<</d' $MERGED > $REMOTE

$cmd -f -d $BASE $LOCAL $REMOTE \
    -c ':diffoff' -c ':set scrollbind' -c 'wincmd T' -c ':tabfirst'

EC=$?

# Overwrite $MERGED
if [[ $EC == "0" ]] ; then
    cat $LOCAL > $MERGED
else
    # Delete temp files
    rm $BASE $LOCAL $REMOTE
fi

exit $EC
