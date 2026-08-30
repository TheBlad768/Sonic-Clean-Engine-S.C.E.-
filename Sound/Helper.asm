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

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
QueueSound1:
PlayMusic:
Play_Music:
	zStopZ80
	move.b	d0,(fZ80_RAM+zMusicNumber).l
	zStartZ80
	rts
; End of function PlayMusic
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
PlaySoundLocal:
Play_SFX_Local:
	tst.b	render_flags(a0)
	bpl.s	PlaySound.done

QueueSound2:
PlaySoundStereo:
Play_SFX:
PlaySound:
	zStopZ80
	cmp.b	(fZ80_RAM+zSFXNumber0).l,d0
	beq.s	.startz80
	tst.b	(fZ80_RAM+zSFXNumber0).l
	bne.s	.slot1
	move.b	d0,(fZ80_RAM+zSFXNumber0).l
	zStartZ80
	rts
; ---------------------------------------------------------------------------
.slot1:
	move.b	d0,(fZ80_RAM+zSFXNumber1).l

.startz80:
	zStartZ80

.done:
	rts
; End of function PlaySound
; ===========================================================================

; =============== S U B R O U T I N E =======================================
; Changes music tempo. This is usually either 0 (normal tempo) or 8 (speed
; shoes tempo), but Blue Spheres uses more values.
;
; Input: d0 = new tempo value
; Output: none
Change_Music_Tempo:
	zStopZ80
	move.b	d0,(fZ80_RAM+zTempoSpeedup).l
	zStartZ80
	rts
; End of function Change_Music_Tempo
; ===========================================================================

; =============== S U B R O U T I N E =======================================
Play_Sample:
	zStopZ80
	move.b  d0,(fZ80_RAM+zDACIndex).l
	zStartZ80
	rts
; End of function Play_Sample
; ===========================================================================

; =============== S U B R O U T I N E =======================================
Pause_Music:
	zStopZ80
	move.b	#1,(fZ80_RAM+zPauseFlag).l
	zStartZ80
	rts
; End of function Pause_Music
; ===========================================================================

; =============== S U B R O U T I N E =======================================
Unpause_Music:
	zStopZ80
	move.b	#0,(fZ80_RAM+zPauseFlag).l
	zStartZ80
	rts
; End of function Unpause_Music
; ===========================================================================

; =============== S U B R O U T I N E =======================================
; Reads the music/game communication byte (see smpsSetCommByte). Its meaning
; is defined by the song data and the game code using it, not the driver.
; Resets the byte to 0 after reading it, so that the game code can detect when
; a new value has been set.
; This should be called at most once per frame, preferably after the Z80 sound
; driver has finished its V-Int handler.
;
; Output: d0.b = communication byte
Read_Music_Comm_Byte:
	zStopZ80
	move.b	(fZ80_RAM+zCommByte).l,d0
	move.b	#0,(fZ80_RAM+zCommByte).l
	zStartZ80
	rts
; End of function Read_Music_Comm_Byte
; ===========================================================================
