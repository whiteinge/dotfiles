#!/bin/bash
# http://stackoverflow.com/questions/1537956/bash-limit-the-number-of-concurrent-jobs

# The following script shows a way to do this with functions. You can either
# put the bgxupdate and bgxlimit functions in your script or have them in a
# separate file which is sourced from your script with:

# . /path/to/bgx.sh

# It has the advantage that you can maintain multiple groups of processes
# independently (you can run, for example, one group with a limit of 10 and
# another totally separate group with a limit of 3).

# It used the bash built-in, jobs, to get a list of sub-processes but maintains
# them in individual variables. In the loop at the bottom, you can see how to
# call the bgxlimit function:

# 1. set up an empty group variable.
# 2. transfer that to bgxgrp.
# 3. call bgxlimit with the limit and command you want to run.
# 4. transfer the new group back to your group variable.
# 5. Of course, if you only have one group, just use bgxgrp directly rather
#    than transferring in and out.

###

# bgxupdate - update active processes in a group.
#   Works by transferring each process to new group
#   if it is still active.
# in:  bgxgrp - current group of processes.
# out: bgxgrp - new group of processes.
# out: bgxcount - number of processes in new group.

bgxupdate() {
    bgxoldgrp=${bgxgrp}
    bgxgrp=""
    ((bgxcount = 0))
    bgxjobs=" $(jobs -pr | tr '\n' ' ')"
    for bgxpid in ${bgxoldgrp} ; do
        echo "${bgxjobs}" | grep " ${bgxpid} " >/dev/null 2>&1
        if [[ $? -eq 0 ]] ; then
            bgxgrp="${bgxgrp} ${bgxpid}"
            ((bgxcount = bgxcount + 1))
        fi
    done
}

# bgxlimit - start a sub-process with a limit.

#   Loops, calling bgxupdate until there is a free
#   slot to run another sub-process. Then runs it
#   an updates the process group.
# in:  $1     - the limit on processes.
# in:  $2+    - the command to run for new process.
# in:  bgxgrp - the current group of processes.
# out: bgxgrp - new group of processes

bgxlimit() {
    bgxmax=$1 ; shift
    bgxupdate
    while [[ ${bgxcount} -ge ${bgxmax} ]] ; do
        sleep 1
        bgxupdate
    done
    if [[ "$1" != "-" ]] ; then
        $* &
        bgxgrp="${bgxgrp} $!"
    fi
}

# Test program, create group and run 6 sleeps with
#   limit of 3.

# group1=""
# echo 0 $(date | awk '{print $4}') '[' ${group1} ']'
# echo
# for i in 1 2 3 4 5 6 ; do
    # bgxgrp=${group1} ; bgxlimit 3 sleep ${i}0 ; group1=${bgxgrp}
    # echo ${i} $(date | awk '{print $4}') '[' ${group1} ']'
# done

# Wait until all others are finished.

# echo
# bgxgrp=${group1} ; bgxupdate ; group1=${bgxgrp}
# while [[ ${bgxcount} -ne 0 ]] ; do
    # oldcount=${bgxcount}
    # while [[ ${oldcount} -eq ${bgxcount} ]] ; do
        # sleep 1
        # bgxgrp=${group1} ; bgxupdate ; group1=${bgxgrp}
    # done
    # echo 9 $(date | awk '{print $4}') '[' ${group1} ']'
# done
