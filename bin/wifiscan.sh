#!/bin/sh

iwlist scan 2> /dev/null | awk '
# skip first line
NR==1{ next }
{
    # left-justify
    sub(/^[ \t]+/, "");
    # seperate records with newlines
    sub(/^Cell.*/,"");
    print;
}
' | awk '
# Trim leading labels
!/^Quality/{ gsub(/^.*:/, "") };
/^Quality/{
    gsub(/^.*=/, "");
    gsub(/  .*$/, "")
};
{ print }
' | awk '
BEGIN {
    RS=""; FS="\n"; ORS="\n"; OFS="\t"
    print "ESSID", "Mode", "Channel", "Quality", "Encryption";
}
{
    if ($7 ~ /WPA/) {
        print $1, $2, $3, $5, $7;
    } else {
        print $1, $2, $3, $5, $6;
    }
}
' | column -tx
