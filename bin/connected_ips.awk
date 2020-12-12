#!/usr/bin/awk -f
# Output IP addresses and ports for machines connected to the local machine
#
# Usage:
# ./connected_ips.awk /proc/net/tcp

function fromhex(s){
    # Amazing voodoo from William.
    # http://compgroups.net/comp.lang.awk/reading-hexadecimal-numbers/33952
    return index("0123456789abcdef", tolower(substr(s, length(s)))) \
        -1 + (sub(/.$/, "" ,s) ? 16 * fromhex(s) : 0)
}

# Skip the header line and loopback addresses.
NR != 1 && $3 != "00000000:0000" {
    split($2, lconn, ":"); port = fromhex(lconn[2])
    split($3, rconn, ":"); ip = rconn[1]

    addr = sprintf("%d.%d.%d.%d", \
        fromhex(substr(ip, 7, 2)),
        fromhex(substr(ip, 5, 2)),
        fromhex(substr(ip, 3, 2)),
        fromhex(substr(ip, 0, 2)))

    print port, addr
}
