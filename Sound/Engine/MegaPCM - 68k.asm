; ===============================================================
; Mega PCM Driver Include File
; (c) 2012, Vladikcomper
; http://forums.sonicretro.org/index.php?showtopic=29057
; ===============================================================

; ---------------------------------------------------------------
; Driver's code (Kosinski-compressed)
; ---------------------------------------------------------------

MegaPCM:
	save
	include	"Sound/Engine/MegaPCM - Z80.asm"
	restore
	padding off
	!org (MegaPCM+Size_of_Mega_PCM_guess)

; ---------------------------------------------------------------
; Macros
; ---------------------------------------------------------------

IncludeDAC macro Name,Extension,Path
Name:		label *
    if ("Path"<>"")
	if ("Extension"="WAV")
		binclude "Sound/DAC/Path/Name.Extension",$3A
	else
		binclude "Sound/DAC/Path/Name.Extension"
	endif
    else
	if ("Extension"="WAV")
		binclude "Sound/DAC/Name.Extension",$3A
	else
		binclude "Sound/DAC/Name.Extension"
	endif
    endif
Name_End:	label *
	endm

; ---------------------------------------------------------------
; DAC Samples Files
; ---------------------------------------------------------------

	include "Sound/DAC Samples.asm"
