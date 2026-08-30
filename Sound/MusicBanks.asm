; ===========================================================================
; ║                                                                         ║
; ║                             SONIC&K SOUND DRIVER                        ║
; ║                         Modified SMPS Z80 Type 2 DAC                    ║
; ║                                                                         ║
; ===========================================================================
; Disassembled by MarkeyJester
; Routines, pointers and stuff by Linncaki
; Thoroughly commented and improved (including optional bugfixes) by Flamewing
; ===========================================================================
; Permission to use, copy, modify, and/or distribute this software for any
; purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
; OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
; ===========================================================================
; Music Banks
; ===========================================================================
; Music Bank 1
; ---------------------------------------------------------------------------
Mus_Bank1_Start:	startBank
	Music_Master_Table
z80_UniVoiceBank:	    include "Sound/UniBank.asm"
MusData_DEZ1:			include "Sound/Music/Mus - DEZ1.asm"
MusData_MidBoss:		include "Sound/Music/Mus - Miniboss.asm"
MusData_ZoneBoss:		include "Sound/Music/Mus - Zone Boss.asm"
MusData_Invincible:		include "Sound/Music/Mus - Invincible.asm"
MusData_GotThrough:		include "Sound/Music/Mus - Sonic Got Through.asm"
MusData_Drowning:		include "Sound/Music/Mus - Drowning.asm"

	finishBank
; ---------------------------------------------------------------------------
