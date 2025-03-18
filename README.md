# Get-LenovoLegionFirmware
Checks for available downloads from the Lenovo firmware web page

## Requirements

Written for Linux and requires PowerShell.  Currently supports firmware types `hhcnXXww` and `nscnXXww`. Tested on Lenovo Legion 5 and 7, though you system may vary.  Use the `CustomType` parameter if your firmware naming is different.

## Backup your system

Before updating firmware you should take a full backup of your system using a USB Lacie drive or similar.
In Ubuntu the backup software require.s your storage media to be able to hold two backups. Always get the
bigger backup drive when in doubt (i.e. from BEstBuy or similar).

## Firmware install requires Windows

The Lenovo Legion firmware updater provided by Lenovo requires Windows to install.
For example, you can dual-boot from Linux into a Windows partition to update the firmware.
Or pretend to install Windows and press SHIFT-F10 to get a terminal and navigate to the firmware.
If using that trick your USB drive will probably be `c:`. You can use `disk part` and `list volumes` to see.
To change directory type `c:` and hit enter. Then list with `dir` and install by typing the executable name (i.e. `nscn37ww.exe` for my Legion 7).
