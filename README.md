Automatic unlocking LUKS root-dev on Linux boot using USB key
=============================================================

What Microsoft Bitlocker does out of the box is a bit difficult to archive with Linux:

Use an USB key to unlock your root filesystem


Rationale
=========

USB keys are cheap.  You can have for few EUR.  Even the smallest USB key does the job of unlocking your root device.

But why would you want to do this?  Just because of some paranoia?

Nope, it's quite easy.  If your harddrive breaks within your warranty period, what do you do?  Yes, you send it to the manufacturer.  This way the manufacturer gets hold on all of your data.  Right?

Most time you can trust your manufacturer.  But can you trust the postal service too?  Things get lost, and later are sold on eBay.  Perhaps this even is not for bad, because the manufacturer sends you a replacement drive, repairs the drive and sells it again - perhaps forgetting to erase the data.  Shit happens.

Encrypting a drive protects your data.  The device dies?  Everything already was saved encrypted, so you don't have to worry where your data goes.

However you cannot store the key onto the drive itself in that case.  You must separete the Key from the drive.

Any small USB stick is just perfect for this need.  Microsoft can do this with Bitlocker, but Debian apparently lacks this feature out of the box.  (At least, I did not find a standard way yet.)

Many modern devices come with a dummy memory card of only a few MB.  Don't throw them away, reuse.  All you need is just a cheap card reader and a free USB1(!) port.


Linux
=====

Just install your Linux as usual, but choose an encrypted root volume:

- One unencrypted Partition /boot
- One encrypted Partition as LVM PV
- Rest is done as LVM LVs, even SWAP

With UEFI and GRUB there might be a way to even encrypt /boot, but forget about this for now.  UEFI, today, is new and therefor difficult.

If you put SWAP into this encrypted LVM, too, you should even keep the hibernation support (in contrast if you just add encrypted SWAP with a random passphrase each time the system boots).

You can use a weak passphrase here, there is no problem to replace it with a stronger one later on.

Now make sure everything works.  The system, however, will ask for a LUKS passphrase each time it boots, which is an annoyance, especially if it is a server which shall automatically recover from a power outage.


Setup USB key
=============

Plug in the USB key and delete it's content.  Create a single small partition on it.  You can add more partitions, as those will not harm the small one.

- Look into /dev/disk/by-uuid/ and save the path to this partition in env-var KEY.
- Look into /etc/crypttab and write down the UUID of your encrypted PV.  Store this in env-var UUID.
- Decide for a length of the crypt key.  512 bytes (like in my example) should be plenty enough.  This is a 4096 bit key!

For the next steps look into the example script unlock-root.sh


Why a raw partition and not a filesystem?
-----------------------------------------

Right, the keyfile can be stored on a filesystem.  But this means, it needs to be mounted on boot time, and later possibly unmounted again.  It's cleaner to read the key directly from a partition than to extract it from a filesytem without any complex sideeffects.

The downside is, that you cannot use /dev/disk/by-uuid/ this way, as UDEV can only detect UUIDs on filesystems.  UDEV can be augmented to detect the key, but this all is difficult and not very generic.

The most generic way seems to be to use a raw partition from /dev/disk/by-id/ - but beware, there are somewhat braindead devices out there, you can see one on my example script.


Security
========

If somebody can get hold on the USB key, this setup is not very secure.  However the idea is not to protect against thieves or spies, the idea is to protect against the most common case:  Failing harddrives.

With this solution you can send it back to the manufacturer and don't worry about your data.


Sources used
============

Initially googling about a solution I found following reference:

- http://www.oxygenimpaired.com/debian-lenny-luks-encrypted-root-hidden-usb-keyfile

I borrowed some ideas from what I found there, but my motivation is completely different.


Differences
-----------

Hiding the key is not very important for me.  To be able to see and remember it, I put it into a (small) partition on the USB card.

As my Linux was already installed using LUKS, I did not need to change any global settings except the keyscript entry in /etc/crypttab.  So basically following steps were needed:

- Create a key USB key
- Add the key to LUKS
- Create the keyscript
- Add the keyscript to /etc/crypttab
- Re-create the initd
- Reboot

Even the USB modules are already available in initrd.  Perhaps I would even be able to reduce the keyscript down to a few lines.  But it does not hurt to have it a bit more elaborated.


Future wishes
=============

Here are some things I would want to see, but I lack the time to do it today:

- A "standard" keyscript which covers some more cases, like pulling the key from a TFTP server
- Put the configuration somewhere into /etc/default/
- Automatically prepare/update LUKS and the USB device(s)
- Allow more places where the keyfile can be stored, like within the UEFI BIOS
- Support more than one single USB devices
- Support a setup for N out of V USB devices (so 2 people are needed to cooperate to boot the system).
- Yubikey support and automatic Yubikey support (the key this way only needs to be plugged in, no manual interaction)
- TPM support (USB TPMs!)
- PIN protect USB devices
- An interactive script to prepare everything.
- Create a printable variant of the key, such that you can recover the key via scanning the paper or entering it manually.

