; ===========================================================================
; Sonic 2 Clone Driver v2
; See https://github.com/Clownacy/Sonic-2-Clone-Driver-v2
; ===========================================================================

	dc.b	"Clownacy's Sonic 2 Clone Driver v2 (v2.7+ prototype)"
	even

; ---------------------------------------------------------------------------
; Subroutine to update music more than once per frame
; (Called by horizontal & vert. interrupts)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71B4C: UpdateMusic:
SMPS_UpdateDriver:
    if ((Clone_Driver_RAM)&$8000)==0
	lea	(Clone_Driver_RAM).l,a6
    else
	lea	(Clone_Driver_RAM).w,a6
    endif

	tst.b	SMPS_RAM.f_stopmusic(a6)	; Is music paused?
	bne.w	DoPauseMusic			; If yes, branch

	tst.b	SMPS_RAM.variables.v_fadeout_counter(a6)
	beq.s	.skipfadeout
	bsr.w	DoFadeOut
; loc_71BA8:
.skipfadeout:
	btst	#f_fadeinflag,SMPS_RAM.variables.bitfield2(a6)
	beq.s	.skipfadein
	bsr.w	DoFadeIn
; loc_71BB2:
.skipfadein:
	tst.l	SMPS_RAM.variables.queue(a6)		; Is a music or sound queued for played?
	beq.s	.nosndinput				; If not, branch
	bsr.w	CycleSoundQueue
; loc_71BBC:
.nosndinput:
    if SMPS_EnableSpinDashSFX
	tst.b   SMPS_RAM.v_spindash_timer(a6)
	beq.s	.notimer
	subq.b	#1,SMPS_RAM.v_spindash_timer(a6)
.notimer:
    endif
	; Clownacy | Pretty large rearrangements have been made here for the
	; Sonic 2-style selective PAL mode. With S2's driver, if the drowning music played on a PAL
	; system, the drowning theme would play at 50fps speed, or 'PAL speed'
	; this code is part of that feature's replication
	btst	#6,(Graphics_flags).w					; is this a PAL console?
	beq.s	.updatemusictracks					; if not, branch
	btst	#f_force_pal_tempo,SMPS_RAM.variables.bitfield2(a6)	; is this song forced to play slow on PAL consoles?
	bne.s	.updatemusictracks					; if so, skip the double-update
	subq.b	#1,SMPS_RAM.variables.v_pal_audio_countdown(a6)		; subtract 1 from the PAL countdown
	bne.s	.updatemusictracks					; if the PAL countdown is not 0, we are not ready to double-update, branch
	move.b	#5,SMPS_RAM.variables.v_pal_audio_countdown(a6)		; if the countdown is now at 0, reset the counter...
	bset	#f_doubleupdate,SMPS_RAM.variables.bitfield2(a6)	; ...and then set the double-update flag

.updatemusictracks:
	bsr.w	TempoWait

	lea	SMPS_RAM.v_music_dac_track(a6),a5
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is DAC track playing?
	bpl.s	.dacdone				; Branch if not
	bsr.w	DACUpdateTrack
; loc_71BD4:
.dacdone:
	moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7	; 6 FM tracks
; loc_71BDA:
.bgmfmloop:
	lea	SMPS_Track.len(a5),a5
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
	bpl.s	.bgmfmnext				; Branch if not
	bsr.w	FMUpdateTrack
; loc_71BE6:
.bgmfmnext:
	dbf	d7,.bgmfmloop

	moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks
; loc_71BEC:
.bgmpsgloop:
	lea	SMPS_Track.len(a5),a5
	tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
	bpl.s	.bgmpsgnext			; Branch if not
	bsr.w	PSGUpdateTrack
; loc_71BF8:
.bgmpsgnext:
	dbf	d7,.bgmpsgloop

    if SMPS_EnablePWM
	moveq	#SMPS_MUSIC_PWM_TRACK_COUNT-1,d7	; 4 PWM tracks

.bgmpwmloop:
	lea	SMPS_Track.len(a5),a5
	tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
	bpl.s	.bgmpwmnext			; Branch if not
	bsr.w	PWMUpdateTrack

.bgmpwmnext:
	dbf	d7,.bgmpwmloop
    endif

	bclr	#f_doubleupdate,SMPS_RAM.variables.bitfield2(a6)	; Clear double-update flag
	bne.s	.updatemusictracks		; Was the flag set? If so, double-update

;.updatesfxtracks:
	moveq	#SMPS_SFX_FM_TRACK_COUNT-1,d7	; SFX only has access to 3 FM tracks
; loc_71C04:
.sfxfmloop:
	lea	SMPS_Track.len(a5),a5
	tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
	bpl.s	.sfxfmnext			; Branch if not
	bsr.w	FMUpdateTrack
; loc_71C10:
.sfxfmnext:
	dbf	d7,.sfxfmloop

	moveq	#SMPS_SFX_PSG_TRACK_COUNT-1,d7	; SFX only has access to 3 PSG tracks
; loc_71C16:
.sfxpsgloop:
	lea	SMPS_Track.len(a5),a5
	tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
	bpl.s	.sfxpsgnext			; Branch of not
	bsr.w	PSGUpdateTrack
; loc_71C22:
.sfxpsgnext:
	dbf	d7,.sfxpsgloop

    if SMPS_EnableSpecSFX
	lea	SMPS_Track.len(a5),a5
	tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
	bpl.s	.specfmdone			; Branch if not
	bsr.w	FMUpdateTrack
; loc_71C38:
.specfmdone:
	lea	SMPS_Track.len(a5),a5
	tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing
	bpl.s	.locret				; Branch if not
	bra.w	PSGUpdateTrack
.locret:
    endif
	rts
; End of function UpdateMusic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71C4E: UpdateDAC:
DACUpdateTrack:
	subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Has DAC sample timeout expired?
	bne.s	.locret					; Return if not
	bsr.s	DACDoNext
	bra.s	DACUpdateSample
.locret:
	rts
; End of function DACUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

DACDoNext:
	movea.l	SMPS_Track.DataPointer(a5),a4	; DAC track data pointer
; loc_71C5E:
.sampleloop:
	moveq	#0,d5
	move.b	(a4)+,d5		; Get next SMPS unit
	cmpi.b	#$FE,d5			; Is it a coord. flag?
	blo.s	.notcoord		; Branch if not
	bsr.w	CoordFlag
	bra.s	.sampleloop
; ===========================================================================
; loc_71C6E:
.notcoord:
	tst.b	d5			; Is it a sample?
	bpl.s	.gotduration		; Branch if not (duration)
	move.b	d5,SMPS_Track.SavedDAC(a5)	; Store new sample
	move.b	(a4)+,d5		; Get another byte
	bpl.s	.gotduration		; Branch if it is a duration
	subq.w	#1,a4			; Put byte back
	move.b	SMPS_Track.SavedDuration(a5),SMPS_Track.DurationTimeout(a5) ; Use last duration
	bra.s	.gotsampleduration
; ===========================================================================
; loc_71C84:
.gotduration:
	bsr.w	SetDuration
; loc_71C88:
.gotsampleduration:
	move.w	a4,SMPS_Track.DataPointer+2(a5)	; Save pointer
	move.l	a4,d0
	swap	d0
	move.b	d0,SMPS_Track.DataPointer+1(a5)	; Save pointer
	rts
; End of function DACDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

DACUpdateSample:
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
	bne.s	locret_71CAA				; Return if yes
	moveq	#0,d0
	move.b	SMPS_Track.SavedDAC(a5),d0	; Get sample
	cmpi.b	#$80,d0				; Is it a rest?
	beq.s	locret_71CAA			; Return if yes

	; From Vladikcomper:
	; "We need the Z80 to be stopped before this command executes and to be started directly afterwards."
	SMPS_stopZ80_safe
	move.b	d0,(SMPS_z80_ram+MegaPCM_DAC_Number).l
	SMPS_startZ80_safe

locret_71CAA:
	rts
; End of function DACUpdateSample


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71CCA:
FMUpdateTrack:
	subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Update duration timeout
	bne.s	.notegoing			; Branch if it hasn't expired
	bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
	bsr.s	FMDoNext
	bsr.w	NoteFillUpdate
	bsr.w	DoModulation
	bsr.w	FMPrepareNote
	bra.w	FMNoteOn
; ===========================================================================
; loc_71CE0:
.notegoing:
	bsr.w	NoteFillUpdate
	bsr.w	DoModulation
	bcs.w	FMUpdateFreq
	rts
; End of function FMUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71CEC:
FMDoNext:
	movea.l	SMPS_Track.DataPointer(a5),a4	; Track data pointer
	bclr	#1,SMPS_Track.PlaybackControl(a5)	; Clear 'track at rest' bit
; loc_71CF4:
.noteloop:
	moveq	#0,d5
	move.b	(a4)+,d5		; Get byte from track
	cmpi.b	#$FE,d5			; Is this a coord. flag?
	blo.s	.gotnote		; Branch if not
	bsr.w	CoordFlag
	bra.s	.noteloop
; ===========================================================================
; loc_71D04:
.gotnote:
	bsr.w	FMNoteOff
	tst.b	d5			; Is this a note?
	bpl.s	.gotduration		; Branch if not
	bsr.s	FMSetFreq
	move.b	(a4)+,d5		; Get another byte
	bpl.s	.gotduration		; Branch if it is a duration
	subq.w	#1,a4			; Otherwise, put it back
	bra.w	FinishTrackUpdate
; ===========================================================================
; loc_71D1A:
.gotduration:
	bsr.w	SetDuration
	bra.w	FinishTrackUpdate
; End of function FMDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71D22:
FMSetFreq:
	subi.b	#$80,d5				; Make it a zero-based index
	beq.w	TrackSetRest
	add.b	SMPS_Track.Transpose(a5),d5		; Add track transposition
	andi.w	#$7F,d5			; Clear high byte and sign bit
	add.w	d5,d5
	move.w	FMFrequencies(pc,d5.w),SMPS_Track.Freq(a5)
	rts
; End of function FMSetFreq

; ===========================================================================
; ---------------------------------------------------------------------------
; FM Note Values: b-0 to a#8
; ---------------------------------------------------------------------------
; word_72790: FM_Notes:
FMFrequencies:
	dc.w $025E,$0284,$02AB,$02D3,$02FE,$032D,$035C,$038F,$03C5,$03FF,$043C,$047C
	dc.w $0A5E,$0A84,$0AAB,$0AD3,$0AFE,$0B2D,$0B5C,$0B8F,$0BC5,$0BFF,$0C3C,$0C7C
	dc.w $125E,$1284,$12AB,$12D3,$12FE,$132D,$135C,$138F,$13C5,$13FF,$143C,$147C
	dc.w $1A5E,$1A84,$1AAB,$1AD3,$1AFE,$1B2D,$1B5C,$1B8F,$1BC5,$1BFF,$1C3C,$1C7C
	dc.w $225E,$2284,$22AB,$22D3,$22FE,$232D,$235C,$238F,$23C5,$23FF,$243C,$247C
	dc.w $2A5E,$2A84,$2AAB,$2AD3,$2AFE,$2B2D,$2B5C,$2B8F,$2BC5,$2BFF,$2C3C,$2C7C
	dc.w $325E,$3284,$32AB,$32D3,$32FE,$332D,$335C,$338F,$33C5,$33FF,$343C,$347C
	dc.w $3A5E,$3A84,$3AAB,$3AD3,$3AFE,$3B2D,$3B5C,$3B8F,$3BC5,$3BFF,$3C3C,$3C7C

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71D40:
SetDuration:
	move.w	d5,d0
	moveq	#0,d1
	move.b	SMPS_Track.TempoDivider(a5),d1
	mulu.w	d1,d0
	move.b	d0,SMPS_Track.SavedDuration(a5)	; Save duration
	move.b	d0,SMPS_Track.DurationTimeout(a5)	; Save duration timeout
	rts
; End of function SetDuration

; ===========================================================================
; loc_71D58:
TrackSetRest:
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	clr.w	SMPS_Track.Freq(a5)			; Clear frequency
	; Clownacy | Sonic 2's driver doesn't continue to FinishTrackUpdate
	rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71D60:
FinishTrackUpdate:
	move.w	a4,SMPS_Track.DataPointer+2(a5)		; Store new track position
	move.l	a4,d0
	swap	d0
	move.b	d0,SMPS_Track.DataPointer+1(a5)		; Store new track position
	move.b	SMPS_Track.SavedDuration(a5),SMPS_Track.DurationTimeout(a5) ; Reset note timeout
	btst	#4,SMPS_Track.PlaybackControl(a5)		; Is track set to not attack note?
	bne.s	locret_71D9C				; If so, branch
	move.b	SMPS_Track.NoteFillMaster(a5),SMPS_Track.NoteFillTimeout(a5) ; Reset note fill timeout
	; Clownacy | We only want VolEnvIndex clearing on PSG tracks, now.
	; Non-PSG tracks use the RAM for something else.
	tst.b	SMPS_Track.VoiceControl(a5)			; Is this a psg track?
	bpl.s	.notpsg					; If not, branch
	clr.b	SMPS_Track.VolEnvIndex(a5)			; Reset PSG volume envelope index
.notpsg:
	btst	#3,SMPS_Track.PlaybackControl(a5)		; Is modulation on?
	beq.s	locret_71D9C				; If not, return
	movea.l	SMPS_Track.ModulationPtr(a5),a0		; Modulation data pointer
	move.b	(a0)+,SMPS_Track.ModulationWait(a5)		; Reset wait
	move.b	(a0)+,SMPS_Track.ModulationSpeed(a5)	; Reset speed
	move.b	(a0)+,SMPS_Track.ModulationDelta(a5)	; Reset delta
	move.b	(a0)+,d0				; Get steps
	lsr.b	#1,d0					; Halve them
	move.b	d0,SMPS_Track.ModulationSteps(a5)		; Then store
	clr.w	SMPS_Track.ModulationVal(a5)		; Reset frequency change
locret_71D9C:
	rts
; End of function FinishTrackUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Clownacy | Nicely optimised
; sub_71D9E:
NoteFillUpdate:
	tst.b	SMPS_Track.NoteFillTimeout(a5)	; Is note fill on?
	beq.s	locret_71D9C			; If not, return
	subq.b	#1,SMPS_Track.NoteFillTimeout(a5)	; Update note fill timeout
	bne.s	locret_71D9C			; Return if it hasn't expired
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Put track at rest
	addq.w	#4,sp				; Do not return to caller
	tst.b	SMPS_Track.VoiceControl(a5)		; Is this a psg track?
	bmi.w	PSGNoteOff			; If yes, branch
	bra.w	FMNoteOff
; End of function NoteFillUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71DC6:
DoModulation:
	; Clownacy | (From S2) Corrects modulation during rests (can be heard in ARZ's theme, as beeping right after the song loops)
	btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track at rest?
	bne.s	.locret				; Return if so

	btst	#3,SMPS_Track.PlaybackControl(a5)	; Is modulation active?
	beq.s	.locret				; Return if not
	tst.b	SMPS_Track.ModulationWait(a5)	; Has modulation wait expired?
	beq.s	.waitdone			; If yes, branch
	subq.b	#1,SMPS_Track.ModulationWait(a5)	; Update wait timeout
; locret_71E16:
.locret:
	move.b	#0,ccr
	rts
; ===========================================================================
; loc_71DDA:
.waitdone:
	subq.b	#1,SMPS_Track.ModulationSpeed(a5)	; Update speed
	beq.s	.updatemodulation		; If it expired, want to update modulation
	move.b	#0,ccr
	rts
; ===========================================================================
; loc_71DE2:
.updatemodulation:
	movea.l	SMPS_Track.ModulationPtr(a5),a0		; Get modulation data
	move.b	1(a0),SMPS_Track.ModulationSpeed(a5)	; Restore modulation speed
	tst.b	SMPS_Track.ModulationSteps(a5)		; Check number of steps
	bne.s	.calcfreq				; If nonzero, branch
	move.b	3(a0),SMPS_Track.ModulationSteps(a5)	; Restore from modulation data
	neg.b	SMPS_Track.ModulationDelta(a5)		; Negate modulation delta
	move.b	#0,ccr
	rts
; ===========================================================================
; loc_71DFE:
.calcfreq:
	subq.b	#1,SMPS_Track.ModulationSteps(a5)	; Update modulation steps
	move.b	SMPS_Track.ModulationDelta(a5),d6	; Get modulation delta
	ext.w	d6
	add.w	d6,SMPS_Track.ModulationVal(a5)
	move.b	#1,ccr
	rts
; End of function DoModulation


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71E18:
FMPrepareNote:
	btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track resting?
	bne.s	locret_71E48			; Return if so
	tst.w	SMPS_Track.Freq(a5)		; Get current note frequency
	beq.s	FMSetRest			; Branch if zero
; loc_71E24:
FMUpdateFreq:
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
	bne.s	locret_71E48			; Return if so
	move.w	SMPS_Track.Freq(a5),d6		; Get current note frequency
	btst	#3,SMPS_Track.PlaybackControl(a5)
	beq.s	.no_modulation
	add.w	SMPS_Track.ModulationVal(a5),d6

.no_modulation:
	move.b	SMPS_Track.Detune(a5),d0		; Get detune value
	ext.w	d0
	add.w	d0,d6				; Add note frequency
	move.w	d6,-(sp)
	move.b	(sp)+,d1
	move.b	#$A4,d0		; Register for upper 6 bits of frequency
	bsr.w	WriteFMIorII
	move.b	d6,d1
	move.b	#$A0,d0		; Register for lower 8 bits of frequency
	bra.w	WriteFMIorII
; ===========================================================================
; loc_71E4A:
FMSetRest:
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit

locret_71E48:
	rts
; End of function FMPrepareNote

; ===========================================================================
; loc_71E50: PauseMusic:
DoPauseMusic:
	bmi.s	DoUnpauseMusic		; Branch if music is being unpaused
	cmpi.b	#2,SMPS_RAM.f_stopmusic(a6)
	beq.s	.locret
	move.b	#2,SMPS_RAM.f_stopmusic(a6)
	tst.b	SMPS_RAM.variables.v_cda_playing(a6)
	beq.s	.skip
	MCDSend	#_MCD_PauseTrack, #20	; flag, timer

.skip:
	bsr.w	FMSilenceAll
	bsr.w	PSGSilenceAll
    if SMPS_EnablePWM
	bsr.w	PWMSilenceAll
    endif
	; From Vladikcomper:
	; "Playing sample $7F executes pause command."
	; "We need the Z80 to be stopped before this command executes and to be started directly afterwards."
	SMPS_stopZ80_safe
	move.b  #$7F,(SMPS_z80_ram+MegaPCM_DAC_Number).l	; pause DAC
	SMPS_startZ80_safe

.locret:
	rts
; ===========================================================================
; loc_71E94: .unpausemusic: UnpauseMusic:
DoUnpauseMusic:
	clr.b	SMPS_RAM.f_stopmusic(a6)

	; Resume CDA
	tst.b	SMPS_RAM.variables.v_cda_playing(a6)
	beq.s	.skip
	MCDSend	#_MCD_UnPauseTrack

.skip:

	; Resume music FM channels
	lea	SMPS_RAM.v_music_fm_tracks(a6),a5
	moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM
	bsr.s	RestoreFMTrackVoices

	; Resume SFX FM channels
	lea	SMPS_RAM.v_sfx_fm_tracks(a6),a5
	moveq	#SMPS_SFX_FM_TRACK_COUNT-1,d7		; 3 FM
	bsr.s	RestoreFMTrackVoices

    if SMPS_EnableSpecSFX
	; Resume Special SFX FM channels
	lea	SMPS_RAM.v_spcsfx_fm_tracks(a6),a5
	moveq	#SMPS_SPECIAL_SFX_FM_TRACK_COUNT-1,d7	; 1 FM
	bsr.s	RestoreFMTrackVoices
    endif

	; From Vladikcomper:
	; "Playing sample $00 cancels pause mode."
	; "We need the Z80 to be stopped before this command executes and to be started directly afterwards."
	SMPS_stopZ80_safe
	clr.b  (SMPS_z80_ram+MegaPCM_DAC_Number).l	; unpause DAC
	SMPS_startZ80_safe

	rts


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; ResumeTrack:
RestoreFMTrackVoices:
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
	bpl.s	.nextTrack				; Branch if not
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding track?
	bne.s	.nextTrack				; Branch if so
	moveq	#0,d0
	move.b	SMPS_Track.VoiceIndex(a5),d0	; Current track FM instrument
	bsr.w	cfSetVoiceCont

.nextTrack:
	lea	SMPS_Track.len(a5),a5	; Advance to next track
	dbf	d7,RestoreFMTrackVoices	; loop
	rts
; End of function RestoreFMTrackVoices

; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	play a sound or	music track
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Sound_Play:
CycleSoundQueue:
	lea	(SoundIndex).l,a0
	lea	SMPS_RAM.variables.queue(a6),a1		; Load music track number
	move.b	SMPS_RAM.variables.v_sndprio(a6),d3	; Get priority of currently playing SFX
	moveq	#SMPS_Queue.len-1,d4			; Clownacy | Number of sound queues-1, now 3 to match the new fourth queue
	moveq	#0,d0
; loc_71F12:
.inputloop:
	move.b	(a1),d0			; Move track number to d0
	move.w	d0,d7
	clr.b	(a1)+			; Clear entry
	cmpi.b	#MusID__First,d0	; Make it into 0-based index
	blo.s	.nextinput		; If negative (i.e., it was $80 or lower), branch
	cmpi.b	#SndID__End,d0		; Is it a special command?
	bhs.w	PlaySoundID		; If so, branch
	subi.b	#SndID__First,d0	; Subtract first SFX index
	blo.w	PlaySoundID		; If it was music, branch
	add.w	d0,d0
	add.w	d0,d0
	move.b	(a0,d0.w),d2		; Get sound type
	cmp.b	d3,d2			; Is it a lower priority sound?
	blo.s	.lowerpriority		; Branch if yes
	move.b	d2,d3			; Store new priority
	movem.l	d0-a6,-(sp)
	bsr.w	PlaySoundID
	movem.l	(sp)+,d0-a6

.lowerpriority:
	tst.b	d3			; We don't want to change sound priority if it is negative
	bmi.s	.locret
	move.b	d3,SMPS_RAM.variables.v_sndprio(a6)	; Set new sound priority
.locret:
	rts

; loc_71F3E:
.nextinput:
	dbf	d4,.inputloop
	rts
; End of function CycleSoundQueue

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sound_PlayCDA:
	tst.b	(SegaCD_Mode).w
	beq.w	Sound_PlayBGM

	bclr	#0,SMPS_RAM.variables.v_cda_ignore(a6)
	bne.w	Sound_PlayBGM

	bsr.w	StopSFX
    if SMPS_EnableSpecSFX
	bsr.w	StopSpecSFX
    endif

	; Clownacy | We're backing-up the variables and tracks separately, to put the backed-up variables after the backed-up tracks
	; this is so the backed-up tracks and SFX tracks start at the same place: at the end of the music tracks
;	clr.b	SMPS_RAM.variables.v_sndprio(a6)		; Clear priority (S2 removes this one)
	lea	SMPS_RAM.v_music_track_ram(a6),a0
	lea	SMPS_RAM.v_1up_ram_copy(a6),a1
	moveq	#((SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)/4)-1,d0	; Backup music track data
; loc_72012:
.backuptrackramloop:
	move.l	(a0)+,(a1)+
	dbf	d0,.backuptrackramloop

    if (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)&2
	move.w	(a0)+,(a1)+
    endif
    if (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)&1
	move.b	(a0)+,(a1)+
    endif

	lea	SMPS_RAM.variables(a6),a0
	lea	SMPS_RAM.variables_backup(a6),a1
	moveq	#(SMPS_RAM_Variables.len/4)-1,d0	; Backup variables

.backupvariablesloop:
	move.l	(a0)+,(a1)+
	dbf	d0,.backupvariablesloop

    if SMPS_RAM_Variables.len&2
	move.w	(a0)+,(a1)+
    endif
    if SMPS_RAM_Variables.len&1
	move.b	(a0)+,(a1)+
    endif

	clr.b	SMPS_RAM.variables.v_sndprio(a6)		; Clear priority twice?

	bsr.w	InitMusicPlayback						; reset SMPS memory
	st	SMPS_RAM.variables.v_cda_playing(a6)		; set CDA playing flag

;	subi.w	#MusID__First,d7					; subtract $E5 to get track number

	move.w	d7,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	PlayCD_Index-4(pc,d1.w),a0
	moveq	#0,d0
	move.b	(a0),d0								; argument
	move.l	(a0),d1								; loop state
	andi.l	#$FFFFFF,d1							; get loop
	MCDSend	d0, d7, d1						; request MCD a track
	addq.w	#4,sp								; Tamper return value so we don't return to caller
	rts
; ===========================================================================

PlayCD_Index:
	dc.l _MCD_PlayTrack<<24|$00000000			; $01 (DEZ)
	dc.l _MCD_PlayTrack<<24|$00000000			; $02 (Mid Boss)
	dc.l _MCD_PlayTrack<<24|$00000000			; $03 (Boss)
	dc.l _MCD_PlayTrack<<24|$00000000			; $04 (Invincible)
	dc.l _MCD_PlayTrack_Once<<24|$00000000	; $05 (Act Clear)
	dc.l _MCD_PlayTrack_Once<<24|$00000000	; $06 (Countdown)
	dc.l _MCD_PlayTrack<<24|$00000000			; $07 (Speedup)
	even

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Sound_ChkValue:
PlaySoundID:	; For the love of god, don't rearrange the order of the groups, it has to be 'music --> SFX --> flags'
	; Music
	cmpi.b	#MusID__First,d7	; Is this before music?
	blo.w	CycleSoundQueue.locret	; Return if yes
	cmpi.b	#MusID__End,d7		; Is this music ($01-$1F)?
	blo.w	Sound_PlayCDA		; Branch if yes

	; SFX
	cmpi.b	#SndID__First,d7	; Is this after music but before sfx?
	blo.w	CycleSoundQueue.locret	; Return if yes
	cmpi.b	#SndID__End,d7		; Is this sfx ($80-$D0)?
	blo.w	Sound_PlaySFX		; Branch if yes

    if SMPS_EnableSpecSFX
	; Special SFX
	cmpi.b	#SpecID__First,d7	; Is this after sfx but before spec sfx?
	blo.w	CycleSoundQueue.locret	; Return if yes
	cmpi.b	#SpecID__End,d7		; Is this spec sfx
	blo.w	Sound_PlaySpecial	; Branch if yes
    endif

	; Commands
	subi.b	#FlgID__First,d7		; Is this after sfx (spec if above code is assembled) but before commands?
	bcs.w	CycleSoundQueue.locret		; Return if yes
	cmpi.b	#FlgID__End-FlgID__First,d7	; Is this after commands?
	bhs.w	CycleSoundQueue.locret		; Return if yes
	add.w	d7,d7
	move.w	Sound_ExIndex(pc,d7.w),d7
	jmp	Sound_ExIndex(pc,d7.w)
; ===========================================================================

Sound_ExIndex:
ptr_flgFA:	dc.w	StopSFX-Sound_ExIndex		; $FA	; Clownacy | Brand new. Was missing from the stock S1 driver because Sonic Team had stripped out various unused components of the driver
ptr_flgFB:	dc.w	FadeOutMusic-Sound_ExIndex	; $FB	; Clownacy | Was $E0
ptr_flgFC:	dc.w	PlaySegaSound-Sound_ExIndex	; $FC	; Clownacy | Was $E1
ptr_flgFD:	dc.w	SpeedUpMusic-Sound_ExIndex	; $FD	; Clownacy | Was $E2
ptr_flgFE:	dc.w	SlowDownMusic-Sound_ExIndex	; $FE	; Clownacy | Was $E3
ptr_flgFF:	dc.w	StopAllSound-Sound_ExIndex	; $FF	; Clownacy | Was $E4
ptr_flgend
; ---------------------------------------------------------------------------
; Play "Say-gaa" PCM sound
; ---------------------------------------------------------------------------
; Sound_E1: PlaySega:
PlaySegaSound:
	moveq	#(MegaPCM_VolumeTbls&$F000)>>8,d0
	SMPS_stopZ80_safe

	; This is a DAC SFX: set to full volume
	move.b	d0,(SMPS_z80_ram+MegaPCM_LoadBank.volume+1).l
	move.b	d0,(SMPS_z80_ram+MegaPCM_Init_PCM.volume+1).l

	move.b	#dSega_S2,(SMPS_z80_ram+MegaPCM_DAC_Number).l	; Queue Sega PCM
	SMPS_startZ80_safe
	    if SMPS_IdlingSegaSound
		move.w	#$11,d1
; loc_71FC0:
.busyloop_outer:
		move.w	#-1,d0
; loc_71FC4:
.busyloop:
		nop
		dbf	d0,.busyloop

		dbf	d1,.busyloop_outer
	    endif

	addq.w	#4,sp				; Tamper return value so we don't return to caller
	rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Play music track $81-$9F
; ---------------------------------------------------------------------------
; Sound_81to9F:
Sound_PlayBGM:
	; Clownacy | The commented-out bsr is from S2's driver, which was used to hide a certain bug.
	; Lucky for us, though, we just fix the bug directly, so we don't need this.
;	bsr.w	StopSFX			; Clownacy | (From S2) Helps stop audio artefacts after SFX interruption
;    if SMPS_EnableSpecSFX
;	bsr.w	StopSpecSFX
;    endif
	cmpi.b	#MusID_ExtraLife,d7	; Is the "extra life" music to be played?
	bne.s	.bgmnot1up		; If not, branch
	bset	#f_1up_playing,SMPS_RAM.variables.bitfield2(a6)	; Is a 1-up music playing?
	bne.s	.bgm_loadMusic		; If yes, branch	; Clownacy | (From S2)

	; Clownacy | Making the music backup share RAM with the SFX tracks makes this code so much more complicated...
	; First up, we have to meddle with bit 7 PlaybackControl, but, afterwards, we wanna put it back the way it was, so we gotta back all 10 of them up
	lea	SMPS_RAM.v_music_track_ram(a6),a5
	moveq	#SMPS_MUSIC_TRACK_COUNT-1,d0	; 1 DAC + 6 FM + 3 PSG tracks
; loc_71FE6:
.clearsfxloop:
	bclr	#2,SMPS_Track.PlaybackControl(a5)		; Clear 'SFX is overriding' bit
	bclr	#7,SMPS_Track.PlaybackControl(a5)		; we don't want the SFX update processing the music track backup
	beq.s	.notPlaying
	bset	#2,SMPS_Track.PlaybackControl(a5)		; Backup 'track is playing' bit in bit 2
.notPlaying:
	lea	SMPS_Track.len(a5),a5
	dbf	d0,.clearsfxloop

	; The RAM this code changes is immediately overwritten with the music track backup, so the code's useless
;	lea	SMPS_RAM.v_sfx_track_ram(a6),a5
;	moveq	#((SMPS_RAM.v_spcsfx_track_ram_end-SMPS_RAM.v_sfx_track_ram)/SMPS_Track.len)-1,d0	; 3 FM + 3 PSG tracks (SFX) + 1 FM + 1 PSG tracks (special SFX)
; loc_71FF8:
;.cleartrackplayloop:
;	bclr	#7,SMPS_Track.PlaybackControl(a5)	; Clear 'track is playing' bit
;	lea	SMPS_Track.len(a5),a5
;	dbf	d0,.cleartrackplayloop

	; Clownacy | We're backing-up the variables and tracks separately, to put the backed-up variables after the backed-up tracks
	; this is so the backed-up tracks and SFX tracks start at the same place: at the end of the music tracks
;	clr.b	SMPS_RAM.variables.v_sndprio(a6)		; Clear priority (S2 removes this one)
	lea	SMPS_RAM.v_music_track_ram(a6),a0
	lea	SMPS_RAM.v_1up_ram_copy(a6),a1
	moveq	#((SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)/4)-1,d0	; Backup music track data
; loc_72012:
.backuptrackramloop:
	move.l	(a0)+,(a1)+
	dbf	d0,.backuptrackramloop

    if (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)&2
	move.w	(a0)+,(a1)+
    endif
    if (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)&1
	move.b	(a0)+,(a1)+
    endif

	lea	SMPS_RAM.variables(a6),a0
	lea	SMPS_RAM.variables_backup(a6),a1
	moveq	#(SMPS_RAM_Variables.len/4)-1,d0	; Backup variables

.backupvariablesloop:
	move.l	(a0)+,(a1)+
	dbf	d0,.backupvariablesloop

    if SMPS_RAM_Variables.len&2
	move.w	(a0)+,(a1)+
    endif
    if SMPS_RAM_Variables.len&1
	move.b	(a0)+,(a1)+
    endif

	clr.b	SMPS_RAM.variables.v_sndprio(a6)		; Clear priority twice?
	bra.s	.bgm_loadMusic
; ===========================================================================
; loc_72024:
.bgmnot1up:
	moveq	#0,d0
	move.b	d0,SMPS_RAM.variables.v_fadein_counter(a6)
	move.b	d0,SMPS_RAM.variables.v_fadeout_counter(a6)
	bclr	#f_1up_playing,SMPS_RAM.variables.bitfield2(a6)
; loc_7202C:
.bgm_loadMusic:

	; If CDA is playing, stop it
	tst.b SMPS_RAM.variables.v_cda_playing(a6)
	beq.s	.NoCD
	MCDSend	#_MCD_PauseTrack, #0		; Stop
	clr.b	SMPS_RAM.variables.v_cda_playing(a6)

.NoCD:
	bsr.w	InitMusicPlayback
	subi.b	#MusID__First,d7
	add.w	d7,d7
	add.w	d7,d7
	lea	MusicIndex(pc),a4
	move.l	(a4,d7.w),d1
	move.b	(a4,d7.w),SMPS_RAM.variables.v_speeduptempo(a6)
	bclr	#0,d1				; Clownacy | Is this a forced-PAL tempo song? (we clear PAL tempo flag so it doesn't interfere later on)
	beq.s	.nopalmode
	bset	#f_force_pal_tempo,SMPS_RAM.variables.bitfield2(a6) ; Clownacy | If so, set flag

.nopalmode:
	movea.l	d1,a4			; a4 now points to (uncompressed) song data
	move.w	(a4),d2			; Load voice pointer
    if SMPS_EnableUniversalVoiceBank
	bne.s	.doesNotUseUniVoiceBank
	move.l	#UniVoiceBank,d2
	bra.s	.got_voice_pointer
.doesNotUseUniVoiceBank:
    endif
	ext.l	d2
	add.l	a4,d2			; It is a relative pointer
.got_voice_pointer:
	move.b	2+4+1(a4),d0		; Load tempo
	move.b	d0,SMPS_RAM.variables.v_tempo_mod(a6)
	btst	#f_speedup,SMPS_RAM.variables.bitfield2(a6)
	beq.s	.nospeedshoes
	move.b	SMPS_RAM.variables.v_speeduptempo(a6),d0
; loc_72068:
.nospeedshoes:
	move.b	d0,SMPS_RAM.variables.v_main_tempo(a6)
	moveq	#0,d1
	move.b	d1,SMPS_RAM.variables.v_main_tempo_timeout(a6)	; Clownacy | Cleared to avoid unintended overflow on first frame of playback
	move.b	#5,SMPS_RAM.variables.v_pal_audio_countdown(a6)	; Clownacy | "reset PAL update tick to 5 (update immediately)"
	movea.l	a4,a3

	addq.w	#2+4+2,a4			; Point past header

	; Clownacy | One of Valley Bell's fixes: this vital code is skipped if FM/DAC channels is 0, so it's been moved to avoid that
	move.b	2+4+0(a3),d4		; Load tempo dividing timing
	moveq	#SMPS_Track.len,d6
	moveq	#1,d5			; Note duration for first "note"

	move.b	#$82,d3			; Initial PlaybackControl value

	moveq	#0,d7			; Clownacy | Hey, look! It's the 'moveq	#0,d7' that the other Play_X's were missing!
	move.b	2+0(a3),d7		; Load number of FM+DAC tracks
	beq.w	.bgm_fmdone		; Branch if zero
	subq.b	#1,d7
	move.b	#$C0,d1			; Default AMS+FMS+Panning
	lea	SMPS_RAM.v_music_fmdac_tracks(a6),a1
; loc_72098:
.bmg_fmloadloop:
	; Clownacy | (From S2) Now sets 'track at rest' bit to prevent hanging notes
	move.b	d3,SMPS_Track.PlaybackControl(a1)	; Initial playback control: set 'track playing' and 'track at rest' bits

	move.b	d4,SMPS_Track.TempoDivider(a1)
	move.b	d6,SMPS_Track.StackPointer(a1)	; Set "gosub" (coord flag F8h) stack init value
	move.b	d1,SMPS_Track.AMSFMSPan(a1)		; Set AMS/FMS/Panning
	move.b	d5,SMPS_Track.DurationTimeout(a1)	; Set duration of first "note"
	move.w	(a4)+,d0			; Load DAC/FM pointer
	ext.l	d0				; Clownacy | Fix negative pointers
	add.l	a3,d0				; Relative pointer
	move.w	d0,SMPS_Track.DataPointer+2(a1)	; Store track pointer
	swap	d0
	move.b	d0,SMPS_Track.DataPointer+1(a1)	; Store track pointer
	move.b	(a4)+,SMPS_Track.Transpose(a1)	; Load FM channel modifier
	move.b	(a4)+,SMPS_Track.Volume(a1)	; Load FM channel modifier
	move.l	d2,SMPS_Track.VoicePtr(a1)	; Load voice pointer
	adda.w	d6,a1
	dbf	d7,.bmg_fmloadloop
; loc_72114:
.bgm_fmdone:
	moveq	#0,d7
	move.b	2+1(a3),d7	; Load number of PSG tracks
	beq.s	.bgm_psgdone	; Branch if zero
	subq.b	#1,d7
	lea	SMPS_RAM.v_music_psg_tracks(a6),a1
; loc_72126:
.bgm_psgloadloop:
	; Clownacy | (From S2) Now sets 'track at rest' bit to prevent hanging notes
	move.b	d3,SMPS_Track.PlaybackControl(a1)	; Initial playback control: set 'track playing' and 'track at rest' bits

	move.b	d4,SMPS_Track.TempoDivider(a1)
	move.b	d6,SMPS_Track.StackPointer(a1)	; Set "gosub" (coord flag F8h) stack init value
	move.b	d5,SMPS_Track.DurationTimeout(a1)	; Set duration of first "note"
	move.w	(a4)+,d0			; Load PSG channel pointer
	ext.l	d0				; Clownacy | Fix negative pointers
	add.l	a3,d0				; Relative pointer
	move.w	d0,SMPS_Track.DataPointer+2(a1)	; Store track pointer
	swap	d0
	move.b	d0,SMPS_Track.DataPointer+1(a1)	; Store track pointer
	move.b	(a4)+,SMPS_Track.Transpose(a1)	; Load PSG modifier
	move.b	(a4)+,SMPS_Track.Volume(a1)	; Load PSG modifier
	addq.w	#1,a4				; Skip redundant byte (SMPS2ASM calls this 'mod', and SMPS 68k Type 2 actually does use it for modulation ($A(a5)))
	move.b	(a4)+,SMPS_Track.VoiceIndex(a1)	; Initial PSG tone
	adda.w	d6,a1
	dbf	d7,.bgm_psgloadloop
; loc_72154:
.bgm_psgdone:

    if SMPS_EnablePWM
	moveq	#0,d7
	move.b	2+2(a3),d7	; Load number of PWM tracks
	beq.s	.bgm_pwmdone	; Branch if zero
	subq.b	#1,d7
	lea	SMPS_RAM.v_music_pwm_tracks(a6),a1

.bgm_pwmloadloop:
	move.b	d3,SMPS_Track.PlaybackControl(a1)	; Initial playback control: set 'track playing' and 'track at rest' bits
	move.b	d4,SMPS_Track.TempoDivider(a1)
	move.b	d6,SMPS_Track.StackPointer(a1)	; Set "gosub" (coord flag F8h) stack init value
	move.b	d5,SMPS_Track.DurationTimeout(a1)	; Set duration of first "note"
	move.w	(a4)+,d0			; Load PWM channel pointer
	ext.l	d0				; Clownacy | Fix negative pointers
	add.l	a3,d0				; Relative pointer
	move.w	d0,SMPS_Track.DataPointer+2(a1)	; Store track pointer
	swap	d0
	move.b	d0,SMPS_Track.DataPointer+1(a1)	; Store track pointer
	move.b	(a4)+,SMPS_Track.Transpose(a1)	; Load PWM modifier
	move.b	(a4)+,SMPS_Track.Volume(a1)	; Load PWM modifier
	adda.w	d6,a1
	dbf	d7,.bgm_pwmloadloop

.bgm_pwmdone:
    endif

	lea	SMPS_RAM.v_sfx_track_ram(a6),a1
	moveq	#SMPS_SFX_TRACK_COUNT-1,d7	; 6 SFX tracks
; loc_7215A:
.sfxstoploop:
	tst.b	SMPS_Track.PlaybackControl(a1)	; Is SFX playing?
	bpl.s	.sfxnext			; Branch if not
	moveq	#0,d0
	move.b	SMPS_Track.VoiceControl(a1),d0	; Get voice control bits
	bmi.s	.sfxpsgchannel			; Branch if this is a PSG channel
	subq.w	#2,d0				; SFX can't have FM1 or FM2
	add.w	d0,d0
	bra.s	.gotchannelindex
; ===========================================================================
; loc_7216E:
.sfxpsgchannel:
	lsr.w	#4,d0		; Convert to index
; loc_72170:
.gotchannelindex:
	lea	SFX_BGMChannelRAM(pc),a0
	movea.w	(a0,d0.w),a0
	adda.l	a6,a0
	; Clownacy | For some reason, this was changed to a bclr in S2's driver, breaking the code
	bset	#2,SMPS_Track.PlaybackControl(a0)	; Set 'SFX is overriding' bit
; loc_7217C:
.sfxnext:
	adda.w	d6,a1
	dbf	d7,.sfxstoploop

    if SMPS_EnableSpecSFX
	tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Is special SFX being played?
	bpl.s	.checkspecialpsg			; Branch if not
	bset	#2,SMPS_RAM.v_music_fm4_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
; loc_7218E:
.checkspecialpsg:
	tst.b	SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6)	; Is special SFX being played?
	bpl.s	.sendfmnoteoff				; Branch if not
	bset	#2,SMPS_RAM.v_music_psg3_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
    endif
; loc_7219A:
.sendfmnoteoff:
	lea	SMPS_RAM.v_music_fm_tracks(a6),a5
	moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d5
; loc_721A0:
.fmnoteoffloop:
	btst	#2,SMPS_Track.PlaybackControl(a5)
	bne.s	.nexttrack
	bsr.w	FMSilenceChannel
.nexttrack:
	adda.w	d6,a5
	dbf	d5,.fmnoteoffloop	; Run all FM tracks
	moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d5
; loc_721AC:
.psgnoteoffloop:
	bsr.w	PSGNoteOff
	adda.w	d6,a5
	dbf	d5,.psgnoteoffloop	; Run all PSG tracks

    if SMPS_EnablePWM
	bra.w	PWMSilenceAll		; TODO - We don't properly support PWM SFX yet, but when we do, this needs changing
    else
	rts
    endif

; ===========================================================================
ChannelInitBytes:
; byte_721BA:
FMDACInitBytes:
	; DAC, FM1, FM2, FM3, FM4, FM5, FM6
	dc.b 6|%10000, 0, 1, 2, 4, 5, 6	; first byte is for DAC; then notice the 0, 1, 2 then 4, 5, 6; this is the gap between parts I and II for YM2612 port writes
	; %10000 is to mark the track as DAC
; byte_721C2:
PSGInitBytes:
	; PSG1, PSG2, PSG3
	dc.b $80, $A0, $C0

    if SMPS_EnablePWM
PWMInitBytes:
	; PWM1, PWM2, PWM3, PWM4
	dc.b $00|%1000, $02|%1000, $04|%1000, $06|%1000
	; $00, $02, $04, and $06 are indexes into SMPS_pwm_comm
	; %1000 is to mark the track as PWM
    endif
	even
; ===========================================================================

PlaySFX_Ring:
	bchg	#v_ring_speaker,SMPS_RAM.bitfield1(a6)	; Is the ring sound playing on right speaker?
	bne.s	.gotringspeaker			; Branch if not
	move.b	#SndID_RingLeft,d7		; Play ring sound in left speaker
; loc_721EE:
.gotringspeaker:
	bra.s	Sound_PlaySFX.play_sfx

    if SMPS_PushSFXBehaviour
PlaySFX_Push:
	bset	#f_push_playing,SMPS_RAM.bitfield1(a6)	; Mark pushing sound as playing
	beq.s	Sound_PlaySFX.play_sfx
	rts
    endif

    if SMPS_GloopSFXBehaviour
PlaySFX_Gloop:
	bchg	#v_gloop_toggle,SMPS_RAM.bitfield1(a6)	; Z80 cpl
	bne.s	Sound_PlaySFX.play_sfx
	rts
    endif

    if SMPS_EnableSpinDashSFX
PlaySFX_SpinDashRev:
	move.b	SMPS_RAM.v_spindash_pitch(a6),d0		; Store extra frequency
	tst.b	SMPS_RAM.v_spindash_timer(a6)		; Is the Spin Dash timer active?
	bne.s	.sfx_timeractive		; If it is, branch
	moveq	#-1,d0				; Otherwise, reset frequency (becomes 0 on next line)

.sfx_timeractive:
	addq.b	#1,d0
	cmpi.b	#$C,d0				; Has the limit been reached?
	bhs.s	.sfx_limitreached		; If it has, branch
	move.b	d0,SMPS_RAM.v_spindash_pitch(a6)		; Otherwise, set new frequency

.sfx_limitreached:
	bset	#f_spindash_lastsound,SMPS_RAM.bitfield1(a6)	; Set flag
	move.b	#60,SMPS_RAM.v_spindash_timer(a6)		; Set timer
	bra.s	Sound_PlaySFX.play_sfx

.sfx_notspindashrev:
    endif

; ---------------------------------------------------------------------------
; Play normal sound effect
; ---------------------------------------------------------------------------
; Sound_A0toCF:
Sound_PlaySFX:
	btst	#f_1up_playing,SMPS_RAM.variables.bitfield2(a6)		; Is 1-up playing?
	bne.w	.clear_sndprio			; Exit is it is
;	tst.b	SMPS_RAM.variables.v_fadeout_counter(a6)		; Is music being faded out?	; Clownacy | S2's driver doesn't bother with this
;	bne.w	.clear_sndprio			; Exit if it is
	btst	#f_fadeinflag,SMPS_RAM.variables.bitfield2(a6)		; Is music being faded in?
	bne.w	.clear_sndprio			; Exit if it is
    if SMPS_EnableSpinDashSFX
	bclr	#f_spindash_lastsound,SMPS_RAM.bitfield1(a6)
    endif

	cmpi.b	#SndID_Ring,d7			; Is ring sound	effect played?
	beq.s	PlaySFX_Ring
    if SMPS_PushSFXBehaviour
	cmpi.b	#sfx_Push,d7			; Is "pushing" sound played?
	beq.s	PlaySFX_Push
    endif
    if SMPS_GloopSFXBehaviour
	cmpi.b	#SndID_Gloop,d7			; Is bloop/gloop sound played?
	beq.s	PlaySFX_Gloop
    endif
    if SMPS_EnableSpinDashSFX
	cmpi.b	#SndID_SpindashRev,d7		; Is this the Spin Dash sound?
	beq.s	PlaySFX_SpinDashRev
    endif

.play_sfx:

    if SMPS_EnableContSFX
	cmpi.b	#SMPS_First_ContSFX,d7		; Is this a continuous SFX?
	blo.s	.sfx_notcont			; If not, branch
	moveq	#0,d0
	move.b	SMPS_RAM.variables.v_current_contsfx(a6),d0
	cmp.b	d7,d0					; Is this the same continuous sound that was playing?
	bne.s	.sfx_notsame				; If not, branch
	bset	#f_continuous_sfx,SMPS_RAM.bitfield1(a6)	; Set flag for continuous playback mode
	subi.b	#SndID__First,d7
	add.w	d7,d7				; Convert sfx ID into index
	add.w	d7,d7
	lea	(SoundIndex).l,a0
	movea.l	(a0,d7.w),a0
	move.b	3(a0),SMPS_RAM.variables.v_contsfx_channels(a6)	; Save number of channels in SFX
	rts

.sfx_notsame:
	bclr	#f_continuous_sfx,SMPS_RAM.bitfield1(a6)	; Clear flag for continuous playback mode
	move.b	d7,SMPS_RAM.variables.v_current_contsfx(a6)		; Mark this as the current continuous SFX

.sfx_notcont:
    endif

	subi.b	#SndID__First,d7	; Make it 0-based
	add.w	d7,d7			; Convert sfx ID into index
	add.w	d7,d7
	lea	(SoundIndex).l,a0
	movea.l	(a0,d7.w),a3		; SFX data pointer
	movea.l	a3,a1
	move.w	(a1)+,d1	; Voice pointer
	ext.l	d1
	add.l	a3,d1		; Relative pointer
	move.b	(a1)+,d5	; Dividing timing
	; DANGER! Ugh, this bug.
	; In the stock driver, sounds >= $E0 would cause a crash.
	; The original Clone Driver had a really messy workaround, and so does the SCHG (at the time of writing)
	; The real bug is that the SFX only has a range of $3F, after that, everything goes to hell.
	; Why? Look at the routine:
	; The index is made zero-based, so $A0 would become 0 (stock driver values).
	; By this logic, $DF would become $3F, and $E0: $40.
	; The value is then multiplied by 4 (the lsl), to suit the longword indexes of SoundIndex.
	; The result for $3F is $FC. Now do the same to $40, notice something?
	; The result is $100. We go beyond a single byte, this is the catalyst.
	; The second line below (move.b) tries to overwrite the register that holds the modified value... with a byte.
	; So, we blank the *entire* register.
	; DANGER! there is a missing 'moveq	#0,d7' here, without which SFXes whose
	; index entry is above $3F will cause a crash. This is actually the same way that
	; this bug is fixed in Ristar's driver.
	moveq	#0,d7

	move.b	(a1)+,d7	; Number of tracks (FM + PSG)
	subq.b	#1,d7
	moveq	#SMPS_Track.len,d6
; loc_72228:
.sfx_loadloop:
	moveq	#0,d3
	move.b	1(a1),d3	; Channel assignment bits
	move.b	d3,d4
	bmi.s	.sfxinitpsg	; Branch if PSG
	subq.w	#2,d3		; SFX can only have FM3, FM4 or FM5
	add.w	d3,d3
	lea	SFX_BGMChannelRAM(pc),a5
	movea.w	(a5,d3.w),a5
	adda.l	a6,a5
	bset	#2,SMPS_Track.PlaybackControl(a5)	; Mark music track as being overridden
	bra.s	.sfxoverridedone
; ===========================================================================
; loc_72244:
.sfxinitpsg:
	lsr.w	#4,d3
	lea	SFX_BGMChannelRAM(pc),a5
	movea.w	(a5,d3.w),a5
	adda.l	a6,a5
	bset	#2,SMPS_Track.PlaybackControl(a5)	; Mark music track as being overridden
	move.b	d4,d0
	ori.b	#$1F,d0			; Command to silence PSG
	move.b	d0,(SMPS_psg_input).l
	cmpi.b	#$C0,d4			; Is this PSG 3?
	bne.s	.sfxoverridedone	; Branch if not
	bchg	#5,d0			; Command to silence noise channel
	move.b	d0,(SMPS_psg_input).l	; Silence PSG 4 (noise), too
; loc_7226E:
.sfxoverridedone:
	movea.w	SFX_SFXChannelRAM(pc,d3.w),a5
	adda.l	a6,a5
	movea.l	a5,a2
	moveq	#(SMPS_Track.len/4)-1,d0	; $30 bytes
	moveq	#0,d2
; loc_72276:
.clearsfxtrackram:
	move.l	d2,(a2)+
	dbf	d0,.clearsfxtrackram

	; Clownacy | Make sure the last few bytes get cleared
    if SMPS_Track.len&2
	move.w	d2,(a2)+
    endif
    if SMPS_Track.len&1
	move.b	d2,(a2)+
    endif

	move.w	(a1)+,SMPS_Track.PlaybackControl(a5)	; Initial playback control bits
	move.b	d5,SMPS_Track.TempoDivider(a5)		; Initial voice control bits
	move.w	(a1)+,d0				; Track data pointer
	ext.l	d0					; Clownacy | Fix negative pointers
	add.l	a3,d0					; Relative pointer
	move.w	d0,SMPS_Track.DataPointer+2(a5)		; Store track pointer
	swap	d0
	move.b	d0,SMPS_Track.DataPointer+1(a5)		; Store track pointer
	move.b	(a1)+,SMPS_Track.Transpose(a5)		; load FM/PSG channel modifier
	move.b	(a1)+,SMPS_Track.Volume(a5)		; load FM/PSG channel modifier
	move.b	#1,SMPS_Track.DurationTimeout(a5)		; Set duration of first "note"
    if SMPS_EnableSpinDashSFX
	btst	#f_spindash_lastsound,SMPS_RAM.bitfield1(a6)	; Is the Spin Dash sound playing?
	beq.s	.notspindash				; If not, branch
	move.b	SMPS_RAM.v_spindash_pitch(a6),d0
	add.b	d0,SMPS_Track.Transpose(a5)
.notspindash:
    endif
	move.b	d6,SMPS_Track.StackPointer(a5)	; Set "gosub" (coord flag F8h) stack init value
	tst.b	d4				; Is this a PSG channel?
	bmi.s	.sfxpsginitdone			; Branch if yes
	move.b	#$C0,SMPS_Track.AMSFMSPan(a5)	; AMS/FMS/Panning
	move.l	d1,SMPS_Track.VoicePtr(a5)		; Voice pointer
; loc_722A8:
.sfxpsginitdone:
	dbf	d7,.sfx_loadloop

    if SMPS_EnableSpecSFX
	tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6)	; Is SFX being played?
	bpl.s	.doneoverride				; Branch if not
	bset	#2,SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Set SFX is overriding bit
; loc_722B8:
.doneoverride:
	tst.b	SMPS_RAM.v_sfx_psg3_track.PlaybackControl(a6)	; Is special SFX being played?
	bpl.s	.locret					; Branch if not
	bset	#2,SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6) ; Set SFX is overriding bit
    endif
; locret_722C4:
.locret:
	rts
; ===========================================================================
; loc_722C6:
.clear_sndprio:
	clr.b	SMPS_RAM.variables.v_sndprio(a6)	; Clear priority
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; RAM addresses for FM and PSG channel variables used by the SFX
; ---------------------------------------------------------------------------
; dword_722CC: BGMChannelRAM:
SFX_BGMChannelRAM:
	dc.w SMPS_RAM.v_music_fm3_track
	dc.w 0
	dc.w SMPS_RAM.v_music_fm4_track
	dc.w SMPS_RAM.v_music_fm5_track
	dc.w SMPS_RAM.v_music_psg1_track
	dc.w SMPS_RAM.v_music_psg2_track
	dc.w SMPS_RAM.v_music_psg3_track	; Plain PSG3
	dc.w SMPS_RAM.v_music_psg3_track	; Noise
; dword_722EC: SFXChannelRAM:
SFX_SFXChannelRAM:
	dc.w SMPS_RAM.v_sfx_fm3_track
	dc.w 0
	dc.w SMPS_RAM.v_sfx_fm4_track
	dc.w SMPS_RAM.v_sfx_fm5_track
	dc.w SMPS_RAM.v_sfx_psg1_track
	dc.w SMPS_RAM.v_sfx_psg2_track
	dc.w SMPS_RAM.v_sfx_psg3_track	; Plain PSG3
	dc.w SMPS_RAM.v_sfx_psg3_track	; Noise

; ===========================================================================
; ---------------------------------------------------------------------------
; Play GHZ waterfall sound
; ---------------------------------------------------------------------------
    if SMPS_EnableSpecSFX
; Sound_D0toDF:
Sound_PlaySpecial:
	btst	#f_1up_playing,SMPS_RAM.variables.bitfield2(a6)		; Is 1-up playing?
	bne.w	.locret				; Return if so
;	tst.b	SMPS_RAM.variables.v_fadeout_counter(a6)		; Is music being faded out?	; Clownacy | S2's driver didn't bother with this in Sound_PlaySFX
;	bne.w	.locret				; Exit if it is
	btst	#f_fadeinflag,SMPS_RAM.variables.bitfield2(a6)		; Is music being faded in?
	bne.w	.locret				; Exit if it is
	lea	(SpecSoundIndex).l,a0
	subi.b	#SpecID__First,d7		; Make it 0-based
	add.w	d7,d7
	add.w	d7,d7
	movea.l	(a0,d7.w),a3
	movea.l	a3,a1
	move.w	(a1)+,d1	; Store voice pointer
	ext.l	d1
	add.l	a3,d1
	move.b	(a1)+,d5			; Dividing timing
	; DANGER! there is a missing 'moveq	#0,d7' here, without which Special SFXes whose
	; index entry is above $3F will cause a crash. Ristar's driver didn't have this
	; particular instance fixed.
	moveq	#0,d7

	move.b	(a1)+,d7	; Number of tracks (FM + PSG)
	subq.b	#1,d7
	moveq	#SMPS_Track.len,d6
; loc_72348:
.sfxloadloop:
	move.b	1(a1),d4					; Voice control bits
	bmi.s	.sfxoverridepsg					; Branch if PSG
	bset	#2,SMPS_RAM.v_music_fm4_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
	lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
	bra.s	.sfxinitpsg
; ===========================================================================
; loc_7235A:
.sfxoverridepsg:
	bset	#2,SMPS_RAM.v_music_psg3_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
	lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a5
; loc_72364:
.sfxinitpsg:
	movea.l	a5,a2
	moveq	#(SMPS_Track.len/4)-1,d0	; $30 bytes
	moveq	#0,d2
; loc_72368:
.clearsfxtrackram:
	move.l	d2,(a2)+
	dbf	d0,.clearsfxtrackram

	; Clownacy | Make sure the last few bytes get cleared
    if SMPS_Track.len&2
	move.w	d2,(a2)+
    endif
    if SMPS_Track.len&1
	move.b	d2,(a2)+
    endif

	move.w	(a1)+,SMPS_Track.PlaybackControl(a5)	; Initial playback control bits
	move.b	d5,SMPS_Track.TempoDivider(a5)		; Initial voice control bits
	move.w	(a1)+,d0				; Track data pointer
	ext.l	d0					; Clownacy | Support negative pointers
	add.l	a3,d0					; Relative pointer
	move.w	d0,SMPS_Track.DataPointer+2(a5)		; Store track pointer
	swap	d0
	move.b	d0,SMPS_Track.DataPointer+1(a5)		; Store track pointer
	move.b	(a1)+,SMPS_Track.Transpose(a5)		; load FM/PSG channel modifier
	move.b	(a1)+,SMPS_Track.Volume(a5)		; load FM/PSG channel modifier
	move.b	#1,SMPS_Track.DurationTimeout(a5)		; Set duration of first "note"
	move.b	d6,SMPS_Track.StackPointer(a5)		; set "gosub" (coord flag F8h) stack init value
	tst.b	d4					; Is this a PSG channel?
	bmi.s	.sfxpsginitdone				; Branch if yes
	move.b	#$C0,SMPS_Track.AMSFMSPan(a5)		; AMS/FMS/Panning
	move.l	d1,SMPS_Track.VoicePtr(a5)			; Store voice pointer
; loc_72396:
.sfxpsginitdone:
	dbf	d7,.sfxloadloop

	tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6)	; Is track playing?
	bpl.s	.doneoverride				; Branch if not
	bset	#2,SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Set 'SFX is overriding' track
; loc_723A6:
.doneoverride:
	tst.b	SMPS_RAM.v_sfx_psg3_track.PlaybackControl(a6)	; Is track playing?
	bpl.s	.PSG3NotOverrided			; Branch if not
	bset	#2,SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6) ; Set 'SFX is overriding' track
	; The original driver made the mistake of silencing PSG3 when the
	; SFX track is using it, not the Special SFX
	rts

.PSG3NotOverrided:
	ori.b	#$1F,d4					; Command to silence channel
	lea	(SMPS_psg_input).l,a1
	move.b	d4,(a1)
	bchg	#5,d4					; Command to silence noise channel
	move.b	d4,(a1)
; locret_723C6:
.locret:
	rts
; End of function PlaySoundID
    endif

; ===========================================================================

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Snd_FadeOut1: Snd_FadeOutSFX: FadeOutSFX:
StopSFX:
	clr.b	SMPS_RAM.variables.v_sndprio(a6)			; Clear priority
	lea	SMPS_RAM.v_sfx_track_ram(a6),a5
	moveq	#SMPS_SFX_TRACK_COUNT-1,d6	; 3 FM + 3 PSG (SFX)	; Clownacy | Now uses d6 instead of d7 so it doesn't conflict with Sound_PlayBGM
; loc_723EA:
.trackloop:
	tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
	bpl.w	.nexttrack			; Branch if not
	bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
	bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note'
	moveq	#0,d3
	move.b	SMPS_Track.VoiceControl(a5),d3	; Get voice control bits
	bmi.s	.trackpsg			; Branch if PSG
	bsr.w	FMNoteOff
    if SMPS_EnableSpecSFX
	cmpi.b	#4,d3				; Is this FM4?
	bne.s	.getfmpointer			; Branch if not
	tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Is special SFX playing?
	bpl.s	.getfmpointer			; Branch if not
	; DANGER! there is a missing 'movea.l	a5,a3' here, without which the
	; code is broken. It is dangerous to do a fade out when a GHZ waterfall
	; is playing its sound!
	movea.l	a5,a3

	lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
	movea.l	SMPS_Track.VoicePtr(a5),a1	; Get special voice pointer
	bra.s	.gotfmpointer
    endif
; ===========================================================================
; loc_72416:
.getfmpointer:
	subq.w	#2,d3				; SFX only has FM3 and up
	add.w	d3,d3
	movea.l	a5,a3
	lea	SFX_BGMChannelRAM(pc),a5
	movea.w	(a5,d3.w),a5
	adda.l	a6,a5
	movea.l	SMPS_Track.VoicePtr(a5),a1		; Get music voice pointer
; loc_72428:
.gotfmpointer:
	bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
	beq.s	.nooverride			; If it was already clear, branch and do nothing
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	move.b	SMPS_Track.VoiceIndex(a5),d0	; Current voice
	bsr.w	SetVoice
.nooverride:
	movea.l	a3,a5
	bra.s	.nexttrack
; ===========================================================================
; loc_7243C:
.trackpsg:
	bsr.w	PSGNoteOff
    if SMPS_EnableSpecSFX
	lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a0
	cmpi.b	#$E0,d3					; Is this a noise channel:
	beq.s	.gotpsgpointer				; Branch if yes
	cmpi.b	#$C0,d3					; Is this PSG 3?
	beq.s	.gotpsgpointer				; Branch if yes
    endif
	lsr.w	#4,d3
	lea	SFX_BGMChannelRAM(pc),a0
	movea.w	(a0,d3.w),a0
	adda.l	a6,a0
; loc_7245A:
.gotpsgpointer:
	bclr	#2,SMPS_Track.PlaybackControl(a0)		; Clear 'SFX is overriding' bit
	bset	#1,SMPS_Track.PlaybackControl(a0)		; Set 'track at rest' bit
	cmpi.b	#$E0,SMPS_Track.VoiceControl(a0)		; Is this a noise channel?
	bne.s	.nexttrack					; Branch if not
	move.b	SMPS_Track.PSGNoise(a0),(SMPS_psg_input).l	; Set noise type
; loc_72472:
.nexttrack:
	lea	SMPS_Track.len(a5),a5
	dbf	d6,.trackloop		; Clownacy | Now uses d6 instead of d7 so it doesn't conflict with Sound_PlayBGM
.locret:
	rts
; End of function StopSFX


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
    if SMPS_EnableSpecSFX
; Snd_FadeOut2: Snd_FadeOutSFX2: FadeOutSpecSFX:
StopSpecSFX:
	lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
	tst.b	SMPS_Track.PlaybackControl(a5)			; Is track playing?
	bpl.s	.fadedfm					; Branch if not
	bclr	#7,SMPS_Track.PlaybackControl(a5)		; Stop track
	btst	#2,SMPS_Track.PlaybackControl(a5)		; Is SFX overriding?
	bne.s	.fadedfm					; Branch if not
	bsr.w	SendFMNoteOff
	lea	SMPS_RAM.v_music_fm4_track(a6),a5
	bclr	#2,SMPS_Track.PlaybackControl(a5)		; Clear 'SFX is overriding' bit
	bset	#1,SMPS_Track.PlaybackControl(a5)		; Set 'track at rest' bit
	tst.b	SMPS_Track.PlaybackControl(a5)			; Is track playing?
	bpl.s	.fadedfm					; Branch if not
	movea.l	SMPS_Track.VoicePtr(a5),a1			; Voice pointer
	move.b	SMPS_Track.VoiceIndex(a5),d0			; Current voice
	bsr.w	SetVoice
; loc_724AE:
.fadedfm:
	lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a5
	tst.b	SMPS_Track.PlaybackControl(a5)			; Is track playing?
	bpl.s	.fadedpsg					; Branch if not
	bclr	#7,SMPS_Track.PlaybackControl(a5)		; Stop track
	btst	#2,SMPS_Track.PlaybackControl(a5)		; Is SFX overriding?
	bne.s	.fadedpsg					; Return if not
	bsr.w	SendPSGNoteOff
	lea	SMPS_RAM.v_music_psg3_track(a6),a5
	bclr	#2,SMPS_Track.PlaybackControl(a5)		; Clear 'SFX is overriding' bit
	bset	#1,SMPS_Track.PlaybackControl(a5)		; Set 'track at rest' bit
	tst.b	SMPS_Track.PlaybackControl(a5)			; Is track playing?
	bpl.s	.fadedpsg					; Return if not
	cmpi.b	#$E0,SMPS_Track.VoiceControl(a5)		; Is this a noise channel?
	bne.s	.fadedpsg					; Return if not
	move.b	SMPS_Track.PSGNoise(a5),(SMPS_psg_input).l	; Set noise type
; locret_724E4:
.fadedpsg
	rts
; End of function StopSpecSFX
    endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Fade out music
; ---------------------------------------------------------------------------
; Sound_E0:
FadeOutMusic:
	; Clownacy | In Sonic 2's driver, StopSFX is split into its own sound command
	; and StopSpecSFX is bumped out entirely
;	bsr.w	StopSFX
;    if SMPS_EnableSpecSFX
;	bsr.s	StopSpecSFX
;    endif
	move.b	#3,SMPS_RAM.variables.v_fadeout_delay(a6)	; Set fadeout delay to 3
	move.b	#$28,SMPS_RAM.variables.v_fadeout_counter(a6)	; Set fadeout counter

	; Fade out CD track
	tst.b	(SegaCD_Mode).w
	beq.s	.skip
	MCDSend	#_MCD_PauseTrack, #$28		; flag, timer

.skip:
	bclr	#f_speedup,SMPS_RAM.variables.bitfield2(a6)	; Disable speed shoes tempo
	rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72504:
DoFadeOut:
	tst.b	SMPS_RAM.variables.v_fadeout_delay(a6)		; Has fadeout delay expired?
	beq.s	.continuefade					; Branch if yes
	subq.b	#1,SMPS_RAM.variables.v_fadeout_delay(a6)
	rts
; ===========================================================================
; loc_72510:
.continuefade:
	subq.b	#1,SMPS_RAM.variables.v_fadeout_counter(a6)	; Update fade counter
	beq.w	StopAllSound					; Branch if fade is done
	move.b	#3,SMPS_RAM.variables.v_fadeout_delay(a6)	; Reset fade delay
	lea	SMPS_RAM.v_music_track_ram(a6),a5

	; Fade DAC
	tst.b	SMPS_Track.PlaybackControl(a5)			; Is track playing?
	bpl.s	.fadefm						; Branch if not
	addq.b	#4,SMPS_Track.Volume(a5)			; Increase volume attenuation
	bpl.s	.senddacvol					; Branch if maximum reached (channel is silent)
	bclr	#7,SMPS_Track.PlaybackControl(a5)		; Stop track
	bra.s	.fadefm
; ===========================================================================

.senddacvol:
	bsr.w	SetDACVolume

.fadefm:
	lea	SMPS_Track.len(a5),a5

	; Fade FM
	moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM tracks
; loc_72524:
.fmloop:
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
	bpl.s	.nextfm					; Branch if not
	addq.b	#1,SMPS_Track.Volume(a5)		; Increase volume attenuation
	bpl.s	.sendfmtl				; Branch if still positive
	bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
	bra.s	.nextfm
; ===========================================================================
; loc_72534:
.sendfmtl:
	bsr.w	SendVoiceTL
; loc_72538:
.nextfm:
	lea	SMPS_Track.len(a5),a5
	dbf	d7,.fmloop

	; Fade PSG
	moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks
; loc_72542:
.psgloop:
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
	bpl.s	.nextpsg				; branch if not
	addq.b	#4,SMPS_Track.Volume(a5)		; Increase volume attenuation
	bpl.s	.sendpsgvol				; Branch if maximum annutation not reached
	bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
	bra.s	.nextpsg
; ===========================================================================
; loc_72558:
.sendpsgvol:
	; If a volume envelope is active, then it will handle updating the volume for us.
	; Doing it manually will just conflict with it.
	tst.b	SMPS_Track.VoiceIndex(a5)
	bne.s	.nextpsg

	move.b	SMPS_Track.Volume(a5),d6	; Store new volume attenuation
	bsr.w	SetPSGVolume
; loc_72560:
.nextpsg:
	lea	SMPS_Track.len(a5),a5
	dbf	d7,.psgloop

	; Done
	rts
; End of function DoFadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

FMSilenceChannel:
	moveq	#$40,d3	; Total level
	moveq	#$7F,d1	; Total attenuation (silent)
	bsr.s	+

	move.b	#$80,d3	; Release rate
	moveq	#$F,d1	; Maximum
	bsr.s	+

	bra.w	FMNoteOff

+	moveq	#4-1,d4	; Four operators
-	move.b	d3,d0
	bsr.w	WriteFMIorII
	addq.b	#4,d3
	dbf	d4,-
	rts
; End of function FMSilenceChannel

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_7256A:
FMSilenceAll:
	moveq	#2,d3		; 3 FM channels for each YM2612 parts
	moveq	#$28,d0		; FM key on/off register
; loc_7256E:
.noteoffloop:
	move.b	d3,d1
	bsr.w	WriteFMI
	addq.b	#4,d1		; Move to YM2612 part 1
	bsr.w	WriteFMI
	dbf	d3,.noteoffloop

	moveq	#$40,d0		; Set TL on FM channels...
	moveq	#$7F,d1		; ... to total attenuation...
	moveq	#2,d4		; ... for all 3 channels...
; loc_72584:
.channelloop:
	moveq	#3,d3		; ... for all operators on each channel...
; loc_72586:
.channeltlloop:
	bsr.w	WriteFMI		; ... for part 0...
	bsr.w	WriteFMII		; ... and part 1
	addq.w	#4,d0			; Next TL operator
	dbf	d3,.channeltlloop

	subi.b	#$F,d0		; Move to TL operator 1 of next channel
	dbf	d4,.channelloop

	rts
; End of function FMSilenceAll

; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music
; ---------------------------------------------------------------------------
; Sound_E4: StopSoundAndMusic:
StopAllSound:

	; If CDA is playing, stop it
	tst.b	SMPS_RAM.variables.v_cda_playing(a6)
	beq.s	.NoCD
	MCDSend	#_MCD_PauseTrack, #0		; Stop
	clr.b	SMPS_RAM.variables.v_cda_playing(a6)

.NoCD:
	moveq	#$27,d0		; Timers, FM3/FM6 mode
	moveq	#0,d1		; FM3/FM6 normal mode, disable timers
	bsr.w	WriteFMI

	; Clear variables
	lea	SMPS_RAM.variables(a6),a0
	moveq	#(SMPS_RAM_Variables.len/4)-1,d1
	moveq	#0,d0
; loc_725B6:
.clearvariablesloop:
	move.l	d0,(a0)+
	dbf	d1,.clearvariablesloop

    if SMPS_RAM_Variables.len&2
	move.w	d0,(a0)+
    endif
    if SMPS_RAM_Variables.len&1
	move.b	d0,(a0)+
    endif

	; Clear track RAM
	lea	SMPS_RAM.v_music_track_ram(a6),a0
	move.w	#((SMPS_RAM.v_spcsfx_track_ram_end-SMPS_RAM.v_music_track_ram)/4)-1,d1	; Clear all variables and track data (don't really care about clearing the music track backup)

.cleartrackRAMloop:
	move.l	d0,(a0)+
	dbf	d1,.cleartrackRAMloop

    if (SMPS_RAM.v_spcsfx_track_ram_end-SMPS_RAM.v_music_track_ram)&2
	move.w	d0,(a0)+
    endif
    if (SMPS_RAM.v_spcsfx_track_ram_end-SMPS_RAM.v_music_track_ram)&1
	move.b	d0,(a0)+
    endif

	; From Vladikcomper:
	; "Playing sample $80 forces to stop playback."
	; "We need the Z80 to be stopped before this command executes and to be started directly afterwards."
	SMPS_stopZ80_safe
	move.b  #$80,(SMPS_z80_ram+MegaPCM_DAC_Number).l	; stop DAC playback
	SMPS_startZ80_safe

    if SMPS_EnablePWM
	bsr.w	PWMSilenceAll
    endif
	bsr.w	FMSilenceAll
	bra.w	PSGSilenceAll

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_725CA:
InitMusicPlayback:
	; WARNING: Must not use d7

	; Save several values
	move.b	SMPS_RAM.variables.v_sndprio(a6),d3
	move.b	SMPS_RAM.variables.bitfield2(a6),d4
	andi.b	#(1<<f_1up_playing)|(1<<f_speedup),d4
	move.b	SMPS_RAM.variables.v_fadein_counter(a6),d5
	move.l	SMPS_RAM.variables.queue(a6),d6

	; Clear variables
	lea	SMPS_RAM.variables(a6),a0
	moveq	#(SMPS_RAM_Variables.len/4)-1,d1
	moveq	#0,d0

; loc_725E4:
.clearvariablesloop:
	move.l	d0,(a0)+
	dbf	d1,.clearvariablesloop

    if SMPS_RAM_Variables.len&2
	move.w	d0,(a0)+
    endif
    if SMPS_RAM_Variables.len&1
	move.b	d0,(a0)+
    endif

	; Clear music track RAM
	lea	SMPS_RAM.v_music_track_ram(a6),a0
	moveq	#((SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)/4)-1,d1

; loc_725E4:
.clearramloop:
	move.l	d0,(a0)+
	dbf	d1,.clearramloop

    if (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)&2
	move.w	d0,(a0)+
    endif
    if (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)&1
	move.b	d0,(a0)+
    endif

	; Restore the values saved above
	move.b	d3,SMPS_RAM.variables.v_sndprio(a6)
	move.b	d4,SMPS_RAM.variables.bitfield2(a6)
	move.b	d5,SMPS_RAM.variables.v_fadein_counter(a6)
	move.l	d6,SMPS_RAM.variables.queue(a6)

	; Reset DAC volume
	moveq	#0|((MegaPCM_VolumeTbls&$F000)>>8),d0	; Clownacy | Reset DAC volume to maximum
	bsr.w	WriteDACVolume
	; Also reset DAC pan
	move.b	#$B6,d0			; Register for AMS/FMS/Panning on FM6 (DAC)
	move.b	#$C0,d1			; Value to send
	bsr.w	WriteFMIorII

	; InitMusicPlayback, and Sound_PlayBGM for that matter,
	; don't do a very good job of setting up the music tracks.
	; Tracks that aren't defined in a music file's header don't have
	; their channels defined, meaning .sendfmnoteoff won't silence
	; hardware properly. In combination with removing the below
	; calls to FMSilenceAll/PSGSilenceAll, this will cause hanging
	; notes.
	; To fix this, we'll just forcefully set all channels, here:
	lea	SMPS_RAM.v_music_track_ram+SMPS_Track.VoiceControl(a6),a1			; Start at the first music track...
	lea	ChannelInitBytes(pc),a2
	moveq	#SMPS_MUSIC_TRACK_COUNT-1,d1		; ...and continue to the last

.writeloop:
	move.b	(a2)+,(a1)		; Write track's channel byte
	lea	SMPS_Track.len(a1),a1		; Next track
	dbf	d1,.writeloop		; Loop for all DAC/FM/PSG tracks

	rts
; End of function InitMusicPlayback


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_7260C:
TempoWait:	; Clownacy | Ported straight from S3K's Z80 driver
	move.b	SMPS_RAM.variables.v_main_tempo(a6),d0		; Get current tempo value
	add.b	d0,SMPS_RAM.variables.v_main_tempo_timeout(a6)
	bcc.s	.skipdelay							; If the addition did not overflow, return

	lea	SMPS_RAM.v_music_track_ram+SMPS_Track.DurationTimeout(a6),a0	; Duration timeout of first track
	moveq	#SMPS_MUSIC_TRACK_COUNT-1,d0					; Number of tracks (1x DAC + 6x FM + 3x PSG)
	moveq	#SMPS_Track.len,d1

.delayloop:
	addq.b	#1,(a0)			; Delay notes another frame
	adda.l	d1,a0			; Advance to next track
	dbf	d0,.delayloop		; Loop for all tracks
; loc_71B9E:
.skipdelay:
	rts
; End of function TempoWait

; ===========================================================================
; ---------------------------------------------------------------------------
; Speed	up music
; ---------------------------------------------------------------------------
; Sound_E2:
SpeedUpMusic:
	btst	#f_1up_playing,SMPS_RAM.variables.bitfield2(a6)
	bne.s	SpeedUpMusic_1up
	move.b	SMPS_RAM.variables.v_speeduptempo(a6),SMPS_RAM.variables.v_main_tempo(a6)
	bset	#f_speedup,SMPS_RAM.variables.bitfield2(a6)
	rts
; ===========================================================================
; loc_7263E: .speedup_1up:
SpeedUpMusic_1up:
	move.b	SMPS_RAM.variables_backup.v_speeduptempo(a6),SMPS_RAM.variables_backup.v_main_tempo(a6)
	bset	#f_speedup,SMPS_RAM.variables_backup.bitfield2(a6)
	rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Change music back to normal speed
; ---------------------------------------------------------------------------
; Sound_E3:
SlowDownMusic:
	btst	#f_1up_playing,SMPS_RAM.variables.bitfield2(a6)
	bne.s	SlowDownMusic_1up
	move.b	SMPS_RAM.variables.v_tempo_mod(a6),SMPS_RAM.variables.v_main_tempo(a6)
	bclr	#f_speedup,SMPS_RAM.variables.bitfield2(a6)
	rts
; ===========================================================================
; loc_7266A: .slowdown_1up:
SlowDownMusic_1up:
	move.b	SMPS_RAM.variables_backup.v_tempo_mod(a6),SMPS_RAM.variables_backup.v_main_tempo(a6)
	bclr	#f_speedup,SMPS_RAM.variables_backup.bitfield2(a6)
	rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_7267C:
DoFadeIn:
	tst.b	SMPS_RAM.variables.v_fadein_delay(a6)	; Has fadein delay expired?
	beq.s	.continuefade				; Branch if yes
	subq.b	#1,SMPS_RAM.variables.v_fadein_delay(a6)
	rts
; ===========================================================================
; loc_72688:
.continuefade:
	tst.b	SMPS_RAM.variables.v_fadein_counter(a6)	; Update fade counter
	bne.s	.notdone
	bclr	#f_fadeinflag,SMPS_RAM.variables.bitfield2(a6)
	rts
; ===========================================================================

.notdone:
	subq.b	#1,SMPS_RAM.variables.v_fadein_counter(a6)	; Update fade counter
	move.b	#2,SMPS_RAM.variables.v_fadein_delay(a6)	; Reset fade delay
	lea	SMPS_RAM.v_music_track_ram(a6),a5

	; Fade DAC
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
	bpl.s	.fadefm					; Branch if not
	subq.b	#4,SMPS_Track.Volume(a5)		; Reduce volume attenuation
	bsr.w	SetDACVolume

.fadefm:
	lea	SMPS_Track.len(a5),a5

	; Fade FM
	moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM tracks
; loc_7269E:
.fmloop:
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
	bpl.s	.nextfm					; Branch if not
	subq.b	#1,SMPS_Track.Volume(a5)		; Reduce volume attenuation
	bsr.w	SendVoiceTL
; loc_726AA:
.nextfm:
	lea	SMPS_Track.len(a5),a5
	dbf	d7,.fmloop

	; Fade PSG
	moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks
; loc_726B4:
.psgloop:
	tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
	bpl.s	.nextpsg			; Branch if not
	subq.b	#4,SMPS_Track.Volume(a5)	; Reduce volume attenuation

	; If a volume envelope is active, then it will handle updating the volume for us.
	; Doing it manually will just conflict with it.
	tst.b	SMPS_Track.VoiceIndex(a5)
	bne.s	.nextpsg

	move.b	SMPS_Track.Volume(a5),d6	; Get value
	bsr.w	SetPSGVolume
; loc_726CC:
.nextpsg:
	lea	SMPS_Track.len(a5),a5
	dbf	d7,.psgloop

	; Done
.locret:
	rts
; End of function DoFadeIn

; ===========================================================================

SetDACVolume:
	move.b	SMPS_Track.Volume(a5),d0
	bpl.s	+		; $7F is the last valid volume
	moveq	#$F<<3,d0	; cap at maximum value (minimum volume)
+
	lsr.b	#3,d0
	ori.b	#(MegaPCM_VolumeTbls&$F000)>>8,d0

WriteDACVolume:
	SMPS_stopZ80_safe
	move.b	d0,(SMPS_z80_ram+MegaPCM_LoadBank.volume+1).l
	move.b	d0,(SMPS_z80_ram+MegaPCM_Init_PCM.volume+1).l
	SMPS_startZ80_safe
	rts
; End of function SetDACVolume

; ===========================================================================

; loc_726E2:
FMNoteOn:
	btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track resting?
	bne.s	locret_726FC				; Return if so
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
	bne.s	locret_726FC				; Return if so
	cmpi.b	#6,SMPS_Track.VoiceControl(a5)		; If this FM6?
	bne.s	.notfm6					; If not, branch
	moveq	#$2B,d0					; DAC enable/disable register
	moveq	#0,d1					; Disable DAC (letting FM6 run)
	bsr.w	WriteFMI
.notfm6:
	moveq	#$28,d0				; Note on/off register
	move.b	SMPS_Track.VoiceControl(a5),d1	; Get channel bits
	ori.b	#$F0,d1				; Note on on all operators
	bra.s	WriteFMI
; ===========================================================================
locret_726FC:
	rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_726FE:
FMNoteOff:
	btst	#4,SMPS_Track.PlaybackControl(a5)	; Is 'do not attack next note' set?
	bne.s	locret_726FC				; Return if yes
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
	bne.s	locret_726FC				; Return if yes
; loc_7270A:
SendFMNoteOff:
	moveq	#$28,d0				; Note on/off register
	move.b	SMPS_Track.VoiceControl(a5),d1	; Note off to this channel
	bra.s	WriteFMI
; End of function FMNoteOff

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72722:
WriteFMIorII:
	move.b	SMPS_Track.VoiceControl(a5),d2	; Get voice control bits
	bclr	#2,d2				; Clear chip toggle
	bne.s	WriteFMIIPart			; Branch if for part II
	or.b	d2,d0				; Add in voice control bits
; End of function WriteFMIorII


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; List of cycle counts from various revisions of WriteFMI (Write cycles + 'wait for YM' cycles)

; (SMPS 68k Type 1a)
;  Michael Jackson's Moonwalker:
;	32(6/2) + 68(14/0)
;  Strider Hiryuu
;	32(6/2) + 58(12/0) (Slightly optimised by replacing a btst #7's function with a bmi)


; (SMPS 68k Type 1b)
;  Sonic the Hedgehog:
;	32(6/2) + 80(17/0) (Interestingly, this uses the Type 1a version, with some nops, so is this an *early* Type 1b driver?)
;  Mega PCM standard:
;	52(10/3) + 102(21/0)
;  Golden Axe 2:
;	32(6/2) + 44(9/0)
;  Nekketsu Koukou Dodgeball Bu Soccer Hen MD:
;	32(6/2) + 40(8/0) (Like Golden Axe 2 minus the nop)


; (SMPS 68k Type 2)
;  Fatal Fury:
;	Same as Golden Axe 2
;  Fatal Fury 2:
;	Same as Golden Axe 2
;  Golden Axe 3:
;	Same as Golden Axe 2
;  Phantasy Star: The End of the Millenium
;	Same as Golden Axe 2
;  Super Shinobi II
;	Same as Golden Axe 2
;  Bishoujo Senshi Sailor Moon
;	Same as Golden Axe 2

; sub_7272E:
WriteFMI:
	SMPS_stopZ80_safe
	tst.b	(Z80_RAM+MegaPCM_Busy_Flag).l
	bne.s	.delayForZ80
	lea	(SMPS_ym2612_a0).l,a0			; 12(3/0)
	SMPS_waitYM
	move.b	d0,(a0)					; 8(1/1)
	move.b	d1,SMPS_ym2612_d0-SMPS_ym2612_a0(a0)	; 12(2/1)
	SMPS_delayYM
	SMPS_waitYM
	move.b	#$2A,(a0)				; 12(2/1)
	SMPS_startZ80_safe
	rts
; End of function WriteFMI

.delayForZ80:
	SMPS_startZ80_safe
	bra.s	WriteFMI

; ===========================================================================
; loc_7275A:
WriteFMIIPart:
	bclr	#4,d2				; Clear DAC indicator
	or.b	d2,d0				; Add in to destination register

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72764:
WriteFMII:
	SMPS_stopZ80_safe
	tst.b	(Z80_RAM+MegaPCM_Busy_Flag).l
	bne.s	.delayForZ80
	lea	(SMPS_ym2612_a0).l,a0			; 12(3/0)
	SMPS_waitYM
	move.b	d0,SMPS_ym2612_a1-SMPS_ym2612_a0(a0)	; 12(2/1)
	move.b	d1,SMPS_ym2612_d1-SMPS_ym2612_a0(a0)	; 12(2/1)
	SMPS_delayYM
	SMPS_waitYM
	move.b	#$2A,(a0)				; 12(2/1)
	SMPS_startZ80_safe
	rts
; End of function WriteFMII

.delayForZ80:
	SMPS_startZ80_safe
	bra.s	WriteFMII

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72850:
PSGUpdateTrack:
	subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Update note timeout
	bne.s	.notegoing
	bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack note' flag
	bsr.s	PSGDoNext
	bsr.w	NoteFillUpdate
	bsr.w	DoModulation
	bsr.w	PSGDoNoteOn
	bra.w	PSGDoVolFX
; ===========================================================================
; loc_72866:
.notegoing:
	bsr.w	NoteFillUpdate
	bsr.w	PSGUpdateVolFX
	bsr.w	DoModulation
	bcs.w	PSGUpdateFreq
	rts
; End of function PSGUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72878:
PSGDoNext:
	bclr	#1,SMPS_Track.PlaybackControl(a5)	; Clear 'track at rest' bit
	movea.l	SMPS_Track.DataPointer(a5),a4	; Get track data pointer
; loc_72880:
.noteloop:
	moveq	#0,d5
	move.b	(a4)+,d5	; Get byte from track
	cmpi.b	#$FE,d5		; Is it a coord. flag?
	blo.s	.gotnote	; Branch if not
	bsr.w	CoordFlag
	bra.s	.noteloop
; ===========================================================================
; loc_72890:
.gotnote:
	tst.b	d5			; Is it a note?
	bpl.s	.gotduration		; Branch if not
	bsr.s	PSGSetFreq
	move.b	(a4)+,d5		; Get another byte
	tst.b	d5			; Is it a duration?
	bpl.s	.gotduration		; Branch if yes
	subq.w	#1,a4			; Put byte back
	bra.w	FinishTrackUpdate
; ===========================================================================
; loc_728A4:
.gotduration:
	bsr.w	SetDuration
	bra.w	FinishTrackUpdate
; End of function PSGDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_728AC:
PSGSetFreq:
	subi.b	#$81,d5				; Convert to 0-based index
	bcs.s	.restpsg			; If $80, put track at rest
	add.b	SMPS_Track.Transpose(a5),d5	; Add in channel transposition
	andi.w	#$7F,d5				; Clear high byte and sign bit
	add.w	d5,d5
	move.w	PSGFrequencies(pc,d5.w),SMPS_Track.Freq(a5)	; Set new frequency
	; Clownacy | Sonic 2's driver doesn't continue to FinishTrackUpdate
	rts
; ===========================================================================
; loc_728CA:
.restpsg:
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	move.w	#-1,SMPS_Track.Freq(a5)			; Invalidate note frequency
	; Clownacy | Sonic 2's driver doesn't continue to FinishTrackUpdate
	bra.w	PSGNoteOff
; End of function PSGSetFreq

; ===========================================================================
; word_729CE:
PSGFrequencies:
	; This table starts with 12 notes not in S1 or S2:
	dc.w $3FF, $3FF, $3FF, $3FF, $3FF, $3FF, $3FF, $3FF
	dc.w $3FF, $3F7, $3BE, $388
	; The following notes are present on S1 and S2 too:
	dc.w $356, $326, $2F9, $2CE, $2A5, $280, $25C, $23A
	dc.w $21A, $1FB, $1DF, $1C4, $1AB, $193, $17D, $167
	dc.w $153, $140, $12E, $11D, $10D,  $FE,  $EF,  $E2
	dc.w  $D6,  $C9,  $BE,  $B4,  $A9,  $A0,  $97,  $8F
	dc.w  $87,  $7F,  $78,  $71,  $6B,  $65,  $5F,  $5A
	dc.w  $55,  $50,  $4B,  $47,  $43,  $40,  $3C,  $39
	dc.w  $36,  $33,  $30,  $2D,  $2B,  $28,  $26,  $24
	dc.w  $22,  $20,  $1F,  $1D,  $1B,  $1A,  $18,  $17
	dc.w  $16,  $15,  $13,  $12,  $11,  $10,    0,    0

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_728DC:
PSGDoNoteOn:
	btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track at rest?
	bne.s	PSGUpdateFreq.locret			; Return if yes
	tst.w	SMPS_Track.Freq(a5)	; Get note frequency
	bmi.s	PSGSetRest		; If invalid, branch
; End of function PSGDoNoteOn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_728E2:
PSGUpdateFreq:
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
	bne.s	.locret					; Return if yes
	move.w	SMPS_Track.Freq(a5),d6		; Get current note frequency
	btst	#3,SMPS_Track.PlaybackControl(a5)
	beq.s	.no_modulation
	add.w	SMPS_Track.ModulationVal(a5),d6

.no_modulation:
	move.b	SMPS_Track.Detune(a5),d0		; Get detune value
	ext.w	d0
	add.w	d0,d6					; Add to frequency
	move.b	SMPS_Track.VoiceControl(a5),d0		; Get channel bits
	cmpi.b	#$E0,d0					; Is it a noise channel?
	bne.s	.notnoise				; Branch if not
	move.b	#$C0,d0					; Use PSG 3 channel bits
; loc_72904:
.notnoise:
	move.w	d6,d1
	andi.b	#$F,d1			; Low nibble of frequency
	or.b	d1,d0			; Latch tone data to channel
	lsr.w	#4,d6			; Get upper 6 bits of frequency
	andi.b	#$3F,d6			; Send to latched channel
	move.b	d0,(SMPS_psg_input).l
	move.b	d6,(SMPS_psg_input).l
; locret_7291E:
.locret:
	rts
; End of function PSGUpdateFreq

; ===========================================================================
; loc_72920:
PSGSetRest:
	bset	#1,SMPS_Track.PlaybackControl(a5)

locret_72924:
	rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72926:
PSGUpdateVolFX:
	tst.b	SMPS_Track.VoiceIndex(a5)	; Test PSG tone
	beq.s	locret_72924			; Return if it is zero
; loc_7292E:
PSGDoVolFX:
	move.b	SMPS_Track.Volume(a5),d6	; Get volume
	moveq	#0,d0
	move.b	SMPS_Track.VoiceIndex(a5),d0	; Get PSG tone
	beq.s	SetPSGVolume
	add.w	d0,d0
	add.w	d0,d0
	lea	(PSG_Index).l,a0
	movea.l	-4(a0,d0.w),a0

PSGDoVolFX_Loop:
	moveq	#0,d0
	move.b	SMPS_Track.VolEnvIndex(a5),d0	; Get volume envelope index
	addq.b	#1,SMPS_Track.VolEnvIndex(a5)	; Increment volume envelope index
	move.b	(a0,d0.w),d0			; Get volume envelope value
	bpl.s	.gotflutter			; If it is not a terminator, branch
	cmpi.b	#$80,d0				; Clownacy | Third most commonly used
	beq.s	VolEnvReset			; 80 - loop back to beginning
	cmpi.b	#$81,d0				; Clownacy | Most commonly used
	beq.s	VolEnvHold			; 81 - hold at current level
	cmpi.b	#$82,d0				; Clownacy | Fourth most commonly used
	beq.s	VolEnvJump2Idx			; 82 xx	- jump to byte xx
	cmpi.b	#$83,d0				; Clownacy | Second most commonly used
	beq.s	VolEnvOff			; 83 - turn Note Off
; loc_72960:
.gotflutter:
	lsl.b	#3,d0
	add.b	d0,d6		; Add volume envelope value to volume
	bcc.s	SetPSGVolume
	moveq	#$F<<3,d6
;	cmpi.b	#$10,d6		; Is volume $10 or higher?	; Clownacy | This correction is moved to SetPSGVolume (the S2 way)
;	blo.s	SetPSGVolume	; Branch if not
;	moveq	#$F,d6		; Limit to silence and fall through
; End of function PSGUpdateVolFX


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_7296A:
SetPSGVolume:
	btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track at rest?
	bne.s	locret_7298A				; Return if so
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
	bne.s	locret_7298A				; Return if so
	btst	#4,SMPS_Track.PlaybackControl(a5)	; Is track set to not attack next note?
	bne.s	PSGCheckNoteFill			; Branch if yes
; loc_7297C:
PSGSendVolume:
	; Clownacy | This correction is present elsewhere in S1's driver, but just having
	; a single copy here saves space and eliminates the few instances where the correction
	; isn't performed
	tst.b	d6				; Is volume $10 or higher?
	bpl.s	+				; Branch if not
	moveq	#$1F,d6				; Limit to silence and fall through
	bra.s	++
+
	lsr.b	#3,d6
	ori.b	#$10,d6				; Mark it as a volume command
+	or.b	SMPS_Track.VoiceControl(a5),d6	; Add in track selector bits
	move.b	d6,(SMPS_psg_input).l

locret_7298A:
	rts
; ===========================================================================
; loc_7298C:
PSGCheckNoteFill:
	tst.b	SMPS_Track.NoteFillMaster(a5)	; Is note fill on?
	beq.s	PSGSendVolume			; Branch if not
	tst.b	SMPS_Track.NoteFillTimeout(a5)	; Has note fill timeout expired?
	bne.s	PSGSendVolume			; Branch if not
	rts
; End of function SetPSGVolume

; ===========================================================================
	; Clownacy | This isn't used by any current PSGs
	; but for the sake of forwards compatibility, it's here
VolEnvJump2Idx:
	move.b	1(a0,d0.w),SMPS_Track.VolEnvIndex(a5)	; Change flutter index to the byte following the flag
	bra.s	PSGDoVolFX_Loop

; ===========================================================================

VolEnvReset:	; For compatibility with S3K
	clr.b	SMPS_Track.VolEnvIndex(a5)
	bra.s	PSGDoVolFX_Loop

; ===========================================================================
; loc_7299A: FlutterDone:
VolEnvHold:
	; Decrement volume envelope index to before flag and last volume update (PSG volume will still update on subsequent frame)
	subq.b	#2,SMPS_Track.VolEnvIndex(a5)
	bra.s	PSGDoVolFX_Loop

; ===========================================================================

VolEnvOff:	; For compatibility with S3K
	; Decrement volume envelope index to before flag and last volume update (PSG volume will still update on subsequent frame)
	; TODO: This might be redundant (why update volume if A. it's meant to be mute, and B. the update is ignored because it's at rest)
	subq.b	#2,SMPS_Track.VolEnvIndex(a5)
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
;	bra.s	PSGNoteOff

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_729A0:
PSGNoteOff:
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
	bne.s	locret_729B4				; Return if so
; loc_729A6:
SendPSGNoteOff:
	move.b	SMPS_Track.VoiceControl(a5),d0	; PSG channel to change
	ori.b	#$1F,d0				; Maximum volume attenuation
	move.b	d0,(SMPS_psg_input).l
	; Without InitMusicPlayback forcefully muting all channels, there's the
	; risk of music accidentally playing noise because it can't detect if
	; the PSG 4/noise channel needs muting, on track initialisation.
	; This bug can be heard be playing the End of Level music in CNZ, whose
	; music uses the noise channel. S&K's driver contains a fix just like this.
	cmpi.b	#$DF,d0			; Are we stopping PSG 3?
	bne.s	locret_729B4
	move.b	#$FF,(SMPS_psg_input).l	; If so, stop noise channel while we're at it
locret_729B4:
	rts
; End of function PSGNoteOff


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_729B6:
PSGSilenceAll:
	lea	(SMPS_psg_input).l,a0
	move.b	#$9F,(a0)	; Silence PSG 1
	move.b	#$BF,(a0)	; Silence PSG 2
	move.b	#$DF,(a0)	; Silence PSG 3
	move.b	#$FF,(a0)	; Silence PSG noise channel
	rts
; End of function PSGSilenceAll

; ===========================================================================

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

    if SMPS_EnablePWM
PWMUpdateTrack:
	subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Has PWM sample timeout expired?
	bne.s	locret_729B4				; Return if not
	bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
	bsr.s	PWMDoNext
	bra.s	PWMUpdateSample
; End of function PWMUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PWMDoNext:
	movea.l	SMPS_Track.DataPointer(a5),a4		; PWM track data pointer

.sampleloop:
	moveq	#0,d5
	move.b	(a4)+,d5		; Get next SMPS unit
	cmpi.b	#$FE,d5			; Is it a coord. flag?
	blo.s	.notcoord		; Branch if not
	bsr.w	CoordFlag
	bra.s	.sampleloop
; ===========================================================================

.notcoord:
	tst.b	d5			; Is it a sample?
	bpl.s	.gotduration		; Branch if not (duration)
	move.b	d5,SMPS_Track.SavedPWM(a5)	; Store new sample
	move.b	(a4)+,d5		; Get another byte
	bpl.s	.gotduration		; Branch if it is a duration
	subq.w	#1,a4			; Put byte back
	move.b	SMPS_Track.SavedDuration(a5),SMPS_Track.DurationTimeout(a5) ; Use last duration
	bra.s	.gotsampleduration
; ===========================================================================

.gotduration:
	bsr.w	SetDuration

.gotsampleduration:
	move.w	a4,SMPS_Track.DataPointer+2(a5)	; Save pointer
	move.l	a4,d0
	swap	d0
	move.b	d0,SMPS_Track.DataPointer+1(a5)	; Save pointer
	rts
; End of function PWMDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PWMUpdateSample:
	move.b	SMPS_Track.SavedPWM(a5),d0
	cmpi.b	#$80,d0				; Is this a rest?
	beq.s	.skipVolumeUpdate		; If so, skip obtaining volume
	move.b	SMPS_Track.Volume(a5),-(sp)
	move.w	(sp)+,d1

.skipVolumeUpdate:
	btst	#4,SMPS_Track.PlaybackControl(a5)	; Is 'do not attack' enabled?
	bne.s	.skipSampleUpdate			; If so, skip obtaining sample ID
	subi.b	#$81,d0
	bmi.s	.skipSampleUpdate			; If invalid sample ($80-$FF), skip obtaining sample ID
	move.b	d0,d1

	; Send command
	moveq	#0,d2
	move.b	SMPS_Track.VoiceControl(a5),d2
	lea	(SMPS_pwm_comm).l,a0
	move.w	d1,-8(a0,d2.w)

.skipSampleUpdate:
	rts
; End of function PWMUpdateSample


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PWMSilenceAll:
	lea	(SMPS_pwm_comm).l,a0
	move.l	#(pwmSilence<<16)|pwmSilence,d0
	move.l	d0,(a0)+	; Silence PWM 1&2
	move.l	d0,(a0)		; Silence PWM 3&4
	rts
; End of function PWMSilenceAll

   endif


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72A5A:
CoordFlag:
	beq.w	cfHoldNote
	move.b	(a4)+,d5	; Clownacy | The true coord flag value follows the $FF
	add.w	d5,d5
	move.w	coordflagLookup(pc,d5.w),d5
	jmp	coordflagLookup(pc,d5.w)
; End of function CoordFlag

; ===========================================================================
; loc_72A64:
coordflagLookup:
	dc.w	cfPanningAMSFMS-coordflagLookup		; $FF, $00	Clownacy | Was $E0
; ===========================================================================
	dc.w	cfDetune-coordflagLookup		; $FF, $01	Clownacy | Was $E1
; ===========================================================================
	dc.w	cfSetCommunication-coordflagLookup	; $FF, $02	Clownacy | Was $E2
; ===========================================================================
	dc.w	cfJumpReturn-coordflagLookup		; $FF, $03	Clownacy | Was $E3
; ===========================================================================
	dc.w	cfFadeInToPrevious-coordflagLookup	; $FF, $04	Clownacy | Was $E4
; ===========================================================================
	dc.w	cfSetTempoDivider-coordflagLookup	; $FF, $05	Clownacy | Was $E5
; ===========================================================================
	dc.w	cfChangeFMVolume-coordflagLookup	; $FF, $06	Clownacy | Was $E6
; ===========================================================================
    if SMPS_EnableSpecSFX
	dc.w	cfStopSpecialFM4-coordflagLookup	; $FF, $07	Clownacy | Was $EE
    else
	dc.w	cfStopTrack-coordflagLookup
    endif
; ===========================================================================
	dc.w	cfNoteFill-coordflagLookup		; $FF, $08	Clownacy | Was $E8
; ===========================================================================
	dc.w	cfChangeTransposition-coordflagLookup	; $FF, $09	Clownacy | Was $E9
; ===========================================================================
	dc.w	cfSetTempo-coordflagLookup		; $FF, $0A	Clownacy | Was $EA
; ===========================================================================
	dc.w	cfSetTempoMod-coordflagLookup		; $FF, $0B	Clownacy | Was $EB
; ===========================================================================
	dc.w	cfChangePSGVolume-coordflagLookup	; $FF, $0C	Clownacy | Was $EC
; ===========================================================================
	dc.w	cfSetVoice-coordflagLookup		; $FF, $0D	Clownacy | Was $EF
; ===========================================================================
	dc.w	cfModulation-coordflagLookup		; $FF, $0E	Clownacy | Was $F0
; ===========================================================================
	dc.w	cfEnableModulation-coordflagLookup	; $FF, $0F	Clownacy | Was $F1
; ===========================================================================
	dc.w	cfStopTrack-coordflagLookup		; $FF, $10	Clownacy | Was $F2
; ===========================================================================
	dc.w	cfSetPSGNoise-coordflagLookup		; $FF, $11	Clownacy | Was $F3
; ===========================================================================
	dc.w	cfDisableModulation-coordflagLookup	; $FF, $12	Clownacy | Was $F4
; ===========================================================================
	dc.w	cfSetPSGTone-coordflagLookup		; $FF, $13	Clownacy | Was $F5
; ===========================================================================
	dc.w	cfJumpTo-coordflagLookup		; $FF, $14	Clownacy | Was $F6
; ===========================================================================
	dc.w	cfRepeatAtPos-coordflagLookup		; $FF, $15	Clownacy | Was $F7
; ===========================================================================
	dc.w	cfJumpToGosub-coordflagLookup		; $FF, $16	Clownacy | Was $F8
; ===========================================================================
	dc.w	cfChanFMCommand-coordflagLookup		; $FF, $17	Clownacy | Brand new
; ===========================================================================
	dc.w	cfSilenceStopTrack-coordflagLookup	; $FF, $18	Clownacy | Brand new
; ===========================================================================
	dc.w	cfPlayDACSample-coordflagLookup		; $FF, $19	Clownacy | Brand new
; ===========================================================================
	dc.w	cfPlaySound-coordflagLookup		; $FF, $1A	Clownacy | Brand new
; ===========================================================================
	dc.w	cfSetKey-coordflagLookup		; $FF, $1B	Clownacy | Brand new
; ===========================================================================
	dc.w	cfSetVolume-coordflagLookup		; $FF, $1C	Clownacy | Brand new
; ===========================================================================
	dc.w	cfNoteFillS3K-coordflagLookup		; $FF, $1D	Clownacy | Brand new
; ===========================================================================
	dc.w	cfLoopContinuousSFX-coordflagLookup	; $FF, $1E	Clownacy | Brand new
; ===========================================================================
    if SMPS_PushSFXBehaviour
	dc.w	cfClearPush-coordflagLookup		; $FF, $1F	Clownacy | Was $ED
    else
	dc.w	locret_72AEA-coordflagLookup
    endif
; ===========================================================================
	dc.w	cfSendFMI-coordflagLookup		; $FF, $20	Clownacy | Brand new
; ===========================================================================
; loc_72ACC:
cfPanningAMSFMS:
	move.b	(a4)+,d1				; New AMS/FMS/panning value
	tst.b	SMPS_Track.VoiceControl(a5)		; Is this a PSG track?
	bmi.s	locret_72AEA				; Return if yes
	move.b	SMPS_Track.AMSFMSPan(a5),d0		; Get current AMS/FMS/panning
	andi.b	#$37,d0					; Retain bits 0-2, 3-4 if set
	or.b	d0,d1					; Mask in new value
	move.b	d1,SMPS_Track.AMSFMSPan(a5)		; Store value
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overriden by sfx?
	bne.s	locret_72AEA				; Return if yes
	move.b	#$B4,d0					; Command to set AMS/FMS/panning
	bra.w	WriteFMIorII
; ===========================================================================
; loc_72AEC: cfAlterNotes:
cfDetune:
	move.b	(a4)+,SMPS_Track.Detune(a5)	; Set detune value
locret_72AEA:
	rts
; ===========================================================================
; loc_72AF2:
cfSetCommunication:
	move.b	(a4)+,SMPS_RAM.variables.v_communication_byte(a6)	; Set otherwise unused communication byte to parameter
	rts
; ===========================================================================
; loc_72AF8:
cfJumpReturn:
	moveq	#0,d0
	move.b	SMPS_Track.StackPointer(a5),d0	; Track stack pointer
	movea.l	(a5,d0.w),a4			; Set track return address
	addq.b	#4,SMPS_Track.StackPointer(a5)	; Actually 'pop' value
	rts
; ===========================================================================
; loc_72B14:
cfFadeInToPrevious:
	; Clownacy | We're restoring the variables and tracks separately, as the backed-up variables are now after the backed-up tracks
	; this is so the backed-up tracks and SFX tracks start at the same place: at the end of the music tracks
	lea	SMPS_RAM.v_music_track_ram(a6),a0
	lea	SMPS_RAM.v_1up_ram_copy(a6),a1
	moveq	#((SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)/4)-1,d0	; restore music track data
; loc_72B1E:
.restoretrackramloop:
	move.l	(a1)+,(a0)+
	dbf	d0,.restoretrackramloop

	; Clownacy | Make sure the last few bytes get cleared
    if (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)&2
	move.w	(a1)+,(a0)+
    endif
    if (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)&1
	move.b	(a1)+,(a0)+
    endif

	lea	SMPS_RAM.variables(a6),a0
	lea	SMPS_RAM.variables_backup(a6),a1
	moveq	#(SMPS_RAM_Variables.len/4)-1,d0	; restore variables
; loc_72B1E:
.restorevariablesloop:
	move.l	(a1)+,(a0)+
	dbf	d0,.restorevariablesloop

	; Clownacy | Make sure the last few bytes get restored
    if SMPS_RAM_Variables.len&2
	move.w	(a1)+,(a0)+
    endif
    if SMPS_RAM_Variables.len&1
	move.b	(a1)+,(a0)+
    endif

	lea	SMPS_RAM.v_music_track_ram(a6),a0
	moveq	#SMPS_MUSIC_TRACK_COUNT-1,d0		; 1 DAC + 6 FM + 3 PSG tracks
; loc_71FE6:
.restoreplaybackloop:
	bclr	#2,SMPS_Track.PlaybackControl(a0)
	beq.s	.notPlaying
	bset	#7,SMPS_Track.PlaybackControl(a0)

.notPlaying:
	lea	SMPS_Track.len(a0),a0
	dbf	d0,.restoreplaybackloop

	movea.l	a5,a3
	moveq	#$28,d6
	sub.b	SMPS_RAM.variables.v_fadein_counter(a6),d6	; If fade already in progress, this adjusts track volume accordingly
	lea	SMPS_RAM.v_music_dac_track(a6),a5
	btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
	beq.s	.fadefm					; Branch if not
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	move.b	d6,d0
	add.b	d0,d0
	add.b	d0,d0
	add.b	d0,SMPS_Track.Volume(a5)		; Apply current volume fade-in
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
	bne.s	.fadefm					; Branch if yes
	bsr.w	SetDACVolume

.fadefm:
	moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7 	; 6 FM tracks
	lea	SMPS_RAM.v_music_fm_tracks(a6),a5
; loc_72B3A:
.fmloop:
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
	bpl.s	.nextfm					; Branch if not
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	add.b	d6,SMPS_Track.Volume(a5)		; Apply current volume fade-in
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
	bne.s	.nextfm					; Branch if yes
	moveq	#0,d0
	move.b	SMPS_Track.VoiceIndex(a5),d0		; Get voice
	movea.l	SMPS_Track.VoicePtr(a5),a1		; Voice pointer
	bsr.w	SetVoice
; loc_72B5C:
.nextfm:
	lea	SMPS_Track.len(a5),a5
	dbf	d7,.fmloop

	moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7
; loc_72B66:
.psgloop:
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
	bpl.s	.nextpsg				; Branch if not
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	bsr.w	PSGNoteOff
	move.b	d6,d0
	add.b	d0,d0
	add.b	d0,d0
	add.b	d0,SMPS_Track.Volume(a5)		; Apply current volume fade-in
	; Clownacy | One of Valley Bell's fixes: this restores the noise mode if need be, avoiding a bug where unwanted noise plays
	cmpi.b	#$E0,SMPS_Track.VoiceControl(a5)	; Is this a noise channel?
	bne.s	.nextpsg				; Branch if not
	move.b	SMPS_Track.PSGNoise(a5),(SMPS_psg_input).l	; Set noise type

; loc_72B78:
.nextpsg:
	lea	SMPS_Track.len(a5),a5
	dbf	d7,.psgloop

	movea.l	a3,a5

	bset	#f_fadeinflag,SMPS_RAM.variables.bitfield2(a6)
	move.b	#$28,SMPS_RAM.variables.v_fadein_counter(a6)	; Fade-in delay
	bclr	#f_1up_playing,SMPS_RAM.variables.bitfield2(a6)
	addi.w	#4*3,sp				; Tamper return value so we don't return to caller
	rts
; ===========================================================================
; loc_72B9E:
cfSetTempoDivider:
	move.b	(a4)+,SMPS_Track.TempoDivider(a5)	; Set tempo divider on current track
.locret:
	rts
; ===========================================================================
; loc_72BA4: cfSetVolume:
cfChangeFMVolume:
	move.b	(a4)+,d0		; Get parameter
	; SMPS Z80 (at least the version S&K uses) prevents PSG channels from using this
	tst.b	SMPS_Track.VoiceControl(a5)	; Is this a PSG track?
	bmi.s	cfSetTempoDivider.locret	; If so, return

	add.b	d0,SMPS_Track.Volume(a5)	; Add to current volume
	btst	#4,SMPS_Track.VoiceControl(a5)	; Is this the DAC track?
	bne.w	SetDACVolume			; If so, branch
    if SMPS_EnablePWM
	btst	#3,SMPS_Track.VoiceControl(a5)	; Is this a PWM track?
	bne.s	cfSetTempoDivider.locret	; If so, return
    endif
	bra.w	SendVoiceTL
; ===========================================================================
; loc_72BAE: cfPreventAttack:
cfHoldNote:
	bset	#4,SMPS_Track.PlaybackControl(a5)	; Set 'do not attack next note' bit
	rts
; ===========================================================================
cfNoteFillS3K:	; Ported from S3K
; S3K's zComputeNoteDuration
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a4)+,d1				; Get parameter
	move.b	SMPS_Track.TempoDivider(a5),d0		; Get tempo divider for this track
	mulu.w	d0,d1					; Multiply the parameter by tempo divider
	move.b	d1,SMPS_Track.NoteFillTimeout(a5)	; Note fill timeout
	move.b	d1,SMPS_Track.NoteFillMaster(a5)	; Note fill master
	rts
; ===========================================================================
; loc_72BB4:
cfNoteFill:
	move.b	(a4)+,d0
	move.b	d0,SMPS_Track.NoteFillTimeout(a5)	; Note fill timeout
	move.b	d0,SMPS_Track.NoteFillMaster(a5)	; Note fill master
	rts
; ===========================================================================
; loc_72BBE: cfAddKey:
cfChangeTransposition:
	move.b	(a4)+,d0			; Get parameter
	add.b	d0,SMPS_Track.Transpose(a5)	; Add to transpose value
	rts
; ===========================================================================
; loc_72BC6:
cfSetTempo:
	move.b	(a4)+,d0
	move.b	d0,SMPS_RAM.variables.v_main_tempo(a6)		; Set main tempo
	move.b	d0,SMPS_RAM.variables.v_main_tempo_timeout(a6)	; And reset timeout (!)
	rts
; ===========================================================================
; loc_72BD0:
cfSetTempoMod:
	move.b	(a4)+,d0			; Get new tempo divider
	lea	SMPS_RAM.v_music_track_ram(a6),a0
	moveq	#SMPS_Track.len,d1
	moveq	#SMPS_MUSIC_TRACK_COUNT-1,d2	; 1 DAC + 6 FM + 3 PSG tracks
; loc_72BDA:
.trackloop:
	move.b	d0,SMPS_Track.TempoDivider(a0)	; Set track's tempo divider
	adda.w	d1,a0
	dbf	d2,.trackloop

	rts
; ===========================================================================
; loc_72BE6: cfChangeVolume:
cfChangePSGVolume:
	move.b	(a4)+,d0			; Get volume change
	add.b	d0,SMPS_Track.Volume(a5)	; Apply it

locret_72CAA:
	rts
; ===========================================================================
    if SMPS_PushSFXBehaviour
; loc_72BEE:
cfClearPush:
	bclr	#f_push_playing,SMPS_RAM.bitfield1(a6)	; Allow push sound to be played once more
	rts
    endif
; ===========================================================================
    if SMPS_EnableSpecSFX
; loc_72BF4:
cfStopSpecialFM4:
	bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
	bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
	bsr.w	FMNoteOff
	tst.b	SMPS_RAM.v_sfx_fm4_track(a6)		; Is SFX using FM4?
	bmi.s	.locexit				; Branch if yes
	movea.l	a5,a3
	lea	SMPS_RAM.v_music_fm4_track(a6),a5
	movea.l	SMPS_Track.VoicePtr(a5),a1		; Voice pointer
	bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
	bsr.s	SetVoice
	movea.l	a3,a5
; loc_72C22:
.locexit:
	addq.w	#8,sp				; Tamper with return value so we don't return to caller
	rts
    endif
; ===========================================================================
; loc_72C26:
cfSetVoice:
	move.b	(a4)+,SMPS_Track.VoiceIndex(a5)		; Store new voice
	tst.b	SMPS_Track.VoiceControl(a5)		; Is this a PSG track?
	bmi.s	locret_72CAA
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding this track?
	bne.s	locret_72CAA				; Return if yes
	bsr.w	FMSilenceChannel
	moveq	#0,d0
	move.b	SMPS_Track.VoiceIndex(a5),d0		; Get new voice ID again

cfSetVoiceCont:
	movea.l	SMPS_Track.VoicePtr(a5),a1		; SFX track voice pointer

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72C4E:
SetVoice:
	; Multiply d0 by 25 (size of FM voice)
	adda.w	d0,a1
	lsl.w	#3,d0
	adda.w	d0,a1
	adda.w	d0,a1
	adda.w	d0,a1
; loc_72C5C:
.havevoiceptr:
	move.b	(a1)+,d1		; feedback/algorithm
	move.b	#$B0,d0			; Command to write feedback/algorithm
	bsr.w	WriteFMIorII

	; Send voice data.
	; Like S2's driver, and unlike S1's original driver, we calculate
	; the operator value, and have a different voice format as a result.
	; Unlike S2's driver, our custom format also has TL data start at 5
	; bytes into the data, instead of 21.

	; Send detune/multiple
	moveq	#$30,d3			; Detune/multiple operator 1
	moveq	#(1*4)-1,d4		; Four operators

-	move.b	d3,d0
	move.b	(a1)+,d1
	bsr.w	WriteFMIorII
	addq.b	#4,d3			; Next operator
	dbf	d4,-

	; Send total level
	move.b	SMPS_Track.Volume(a5),d5	; Track volume attenuation
	moveq	#(1*4)-1,d4			; Four operators

-	move.b	d3,d0
	move.b	(a1)+,d1
	bpl.s	+
	add.b	d5,d1			; Include additional attenuation
+
	bsr.w	WriteFMIorII
	addq.b	#4,d3			; Next operator
	dbf	d4,-

	; Send...
	;  Rate scalling/attack rate
	;  Amplitude modulation/first decay rate
	;  Secondary decay rate
	;  Secondary amplitude/release rate
	moveq	#(4*4)-1,d4		; Four sets of four operators

-	move.b	d3,d0
	move.b	(a1)+,d1
	bsr.w	WriteFMIorII
	addq.b	#4,d3			; Next operator
	dbf	d4,-

	move.b	#$B4,d0				; Register for AMS/FMS/Panning
	move.b	SMPS_Track.AMSFMSPan(a5),d1	; Value to send
	bra.w	WriteFMIorII

;locret_72CAA:
;	rts
; End of function SetVoice

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72CB4:
SendVoiceTL:
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
	bne.s	.locret					; Return if so
	moveq	#0,d0
	move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
	movea.l	SMPS_Track.VoicePtr(a5),a1
	; Multiply d0 by 25 (size of FM voice)
	adda.w	d0,a1
	lsl.w	#3,d0
	adda.w	d0,a1
	adda.w	d0,a1
	adda.w	d0,a1
	addq.w	#5,a1			; Want TL (was '21(a0)' in original driver)
	move.b	SMPS_Track.Volume(a5),d3	; Get track volume attenuation
	bmi.s	.locret				; If negative, stop

	moveq	#$40,d4				; Total level operator 1
	moveq	#4-1,d5				; Four operators
; loc_72D02:
.sendtlloop:
	move.b	d4,d0
	move.b	(a1)+,d1
	bpl.s	.senttl
	add.b	d3,d1			; Include additional attenuation
	bsr.w	WriteFMIorII
; loc_72D12:
.senttl:
	addq.b	#4,d4			; Go to operator 2, then 3, then 4
	dbf	d5,.sendtlloop
; locret_72D16:
.locret:
	rts
; End of function SendVoiceTL

; ===========================================================================
; loc_72D30:
cfModulation:
	bset	#3,SMPS_Track.PlaybackControl(a5)	; Turn on modulation
	move.w	a4,SMPS_Track.ModulationPtr+2(a5)	; Save pointer to modulation data
	move.l	a4,d0
	swap	d0
	move.b	d0,SMPS_Track.ModulationPtr+1(a5)	; Save pointer to modulation data
	move.b	(a4)+,SMPS_Track.ModulationWait(a5)	; Modulation delay
	move.b	(a4)+,SMPS_Track.ModulationSpeed(a5)	; Modulation speed
	move.b	(a4)+,SMPS_Track.ModulationDelta(a5)	; Modulation delta
	move.b	(a4)+,d0				; Modulation steps...
	lsr.b	#1,d0					; ... divided by 2...
	move.b	d0,SMPS_Track.ModulationSteps(a5)	; ... before being stored
	clr.w	SMPS_Track.ModulationVal(a5)		; Total accumulated modulation frequency change
	rts
; ===========================================================================
; loc_72D52:
cfEnableModulation:
	bset	#3,SMPS_Track.PlaybackControl(a5)	; Turn on modulation
	rts
; ===========================================================================
; loc_72D58:
cfStopTrack:
	bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
    if SMPS_EnablePWM
	btst	#3,SMPS_Track.VoiceControl(a5)		; Is this a PWM track?
	bne.w	.locexit
    endif
	bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
	tst.b	SMPS_Track.VoiceControl(a5)		; Is this a PSG track?
	bmi.s	.stoppsg				; Branch if yes
	btst	#4,SMPS_Track.VoiceControl(a5)		; Is this the DAC we are updating?
	bne.w	.locexit				; Exit if yes
	bsr.w	FMNoteOff
	bra.s	.stoppedchannel
; ===========================================================================
; loc_72D74:
.stoppsg:
	bsr.w	PSGNoteOff
; loc_72D78:
.stoppedchannel:
	lea	SMPS_RAM.v_sfx_track_ram(a6),a0
	cmpa.l	a0,a5					; Are we updating SFX?
	blo.w	.locexit				; Exit if not
	clr.b	SMPS_RAM.variables.v_sndprio(a6)	; Clear priority
	moveq	#0,d0
	move.b	SMPS_Track.VoiceControl(a5),d0		; Get voice control bits
	bmi.s	.getpsgptr				; Branch if PSG
	lea	SFX_BGMChannelRAM(pc),a0
	movea.l	a5,a3
    if SMPS_EnableSpecSFX
	cmpi.b	#4,d0					; Is this FM4?
	bne.s	.getpointer				; Branch if not
	tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Is special SFX playing?
	bpl.s	.getpointer				; Branch if not
	lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
	movea.l	SMPS_Track.VoicePtr(a5),a1		; Get voice pointer
	bra.s	.gotpointer
; ===========================================================================
; loc_72DA8:
.getpointer:
    endif
	subq.w	#2,d0			; SFX can only use FM3 and up
	add.w	d0,d0
	movea.w	(a0,d0.w),a5
	adda.l	a6,a5
	tst.b	SMPS_Track.PlaybackControl(a5)		; Is track playing?
	bpl.s	.novoiceupd				; Branch if not
	movea.l	SMPS_Track.VoicePtr(a5),a1		; Get voice pointer
; loc_72DB8:
.gotpointer:
	bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX overriding' bit
	bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
	move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
	bsr.w	SetVoice
; loc_72DC8:
.novoiceupd:
	movea.l	a3,a5
	addq.w	#8,sp		; Tamper with return value so we don't go back to caller
	rts
; ===========================================================================
; loc_72DCC:
.getpsgptr:
    if SMPS_EnableSpecSFX
	lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a0
	tst.b	SMPS_Track.PlaybackControl(a0)	; Is track playing?
	bpl.s	.getchannelptr			; Branch if not
	cmpi.b	#$E0,d0				; Is it the noise channel?
	beq.s	.gotchannelptr			; Branch if yes
	cmpi.b	#$C0,d0				; Is it PSG 3?
	beq.s	.gotchannelptr			; Branch if yes
; loc_72DE0:
.getchannelptr:
    endif
	lea	SFX_BGMChannelRAM(pc),a0
	lsr.w	#4,d0
	movea.w	(a0,d0.w),a0
	adda.l	a6,a0
; loc_72DEA:
.gotchannelptr:
	bclr	#2,SMPS_Track.PlaybackControl(a0)	; Clear 'SFX overriding' bit
	bset	#1,SMPS_Track.PlaybackControl(a0)	; Set 'track at rest' bit
	cmpi.b	#$E0,SMPS_Track.VoiceControl(a0)	; Is this a noise pointer?
	bne.s	.locexit				; Branch if not
	move.b	SMPS_Track.PSGNoise(a0),(SMPS_psg_input).l ; Set noise tone
; loc_72E02:
.locexit:
	addq.w	#8,sp			; Tamper with return value so we don't go back to caller
	rts
; ===========================================================================
; loc_72E06:
cfSetPSGNoise:
	move.b	#$E0,d1					; Turn track into PSG noise
	move.b	(a4)+,d0				; Get tone noise
	move.b	d0,SMPS_Track.PSGNoise(a5)		; Save it
	bne.s	.enableNoiseMode
	; leave noise mode
	subq.b	#1,d0					; d0 = $FF ('silence PSG noise' command)
	move.b	#$C0,d1					; Turn track into PSG 3
.enableNoiseMode:
	move.b	d1,SMPS_Track.VoiceControl(a5)		; Turn channel into PSG 3 or PSG noise channel
	btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
	bne.s	.locret					; Return if yes
	move.b	d0,(SMPS_psg_input).l
; locret_72E1E:
.locret:
	rts
; ===========================================================================
; loc_72E20:
cfDisableModulation:
	bclr	#3,SMPS_Track.PlaybackControl(a5)	; Disable modulation
	rts
; ===========================================================================
; loc_72E26:
cfSetPSGTone:
	move.b	(a4)+,d0
	tst.b	SMPS_Track.VoiceControl(a5)	; Is this a PSG track?
	bpl.s	+				; Return if not
	move.b	d0,SMPS_Track.VoiceIndex(a5)	; Set current PSG tone
+	rts
; ===========================================================================
; loc_72E2C:
cfJumpTo:
	move.b	(a4)+,-(sp)
	move.w	(sp)+,d0
	move.b	(a4),d0		; Low byte of offset
	adda.w	d0,a4		; Add to current position
	rts
; ===========================================================================
; loc_72E38:
cfRepeatAtPos:
	moveq	#0,d0
	move.b	(a4)+,d0				; Loop index
	move.b	(a4)+,d1				; Repeat count
	tst.b	SMPS_Track.LoopCounters(a5,d0.w)	; Has this loop already started?
	bne.s	.loopexists				; Branch if yes
	move.b	d1,SMPS_Track.LoopCounters(a5,d0.w)	; Initialize repeat count
; loc_72E48:
.loopexists:
	subq.b	#1,SMPS_Track.LoopCounters(a5,d0.w)	; Decrease loop's repeat count
	bne.s	cfJumpTo				; If nonzero, branch to target
	addq.w	#2,a4					; Skip target address
	rts
; ===========================================================================
; loc_72E52:
cfJumpToGosub:
	move.b	(a4)+,-(sp)
	move.w	(sp)+,d1
	move.b	(a4)+,d1

	subq.b	#4,SMPS_Track.StackPointer(a5)	; Add space for another target
	moveq	#0,d0
	move.b	SMPS_Track.StackPointer(a5),d0	; Current stack pointer
	move.l	a4,(a5,d0.w)			; Put in current address (after target for jump!)
	adda.w	d1,a4		; Add to current position
	rts
; ===========================================================================

; Clownacy | Since I reintroduced cfSendFMI, this flag is pointless

; loc_72E64:
;cfOpF9:
;	move.b	#$88,d0		; D1L/RR of Operator 3
;	moveq	#$F,d1		; Loaded with fixed value (max RR, 1TL)
;	bsr.w	WriteFMI
;	move.b	#$8C,d0		; D1L/RR of Operator 4
;	moveq	#$F,d1		; Loaded with fixed value (max RR, 1TL)
;	bra.w	WriteFMI
; ===========================================================================

cfSilenceStopTrack:
	tst.b	SMPS_Track.VoiceControl(a5)	; Is this a PSG track?
	bmi.w	cfStopTrack			; If so, don't mess with the YM2612
	bsr.w	FMSilenceChannel
	bra.w	cfStopTrack
; ===========================================================================
; Sets a new DAC sample for play.
;
; Has one parameter, the index (1-based) of the DAC sample to play.
;
cfPlayDACSample:
	moveq	#(MegaPCM_VolumeTbls&$F000)>>8,d0
	SMPS_stopZ80_safe
	move.b	(a4)+,(SMPS_z80_ram+MegaPCM_DAC_Number).l
	; This is a DAC SFX: set to full volume
	move.b	d0,(SMPS_z80_ram+MegaPCM_LoadBank.volume+1).l
	move.b	d0,(SMPS_z80_ram+MegaPCM_Init_PCM.volume+1).l
	SMPS_startZ80_safe
	rts
; ===========================================================================
; Plays another song or SFX.
;
; Has one parameter byte, the ID of what is to be played.
;
; cfPlaySoundByIndex
cfPlaySound:
	move.b	(a4)+,SMPS_RAM.variables.queue.v_playsnd2(a6)
	rts
; ===========================================================================
; Changes the track's key displacement.
;
; There is a single parameter byte, the new track key offset + 40h (that is,
; 40h is subtracted from the parameter byte before the key displacement is set)
;
cfSetKey:
	move.b	(a4)+,d0
	subi.b	#$40,d0
	move.b	d0,SMPS_Track.Transpose(a5)
	rts
; ===========================================================================
; Sets track volume.
;
; Has one parameter byte, the volume.
;
; For FM tracks, this is a 7-bit value from 0 (lowest volume) to 127 (highest
; volume). The value is XOR'ed with 7Fh before being sent, then stripped of the
; sign bit. The volume change takes effect immediately.
;
; For PSG tracks, this is a 4-bit value ranging from 8 (lowest volume) to 78h
; (highest volume). The value is shifted 3 bits to the right, XOR'ed with 0Fh
; and AND'ed with 0Fh before being uploaded, so the sign bit and the lower 3
; bits are discarded.
;
cfSetVolume:
	move.b	(a4)+,d0			; Load parameter byte
	not.b	d0				; Invert bits
	tst.b	SMPS_Track.VoiceControl(a5)	; Is this a psg track?
	bpl.s	.FMVolume			; If not, branch
	andi.b	#$F0,d0
	move.b	d0,SMPS_Track.Volume(a5)	; Write volume
	rts
.FMVolume:
	bchg	#7,d0				; Retain sign bit
	move.b	d0,SMPS_Track.Volume(a5)	; Write volume
	bra.w	SendVoiceTL
; ===========================================================================
; If a continuous SFX is playing, it will continue playing from target address.
; A loop counter is decremented (it is initialized to number of SFX tracks)
; for continuous SFX; if the result is zero, the continuous SFX will be flagged
; to stop.
; Non-continuous SFX do not loop.
;
; Has a 2-byte parameter, the jump target address.
;
cfLoopContinuousSFX:
    if SMPS_EnableContSFX
	btst	#f_continuous_sfx,SMPS_RAM.bitfield1(a6)	; Is the flag for continuous playback mode set?
	bne.s	.continuousmode					; If so, branch
	clr.b	SMPS_RAM.variables.v_current_contsfx(a6)	; Communicate that there is no continuous SFX playing
	addq.w	#2,a4						; Clownacy | Advance reading counter to skip the address
	rts

.continuousmode:
	subq.b	#1,SMPS_RAM.variables.v_contsfx_channels(a6)	; Mark one channel as processed
	bne.w	cfJumpTo					; If that wasn't the last channel, branch
	bclr	#f_continuous_sfx,SMPS_RAM.bitfield1(a6)	; If it was, clear flag for continuous playback mode...
	bra.w	cfJumpTo					; ...and then branch
    else
	addq.w	#2,a4			; Skip parameters
	rts
    endif
; ===========================================================================
; Sends an FM command to the YM2612. The command is sent to part I, so not all
; registers can be set using this coord. flag (in particular, channels FM4,
; FM5 and FM6 cannot (in general) be affected).
;
; Has 2 parameter bytes: a 1-byte register selector and a 1-byte register data.
;
cfSendFMI:
	move.b	(a4)+,d0	; Get YM2612 register selector
	move.b	(a4)+,d1	; Get YM2612 register data
	bra.w	WriteFMI	; Send it to YM2612
; ===========================================================================
; Sends an FM command to the YM2612. The command is sent to the adequate part
; for the current track, so it is only appropriate for those registers that
; affect specific channels.
;
; Has 2 parameter bytes: a 1-byte register selector and a 1-byte register data.
;
cfChanFMCommand:
	move.b	(a4)+,d0				; Get YM2612 register selector
	move.b	(a4)+,d1				; Get YM2612 register data
	bra.w	WriteFMIorII				; Send it to YM2612
; ===========================================================================
; ---------------------------------------------------------------------------
; Music 'include's and pointers
; ---------------------------------------------------------------------------
	include "Sound/Music.asm"

; ---------------------------------------------------------------------------
; SFX 'include's and pointers
; ---------------------------------------------------------------------------
	include "Sound/SFX.asm"

; ---------------------------------------------------------------------------
; Special SFX 'include's and pointers
; ---------------------------------------------------------------------------
    if SMPS_EnableSpecSFX
	include "Sound/Special SFX.asm"
    endif
; ---------------------------------------------------------------------------
; FM Universal Voice Bank
; ---------------------------------------------------------------------------
    if SMPS_EnableUniversalVoiceBank
	include "Sound/FM Universal Voice Bank.asm"
    endif
; ---------------------------------------------------------------------------
; PSG volume envelopes 'include's and pointers
; ---------------------------------------------------------------------------
	include "Sound/PSG Volume Envelopes.asm"

; ---------------------------------------------------------------------------
; Vladikcomper's Mega PCM DAC driver
; ---------------------------------------------------------------------------

	include	"Sound/Engine/MegaPCM - 68k.asm"

	dc.b	$43,$6C,$6F,$77,$6E,$61,$63,$79
	even
