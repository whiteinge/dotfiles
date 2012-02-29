Battery=$(acpi -b | grep "Battery" | sed -nr '/Battery/s/.*(\<[[:digit:]]+%).*/\1/p')
Thermal=$(acpi -t | grep "Thermal" | sed -nr "s/.*(\<[[:digit:]]+\.[[:digit:]]) degrees.*/\1°C/p" )
echo "<openbox_pipe_menu>"
echo "<item label=\"Battery: $Battery\"/>"
echo "<item label=\"Temperature: $Thermal\"/>"
echo "</openbox_pipe_menu>"
