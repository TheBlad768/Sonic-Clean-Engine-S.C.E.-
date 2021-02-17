# msu-md
MegaCD driver for msu-like interfacing with CD hardware

-------------------------------------------- control registers
0xA12010 	command
0xA12011	argument
0xA1201F	command clock. increment it for command execution
0xA12020	mcd status. 0-ready, 1-init, 2-cmd busy

commands:
PLAY:		0x11 playback will be stopped in the end of track
 arguments:	decimal number of track (1-99)

PLAYLP:		0x12 play looped cdda track.
 arguments:	decimal number of track (1-99)

PAUSE:		0x13 pause playback
 arguments:	volume fading time. 1/75 of sec (75 equal to 1 sec) instant stop if 0

RESUME:		0x14 resume playback
 arguments:	no

VOL:		0x15 set cdda volume
 arguments:	volume 0-255

NOSEEK:		0x16 seek time emulation switch
  arguments:	0-enulation on(default state), 1-emultion off(no seek delays)

PLAYOF:		0x1A play cdda track and loop from specified sector offset
 arguments:	#1 = decimal number of track (1-99)
            	#2 = offset in sectors from the start of the track to apply when looping.

-------------------------------------------- usage
Include msu-drv.bin in your binary and call it as function for initialization.
Finction will return 0 if driver loaded succesfuly or 1 if MCD hardware not detected.
Driver ready for commands processing  when 0xA12020 sets to 0

--------------------------------------------content
msu-drv.bin	compilled driver binary
msu-md-drv	driver sources
msu-md-sample	driver usage sample

