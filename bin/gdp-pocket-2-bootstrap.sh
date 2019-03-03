#!/usr/bin/env sh
# Mostly thanks to https://github.com/joshskidmore/gpd-pocket-2-arch-guide

dnf install -y iwl7260-firmware

# Add Yubikey detection.
cat > /etc/udev/rules.d/70-u2f.rules <<'EOF'
ACTION!="add|change", GOTO="u2f_end"
# Yubico YubiKey
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", TAG+="uaccess", GROUP="plugdev", MODE="0660"
LABEL="u2f_end"
EOF

# Rotate the framebuffer by defualt.
sed -i -e '/GRUB_CMDLINE_LINUX/ s/quiet"$/fbcon=rotate:1 quiet"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Set up X server for the unique display.
cat > /etc/xorg.conf.d/20-intel.conf <<'EOF'
Section "Device"
	Identifier "Intel Graphics"
	Driver "intel"
	Option "AccelMethod" "sna"
	Option "TearFree" "true"
	Option "DRI" "3"
EndSection
EOF

cat > /etc/xorg.conf.d/30-display.conf <<'EOF'
Section "Monitor"
	Identifier "eDP1"
	Option "Rotate" "right"
EndSection
EOF

cat > /etc/xorg.conf.d/99-touchscreen.conf <<'EOF'
Section "InputClass"
	Identifier "calibration"
	MatchProduct "Goodix Capacitive TouchScreen"
	Option "TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
EndSection
EOF
