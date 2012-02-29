#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
#-------------------------------------------------------------------------------

processes.py - version 7
by Vlad George

#-------------------------------------------------------------------------------

Description:
    This script pipes a process manipulation menu into the openbox menu.

Usage:
    Just place this script in ~/.config/openbox/scripts, make it executable; if you want you can enlist the processes
    which should not be shown in the unwanted_procs list below, then add following to your ~/.config/openbox/menu.xml:
    "<menu id="proc-menu" label="processes" execute="~/.config/openbox/scripts/processes.py" />...
    <menu id="root-menu" label="Openbox3">...<menu id="proc-menu" />...</menu>"
    and reconfigure openbox.
    To enable cpu usage display uncomment the lines marked with (***) (lines 106-108 and 146).
      Note: You need 'ps'.
    To enable cpulimit just uncomment the lines marked with (#*#) (lines 158-169).
      Note: You need 'cpulimit'. Get it from here: "http://cpulimit.sourceforge.net"

Changelog:
    20.02.07: 7th version - added "-z" flag to cpulimit; added ValueError handling for printXml; added --title flag
    04.12.07: 6th version - added cpulimit; to enable it just uncomment the lines marked with (#*#)
    18.11.07: 5th version - processes alphabetically sorted
    22.10.07: 4th version - totally removed SleepAVG from script. for kernels < 2.6.20 please use earlier versions.
                            simplified cpu usage command.
    07.07.07: 3rd version - added cpu usage;
                            since SleepAVG was removed from /proc (2.6.20), it will be only displayed depending on running kernel version
    17.02.07: 2nd version - shortened procData

#-------------------------------------------------------------------------------

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
http://www.fsf.org/

"""

#-------------------------------------------------------------------------------             
#                             User set variables
#-------------------------------------------------------------------------------             

##  processes (e.g. daemons, bash, this script, etc) you do not want to be shown in the process manipulation menu:
##  !!! don´t forget quotes !!!

##  unwanted_procs = ["processes.py","ssh-agent","gconfd-2","dbus-daemon","dbus-launch","kded","dcopserver","..."]
unwanted_procs = ["processes.py","sh","bash","netstat","ssh-agent","gconfd-2","gnome-pty-helpe","dbus-daemon","dbus-launch",\
                  "visibility","pypanel","knotify","kdeinit","klauncher","kded","dcopserver","kio_file"]

##  if you want a title (separator) for the processes menu you can set it here; to show the title use the "--title" flag (/path/to/processes.py --title)
processes_menu_title = "processes"


#-------------------------------------------------------------------------------
#                                   Script
#-------------------------------------------------------------------------------


def _procName(pid):
    """ pid -> processname """
    try:
        return file(os.path.join('/proc', str(pid), 'status'), 'r').readline().split()[1]
    except IOError:
        return None


def _procData(pid):
    """ pid -> info_list = [State, VmSize, VmLck, VmRSS, VmLib, priority(nice), command, cpu usage] """
    info_list = list()

    ##  from /proc/<pid>/status get State, VmSize, VmLck, VmRSS, VmLib
    status_file = file(os.path.join("/proc", str(pid), "status"), 'r')
    status = status_file.readlines()
    status_file.close()
    [info_list.append(status[i].split(":")[1].lstrip().rstrip("\n")) for i in (1,11,12,14,18)]

    ##  from /proc/<pid>/stat get priority(nicelevel)
    priority_file = file(os.path.join('/proc', str(pid), 'stat'), 'r')
    priority = priority_file.read()
    priority_file.close()
    info_list.append(priority.split()[18])

    ##  from /proc/<pid>/cmdline get command
    cmdline_file = file(os.path.join("/proc", str(pid),"cmdline"),'r')
    cmdline = cmdline_file.read()
    cmdline_file.close()
    info_list.append(" ".join(cmdline.split("\x00")[:-1]))

    ##  from "ps --pid %s -o pcpu=" get cpu usage for pid
    ##  (***) comment out following three lines to disable cpu usage display
    #ps_cpu_for_pid = 'ps --pid %s -o pcpu=' % (pid)
    #ps_cmd = os.popen(ps_cpu_for_pid).readline()
    #info_list.append(ps_cmd)
    ##  (***)
    return info_list


def userPidFilter():
    """ fiters pids from /proc/<pid>/ for user who owns script excluding the unwanted_procs ids """
    uid = os.stat(sys.argv[0])[4]
    uid_pids = list()
    for pid in os.listdir("/proc"):
        if os.path.isdir(os.path.join("/proc", pid)):
             try:
                if os.stat(os.path.join("/proc", pid))[4] == uid :
                    uid_pids.append(int(pid))
             except ValueError:
                pass

    ##  sort pids according to process names 
    pid_proc_list = list()
    [pid_proc_list.append((i, _procName(i))) for i in uid_pids]

    def removeProcsFromList(pid):
        process = _procName(pid)
        if process in unwanted_procs:
            pid_proc_list.remove((pid, process))
    map(removeProcsFromList, uid_pids)

    pid_proc_list.sort(key = lambda t:t[1].lower())
    return [pid_proc_list[i][0] for i in xrange(len(pid_proc_list))]


def printXml(pid):
    """ xml output for each pid
    _procData(pid)=[[0]-State, [1]-VmSize, [2]-VmLck, [3]-VmRSS, [4]-VmLib, [5]-priority(nice), [6]-command, [(***)optional: [7]-cpu usage]] """

    proc_info = _procData(pid)

##  (***) uncomment following line to enable cpu usage display:
    #print '<item label="cpu usage: %s' % (proc_info[7]) + ' %"><action name="execute"><command>true</command></action></item>'
##  (***)
    print '<menu id="%s-menu-memory" label="memory: %s MB">' % (pid, int(proc_info[1].split()[0])/1024)
    print '<item label="Ram: %s"><action name="Execute"><command>true</command></action></item>' % (proc_info[3])
    print '<item label="Lib: %s"><action name="Execute"><command>true</command></action></item>' % (proc_info[4])
    print '<item label="Lock: %s"><action name="Execute"><command>true</command></action></item>' % (proc_info[2])
    print '<item label="Total: %s"><action name="Execute"><command>true</command></action></item>' % (proc_info[1])
    print '</menu>'

    print '<separator />'

##  (#*#) uncomment following lines to enable cpulimit:
    #print '<menu id="%s-menu-cpulimit" label="cpulimit">' % (pid)
    #print '<item label=" 10 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 10</command></action></item>' % (pid)
    #print '<item label=" 20 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 20</command></action></item>' % (pid)
    #print '<item label=" 30 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 30</command></action></item>' % (pid)
    #print '<item label=" 40 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 40</command></action></item>' % (pid)
    #print '<item label=" 50 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 50</command></action></item>' % (pid)
    #print '<item label=" 60 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 60</command></action></item>' % (pid)
    #print '<item label=" 70 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 70</command></action></item>' % (pid)
    #print '<item label=" 80 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 80</command></action></item>' % (pid)
    #print '<item label=" 90 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 90</command></action></item>' % (pid)
    #print '<item label="100 &#37;"><action name="Execute"><command>cpulimit -p %s -z -l 100</command></action></item>' % (pid)
    #print '</menu>'
##  (#*#)

    print '<menu id="%s-menu-priority" label="priority (%s)">' % (pid, proc_info[5])
    print '<item label="-10 (fast)"><action name="Execute"><command>renice -10 %s</command></action></item>' % (pid)
    print '<item label="-5"><action name="Execute"><command>renice -5 %s</command></action></item>' % (pid)
    print '<item label="0 (base)"><action name="Execute"><command>renice 0 %s</command></action></item>' % (pid)
    print '<item label="5"><action name="Execute"><command>renice 5 %s</command></action></item>' % (pid)
    print '<item label="10"><action name="Execute"><command>renice 10 %s</command></action></item>' % (pid)
    print '<item label="15"><action name="Execute"><command>renice 15 %s</command></action></item>' % (pid)
    print '<item label="19 (idle)"><action name="Execute"><command>renice 19 %s</command></action></item>' % (pid)
    print '</menu>'

    print '<menu id="%s-menu-state" label="%s">' % (pid, proc_info[0])
    print '<item label="stop"><action name="Execute"><command>kill -SIGSTOP %s</command></action></item>' % (pid)
    print '<item label="continue"><action name="Execute"><command>kill -SIGCONT %s</command></action></item>' % (pid)
    print '</menu>'

    print '<menu id="%s-menu-stop" label="stop signals">' % (pid)
    print '<item label="exit"><action name="Execute"><command>kill -TERM %s</command></action></item>' % (pid)
    print '<item label="hangup"><action name="Execute"><command>kill -HUP %s</command></action></item>' % (pid)
    print '<item label="interrupt"><action name="Execute"><command>kill -INT %s</command></action></item>' % (pid)
    print '<item label="kill"><action name="Execute"><command>kill -KILL %s</command></action></item>' % (pid)
    print '</menu>'
    print '<separator />'

    print '<menu id="%s-menu-command" label="command">' % (pid)
    print '<item label="%s"><action name="Execute"><command>true</command></action></item>' % (proc_info[6])
    print '<separator />'
    print '<item label="spawn new"><action name="Execute"><command>%s</command></action></item>' % (proc_info[6])
    print '</menu>'


def generateMenu(pid):
    """ generate main menu """
    print '<menu id="%s-menu" label="%s" execute="%s --pid %s"/>' % (pid, _procName(pid), sys.argv[0], pid)

#-------------------------------------------------------------------------------             
#                                    Main
#-------------------------------------------------------------------------------             

import os, sys

#-------------------------#
if __name__ == "__main__" :
#-------------------------#
    print '<?xml version="1.0" encoding="UTF-8"?>'
    print '<openbox_pipe_menu>'
    args = sys.argv[1:]
    if ('--pid' in args):
        try:
            printXml(int(sys.argv[2]))
        except ValueError and IOError:
            pass
    else:
        if ('--title' in args):
            print '<separator label="%s" />' % (processes_menu_title)
        else:
            pass
        map(generateMenu, userPidFilter())
    print '</openbox_pipe_menu>'

# vim: set ft=python nu ts=4 sw=4 :
