# Get-LenovoLegionFirmware
Checks for available downloads from the Lenovo firmware web page

## Requirements

Written for Linux intially but now support Windows as well.  This requires PowerShell.

Initially only supported firmware types `hhcnXXww` and `nscnXXww`, but now we support many of the latest Legion 5, 6 and  7 models.
Thanks to Reddit user Masayoshii for the list of models!

Use the `CustomType` parameter if your firmware naming is different than those provided by the FirmwareType parameter.

## About the script

The script only downloads the bits from Lenovo. It is up to you to save the firmware to USB and go install it.
There is no special handling to make a bootable image. You simply place the exe on a USB drive and boot into Windows to install.

## Backup your system

Before updating firmware you should take a full backup of your system using a USB Lacie drive or similar.
In Ubuntu the backup software requires your storage media to be able to hold two backups. Always get the
bigger backup drive when in doubt (i.e. from BestBuy or similar).

## Firmware install requires Windows

The Lenovo Legion firmware updater provided by Lenovo requires Windows to install.
For example, you can dual-boot from Linux into a Windows partition to update the firmware.
Or pretend to install Windows and press SHIFT-F10 to get a terminal and navigate to the firmware.
If using that trick your USB drive will probably be `c:`. You can use `disk part` and `list volumes` to see.
To change directory type `c:` and hit enter. Then list with `dir` and install by typing the executable name (i.e. `nscn37ww.exe` for my Legion 7).
