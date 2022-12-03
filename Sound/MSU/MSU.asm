; ---------------------------------------------------------------------------
; MegaCD driver for msu-like interfacing with CD hardware by Krikzz
; Modification by Ekeeke
; Thanks to Vladikcomper for the integration examples
; https://github.com/krikzz/msu-md
; https://github.com/ekeeke/msu-md
; Doesn't work on Kega Fusion(DMA bug). Use RetroArch or real hardware
; ---------------------------------------------------------------------------

MCD_Command			= $A12010		; Command sent to Mega CD	; .b
MCD_Argument		 	= $A12011		; Argument sent to Mega CD	; .b
MCD_Argument2		 	= $A12012		; Argument2 sent to Mega CD	; .l
MCD_Command_Clock	= $A1201F		; Command clock. increment it for command execution	; .b
MCD_Status       			= $A12020		; MCD status. 0-ready, 1-init, 2-cmd busy	; .b

_MCD_PlayTrack_Once	= $11			; Playback will be stopped in the end of track. Decimal number of track (1-99)
_MCD_PlayTrack			= $12			; Play looped cdda track. Decimal number of track (1-99)
_MCD_PauseTrack		= $13			; Pause playback. Volume fading time. 1/75 of sec (75 equal to 1 sec) instant stop if 0
_MCD_UnPauseTrack		= $14			; Resume playback
_MCD_SetVolume		= $15			; Set cdda volume. Volume 0-255
_MCD_NoSeek			= $16			; Seek time emulation switch. 0-enulation on(default state), 1-emultion off(no seek delays)
_MCD_PlayTrack_Loop	= $1A			; #1 = decimal number of track (1-99). #2 = offset in sectors from the start of the track to apply when looping
; ---------------------------------------------------------------------------

Init_MSU_Driver:		binclude "Sound/MSU/MSU.bin"
	even