# Duet Wifi Configuration!

This is the contents of my Duet Wifi SD card - it contains the latest non-beta firmware, 1.18.1, as well as the latest server, web control and wifi firmwares.
Firmware comes from here: https://github.com/dc42/RepRapFirmware/tree/dev/Release/Duet-WiFi/Stable
The rest of that GitHub is development et al - those are the latest stable bits.


## Firmwares
To update, copy this to your Duet Wifi SD card - as long as you have a working Duet Wifi firmware, it can update itself!

You need these four files in the /sys/ folder on your SD card:
DuetWebControl-1.15a.bin	Version 1.18	4 months ago
DuetWiFiFirmware-1.18.1.bin	Version 1.18.1	4 months ago
DuetWiFiServer-1.03-ch.bin	Version 1.16 release	9 months ago
iap4e.bin

Then you can run "M997 S0:1:2" to update all of them at once.
https://duet3d.com/wiki/Updating_more_than_one_firmware_at_a_time

## Config
Also in the /sys/ folder are the config files - here's a quick rundown.

All the configuration is done in gcode - so if you want to test a new config, simply send the gcode; if it works as you intended, you can then write it into the appropriate file.
Gcodes are documented here: http://reprap.org/wiki/Gcode
You MUST pay attention to the "supported by RepRapFirmware" box!

config.g - most of the parameters to set up the machine - steps per mm, extruder settings, endstops, etc.
homeall.g - what to do when G28 is called
home[xyz].g - what to do when G28 [XYZ] is called
pause.g - how to pause
resume.g - how to resume

I haven't looked at the rest of the .g files yet.

## Macros
I, uh, just copied these over.
