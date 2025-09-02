; ---------------------------------------------------------------------------
; play a sound effect or music
; input: track, terminate routine, branch or jump, move operand size
; ---------------------------------------------------------------------------

music macro track,terminate,byte
    if ("byte"="0") || ("byte"="")
	moveq	#signextendB(track),d0
    else
	move.w	#(track),d0
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Play_Music).w
    else
	jmp	(Play_Music).w
    endif
    endm

sfx macro track,terminate,byte
    if ("byte"="0") || ("byte"="")
	moveq	#signextendB(track),d0
    else
	move.w	#(track),d0
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Play_SFX).w
    else
	jmp	(Play_SFX).w
    endif
    endm

sfxcont macro track,wait,terminate,byte
    if ("byte"="0") || ("byte"="")
	moveq	#signextendB(track),d0
    else
	move.w	#(track),d0
    endif
	moveq	#signextendB(wait),d1
    if ("terminate"="0") || ("terminate"="")
	jsr	(Play_SFX_Continuous).w
    else
	jmp	(Play_SFX_Continuous).w
    endif
    endm

tempo macro speed,terminate,byte
    if ("byte"="0") || ("byte"="")
	moveq	#signextendB(speed),d0
    else
	move.w	#(speed),d0
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Change_Music_Tempo).w
    else
	jmp	(Change_Music_Tempo).w
    endif
    endm

sample macro id,terminate,byte
    if ("byte"="0") || ("byte"="")
	moveq	#signextendB(id),d0
    else
	move.w	#(id),d0
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Play_Sample).w
    else
	jmp	(Play_Sample).w
    endif
    endm

; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------

SMPS_stopZ80 macro
	SMPS_stopZ80a
	SMPS_waitZ80
    endm

SMPS_stopZ80a macro
	move.w	#$100,(Z80_bus_request).l
    endm

; ---------------------------------------------------------------------------
; wait for Z80 to stop
; ---------------------------------------------------------------------------

SMPS_waitZ80 macro

.wait
	btst	#0,(Z80_bus_request).l
	bne.s	.wait
    endm

; ---------------------------------------------------------------------------
; reset the Z80
; ---------------------------------------------------------------------------

SMPS_resetZ80 macro
	move.w	#$100,(Z80_reset).l
    endm

SMPS_resetZ80a macro
	move.w	#0,(Z80_reset).l
    endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------

SMPS_startZ80 macro
	move.w	#0,(Z80_bus_request).l		; start the Z80
    endm

; ---------------------------------------------------------------------------
; Pause music
; ---------------------------------------------------------------------------

SMPS_PauseMusic macro
	SMPS_stopZ80
	move.b	#1,(Z80_RAM+zPauseFlag).l	; pause the music
	SMPS_startZ80
    endm

; ---------------------------------------------------------------------------
; Unpause music
; ---------------------------------------------------------------------------

SMPS_UnpauseMusic macro
	SMPS_stopZ80
	move.b	#$80,(Z80_RAM+zPauseFlag).l	; unpause music
	SMPS_startZ80
    endm
