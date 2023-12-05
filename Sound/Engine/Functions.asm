; ---------------------------------------------------------------------------
; Perform sound driver initialisation and load the DAC driver
; ---------------------------------------------------------------------------
; SoundDriverLoad: JmpTo_SoundDriverLoad  SMPS_LoadDACDriver:
SMPS_LoadDACDriver:

	; mask off interrupts so that an interrupt cannot occur and mess with
	; the Z80 bus request or DAC driver before they are finished with
	disableIntsSave
	SMPS_stopZ80
	SMPS_resetZ80

	; detect PAL consoles and set the PAL flag if needed
	btst	#6,(Graphics_flags).w
	beq.s	.not_pal
	bset	#f_pal,(Clone_Driver_RAM+SMPS_RAM.bitfield1).l
.not_pal:

	; load Mega PCM (Kosinski-compressed)
	lea	(MegaPCM).l,a0	; source
	lea	(SMPS_z80_ram).l,a1	; destination
	bsr.w	KosDec

	moveq	#0,d1
	move.w	d1,(SMPS_z80_reset).l
	nop
	nop
	nop
	nop
	SMPS_resetZ80
	move.w	d1,(SMPS_z80_bus_request).l	; start the Z80
	tst.b	(SegaCD_Mode).w
	beq.s	.skip
	MCDSend	#_MCD_SetVolume, #255
	MCDSend	#_MCD_NoSeek, #1

.skip
	enableIntsSave
	rts
; End of function SMPS_LoadDACDriver

; ---------------------------------------------------------------------------
; Queue sound for play (queue 1)
; ---------------------------------------------------------------------------
; sub_135E: PlayMusic:
SMPS_QueueSound1:
	tst.w	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1).w
	bne.s	+
	clr.b	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1+0).w
	move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1+1).w
	rts
+
	clr.b	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd4+0).w
	move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd4+1).w
	rts
; End of function SMPS_QueueSound1

; ---------------------------------------------------------------------------
; Queue sound for play (queue 2)
; and optionally only do so if object is on-screen (Sonic engine feature)
; ---------------------------------------------------------------------------
    if SMPS_EnablePlaySoundLocal
; sub_137C: PlaySoundLocal:
SMPS_QueueSound2Local:
	tst.b	render_flags(a0)
	bpl.s	++	; rts
    endif
; sub_1370: PlaySound:
SMPS_QueueSound2:
	tst.w	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd2).w
	bne.s	+
	clr.b	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd2+0).w
	move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd2+1).w
	rts
+
	clr.b	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd3+0).w
	move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd3+1).w
+
	rts
; End of function SMPS_QueueSound2

; ---------------------------------------------------------------------------
; Queue sound for play (queue 3)
; ---------------------------------------------------------------------------
; sub_1376: PlaySoundStereo:
SMPS_QueueSound3:
	clr.b	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd3+0).w
	move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd3+1).w
	rts
; End of function SMPS_QueueSound3

; ---------------------------------------------------------------------------
; Queue sound for play (queue 1)
; ---------------------------------------------------------------------------

SMPS_QueueSound1_Extended:
	tst.w	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1).w
	bne.s	+
	move.w	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1).w
	rts
+
	move.w	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd4).w
	rts
; End of function SMPS_QueueSound1Word

; ---------------------------------------------------------------------------
; Queue sound for play (queue 2)
; and optionally only do so if object is on-screen (Sonic engine feature)
; ---------------------------------------------------------------------------

    if SMPS_EnablePlaySoundLocal
SMPS_QueueSound2Local_Extended:
	tst.b	render_flags(a0)
	bpl.s	++	; rts
    endif

SMPS_QueueSound2_Extended:
	tst.w	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd2).w
	bne.s	+
	move.w	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd2).w
	rts
+
	move.w	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd3).w
+
	rts
; End of function SMPS_QueueSound2Word

; ---------------------------------------------------------------------------
; Queue sound for play (queue 3)
; ---------------------------------------------------------------------------

SMPS_QueueSound3_Extended:
	move.w	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd3).w
	rts
; End of function SMPS_QueueSound3Word

; ---------------------------------------------------------------------------
; Play a DAC sample
;
; d0 = Sample ID
; ---------------------------------------------------------------------------
SMPS_PlayDACSample:
	SMPS_stopZ80_safe
	move.b  d0,(SMPS_z80_ram+MegaPCM_DAC_Number).l
	; This is a DAC SFX: set to full volume
	move.b	#(MegaPCM_VolumeTbls&$F000)>>8,d0
	move.b	d0,(SMPS_z80_ram+MegaPCM_LoadBank.volume+1).l
	move.b	d0,(SMPS_z80_ram+MegaPCM_Init_PCM.volume+1).l
	SMPS_startZ80_safe
	rts
; End of function SMPS_PlayDACSample

; ---------------------------------------------------------------------------
; Play a PWM sample
;
; d0 = Sample ID
; d1 = Sample volume/panning
; d2 = PWM channel*2 (0 = channel 1, 2 = channel 2, etc.)
; ---------------------------------------------------------------------------
    if SMPS_EnablePWM
SMPS_PlayPWMSample:
	; Merge ID with volume/pan to get PWM command
	lsl.w	#8,d1
	move.b	d0,d1
	; Save a0
	move.l	a0,d0
	; Send PWM command
	lea	(SMPS_pwm_comm).l,a0
	move.w	d1,(a0,d2.w)
	; Restore a0
	movea.l	d0,a0
	rts
; End of function SMPS_PlayPWMSample
    endif
