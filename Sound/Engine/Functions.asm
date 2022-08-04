; ---------------------------------------------------------------------------
; Load DAC driver (Mega PCM)
; ---------------------------------------------------------------------------
; SoundDriverLoad: JmpTo_SoundDriverLoad 
SMPS_LoadDACDriver:
	SMPS_stopZ80
	SMPS_resetZ80

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
	beq.s	+
	MCDSend	#_MCD_SetVolume, #255
	MCDSend	#_MCD_NoSeek, #1
+	rts
; End of function SMPS_LoadDACDriver

; ---------------------------------------------------------------------------
; Queue sound for play (queue 1)
; ---------------------------------------------------------------------------
; sub_135E: PlayMusic:
SMPS_QueueSound1:
	tst.b	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1).w
	bne.s	+
	move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1).w
	rts
+
	move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd4).w
	rts
; End of function SMPS_QueueSound1

; ---------------------------------------------------------------------------
; Queue sound for play (queue 2)
; and optionally only do so if object is on-screen (Sonic engine feature)
; ---------------------------------------------------------------------------
; sub_137C: PlaySoundLocal:
    if SMPS_EnablePlaySoundLocal
SMPS_QueueSound2Local:
	tst.b	render_flags(a0)
	bpl.s	++	; rts
    endif
; sub_1370: PlaySound:
SMPS_QueueSound2:
	tst.b	(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd2).w
	bne.s	+
	move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd2).w
	rts
+
	move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd3).w
+	rts
; End of function SMPS_QueueSound2

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

    if SMPS_EnablePWM

; ---------------------------------------------------------------------------
; Play a PWM sample
;
; d0 = Sample ID
; d1 = Sample volume/panning
; d2 = PWM channel*2 (0 = channel 1, 2 = channel 2, etc.)
; ---------------------------------------------------------------------------

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
