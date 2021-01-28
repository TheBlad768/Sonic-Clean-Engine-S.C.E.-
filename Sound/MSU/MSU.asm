; ---------------------------------------------------------------------------
; MegaCD driver for msu-like interfacing with CD hardware by Krikzz
; Modification by Ekeeke
; Thanks to Vladikcomper for the integration examples
; https://github.com/krikzz/msu-md
; https://github.com/ekeeke/msu-md
; ---------------------------------------------------------------------------

MCD_Command			= $A12010		; Command sent to Mega CD	; .b
MCD_Argument		 	= $A12011		; Argument sent to Mega CD	; .b
MCD_Argument2		 	= $A12012		; Argument2 sent to Mega CD	; .l
MCD_Command_Clock	= $A1201F		; Command clock. increment it for command execution	; .b
MCD_Status       			= $A12020		; MCD status. 0-ready, 1-init, 2-cmd busy	; .b

_MCD_PlayTrack_Once	= $11
_MCD_PlayTrack			= $12
_MCD_PauseTrack		= $13
_MCD_UnpauseTrack		= $14
_MCD_SetVolume		= $15
_MCD_PlayTrack_Loop	= $1A
; ---------------------------------------------------------------------------

Init_MSU_Driver:		binclude "Sound/MSU/MSU.bin"
	even