#!/bin/sh

if [ $# == 0 ]; then
    echo "Usage:"
    echo "$(basename $0) BAT1 ADP1"
    exit 1;
fi

battery_id=$1
ac_adapter_id=$2
critical_level=10

if [ "$(grep -o off /proc/acpi/ac_adapter/$ac_adapter_id/state)" == "off" ]; then
    battery_max=`awk ' NR==3 {print $4}' /proc/acpi/battery/$battery_id/info`
    battery_current=`awk ' NR==5 {print $3}' /proc/acpi/battery/$battery_id/state`
    battery_level=$((100*$battery_current/$battery_max))

    if [ $battery_level -le $critical_level ]; then
        xmessage "Low Battery Warning! ${battery_level}% remains."
    fi
fi
