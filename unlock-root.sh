#!/bin/sh
#
# Getting started:
#	root
#	git clone https://github.com/hilbix/LUKS
# This checks it out under /root/LUKS/
#
# Decide:
#	KEY=/dev/disk/by-id/usb-THE-DEVICE-YOU-WANT-TO-USE
#	# The device shall be some (small) partition on your USB-key
#	LEN=512 # or any other key length you want
#	UUID=UUID of your encrypted drive, usually from /etc/crypttab
#
# Create random key on $KEY - beware, it kills any FS if the device is not empty:
#	dd if=/dev/urandom of=$KEY bs=$LEN count=1
#
# Enable the Key for LUKS:
#	cryptsetup luksAddKey /dev/disk/by-uuid/$UUID <(dd if=$KEY bs=$LEN count=1)
#
# Alter this script
#	below set KEY=$KEY and LEN=$LEN from above
#
# Add this script to /etc/crypttab
#	vim /etc/crypttab
#		root_crypt UUID=$UUID none luks,keyscript=/root/LUKS/unlock-root.sh
#
# Update your ramdisk:
#	update-initramfs -u
#
# Try the reboot with the USB device.
# If this works, try reboot without USB device.
#
# If satisfied, you can remove all weak passphrases on $UUID.
# Add a secure difficult one, write it down in case the USB key breaks, put it into your bank safe.

KEY=/dev/disk/by-id/usb-Generic_STORAGE_DEVICE_000000009451-0:0-part1
LEN=512

out()
{
echo "$*" >&2
}

out "Loading USB"
modprobe usb_storage
out "Waiting for USB to come up"
sleep 10
if [ -b "$KEY" ]
then
	out "Unlocking LUKS with $KEY"
	exec dd if="$KEY" bs="$LEN" count=1 2>/dev/null
fi

out "Failed to detect $KEY"
exec /lib/cryptsetup/askpass "LUKS password: "
