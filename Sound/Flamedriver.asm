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
; ---------------------------------------------------------------------------
; Subroutine to load the sound driver
; ---------------------------------------------------------------------------
SoundDriverLoad:
SndDrvInit:
	zHaltZ80
	zReleaseZ80Reset
	lea	Snd_Driver(pc),a0
	lea	(fZ80_RAM).l,a1
	jsr	(KosPlus_Decomp).w
	lea	(fZ80_RAM+z80_stack).l,a1
	moveq	#0,d1
	moveq	#bytesToXcnt(zTracksStart-z80_stack,8),d0

.loop:
	movep.l	d1,0(a1)
	movep.l	d1,1(a1)
	addq.w	#8,a1
	dbf	d0,.loop

	btst	#6,(fHW_Version).l
	beq.s	.not_pal
	move.b	#1,(fZ80_RAM+zPalFlag).l		; set PAL mode flag

.not_pal:
	zResetZ80
	zStartZ80
	rts
; End of function SndDrvInit
; ===========================================================================
; The driver itself
Snd_Driver:
	include "Sound/Z80Driver.a80"
Snd_Driver_End:
; ---------------------------------------------------------------------------
; DAC, music, and SFX banks.
	include "Sound/DACBanks.asm"
	include "Sound/SFXBanks.asm"
	include "Sound/MusicBanks.asm"
; ---------------------------------------------------------------------------
