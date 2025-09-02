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

; extended music
emusic macro track,terminate
	move.w	#(track),d0
    if ("terminate"="0") || ("terminate"="")
	jsr	(SMPS_QueueSound1_Extended).w
    else
	jmp	(SMPS_QueueSound1_Extended).w
    endif
    endm

; extended sfx
esfx macro track,terminate
	move.w	#(track),d0
    if ("terminate"="0") || ("terminate"="")
	jsr	(SMPS_QueueSound2_Extended).w
    else
	jmp	(SMPS_QueueSound2_Extended).w
    endif
    endm

sample macro id,terminate,byte
    if ("byte"="0") || ("byte"="")
	moveq	#signextendB(id),d0
    else
	move.w	#(id),d0
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(SMPS_PlayDACSample).w
    else
	jmp	(SMPS_PlayDACSample).w
    endif
    endm

; ---------------------------------------------------------------------------
; Music macros and constants
; ---------------------------------------------------------------------------
SMPS_MUSIC_METADATA macro address,fasttempo,flags
	dc.l	((fasttempo)<<24)|(((address)|(flags))&$FFFFFF)
    endm

SMPS_MUSIC_METADATA_FORCE_PAL_SPEED = $00000001				; forces song to play at PAL speeds on PAL consoles for synchronisation (used by drowning theme)

; ---------------------------------------------------------------------------
; SFX macros and constants
; ---------------------------------------------------------------------------
SMPS_SFX_METADATA macro address,priority,flags
	dc.l	((priority)<<24)|((address)&$FFFFFF)
    endm

; ---------------------------------------------------------------------------
; Special SFX macros and constants
; ---------------------------------------------------------------------------
SMPS_SPECIAL_SFX_METADATA macro address,flags
	dc.l	address
    endm

; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------
SMPS_stopZ80 macro
	move.w	#$100,(SMPS_z80_bus_request).l
	SMPS_delayYM
    endm

; ---------------------------------------------------------------------------
; wait for Z80 to stop
; ---------------------------------------------------------------------------
SMPS_waitZ80 macro
.wait:	btst	#0,(SMPS_z80_bus_request).l
	bne.s	.wait
    endm

; ---------------------------------------------------------------------------
; reset the Z80
; ---------------------------------------------------------------------------
SMPS_resetZ80 macro
	move.w	#$100,(SMPS_z80_reset).l
    endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------
SMPS_startZ80 macro
	move.w	#0,(SMPS_z80_bus_request).l
    endm

; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------
SMPS_stopZ80_safe macro
	disableIntsSave	; mask off interrupts
	SMPS_stopZ80
	SMPS_waitZ80
    endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------
SMPS_startZ80_safe macro
	SMPS_startZ80
	enableIntsSave
    endm

; ---------------------------------------------------------------------------
; Macros to wait for when the YM2612 isn't busy.
;
; Might as well document this a little:
; When you write to the YM2612's data ports, it takes 2 YM cycles
; for the BUSY flag to set itself. A YM-cycle takes 6 cycles on the
; 68k, so we wait 12 cycles before checking the flag.
;
; The BUSY flag is seemingly hardcoded to last 32 YM cycles, or 192
; 68k cycles, so theoretically I could just burn a bunch of cycles
; here with ineffective instructions, but I think checking the flag
; would let me be a bit more precise (I don't know exactly *when* in
; the 12-cycle instruction the YM2612 is actually written to).
; ---------------------------------------------------------------------------
SMPS_delayYM macro target
	nop		; 4(1/0)
	nop		; 4(1/0)
	nop		; 4(1/0)
    endm

SMPS_waitYM macro target
.loop:	tst.b	(a0)	; 8(2/0)
	bmi.s	.loop	; 10(2/0) | 8(1/0)
    endm

; ---------------------------------------------------------------------------
; Pauses the driver: music, SFX, everything
; ---------------------------------------------------------------------------
SMPS_PauseMusic macro
	move.b	#1,(Clone_Driver_RAM+SMPS_RAM.f_pause).w
    endm

; ---------------------------------------------------------------------------
; Unpauses the driver
; ---------------------------------------------------------------------------
SMPS_UnpauseMusic macro
	move.b	#$80,(Clone_Driver_RAM+SMPS_RAM.f_pause).w
    endm

; ---------------------------------------------------------------------------
; update sound driver
; ---------------------------------------------------------------------------
SMPS_UpdateSoundDriver macro
	move	#$2300,sr						; enable interrupts (we can accept horizontal interrupts from now on)
	bset	#0,(Clone_Driver_RAM+SMPS_RAM.SMPS_running_flag).w	; set "SMPS running flag"
	bne.s	.skip							; if it was set already, don't call another instance of SMPS
	jsr	(SMPS_UpdateDriver).l					; update Sonic 2 Clone Driver v2
	clr.b	(Clone_Driver_RAM+SMPS_RAM.SMPS_running_flag).w		; reset "SMPS running flag"
.skip:
    endm

; ---------------------------------------------------------------------------
; pad RAM to even address
; ---------------------------------------------------------------------------
SMPS_RAM_even macro
    if (*)&1	; pretty much an 'even'
	ds.b 1
    endif
    endm

; ---------------------------------------------------------------------------
; helper for sound IDs
; ---------------------------------------------------------------------------
SMPS_id function ptr,((ptr-offset)/ptrsize+idstart)

; ---------------------------------------------------------------------------
; Macro to communicate with Sega CD
; Arguments:
; 1 - command id
; 2 - command arg
; 2 - command arg2
; -------------------------------------------------------------

MCDSend macro	id, arg, arg2
.wait
	tst.b	(MCD_Status).l
	bne.s	.wait
	move.b	id,(MCD_Command).l
	if ("arg"<>"")
		move.b arg,(MCD_Argument).l
	endif
	if ("arg2"<>"")
		move.l arg2,(MCD_Argument2).l
	endif
	addq.b  #1,(MCD_Command_Clock).l

.wait2
	tst.b	(MCD_Status).l						; waiting for the first command to be executed
	beq.s	.wait2
    endm
