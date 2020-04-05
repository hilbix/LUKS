#!/bin/sh
#
# Getting started:
#	sudo -i
#	git clone https://github.com/hilbix/LUKS
# This checks it out under /root/LUKS/
#
# Decide:
#	KEY=/dev/disk/by-id/usb-THE-DEVICE-YOU-WANT-TO-USE
#	# The device shall be some (small) partition on your USB-key
#	LEN=512 # or any other key length you want
#	UUID=UUID of your encrypted drive, usually found in /etc/crypttab
#
# Create random key on $KEY - beware, it kills any FS if the device $KEY is not empty:
#	blkid $KEY | grep TYPE && echo BETTER STOP HERE, $KEY MIGHT BE USED
#	dd if=/dev/urandom of=$KEY bs=$LEN count=1
#
# Enable the Key for LUKS:
#	cryptsetup luksAddKey /dev/disk/by-uuid/$UUID <(dd if=$KEY bs=$LEN count=1)
# You can repeat that for other encrypted disks in /etc/crypttab
#
# Alter this script
#	below set KEY=$KEY and LEN=$LEN from above
#
# Add this script here (/root/LUKS/unlock-root.sh) to /etc/crypttab
#	vim /etc/crypttab
#		root_crypt UUID=$$$UUID$$$ none luks,keyscript=/root/LUKS/unlock-root.sh
# Just add the ",keyscript=/root/LUKS/unlock-root.sh" to all of the devices which should
# be automatically unlocked.  ($$$UUID$$$ usually is the UUID from above!)
#
# Update your ramdisk:
#	update-initramfs -u
#
# Try the reboot with the USB device.
# If this works, try reboot without USB device.
#
# If satisfied, you can remove all weak passphrases on $UUID.  (see: cryptsetup luksRemoveKey </dev/tty)
# Add a secure difficult one (cryptsetup luksAddKey), write it down and keep it somewhere safe.

KEY=/dev/disk/by-id/usb-Generic_STORAGE_DEVICE_000000009451-0:0-part1
LEN=512

out()
{
# GitHub disklikes stray CR in a text.  WTF?
echo -e "$*\\r" >&2
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
