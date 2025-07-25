; ---------------------------------------------------------------------------
; ===========================================================================
; |                                                                         |
; |	                        SONIC&K SOUND DRIVER                            |
; |                                                                         |
; ===========================================================================
; Disassembled by MarkeyJester
; Routines, pointers and stuff by Linncaki
; Thoroughly commented and improved by Flamewing
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
; Constants
; ===========================================================================

; Approximate size of compressed sound driver
Size_of_Snd_driver_guess	= $1200

; Used by SMPS2ASM include file.
SonicDriverVer			= 5
; Set the following to non-zero to use all S2 DAC samples, or to zero otherwise.
; The S1 samples are a subset of this.
use_s2_samples			= 0
; Set the following to non-zero to use all S3D DAC samples, or to zero
; otherwise. Most of the S3D samples are also present in S3/S&K, but
; there are two samples specific to S3D.
use_s3d_samples			= 0
; Set the following to non-zero to use all S3 DAC samples,
; or to zero otherwise.
use_s3_samples			= 0
; Set the following to non-zero to use all S&K DAC samples,
; or to zero otherwise.
use_sk_samples			= 1

; ---------------------------------------------------------------------------

z80_SoundDriverStart:

; ---------------------------------------------------------------------------
zTrack STRUCT DOTS
	; Playback control bits:
	;	0 (01h)		Noise channel (PSG) or FM3 special mode (FM)
	;	1 (02h)		Do not attack next note
	;	2 (04h)		SFX is overriding this track
	;	3 (08h)		'Alternate frequency mode' flag
	;	4 (10h)		'Track is resting' flag
	;	5 (20h)		'Pitch slide' flag
	;	6 (40h)		'Sustain frequency' flag -- prevents frequency from changing again for the lifetime of the track
	;	7 (80h)		Track is playing
	PlaybackControl:	ds.b 1	; S&K: 0
	; Voice control bits:
	;	0-1			FM channel assignment bits (00 = FM1 or FM4, 01 = FM2 or FM5, 10 = FM3 or FM6/DAC, 11 = invalid)
	;	2 (04h)		For FM/DAC channels, selects if reg/data writes are bound for part II (set) or part I (unset)
	;	3 (08h)		Unknown/unused
	;	4 (10h)		Unknown/unused
	;	5-6			PSG Channel assignment bits (00 = PSG1, 01 = PSG2, 10 = PSG3, 11 = Noise)
	;	7 (80h)		PSG track if set, FM or DAC track otherwise
	VoiceControl:		ds.b 1	; S&K: 1
	TempoDivider:		ds.b 1	; S&K: 2
	DataPointerLow:		ds.b 1	; S&K: 3
	DataPointerHigh:	ds.b 1	; S&K: 4
	Transpose:			ds.b 1	; S&K: 5
	Volume:				ds.b 1	; S&K: 6
	ModulationCtrl:		ds.b 1	; S&K: 7		; Modulation is on if nonzero. If only bit 7 is set, then it is normal modulation; otherwise, this-1 is index on modulation envelope pointer table
	VoiceIndex:			ds.b 1	; S&K: 8		; FM instrument/PSG voice
	StackPointer:		ds.b 1	; S&K: 9		; For call subroutine coordination flag
	AMSFMSPan:			ds.b 1	; S&K: 0Ah
	DurationTimeout:	ds.b 1	; S&K: 0Bh
	SavedDuration:		ds.b 1	; S&K: 0Ch		; Already multiplied by timing divisor
	; ---------------------------------
	; Alternate names for same offset:
	SavedDAC:					; S&K: 0Dh		; For DAC channel
	FreqLow:			ds.b 1	; S&K: 0Dh		; For FM/PSG channels
	; ---------------------------------
	FreqHigh:			ds.b 1	; S&K: 0Eh		; For FM/PSG channels
	VoiceSongID:		ds.b 1	; S&K: 0Fh		; For using voices from a different song
	DACSFXPlaying:
	Detune:				ds.b 1	; S&K: 10h/11h	; In S&K, some places used 11h instead of 10h
	VolEnv:				ds.b 1	; S&K: 17h		; Used for dynamic volume adjustments
	; ---------------------------------
	; Alternate names for same offsets:
	FMVolEnv:					; S&K: 18h
	HaveSSGEGFlag:		ds.b 1	; S&K: 18h		; For FM channels, if track has SSG-EG data
	FMVolEnvMask:				; S&K: 19h
	SSGEGPointerLow:	ds.b 1	; S&K: 19h		; For FM channels, custom SSG-EG data pointer
	PSGNoise:					; S&K: 1Ah
	SSGEGPointerHigh:	ds.b 1	; S&K: 1Ah		; For FM channels, custom SSG-EG data pointer
	; ---------------------------------
	TLPtrLow:			ds.b 1	; S&K: 1Ch
	TLPtrHigh:			ds.b 1	; S&K: 1Dh
	NoteFillTimeout:	ds.b 1	; S&K: 1Eh
	NoteFillMaster:		ds.b 1	; S&K: 1Fh
	ModulationPtrLow:	ds.b 1	; S&K: 20h
	ModulationPtrHigh:	ds.b 1	; S&K: 21h
	; ---------------------------------
	; Alternate names for same offset:
	ModulationValLow:			; S&K: 22h
	ModEnvSens:			ds.b 1	; S&K: 22h
	; ---------------------------------
	ModulationValHigh:	ds.b 1	; S&K: 23h
	ModulationWait:		ds.b 1	; S&K: 24h
	; ---------------------------------
	; Alternate names for same offset:
	ModulationSpeed:			; S&K: 25h
	ModEnvIndex:		ds.b 1	; S&K: 25h
	; ---------------------------------
	ModulationDelta:	ds.b 1	; S&K: 26h
	ModulationSteps:	ds.b 1	; S&K: 27h
	LoopCounters:		ds.b 2	; S&K: 28h		; Might overflow into the following data
	VoicesLow:			ds.b 1	; S&K: 2Ah		; Low byte of pointer to track's voices, used only if zUpdatingSFX is set
	VoicesHigh:			ds.b 1	; S&K: 2Bh		; High byte of pointer to track's voices, used only if zUpdatingSFX is set
	Stack_top:			ds.b 4	; S&K: 2Ch-2Fh	; Track stack; can be used by LoopCounters
zTrack ENDSTRUCT
; ---------------------------------------------------------------------------
; Playback control bits:
bitPSGNoise       = 0
bitFM3Special     = 0
bitNoAttack       = 1
bitSFXOverride    = 2
bitAltFreqMode    = 3
bitTrackAtRest    = 4
bitPitchSlide     = 5
bitSustainFreq    = 6
bitTrackPlaying   = 7
maskSkipFMNoteOn  = (1<<bitNoAttack)|(1<<bitSFXOverride)|(1<<bitNoAttack)
maskSkipFMNoteOff = (1<<bitSFXOverride)|(1<<bitNoAttack)
maskPlayRest      = (1<<bitTrackPlaying)|(1<<bitTrackAtRest)
maskFM6Unused     = (1<<bitSFXOverride)|(1<<bitTrackAtRest)
; Voice control values:
ymFM1      = 0
ymFM2      = 1
ymFM3      = 2
ymFM4      = 4
ymFM5      = 5
ymFM6      = 6
ymDAC      = 6
ymPartII   = 2			; Bit value
snPSGTone  = 0
snPSGVol   = $10
snPSG1     = $80
snPSG2     = $A0
snPSG3     = $C0
snNoise    = $E0
bitIsPSG   = 7			; Bit value
; ---------------------------------------------------------------------------
; equates: standard (for Genesis games) addresses in the memory map
zYM2612_A0				=	$4000
zYM2612_D0				=	$4001
zYM2612_A1				=	$4002
zYM2612_D1				=	$4003
zBankRegister			=	$6000
zPSG					=	$7F11
zROMWindow				=	$8000
; ---------------------------------------------------------------------------
; YM2612 register equates
ymLFO                      = $22
maskLFOFrequency           = 7
bitLFOEnable               = 3

ymTimerAFrequencyHigh      = $24
ymTimerAFrequencyLow       = $25

ymTimerBFrequency          = $26

ymTimerControlFm3Mode      = $27
maskFM3Normal              = 0
maskFM3Special             = $40
bitTimerALoad              = 0
bitTimerBLoad              = 1
bitTimerAEnable            = 2
bitTimerBEnable            = 3
bitTimerAReset             = 4
bitTimerBReset             = 5
maskEnableLoadTimers       = (1<<bitTimerBEnable)|(1<<bitTimerAEnable)|(1<<bitTimerBLoad)|(1<<bitTimerALoad)

ymKeyOnOff                 = $28
bitOperator1               = 4
bitOperator2               = 5
bitOperator3               = 6
bitOperator4               = 7
maskAllOperators           = (1<<bitOperator4)|(1<<bitOperator3)|(1<<bitOperator2)|(1<<bitOperator1)

ymDACPCM                   = $2A
ymDACEnable                = $2B
maskDACDisable             = 0
maskDACEnable              = $80

ymDetuneMultiply1          = $30
ymDetuneMultiply2          = $34
ymDetuneMultiply3          = $38
ymDetuneMultiply4          = $3C

ymTotalLevel1              = $40
ymTotalLevel2              = $44
ymTotalLevel3              = $48
ymTotalLevel4              = $4C

ymRateScaleAttackRate1     = $50
ymRateScaleAttackRate2     = $54
ymRateScaleAttackRate3     = $58
ymRateScaleAttackRate4     = $5C
maskAttackRate             = $1F
maxAttackRate              = maskAttackRate
maskRateScale              = $C0

ymAMDecayRate1             = $60
ymAMDecayRate2             = $64
ymAMDecayRate3             = $68
ymAMDecayRate4             = $6C

ymSustainRate1             = $70
ymSustainRate2             = $74
ymSustainRate3             = $78
ymSustainRate4             = $7C

ymSustainLevelReleaseRate1 = $80
ymSustainLevelReleaseRate2 = $84
ymSustainLevelReleaseRate3 = $88
ymSustainLevelReleaseRate4 = $8C
maskReleaseRate            = $F
maxReleaseRate             = maskReleaseRate
maskSustainLevel           = $F0
maxSustainLevel            = maskSustainLevel

ymSSGEG1                   = $90
ymSSGEG2                   = $94
ymSSGEG3                   = $98
ymSSGEG4                   = $9C
maskSSGEGEnvelopeShape     = 7
bitSSGEGEnable             = 3
maskSSGEGEnable            = 1<<bitSSGEGEnable

ymFrequencyLow             = $A0
ymFrequencyHigh            = $A4
ymCH3FrequencyLow1         = $A9
ymCH3FrequencyLow2         = $AA
ymCH3FrequencyLow3         = $A8
ymCH3FrequencyLow4         = $A2
ymCH3FrequencyHigh1        = $AD
ymCH3FrequencyHigh2        = $AE
ymCH3FrequencyHigh3        = $AC
ymCH3FrequencyHigh4        = $A6

ymAlgorithmFeedback        = $B0
maskAlgorithm              = 7
maskFeedback               = $38

ymPanningAMSensFMSens      = $B4
maskFMSensitivity          = 7
maskAMSensitivity          = $30
bitOutputRight             = 6
bitOutputLeft              = 7
maskPanning                = $C0
; ---------------------------------------------------------------------------
; Envelope-related constants
ModEnvReset     = $80
ModEnvSustain1  = $81
ModEnvJumpTo    = $82
ModEnvSustain   = $83
ModEnvAlterSens = $84

VolEnvReset     = $80
VolEnvRestTrack = $81
VolEnvJumpTo    = $82
VolEnvStopTrack = $83
; ---------------------------------------------------------------------------
; z80 RAM:
zDataStart				=	$1C1A
		phase zDataStart
z80_stack_top:		ds.b $60
z80_stack:
zDACEnable:			ds.b 1
zDACEnableSave:		ds.b 1
zSpecFM3Freqs:		ds.b 8
zSpecFM3FreqsSFX:	ds.b 8
zQueueVariables:
zPalFlag:			ds.b 1
zPalDblUpdCounter:	ds.b 1
zSoundQueue0:		ds.b 1
zSoundQueue1:		ds.b 1
zSoundQueue2:		ds.b 1
zTempoSpeedup:		ds.b 1
zTempoSpeedupReq:	ds.b 1
zNextSound:			ds.b 1
; The following 3 variables are used for M68K input
zMusicNumber:		ds.b 1	; Play_Sound
zSFXNumber0:		ds.b 1	; Play_Sound_2
zSFXNumber1:		ds.b 1	; Play_Sound_2
	if (zQueueVariables&1)<>0
		fatal "zQueueVariables must be at an even address."
	endif
zContinuousSFX:		ds.b 1
zContinuousSFXFlag:	ds.b 1
zContSFXLoopCnt:	ds.b 1	; Used as a loop counter for continuous SFX
zFadeOutTimeout:	ds.b 1
zFadeDelay:			ds.b 1
zFadeDelayTimeout:	ds.b 1
zPauseFlag:			ds.b 1
zHaltFlag:			ds.b 1
zTempoAccumulator:	ds.b 1
zFadeToPrevFlag:	ds.b 1
zUpdatingSFX:		ds.b 1
zCurrentTempo:		ds.b 1
zSpindashRev:		ds.b 1
zRingSpeaker:		ds.b 1
zFadeInTimeout:		ds.b 1
zVoiceTblPtrSave:	ds.b 2	; For 1-up
zCurrentTempoSave:	ds.b 1	; For 1-up
zSongBankSave:		ds.b 1	; For 1-up
zTempoSpeedupSave:	ds.b 1	; For 1-up
zSpeedupTimeout:	ds.b 1
zDACIndex:			ds.b 1	; bit 7 = 1 if playing, 0 if not; remaining 7 bits are index into DAC tables (1-based)
zSongPosition:		ds.b 2
zTrackInitPos:		ds.b 2	; 2 bytes
zVoiceTblPtr:		ds.b 2	; 2 bytes
zSongBank:			ds.b 1	; Bits 15 to 22 of M68K bank address
PlaySegaPCMFlag:	ds.b 1
zSFXVoiceTblPtr:	ds.b 2	; 2 bytes
zSFXTempoDivider:	ds.b 1
; Now starts song and SFX z80 RAM
; Max number of music channels: 6 FM + 3 PSG or 1 DAC + 5 FM + 3 PSG
zTracksStart:
zSongDAC:		zTrack
zSongFM1:		zTrack
zSongFM2:		zTrack
zSongFM3:		zTrack
zSongFM4:		zTrack
zSongFM5:		zTrack
zSongFM6:		zTrack
zSongPSG1:		zTrack
zSongPSG2:		zTrack
zSongPSG3:		zTrack
zTracksEnd:
; This is RAM for backup of songs (when 1-up jingle is playing)
; and for SFX channels. Note these two overlap.
; Max number of SFX channels: 4 FM + 3 PSG
zTracksSFXStart:
zSFX_FM3:		zTrack
zSFX_FM4:		zTrack
zSFX_FM5:		zTrack
zSFX_FM6:		zTrack
zSFX_PSG1:		zTrack
zSFX_PSG2:		zTrack
zSFX_PSG3:		zTrack
zTracksSFXEnd:
		dephase
		phase zTracksSFXStart
zTracksSaveStart:
zSaveSongDAC:	zTrack
zSaveSongFM1:	zTrack
zSaveSongFM2:	zTrack
zSaveSongFM3:	zTrack
zSaveSongFM4:	zTrack
zSaveSongFM5:	zTrack
zSaveSongFM6:	zTrack
zSaveSongPSG1:	zTrack
zSaveSongPSG2:	zTrack
zSaveSongPSG3:	zTrack
zTracksSaveEnd:
	if (zQueueVariables&1)<>0
		fatal "zQueueVariables must be at an even address as it is used as a longword by the 68k!"
	endif
	if * > $2000	; Don't declare more space than the RAM can contain!
		fatal "The RAM variable declarations are too large by $\{$} bytes."
	endif
		dephase
zNumMusicTracks = (zTracksEnd-zTracksStart)/zTrack.len
zNumMusicFMorPSGTracks = (zTracksEnd-zSongFM1)/zTrack.len
zNumMusicFMorDACTracks = (zSongPSG1-zTracksStart)/zTrack.len
zNumMusicFMTracks = (zSongPSG1-zSongFM1)/zTrack.len
zNumMusicFM1Tracks = (zSongFM4-zSongFM1)/zTrack.len
zNumMusicFM2Tracks = (zSongPSG1-zSongFM4)/zTrack.len
zNumMusicPSGTracks = (zTracksEnd-zSongPSG1)/zTrack.len
zNumSFXTracks = (zTracksSFXEnd-zTracksSFXStart)/zTrack.len
zNumSaveTracks = (zTracksSaveEnd-zTracksSaveStart)/zTrack.len
; ---------------------------------------------------------------------------
		!org z80_SoundDriverStart
z80_SoundDriver:
		save
		!org	0							; z80 Align, handled by the build process
		CPU Z80
		listing purecode
; ---------------------------------------------------------------------------
	ifndef MusID__First
		ifdef mus__First
MusID__First			= mus__First
		else
			ifdef bgm__First
MusID__First			= bgm__First
			endif
		endif
		ifndef MusID__First
MusID__First			= 01h
		endif
	endif

	ifndef MusID_ExtraLife
		ifdef mus_ExtraLife
MusID_ExtraLife			= mus_ExtraLife
		else
			ifdef bgm_ExtraLife
MusID_ExtraLife			= bgm_ExtraLife
			endif
		endif
		ifndef MusID_ExtraLife
MusID_ExtraLife			= 2Ah
		endif
	endif

	ifndef MusID__End
		ifdef mus__End
MusID__End				= mus__End
		else
			ifdef bgm__Last
MusID__End				= bgm__Last
			endif
		endif
		ifndef MusID__End
MusID__End				= 33h
		endif
	endif

	ifdef MusID_SKCredits
		if MusID_SKCredits>=MusID__End
			fatal "S&K Credits music must have an ID within the music range of [$\{MusID__First}, $\{MusID__End}), but it has ID $\{MusID_SKCredits}"
		endif
	endif
	ifdef mus_CreditsK
		if mus_CreditsK>=MusID__End
			fatal "S&K Credits music must have an ID within the music range of [$\{MusID__First}, $\{MusID__End}), but it has ID $\{mus_CreditsK}"
		endif
	endif

	ifndef SndID__First
		ifdef sfx_First
SndID__First			= sfx_First
			if sfx_First>1
				message "You can gain more IDs for SFX by changing the the definition of the sfx_First constant to 1 (it is currently $\{sfx_First})"
			endif
		else
			ifdef sfx__First
SndID__First			= sfx__First
				if sfx__First>1
					message "You can gain more IDs for SFX by changing the the definition of the sfx__First constant to 1 (it is currently $\{sfx__First})"
				endif
			endif
		endif
		ifndef SndID__First
SndID__First			= 01h
		endif
	elseif SndID__First>1
		message "You can gain more IDs for SFX by changing the the definition of the SndID__First constant to 1 (it is currently $\{SndID__First})"
	endif

	ifndef SndID_Ring
		ifdef sfx_RingRight
SndID_Ring				= sfx_RingRight
		else
			ifdef sfx_Ring
SndID_Ring				= sfx_Ring
			endif
		endif
		ifndef SndID_Ring
SndID_Ring				= SndID__First
		endif
	endif

	ifndef SndID_RingLeft
		ifdef sfx_RingLeft
SndID_RingLeft			= sfx_RingLeft
		endif
		ifndef SndID_RingLeft
SndID_RingLeft			= SndID_Ring+1
		endif
	endif

	if SndID_RingLeft==SndID_Ring+1
RingSoundsAdjacent := 1
	else
RingSoundsAdjacent := 0
		warning "You should make sure SndID_RingLeft is immediately after SndID_Ring"
	endif

	ifndef SndID_SpindashRev
		ifdef sfx_SpinDash
SndID_SpindashRev		= sfx_SpinDash
		else
			ifdef sfx_Roll
SndID_SpindashRev		= sfx_Roll
				warning "Approximating spindash rev sound by rolling sound. Please provide an adequate equate for the ported spindash rev sound"
			endif
		endif
		ifndef SndID_SpindashRev
SndID_SpindashRev		= 0ABh-33h+SndID__First
		endif
	endif

	ifndef SndID__End
		ifdef sfx__End
SndID__End				= sfx__End
		else
			ifdef sfx__Last
SndID__End				= sfx__Last
			endif
		endif
		ifndef SndID__End
SndID__End				= 0E0h-33h+SndID__First
		endif
	endif

	ifndef SndID__FirstContinuous
		ifdef sfx__FirstContinuous
SndID__FirstContinuous	= sfx__FirstContinuous
		else
SndID__FirstContinuous	= 0BCh-33h+SndID__First
		endif
	endif

	ifndef SndID__FirstContinuous
SndID__FirstContinuous	= SndID__End
	endif

	ifndef DACID__First
		ifdef dac__First
DACID__First	= dac__First
		else
DACID__First	= SndID__End
		endif
	endif

	ifndef DACID__End
		ifdef dac__End
DACID__End	= dac__End
		else
DACID__End	= SndID__End
		endif
	endif

	ifndef FadeID__First
		ifdef mus__FirstCmd
FadeID__First			= mus__FirstCmd
		else
			ifdef flg__First
FadeID__First			= flg__First
			endif
		endif
		ifndef FadeID__First
FadeID__First			= 0E1h
		endif
	endif

	ifndef FadeID__End
		ifdef mus__EndCmd
FadeID__End				= mus__EndCmd
		else
			ifdef flg__Last
FadeID__End				= flg__Last
			endif
		endif
		ifndef FadeID__End
FadeID__End				= 0E6h
		endif
	endif

	ifndef MusID_StopSega
		ifdef mus_StopSEGA
MusID_StopSega			= mus_StopSEGA
		else
			ifndef MusID_StopSega
MusID_StopSega			= 0FEh
			endif
		endif
	endif

	ifndef MusID_SegaSound
		ifdef mus_SEGA
MusID_SegaSound			= mus_SEGA
		else
			ifdef sfx_Sega
MusID_SegaSound			= sfx_Sega
			endif
		endif
		ifndef MusID_SegaSound
MusID_SegaSound			= 0FFh
		endif
	endif
; ---------------------------------------------------------------------------
NoteRest				= 080h
FirstCoordFlag			= 0E0h
; ---------------------------------------------------------------------------
zID_MusicPointers = 0
zID_SFXPointers = 2
zID_ModEnvPointers = 4
zID_VolEnvPointers = 6
; ---------------------------------------------------------------------------

; ===========================================================================
; Macros
; ===========================================================================
bankswitch macro
		ld	hl, zBankRegister
		ld	(hl), a
		rept 7
			rrca
			ld	(hl), a
		endr
		ld	(hl), h							; The low bit of h is 0
	endm

bankswitchLoop macro
		ld	b, 8
.bankloop:
		ld	(zBankRegister), a
		rrca
		djnz	.bankloop
		xor	a
		ld	(zBankRegister), a
	endm

bankswitchToMusic macro
		ld	a, (zSongBank)
		bankswitch
	endm

; macro to make a certain error message clearer should you happen to get it...
rsttarget macro {INTLABEL}
	if ($&7)||($>38h)
		fatal "Function __LABEL__ is at 0\{$}h, but must be at a multiple of 8 bytes <= 38h to be used with the rst instruction."
	endif
	if "__LABEL__"<>""
__LABEL__ label $
	endif
	endm

setMaxAR macro
		or	maxAttackRate					; Set AR to maximum
	endm

calcVolume macro
		or	a								; Is it positive?
		jp	p, .skip_track_vol				; Branch if yes
		add	a, (ix+zTrack.Volume)			; Add track's volume to it
		jr	nc, .skip_track_vol
		sbc	a, a							; Clamp volume attenuation as it overflowed
.skip_track_vol:
	endm

zFastWriteFM macro reg, data, dataMacro
		ld	a, reg							; Get register to write to
		add	a, c							; Add the channel bits to the register address
		ld	(iy+0), a						; Select YM2612 register
		ld	a, data							; a = data to send
		if "dataMacro"<>""
			dataMacro
		endif
		ld	(iy+1), a						; Send data to register
	endm

zGetFMPartPointer macro
		ld	c, (ix+zTrack.VoiceControl)		; Get voice control bits for future use
		ld	iy, zYM2612_A0					; Point to part I
		bit	ymPartII, c						; Is this the DAC channel or FM4 or FM5 or FM6?
		jr	z, .notFMII						; If not, write reg/data pair to part I
		res	ymPartII, c						; Strip 'bound to part II regs' bit
		ld	iy, zYM2612_A1					; Point to part II
.notFMII:
	endm

; function to turn a 68k address into a word the Z80 can use to access it
zmake68kPtr function addr,zROMWindow+(addr&7FFFh)

; function to turn a 68k address into a bank byte
; Note: This discards a bit (should be 0FF8000h instead of 7F8000h). This is
; relatively harmless since the driver only uses 8 bits anyway.
zmake68kBank function addr,(((addr&7F8000h)>>15))
; ---------------------------------------------------------------------------
; ===========================================================================
; Entry Point
; ===========================================================================

; EntryPoint:
		di									; Disable interrupts
		di									; Disable interrupts
		im	1								; set interrupt mode 1
		jp	zInitAudioDriver
; ---------------------------------------------------------------------------

; =============== S U B	R O U T	I N E =======================================
;
; Gets the correct pointer to pointer table for the data type in question
; (music, sfx, voices, etc.).
;
; Input:  c    ID for data type.
; Output: hl   Master pointer table for	index
;         af'  Trashed
;         b    Trashed

; sub_8
	align	8
GetPointerTable:	rsttarget
		ld	hl,z80_SoundDriverPointers		; Load pointer table
		ld	b, 0							; b = 0
		add	hl, bc							; Add offset into pointer table
		ex	af, af'							; Back up af
		ld	a, (hl)							; Read low byte of pointer into a
		inc	hl
		ld	h, (hl)							; Read high byte of pointer into h
		ld	l, a							; Put low byte of pointer into l
		ex	af, af'							; Restore af
		jp	PointerTableOffset
; End of function GetPointerTable

; =============== S U B	R O U T	I N E =======================================
;
; Reads	an offset into a pointer table and returns dereferenced pointer.
;
;
; Input:  a    Index into pointer table
;	      hl   Pointer to pointer table
; Output: hl   Selected	pointer	in pointer table
;         bc   Trashed

; sub_18
	align	8
PointerTableOffset:	rsttarget
		ld	c, a							; c = index into pointer table
		ld	b, 0							; b = 0
		add	hl, bc							; hl += bc
		add	hl, bc							; hl += bc
		jp	ReadPointer						; 10 clock cycles, 3 bytes
; End of function PointerTableOffset

; =============== S U B	R O U T	I N E =======================================
;
; Dereferences a pointer.
;
; Input:  hl	Pointer
; output: hl	Equal to what that was being pointed to by hl

; loc_20
	align	8
ReadPointer:	rsttarget
		ld	a, (hl)							; Read low byte of pointer into a
		inc	hl
		ld	h, (hl)							; Read high byte of pointer into h
		ld	l, a							; Put low byte of pointer into l
		ret
; End of function ReadPointer

; ---------------------------------------------------------------------------
; There is room for two more 'rsttarget's here
; ---------------------------------------------------------------------------
	align	38h
; =============== S U B	R O U T	I N E =======================================
;
; This subroutine is called every V-Int. After it is processed, the z80
; returns to the digital audio loop to comtinue playing DAC samples.
;
; If the SEGA PCM is being played, it disables interrupts -- this means that
; this procedure will NOT be called while the SEGA PCM is playing.
;
;zsub_38
zVInt:	rsttarget
		di									; Disable interrupts
		push	af							; Save af
		push	iy							; Save iy
		exx									; Save bc,de,hl

.doupdate:
		call	zUpdateEverything			; Update all tracks
		ld	a, (zPalFlag)					; Get PAL flag
		or	a								; Is it set?
		jr	z, .not_pal						; Branch if not (NTSC)
		ld	a, (zPalDblUpdCounter)			; Get PAL double-update timeout counter
		or	a								; Is it zero?
		jr	nz, .pal_timer					; Branch if not
		ld	a, 5							; Set it back to 5...
		ld	(zPalDblUpdCounter), a			; ... and save it
		jp	.doupdate						; Go again

.pal_timer:
		dec	a								; Decrease PAL double-update timeout counter
		ld	(zPalDblUpdCounter), a			; Store it

.not_pal:
		ld	a, (zDACIndex)					; Get index of playing DAC sample
		and	7Fh								; Strip 'DAC playing' bit
		ld	c, a							; c = a
		ld	b, 0							; Sign extend c to bc
		ld	hl, DAC_Banks					; Make hl point to DAC bank table
		add	hl, bc							; Offset into entry for current sample
		ld	a, (hl)							; Get bank index
		bankswitch							; Switch to current DAC sample's bank
		exx									; Restore bc,de,hl
		pop	iy								; Restore iy
		pop	af								; Restore af
		ld	b, 1							; b = 1
		ret
; ---------------------------------------------------------------------------
;loc_85
zInitAudioDriver:
		ld	sp, z80_stack					; set the stack pointer to 0x2000 (end of z80 RAM)
		; The following instruction block keeps the z80 in a tight loop.
		ld	c, 0							; c = 0

.loop:
		ld	b, 0							; b = 0
		djnz	$							; Loop in this instruction, decrementing b each iteration, until b = 0
		dec	c								; c--
		jr	z, .loop						; Loop if c = 0

		call	zMusicFade					; Stop all music

	if (use_s3_samples<>0)||(use_sk_samples<>0)||(use_s3d_samples<>0)
		ld	a, zmake68kBank(DacBank2)		; Set song bank to second DAC bank (default value)
	else
		ld	a, zmake68kBank(DacBank4)		; Set song bank to second DAC bank (default value)
	endif

		ld	(zSongBank), a					; Store it
		xor	a								; a = 0
		ld	(zSpindashRev), a				; Reset spindash rev
		ld	(zDACIndex), a					; Clear current DAC sample index
		ld	(PlaySegaPCMFlag), a			; Clear the Sega sound flag
		ld	(zRingSpeaker), a				; Make rings play on left speaker
		ld	a, 5							; Set PAL double-update counter to 5
		ld	(zPalDblUpdCounter), a			; (that is, do not double-update for 5 frames)
		ei									; Enable interrupts
		jp	zPlayDigitalAudio				; Start digital audio loop
; ---------------------------------------------------------------------------

; =============== S U B	R O U T	I N E =======================================
;
; Writes a reg/data pair to part I or II
;
; Input:  a    Value for register
;         c    Value for data
;         ix   Pointer to track RAM

;sub_AF
zWriteFMIorII:
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		ret	nz								; Is so, quit
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is SFX overriding this track?
		ret	nz								; Return if yes
		add	a, (ix+zTrack.VoiceControl)		; Add the channel bits to the register address
		bit	ymPartII, (ix+zTrack.VoiceControl)	; Is this the DAC channel or FM4 or FM5 or FM6?
		jr	nz, zWriteFMII_reduced			; If yes, write reg/data pair to part II;
											; otherwise, write reg/data pair as is to part I.
; End of function zWriteFMIorII


; =============== S U B	R O U T	I N E =======================================
;
; Writes a reg/data pair to part I
;
; Input:  a    Value for register
;         c    Value for data

;sub_C2
zWriteFMI:
		ld	(zYM2612_A0), a					; Select YM2612 register
		nop									; Wait
		ld	a, c							; a = data to send
		ld	(zYM2612_D0), a					; Send data to register
		ret
; End of function zWriteFMI
; ---------------------------------------------------------------------------

;loc_CB
zWriteFMII_reduced:
		sub	1<<ymPartII						; Strip 'bound to part II regs' bit
; ---------------------------------------------------------------------------

; =============== S U B	R O U T	I N E =======================================
;
; Writes a reg/data pair to part II
;
; Input:  a    Value for register
;         c    Value for data

;sub_CD
zWriteFMII:
		ld	(zYM2612_A1), a					; Select YM2612 register
		nop									; Wait
		ld	a, c							; a = data to send
		ld	(zYM2612_D1), a					; Send data to register
		ret
; End of function zWriteFMII

; ---------------------------------------------------------------------------

; =============== S U B	R O U T	I N E =======================================
;
;sub_11B
zUpdateEverything:
		call	zPauseUnpause				; Pause/unpause according to M68K input
		call	zUpdateSFXTracks			; Do SFX tracks

;loc_121
zUpdateMusic:
		call	TempoWait					; Delay song tracks as appropriate for main tempo mod
		call	zDoMusicFadeOut				; Check if music should be faded out and fade if needed
		call	zDoMusicFadeIn				; Check if music should be faded in and fade if needed
		ld	a, (zFadeToPrevFlag)			; Get fade-to-prev flag
		cp	MusID_ExtraLife-1				; Is it still 1-Up?
		jr	nz, .check_fade_in				; Branch if not
		ld	a, (zMusicNumber)				; Get next music to play
		cp	MusID_ExtraLife					; Is it another 1-Up?
		jr	z, .clr_queue					; Branch if yes
		cp	MusID__End-1					; Is it music?
		jr	c, .clr_sfx						; Branch if not

.clr_queue:
		xor	a								; a = 0
		ld	(zMusicNumber), a				; Clear queue entry

.clr_sfx:
		xor	a								; a = 0
		ld	(zSFXNumber0), a				; Clear first queued SFX
		ld	(zSFXNumber1), a				; Clear second queued SFX
		jr	.update_music

;loc_149
.check_fade_in:
		ld	a, (zFadeToPrevFlag)			; Get fade-to-previous flag
		cp	0FFh							; Is it 0FFh?
		jr	z, .update_music				; Branch if yes
		ld	hl, zMusicNumber				; Point hl to M68K input
		ld	e, (hl)							; e = next song to play
		inc	hl								; Advance pointer
		ld	d, (hl)							; d = next SFX to play
		inc	hl								; Advance pointer
		ld	a, (hl)							; a = next SFX to play
		or	d								; Combine bits of a and d
		or	e								; Is anything in the play queue?
		jr	z, .update_music				; Branch if not
		call	zFillSoundQueue				; Transfer M68K input
		call	zCycleMusicQueue			; Cycle queue and play first entry (moves on to second)
		call	zCycleSoundQueue			; Cycle queue and play second entry
		call	zCycleSoundQueue			; Cycle queue and play third entry

.update_music:
		bankswitchToMusic
		xor	a								; a = 0
		ld	(zUpdatingSFX), a				; Updating music
		ld	a, (zFadeToPrevFlag)			; Get fade-to-previous flag
		cp	0FFh							; Is it 0FFh?
		call	z, zFadeInToPrevious		; Fade to previous if yes
		ld	ix, zSongDAC					; ix = DAC track RAM
		bit	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Is DAC track playing?
		call	nz, zUpdateDACTrack			; Branch if yes
		ld	b, zNumMusicFMorPSGTracks		; Number of FM+PSG tracks
		ld	ix, zSongFM1					; ix = FM1 track RAM
		jr	zTrackUpdLoop					; Play all tracks

; =============== S U B	R O U T	I N E =======================================
;
;sub_19E
zUpdateSFXTracks:
		ld	a, 1							; a = 1
		ld	(zUpdatingSFX), a				; Updating SFX
		ld	a, zmake68kBank(SndBank)		; Get SFX bank ID
		bankswitch							; Bank switch to SFX
		ld	ix, zTracksSFXStart				; ix = start of SFX track RAM
		ld	b, zNumSFXTracks				; Number of channels

zTrackUpdLoop:
		push	bc							; Save bc
		bit	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Is track playing?
		call	nz, zUpdateFMorPSGTrack		; Call routine if yes
		ld	de, zTrack.len					; Spacing between tracks
		add	ix, de							; Advance to next track
		pop	bc								; Restore bc
		djnz	zTrackUpdLoop				; Loop for all tracks

		ld	a, (zTempoSpeedup)				; Get tempo speed-up value
		or	a								; Is music sped up?
		ret	z								; Return if not
		ld	a, (zSpeedupTimeout)			; Get extra tempo timeout
		or	a								; Has it expired?
		jp	nz, .no_dbl_update				; Branch if not
		ld	a, (zTempoSpeedup)				; Get master tempo speed-up value
		ld	(zSpeedupTimeout), a			; Reset extra tempo timeout to it
		jp	zUpdateMusic					; Update music again
; ---------------------------------------------------------------------------
.no_dbl_update:
		dec	a								; Decrement timeout...
		ld	(zSpeedupTimeout), a			; ... then store new value
		ret
; End of function zUpdateSFXTracks


; =============== S U B	R O U T	I N E =======================================
; Updates FM or PSG track.
;
;sub_1E9
zUpdateFMorPSGTrack:
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG channel?
		jp	nz, zUpdatePSGTrack				; Branch if yes
		dec	(ix+zTrack.DurationTimeout)		; Run note timer
		jr	nz, .note_going					; Branch if note hasn't expired yet
		call	zGetNextNote				; Get next note for FM track
		bit	bitTrackAtRest, (ix+zTrack.PlaybackControl)	; Is track resting?
		ret	nz								; Return if yes
		call	zPrepareModulation			; Initialize modulation
		call	zDoPitchSlide				; Apply pitch slide and detune
		call	zDoModulation				; Apply modulation
		call	zFMSendFreq					; Send frequency to YM2612
		jp	zFMNoteOn						; Note on on all operators
; ---------------------------------------------------------------------------
.note_going:
		bit	bitTrackAtRest, (ix+zTrack.PlaybackControl)	; Is track resting?
		ret	nz								; Return if yes
		call	zDoFMVolEnv					; Do FM volume envelope effects for track
		ld	a, (ix+zTrack.NoteFillTimeout)	; Get note fill timeout
		or	a								; Is timeout either not running or expired?
		jr	z, .keep_going					; Branch if yes
		dec	(ix+zTrack.NoteFillTimeout)		; Update note fill timeout
		jp	z, zKeyOffIfActive				; Send key off if needed

.keep_going:
		call	zDoPitchSlide				; Apply pitch slide and detune
		bit	bitSustainFreq, (ix+zTrack.PlaybackControl)	; Is 'sustain frequency' bit set?
		ret	nz								; Return if yes
		call	zDoModulation				; Apply modulation then fall through
		; Fall through to next function
; End of function zUpdateFMorPSGTrack


; =============== S U B	R O U T	I N E =======================================
; Uploads track's frequency to YM2612.
;
; Input:   ix    Pointer to track RAM
;          hl    Frequency to upload
;          de    For FM3 in special mode, pointer to extra FM3 frequency data (never correctly set)
; Output:  a     Trashed
;          bc    Trashed
;          hl    Trashed
;          de    Increased by 8
;
;sub_22B
zFMSendFreq:
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is SFX overriding this track?
		ret	nz								; Return if yes
		bit	bitFM3Special, (ix+zTrack.PlaybackControl)	; Is track in special mode (FM3 only)?
		jp	nz, .special_mode				; Branch if yes

.not_fm3:
		ld	a, ymFrequencyHigh				; Command to update frequency MSB
		ld	c, h							; High byte of frequency
		call	zWriteFMIorII				; Send it to YM2612
		ld	a, ymFrequencyLow				; Command to update frequency LSB
		ld	c, l							; Low byte of frequency
		jp	zWriteFMIorII					; Send it to YM2612
; ---------------------------------------------------------------------------
.special_mode:
		ld	a, (ix+zTrack.VoiceControl)		; a = voice control byte
		cp	ymFM3							; Is this FM3?
		jr	nz, .not_fm3					; Branch if not
		call	zGetSpecialFM3DataPointer	; de = pointer to saved FM3 frequency shifts
		ld	b, zSpecialFreqCommands_End-zSpecialFreqCommands	; Number of entries
		ld	hl, zSpecialFreqCommands		; Lookup table

.loop:
		push	bc							; Save bc
		ld	a, (hl)							; a = register selector
		inc	hl								; Advance pointer
		push	hl							; Save hl
		ex	de, hl							; Exchange de and hl
		ld	c, (hl)							; Get byte from FM3 data
		inc	hl								; Advance pointer
		ld	b, (hl)							; Get byte from FM3 data
		inc	hl								; Advance pointer
		ex	de, hl							; Exchange de and hl
		ld	l, (ix+zTrack.FreqLow)			; l = low byte of track frequency
		ld	h, (ix+zTrack.FreqHigh)			; h = high byte of track frequency
		add	hl, bc							; hl = full frequency for operator
		push	af							; Save af
		ld	c, h							; High byte of frequency
		call	zWriteFMI					; Sent it to YM2612
		pop	af								; Restore af
		sub	ymCH3FrequencyHigh1-ymCH3FrequencyLow1	; Move on to frequency LSB
		ld	c, l							; Low byte of frequency
		call	zWriteFMI					; Sent it to YM2612
		pop	hl								; Restore hl
		pop	bc								; Restore bc
		djnz	.loop						; Loop for all operators
		ret
; End of function zFMSendFreq

; ---------------------------------------------------------------------------
;loc_272
zSpecialFreqCommands:
		db ymCH3FrequencyHigh1				; Operator 4 frequency MSB
		db ymCH3FrequencyHigh2				; Operator 3 frequency MSB
		db ymCH3FrequencyHigh3				; Operator 2 frequency MSB
		db ymCH3FrequencyHigh4				; Operator 1 frequency MSB
zSpecialFreqCommands_End

; =============== S U B	R O U T	I N E =======================================
;
zGetSpecialFM3DataPointer:
		ld	de, zSpecFM3Freqs				; de = pointer to saved FM3 frequency shifts
		ld	a, (zUpdatingSFX)				; Get flag
		or	a								; Is this a SFX track?
		ret	z								; Return if not
		ld	de, zSpecFM3FreqsSFX			; de = pointer to saved FM3 frequency shifts
		ret
; End of function zGetSpecialFM3DataPointer


; =============== S U B	R O U T	I N E =======================================
; Gets next note from the track's data stream. If any coordination flags are
; found, they are handled and then the function keeps looping until a note is
; found.
;
; Input:   ix    Pointer to track's RAM
; Output:  de    Pointer to current position on track data
;          hl    Note frequency
;          All others possibly trashed due to coordination flags
;
;sub_277
zGetNextNote:
		ld	e, (ix+zTrack.DataPointerLow)	; e = low byte of track data pointer
		ld	d, (ix+zTrack.DataPointerHigh)	; d = high byte of track data pointer
		res	bitNoAttack, (ix+zTrack.PlaybackControl)	; Clear 'do not attack next note' flag
		res	bitTrackAtRest, (ix+zTrack.PlaybackControl)	; Clear 'track is at rest' flag

;loc_285
zGetNextNote_cont:
		ld	a, (de)							; Get next byte from track
		inc	de								; Advance pointer
		cp	FirstCoordFlag					; Is it a coordination flag?
		jp	nc, zHandleFMorPSGCoordFlag		; Branch if yes
		ex	af, af'							; Save af
		call	zKeyOffIfActive				; Kill note
		ex	af, af'							; Restore af
		bit	bitAltFreqMode, (ix+zTrack.PlaybackControl)	; Is alternate frequency mode flag set?
		jp	nz, zAltFreqMode				; Branch if yes
		or	a								; Is this a duration?
		jp	p, zStoreDuration				; Branch if yes
		sub	81h								; Make the note into a 0-based index
		jp	p, .got_note					; Branch if it is a note and not a rest
		call	zRestTrack					; Put track at rest
		jr	zGetNoteDuration
; ---------------------------------------------------------------------------
.got_note:
		add	a, (ix+zTrack.Transpose)		; Add in transposition
		ld	hl, zPSGFrequencies				; PSG frequency lookup table
		push	af							; Save af
		rst	PointerTableOffset				; hl = frequency value for note
		pop	af								; Restore af
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		jr	nz, zGotNoteFreq				; Branch if yes
		push	de							; Save de
		ld	d, 8							; Each octave above the first adds this to frequency high bits
		ld	e, 0Ch							; 12 notes per octave
		ex	af, af'							; Exchange af with af'
		xor	a								; Clear a (which will clear a')

.loop:
		ex	af, af'							; Exchange af with af'
		sub	e								; Subtract 1 octave from the note
		jr	c, .got_displacement			; If this is less than zero, we are done
		ex	af, af'							; Exchange af with af'
		add	a, d							; One octave up
		jr	.loop							; Loop
; ---------------------------------------------------------------------------
.got_displacement:
		add	a, e							; Add 1 octave back (so note index is positive)
		ld	hl, zFMFrequencies				; FM first octave frequency lookup table
		rst	PointerTableOffset				; hl = frequency of the note on the first octave
		ex	af, af'							; Exchange af with af'
		or	h								; a = high bits of frequency (including octave bits, which were in a)
		ld	h, a							; h = high bits of frequency (including octave bits)
		pop	de								; Restore de

;loc_2CE
zGotNoteFreq:
		ld	(ix+zTrack.FreqLow), l			; Store low byte of note frequency
		ld	(ix+zTrack.FreqHigh), h			; Store high byte of note frequency

;loc_2D4
zGetNoteDuration:
		bit	bitPitchSlide, (ix+zTrack.PlaybackControl)
		jr	nz, zApplyPitchSlide
		ld	a, (de)							; Get duration from the track
		or	a								; Is it an actual duration?
		jp	p, zGotNoteDuration				; Branch if yes
		ld	a, (ix+zTrack.SavedDuration)	; Get saved duration
		ld	(ix+zTrack.DurationTimeout), a	; Set it as next timeout duration
		jr	zFinishTrackUpdate
; ---------------------------------------------------------------------------
zApplyPitchSlide:
		; Unused/dead code in S3/S&K/S3D; this is code for pitch slides
		; in the Battletoads sound driver.
		ld	a, (de)							; Get new pitch slide value from track
		inc	de								; Advance pointer
		ld	(ix+zTrack.Detune), a			; Store detune
		jr	zGetRawDuration
; ---------------------------------------------------------------------------
;loc_2E8
;zAlternateSMPS
zAltFreqMode:
		; Setting bit 3 on zTrack.PlaybackControl puts the song in a weird mode.
		;
		; This weird mode has literal frequencies and durations on the track.
		; Each byte on the track is either a coordination flag (0E0h to 0FFh) or
		; the high byte of a frequency. For the latter case, the following byte
		; is then the low byte of this same frequency.
		; If the frequency is nonzero, the (sign extended) transposition is
		; simply *added* to this frequency.
		; After the frequency, there is then a byte that is unused.
		; Finally, there is a raw duration byte following.
		;
		; To put the track in this mode, coord. flag 0FDh can be used; if the
		; parameter byte is 1, the mode is toggled on. To turn the mode off,
		; coord. flag 0FDh can be used with a parameter != 1.
		ld	h, a							; h = byte from track
		ld	a, (de)							; a = next byte from track
		inc	de								; Advance pointer
		ld	l, a							; l = last byte read from track
		or	h								; Is hl nonzero?
		jr	z, .got_zero					; Branch if not
		ld	a, (ix+zTrack.Transpose)		; a = transposition
		ld	c, a							; bc = sign extension of transposition
		rla									; Carry contains sign of transposition
		sbc	a, a							; a = 0 or -1 if carry is 0 or 1
		ld	b, a							; bc = sign extension of transposition
		add	hl, bc							; hl += transposition

.got_zero:
		ld	(ix+zTrack.FreqLow), l			; Store low byte of note frequency
		ld	(ix+zTrack.FreqHigh), h			; Store high byte of note frequency
		bit	bitPitchSlide, (ix+zTrack.PlaybackControl)
		jr	z, zGetRawDuration
		ld	a, (de)							; Get pitch slide value from the track
		inc	de								; Advance to next byte in track
		ld	(ix+zTrack.Detune), a			; Store detune
;loc_306
zGetRawDuration:
		ld	a, (de)							; Get raw duration from track

;loc_307
zGotNoteDuration:
		inc	de								; Advance to next byte in track

;loc_308
zStoreDuration:
		call	zComputeNoteDuration		; Multiply note by tempo divider
		ld	(ix+zTrack.SavedDuration), a	; Store it for next note

;loc_30E
zFinishTrackUpdate:
		ld	(ix+zTrack.DataPointerLow), e	; Save low byte of current location in song
		ld	(ix+zTrack.DataPointerHigh), d	; Save high byte of current location in song
		ld	a, (ix+zTrack.SavedDuration)	; Get current saved duration
		ld	(ix+zTrack.DurationTimeout), a	; Set it as duration timeout
		bit	bitNoAttack, (ix+zTrack.PlaybackControl)	; Is 'do not attack next note' flag set?
		ret	nz								; Branch if yes
		xor	a								; Clear a
		ld	(ix+zTrack.ModEnvIndex), a		; Clear modulation envelope index
		ld	(ix+zTrack.ModEnvSens), a		; Clear modulation envelope multiplier
		ld	(ix+zTrack.VolEnv), a			; Reset volume envelope
		ld	a, (ix+zTrack.NoteFillMaster)	; Get master note fill
		ld	(ix+zTrack.NoteFillTimeout), a	; Set note fill timeout
		ret
; End of function zGetNextNote


; =============== S U B	R O U T	I N E =======================================
; This routine multiplies the note duration by the tempo divider. This can
; easily overflow, as the result is stored in a byte.
;
; Input:   a    Note duration
; Output:  a    Final note duration
;          b    zero
;          c    Damaged
;sub_330
zComputeNoteDuration:
		ld	b, (ix+zTrack.TempoDivider)		; Get tempo divider for this track
		dec	b								; Make it into a loop counter
		ret	z								; Return if it was 1
		ld	c, a							; c = a

.loop:
		add	a, c							; a += c
		djnz	.loop						; Loop
		ret
; End of function zComputeNoteDuration
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
;loc_342
zFMNoteOn:
		ld	a, (ix+zTrack.FreqLow)			; Get low byte of note frequency
		or	(ix+zTrack.FreqHigh)			; Is the note frequency zero?
		ret	z								; Return if yes
		ld	a, (ix+zTrack.PlaybackControl)	; Get playback control byte for track
		and	maskSkipFMNoteOn				; Is either bit 4 ("track at rest") or 2 ("SFX overriding this track") or bit 1 ("do not attack next note") set?
		ret	nz								; Return if yes
		ld	a, (ix+zTrack.VoiceControl)		; Get voice control byte from track
		or	maskAllOperators				; Add in bits for all operators
		ld	c, a							; Key on for all operators
		ld	a, ymKeyOnOff					; Select key on/of register
		jp	zWriteFMI						; Send command to YM2612
; ---------------------------------------------------------------------------

; =============== S U B	R O U T	I N E =======================================
; Writes reg/data pair to register 28h (key on/off) if track active
;
; Input:   ix   Track data
; Output:  a    Damaged
;          c    Damaged
;sub_35B
zKeyOffIfActive:
		ld	a, (ix+zTrack.PlaybackControl)	; Get playback control byte for track
		and	maskSkipFMNoteOff				; Is either bit 1 ("do not attack next note") or 2 ("SFX overriding this track") set?
		ret	nz								; Return if yes
; End of function zKeyOffIfActive

; =============== S U B	R O U T	I N E =======================================
; Writes reg/data pair to register 28h (key on/off)
;
; Input:   ix   Track data
; Output:  a    Damaged
;          c    Damaged
;loc_361
zKeyOff:
		ld	c, (ix+zTrack.VoiceControl)		; Get voice control byte for track (this will turn off all operators as high nibble = 0)
		bit	bitIsPSG, c						; Is this a PSG track?
		ret	nz								; Return if yes
; End of function zKeyOff

; =============== S U B	R O U T	I N E =======================================
; Writes reg/data pair to register 28h (key on/off)
;
; Input:   c    Data to write
; Output:  a    Damaged
;loc_367
zKeyOnOff:
		ld	a, ymKeyOnOff					; Write to KEY ON/OFF port
		res	bitSustainFreq, (ix+zTrack.PlaybackControl)	; From Dyna Brothers 2, but in a better place; clear flag to sustain frequency
		jp	zWriteFMI						; Send it
; End of function zKeyOnOff

; =============== S U B	R O U T	I N E =======================================
; Performs volume envelope effects in FM channels.
;
; Input:   ix    Pointer to track RAM
; Output:  a     Trashed
;          bc    Trashed
;          de    Trashed
;          hl    Trashed
;
;sub_36D
;zDoFMFlutter
zDoFMVolEnv:
		ld	a, (ix+zTrack.FMVolEnv)			; Get FM volume envelope
		or	a								; Is it zero?
		ret	z								; Return if yes
		ret	m								; Return if it is actually the custom SSG-EG flag
		dec	a								; Make a into an index
		ld	c, zID_VolEnvPointers			; Value for volume envelope pointer table
		rst	GetPointerTable					; hl = pointer to volume envelope for track
		call	zDoVolEnv					; a = new volume envelope
		ld	h, (ix+zTrack.TLPtrHigh)			; h = high byte to TL data pointer
		ld	l, (ix+zTrack.TLPtrLow)			; l = low byte to TL data pointer
		ld	de, zFMInstrumentTLTable		; de = pointer to FM TL register table
		ld	b, zFMInstrumentTLTable_End-zFMInstrumentTLTable	; Number of entries
		ld	c, a							; Save volume envelope
		ld	a, (ix+zTrack.FMVolEnvMask)		; a = envelope bitmask

.loop:
		sra	a								; Divide a by 2
		jr	nc, .skip_reg					; Branch if bit shifted was zero
		push	af							; Save af
		ld	a, (hl)							; Get TL value
		or	a								; Do we need to add track volume?
		jp	p, .skip_track_vol				; Branch if not
		add	a, (ix+zTrack.Volume)			; Add track's volume to it
		jr	c, .do_clamp					; Branch on carry (overflow)
		and	7Fh								; Clear top bit for overflow check below

.skip_track_vol:
		add	a, c							; Add volume envelope
		call	zDoFMVolumeClamp			; Clamp if needed
		jr	.update_volume
; ---------------------------------------------------------------------------
.do_clamp:
		sbc	a, a							; Clamp volume attenuation as it overflowed

.update_volume:
		push	bc							; Save bc
		ld	c, a							; c = TL + volume envelope
		ld	a, (de)							; a = YM2612 register
		call	zWriteFMIorII				; Send TL data to YM2612
		pop	bc								; Restore bc
		pop	af								; Restore af

.skip_reg:
		inc	de								; Advance to next YM2612 register
		inc	hl								; Advance to next TL value
		djnz	.loop						; Loop for all registers
		ret
; End of function zDoFMVolEnv

; =============== S U B	R O U T	I N E =======================================
; Initializes normal modulation.
;
; Input:   ix    Pointer to track's RAM
; Output:  de    If modulation control has bit 7 set and track is to attack next note, pointer to modulation steps in track RAM
;          hl    If modulation control has bit 7 set and track is to attack next note, pointer to modulation steps in track data
;
;sub_39E
zPrepareModulation:
		bit	7, (ix+zTrack.ModulationCtrl)	; Is modulation on?
		ret	z								; Return if not
		bit	bitNoAttack, (ix+zTrack.PlaybackControl)	; Is 'do not attack next note' bit set?
		ret	nz								; Return if yes
		ld	e, (ix+zTrack.ModulationPtrLow)	; e = low byte of pointer to modulation data
		ld	d, (ix+zTrack.ModulationPtrHigh)	; d = high byte of pointer to modulation data
		push	ix							; Save ix
		pop	hl								; hl = pointer to track data
		ld	b, 0							; b = 0
		ld	c, zTrack.ModulationWait		; c = offset in track RAM for modulation data
		add	hl, bc							; hl = pointer to modulation data in track RAM
		ex	de, hl							; Exchange de and hl
		ldi									; *de++ = *hl++
		ldi									; *de++ = *hl++
		ldi									; *de++ = *hl++
		ld	a, (hl)							; a = number of modulation steps
		srl	a								; Divide by 2
		ld	(de), a							; Store in track RAM
		xor	a								; a = 0
		ld	(ix+zTrack.ModulationValLow), a	; Clear low byte of accumulated modulation
		ld	(ix+zTrack.ModulationValHigh), a	; Clear high byte of accumulated modulation
		ret
; End of function zPrepareModulation


; =============== S U B	R O U T	I N E =======================================
; Applies modulation.
;
; Input:   ix    Pointer to track's RAM
;          hl    Note frequency
; Output:
;    If modulation control is 80h (normal modulation):
;          hl    Final note frequency
;          de    Pointer to modulation data in track RAM
;          iy    Pointer to modulation data in track RAM
;          bc    Unmodulated note frequency
;
;    If modulation control is nonzero and not 80h (modulation envelope effects):
;
;
;sub_3C9
zDoModulation:
		ld	a, (ix+zTrack.ModulationCtrl)	; Get modulation control byte
		or	a								; Is modulation active?
		ret	z								; Return if not
		cp	80h								; Is modulation control 80h?
		jr	nz, zDoModEnvelope				; Branch if not
		dec	(ix+zTrack.ModulationWait)		; Decrement modulation wait
		ret	nz								; Return if nonzero
		inc	(ix+zTrack.ModulationWait)		; Increase it back to 1 for next frame
		push	hl							; Save hl
		ld	l, (ix+zTrack.ModulationValLow)	; l = low byte of accumulated modulation
		ld	h, (ix+zTrack.ModulationValHigh)	; h = high byte of accumulated modulation
		; In non-Type 2 DAC versions of SMPS Z80, the following four instructions were below the 'jr nz'
		; which could lead to a bug where iy isn't initialised, but still used as a pointer.
		ld	e, (ix+zTrack.ModulationPtrLow)	; e = low byte of modulation data pointer
		ld	d, (ix+zTrack.ModulationPtrHigh)	; d = high byte of modulation data pointer
		push	de							; Save de
		pop	iy								; iy = pointer to modulation data
		dec	(ix+zTrack.ModulationSpeed)		; Decrement modulation speed
		jr	nz, .mod_sustain				; Branch if nonzero
		ld	a, (iy+1)						; Get original modulation speed
		ld	(ix+zTrack.ModulationSpeed), a	; Reset modulation speed timeout
		ld	a, (ix+zTrack.ModulationDelta)	; Get modulation delta per step
		ld	c, a							; c = modulation delta per step
		rla									; Carry contains sign of delta
		sbc	a, a							; a = 0 or -1 if carry is 0 or 1
		ld	b, a							; bc = sign extension of delta
		add	hl, bc							; hl += bc
		ld	(ix+zTrack.ModulationValLow), l	; Store low byte of accumulated modulation
		ld	(ix+zTrack.ModulationValHigh), h	; Store high byte of accumulated modulation

.mod_sustain:
		pop	bc								; bc = note frequency
		add	hl, bc							; hl = modulated note frequency
		dec	(ix+zTrack.ModulationSteps)		; Reduce number of modulation steps
		ret	nz								; Return if nonzero
		ld	a, (iy+3)						; Get number of steps from track data
		ld	(ix+zTrack.ModulationSteps), a	; Reset modulation steps in track RAM
		ld	a, (ix+zTrack.ModulationDelta)	; Load modulation delta
		neg									; Change its sign
		ld	(ix+zTrack.ModulationDelta), a	; Store it back
		ret
; ---------------------------------------------------------------------------
;loc_41A
;zDoFrequencyFlutter
zDoModEnvelope:
		dec	a								; Convert into pointer table index
		ex	de, hl							; Exchange de and hl; de = note frequency
		ld	c, zID_ModEnvPointers			; Value for modulation envelope pointer table
		rst	GetPointerTable					; hl = modulation envelope pointer for modulation control byte
		jr	zDoModEnvelope_cont
; ---------------------------------------------------------------------------
;zFreqFlutterSetIndex
zModEnvSetIndex:
		ld	(ix+zTrack.ModEnvIndex), a		; Set new modulation envelope index

;loc_425
;zDoFrequencyFlutter_cont
zDoModEnvelope_cont:
		push	hl							; Save hl
		ld	c, (ix+zTrack.ModEnvIndex)		; c = modulation envelope index
		ld	b, 0							; b = 0
		add	hl, bc							; Offset into modulation envelope table
		; Fix based on similar code from Space Harrier II's sound driver.
		; This is better than the previous fix, which was based on Ristar's driver.
		ld	c, l
		ld	b, h
		ld	a, (bc)							; a = new modulation envelope value
		pop	hl								; Restore hl
		bit	7, a							; Is modulation envelope negative?
		jp	z, zlocPositiveModEnvMod		; Branch if not
		cp	ModEnvJumpTo					; Is it a command to jump to another value?
		jr	z, zlocChangeModEnvIndex		; Branch if yes
		cp	ModEnvReset						; Is it a command to reset envelope?
		jr	z, zlocResetModEnvMod			; Branch if yes
		cp	ModEnvAlterSens					; Is it a command to change sensibility?
		jr	z, zlocModEnvIncMultiplier		; Branch if yes
		ld	h, -1							; For sign-extending negative modulation envelope
		jr	nc, zlocApplyModEnvMod			; Branch if more than 84h
		; Only 81h and 83h can get here.
		set	bitSustainFreq, (ix+zTrack.PlaybackControl)	; Set 'sustain frequency' bit
		pop	hl								; Tamper with return location so as to not return to caller
		ret
; ---------------------------------------------------------------------------
;loc_449
;zlocChangeFlutterIndex
zlocChangeModEnvIndex:
		inc	bc								; Increment bc
		ld	a, (bc)							; Get next byte from modulation envelope
		jr	zModEnvSetIndex					; Set position to value read
; ---------------------------------------------------------------------------
;loc_44D
;zlocResetFlutterMod
zlocResetModEnvMod:
		xor	a								; a = 0
		jr	zModEnvSetIndex					; Reset position for modulation envelope
; ---------------------------------------------------------------------------
;loc_450
;zlocFlutterIncMultiplier
zlocModEnvIncMultiplier:
		inc	bc								; Increment bc
		ld	a, (bc)							; Get next byte from modulation envelope
		add	a, (ix+zTrack.ModEnvSens)		; Add envelope sensibility to a...
		ld	(ix+zTrack.ModEnvSens), a		; ... then store new value
		inc	(ix+zTrack.ModEnvIndex)			; Advance envelope modulation...
		inc	(ix+zTrack.ModEnvIndex)			; ... twice.
		jr	zDoModEnvelope_cont
; ---------------------------------------------------------------------------
;loc_460
;zlocPositiveFlutterMod
zlocPositiveModEnvMod:
		ld	h, 0							; h = 0

;loc_462
;zlocApplyFlutterMod
zlocApplyModEnvMod:
		ld	l, a							; hl = sign extension of modulation value
		ld	b, (ix+zTrack.ModEnvSens)		; Fetch envelope sensibility
		inc	b								; Increment it (minimum 1)
		ex	de, hl							; Swap hl and de; hl = note frequency

.loop:
		add	hl, de							; hl += de
		djnz	.loop						; Make hl = note frequency + b * de
		inc	(ix+zTrack.ModEnvIndex)			; Advance modulation envelope
		ret
; End of function zDoModulation

; =============== S U B	R O U T	I N E =======================================
; Adds the current detune (signed) to note frequency.
;
; Input:   ix    Track RAM
; Output:  hl    Shifted frequency
;          a     Damaged
;          bc    Damaged
;
;sub_46F
;zUpdateFreq
zDoPitchSlide:
		ld	h, (ix+zTrack.FreqHigh)			; h = high byte of note frequency
		ld	l, (ix+zTrack.FreqLow)			; l = low byte of note frequency
		ld	a, (ix+zTrack.Detune)			; a = detune
		ld	c, a							; bc = sign extension of detune
		rla									; Carry contains sign of detune
		sbc	a, a							; a = 0 or -1 if carry is 0 or 1
		ld	b, a							; bc = sign extension of detune
		add	hl, bc							; Add to frequency

		; Battletoads did this check under zApplyFreq below. Putting it
		; here is an optimization.
		bit	bitPitchSlide, (ix+zTrack.PlaybackControl)	; Is pitch slide on?
		ret	z								; Return if not
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		jr	nz, zApplyFreq					; Branch if yes
		ex	de, hl							; de = new frequency
		ld	a, 7							; Want to mask off octave bits
		and	d								; a = bits 8-10 of frequency
		ld	b, a							; Copy it to b
		ld	c, e							; bc = raw frequency of note
		or	a								; Clear carry flag
		ld	hl, 283h						; hl = lowest FM note - 1
		sbc	hl, bc							; Is raw frequency lower than this?
		jr	c, .no_underflow				; Branch if not
		ld	hl, -57Bh						; hl = +12 semitones (freq) - 1 octave (block)
		add	hl, de							; hl = de exchanging 1 octave (block) for 12 semitones (freq)
		jr	zApplyFreq
; ---------------------------------------------------------------------------
.no_underflow:
		or	a								; Clear carry flag
		ld	hl, 508h						; hl = 1 octave above lowest FM note
		sbc	hl, bc							; Is raw frequency above this?
		jr	nc, .no_overflow				; Branch if not
		ld	hl, 57Ch						; hl = -12 semitones (freq) + 1 octave (block)
		add	hl, de							; hl = de exchanging 1 octave (block) for 12 semitones (freq)
		ex	de, hl							; de = new frequency

.no_overflow:
		ex	de, hl							; hl = new frequency

zApplyFreq:
		ld	(ix+zTrack.FreqHigh), h			; Save high byte of new frequency
		ld	(ix+zTrack.FreqLow), l			; Save low byte of new frequency
		ret
; End of function zDoPitchSlide

; =============== S U B	R O U T	I N E =======================================
; Gets offset for requested FM instrument.
;
;sub_483
zGetFMInstrumentPointer:
		ld	hl, (zVoiceTblPtr)				; hl = pointer to voice table
		ld	a, (zUpdatingSFX)				; Get flag
		or	a								; Is this a SFX track?
		jr	z, zGetFMInstrumentOffset		; Branch if not
		ld	l, (ix+zTrack.VoicesLow)		; l = low byte of track's voice pointer
		ld	h, (ix+zTrack.VoicesHigh)		; h = high byte of track's voice pointer

;loc_492
zGetFMInstrumentOffset:
		xor	a								; a = 0
		or	b								; Is FM instrument the first one (zero)?
		ret	z								; Return if so
		ld	de, 25							; Size of each FM instrument

.loop:
		add	hl, de							; Advance pointer to next instrument
		djnz	.loop						; Loop until instrument offset is found
		ret
; End of function zGetFMInstrumentPointer

; ---------------------------------------------------------------------------
;loc_49C
zFMInstrumentRegTable:
		db ymAlgorithmFeedback				; Feedback/Algorithm
zFMInstrumentOperatorTable:
		db ymDetuneMultiply1				; Detune/multiple operator 1
		db ymDetuneMultiply3				; Detune/multiple operator 3
		db ymDetuneMultiply2				; Detune/multiple operator 2
		db ymDetuneMultiply4				; Detune/multiple operator 4
zFMInstrumentRSARTable:
		db ymRateScaleAttackRate1			; Rate scaling/attack rate operator 1
		db ymRateScaleAttackRate3			; Rate scaling/attack rate operator 3
		db ymRateScaleAttackRate2			; Rate scaling/attack rate operator 2
		db ymRateScaleAttackRate4			; Rate scaling/attack rate operator 4
zFMInstrumentAMD1RTable:
		db ymAMDecayRate1					; Amplitude modulation/first decay rate operator 1
		db ymAMDecayRate3					; Amplitude modulation/first decay rate operator 3
		db ymAMDecayRate2					; Amplitude modulation/first decay rate operator 2
		db ymAMDecayRate4					; Amplitude modulation/first decay rate operator 4
zFMInstrumentD2RTable:
		db ymSustainRate1					; Secondary decay rate operator 1
		db ymSustainRate3					; Secondary decay rate operator 3
		db ymSustainRate2					; Secondary decay rate operator 2
		db ymSustainRate4					; Secondary decay rate operator 4
zFMInstrumentD1LRRTable:
		db ymSustainLevelReleaseRate1		; Secondary amplitude/release rate operator 1
		db ymSustainLevelReleaseRate3		; Secondary amplitude/release rate operator 3
		db ymSustainLevelReleaseRate2		; Secondary amplitude/release rate operator 2
		db ymSustainLevelReleaseRate4		; Secondary amplitude/release rate operator 4
zFMInstrumentOperatorTable_End
;loc_4B1
zFMInstrumentTLTable:
		db ymTotalLevel1					; Total level operator 1
		db ymTotalLevel3					; Total level operator 3
		db ymTotalLevel2					; Total level operator 2
		db ymTotalLevel4					; Total level operator 4
zFMInstrumentTLTable_End
;loc_4B5
zFMInstrumentSSGEGTable:
		db ymSSGEG1							; SSG-EG operator 1
		db ymSSGEG3							; SSG-EG operator 3
		db ymSSGEG2							; SSG-EG operator 2
		db ymSSGEG4							; SSG-EG operator 4
zFMInstrumentSSGEGTable_End

; =============== S U B	R O U T	I N E =======================================
; Subroutine to send FM instrument data to YM2612 chip.
;
;sub_4B9
zSendFMInstrument:
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is SFX overriding this track?
		jr	z, .active						; Is so, quit

		ld	c, zFMInstrumentOperatorTable_End-zFMInstrumentRegTable
		ld	b, 0
		add	hl, bc							; Point hl to TL data
		ld	(ix+zTrack.TLPtrLow), l			; Save low byte of pointer to (not yet uploaded) TL data
		ld	(ix+zTrack.TLPtrHigh), h		; Save high byte of pointer to (not yet uploaded) TL data
		ret
; ---------------------------------------------------------------------------
.active:
		push	iy							; Save iy
		zGetFMPartPointer					; Point iy to appropriate FM part
		ld	de, zFMInstrumentRegTable		; de = pointer to register output table
		zFastWriteFM ymPanningAMSensFMSens, (ix+zTrack.AMSFMSPan)
		ld	b, zFMInstrumentOperatorTable_End-zFMInstrumentRegTable	; Number of commands to issue
		ld	a, (ix+zTrack.HaveSSGEGFlag)	; Get custom SSG-EG flag
		or	a								; Does track have custom SSG-EG data?
		jp	p, .sendinstrument				; Branch if not

		; Handle case of SSG-EG
		; Start with detune/multiplier operators
		ld	b, zFMInstrumentRSARTable-zFMInstrumentRegTable	; Number of commands to issue
		call	zSendFMInstrData			; Send FM instrument data

		; Now for rate scaling/attack rate. The attack rate must be 1Fh if using
		; SSG-EG, which is the reason for the split.
		ld	b, zFMInstrumentAMD1RTable-zFMInstrumentRSARTable	; Number of commands to issue
		call	zSendFMInstrDataRSAR		; Send FM instrument data

		; Finalize with all the other operators.
		ld	b, zFMInstrumentOperatorTable_End-zFMInstrumentAMD1RTable	; Number of commands to issue

.sendinstrument:
		call	zSendFMInstrData			; Send FM instrument data
		ld	(ix+zTrack.TLPtrLow), l			; Save low byte of pointer to (not yet uploaded) TL data
		ld	(ix+zTrack.TLPtrHigh), h		; Save high byte of pointer to (not yet uploaded) TL data
		push	de							; Needed to balance stack
		jp	zSendTL.got_pointers			; Send TL data
; End of function zSendFMInstrument

; =============== S U B	R O U T	I N E =======================================
; Sends FM instrument data to YM2612.
;
; Input:   ix    Track data
;          hl    Pointer to instrument data
;          de    Pointer to register selector table
; Output:   a    Value written to the register
;           c    Value written to the register
;
;sub_4DA
zSendFMInstrData:
		zFastWriteFM (de), (hl)
		inc	de								; Advance pointer
		inc	hl								; Advance pointer
		djnz	zSendFMInstrData			; Loop
		ret
; End of function zSendFMInstrData

zSendFMInstrDataRSAR:
		zFastWriteFM (de), (hl), setMaxAR
		inc	de								; Advance pointer
		inc	hl								; Advance pointer
		djnz	zSendFMInstrDataRSAR		; Loop
		ret

; =============== S U B	R O U T	I N E =======================================
; Rotates sound queue and clears last entry. Then plays the popped sound from
; the queue.
;loc_4E2
zCycleSoundQueue:
		ld	a, (zSoundQueue1)				; Get first item in sound queue
		ld	(zNextSound), a					; Save into next sound variable
		ld	a, (zSoundQueue2)				; Get second item in queue
		ld	(zSoundQueue1), a				; Move to first spot
		xor	a								; a = 0
		ld	(zSoundQueue2), a				; Clear third spot in queue
		ld	a, (zNextSound)					; a = next sound to play
		; Fall through to zPlaySFXByIndex

zPlaySFXByIndex:
	if SndID__First=1
		or	a								; Is this below the sound start point?
		ret	z								; Return if yes
	else
		cp	SndID__First					; Is this below the sound start point?
		ret	c								; Return if yes
	endif
		cp	SndID__End						; Is this a sound effect?
		jp	c, zPlaySound_CheckRing			; Branch if yes
		cp	DACID__First
		ret	c
		cp	DACID__End
		ret	nc
		; "PlayVoice/PlayDACSFX" in ValleyBell's SMPS disassemblies
		sub	DACID__First-1
		ld	(zDACIndex), a
		ld	a, 1
		ld	(zSongDAC.DACSFXPlaying), a
		jp	zClearNextSound
; End of function zPlaySFXByIndex

; =============== S U B	R O U T	I N E =======================================
; Rotates sound queue and clears last entry. Then plays the popped sound from
; the queue.
;loc_4E2
zCycleMusicQueue:
		ld	a, (zSoundQueue0)				; Get queued music
		ld	(zNextSound), a					; Save into next sound variable
		xor	a								; a = 0
		ld	(zSoundQueue0), a				; Clear music spot
		ld	a, (zNextSound)					; a = next sound to play
		; Fall through to zPlaySoundByIndex
; End of function zCycleSoundQueue

; ===========================================================================
; Type Check
; ===========================================================================
; 1-32, DC = Music
; 33-DB, DD-DF = SFX
; E1-E6 = Fade Effects
; FF = SEGA Scream

; TypeCheck:
;sub_4FB
zPlaySoundByIndex:
		cp	MusID_SegaSound					; Is this the SEGA sound?
		jp	z, zPlaySegaSound				; Branch if yes
		cp	MusID__End						; Is this a music?
		jp	c, zPlayMusic					; Branch if yes
		cp	FadeID__First					; Is it before the first fade effect?
		jp	c, zMusicFade					; Branch if yes
		cp	FadeID__End						; Is this after the last fade effect?
		jp	nc, zMusicFade					; Branch if yes
		sub	FadeID__First					; If none of the checks passed, do fade effects.
		ld	hl, zFadeEffects				; hl = switch table pointer
		rst	PointerTableOffset				; Get address of function that handles the fade effect
		jp	(hl)							; Handle fade effect
; End of function zPlaySoundByIndex
; ---------------------------------------------------------------------------
;loc_524
zFadeEffects:
		dw	zFadeOutMusic					; E1h
		dw	zMusicFade						; E2h
		dw	zPSGSilenceAll					; E3h
		dw	zStopSFX						; E4h
		dw	zFadeOutMusic					; E5h
; ---------------------------------------------------------------------------
;sub_52E
zStopSFX:
		ld	ix, zTracksSFXStart				; ix = pointer to SFX track memory
		ld	b, zNumSFXTracks				; Number of channels
		ld	a, 1							; a = 1
		ld	(zUpdatingSFX), a				; Set flag to update SFX

.loop:
		push	bc							; Save bc
		bit	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Is track playing?
		call	nz, zSilenceStopTrack		; Branch if yes
		ld	de, zTrack.len					; Spacing between tracks
		add	ix, de							; ix = pointer to next track
		pop	bc								; Restore bc
		djnz	.loop						; Loop for each track
		jp	zClearNextSound

; =============== S U B	R O U T	I N E =======================================
; Writes hl to stack twice and stops track, silencing it. The two hl pushes
; will be counteracted by cfSilenceStopTrack.
;
;sub_54D
zSilenceStopTrack:
		push	hl							; Save hl...
		push	hl							; ... twice
		jp	cfSilenceStopTrack				; Silence FM channel and stop track
; End of function zSilenceStopTrack
; ---------------------------------------------------------------------------

;loc_558
zPlayMusic:
		sub	MusID__First					; Remap index from 1h-33h to 0h-32h
		ret	m								; Return if negative (id = 0)
		push	af							; Save af
		cp	MusID_ExtraLife-MusID__First	; Is it the 1-up music?
		jp	nz, zPlayMusic_DoFade			; Branch if not
		ld	a, (zFadeInTimeout)				; Fading timeout
		or	a								; Is music being faded?
		jp	z, .no_fade						; Branch if not
		xor	a								; a = 0
		ld	(zMusicNumber), a				; Clear M68K input queue...
		ld	(zSFXNumber0), a				; ... including SFX slot 0...
		ld	(zSFXNumber1), a				; ... and SFX slot 1
		ld	(zSoundQueue0), a				; Also clear music queue entry 0...
		ld	(zSoundQueue1), a				; ... and entry 1...
		ld	(zSoundQueue2), a				; ... and entry 2
		ld	(zNextSound), a					; Clear currently selected song to play
		pop	af								; Restore af
		ret
; ---------------------------------------------------------------------------
.no_fade:
		ld	a, (zFadeToPrevFlag)			; Get fade-to-prev flag
		cp	MusID_ExtraLife-1				; Was it triggered by the 1-up song?
		jp	z, zBGMLoad						; Branch if yes
		xor	a								; a = 0
		ld	(zMusicNumber), a				; Clear M68K input queue...
		ld	(zSFXNumber0), a				; ... including SFX slot 0...
		ld	(zSFXNumber1), a				; ... and SFX slot 1
		ld	(zSoundQueue0), a				; Also clear music queue entry 0...
		ld	(zSoundQueue1), a				; ... and entry 1...
		ld	(zSoundQueue2), a				; ... and entry 2
		ld	a, (zSongBank)					; Get song bank for extant track...
		ld	(zSongBankSave), a				; ... and save it
		ld	a, (zTempoSpeedup)				; Get current tempo speed-up value...
		ld	(zTempoSpeedupSave), a			; ... and save it
		ld	a, (zCurrentTempo)				; Get current tempo
		ld	(zCurrentTempoSave), a			; Save it
		ld	a, (zDACEnable)					; Get song DAC enable for extant track...
		ld	(zDACEnableSave), a				; ... and save it
		xor	a								; a = 0
		ld	(zTempoSpeedup), a				; 1-Up should play on normal speed
		ld	(zContinuousSFX), a				; Clear continuous SFX ID
		ld	(zContinuousSFXFlag), a			; Clear continuous SFX flag
		ld	(zContSFXLoopCnt), a			; Clear continuous SFX counter
		ld	hl, zTracksStart				; hl = pointer to song RAM
		ld	de, zTracksSaveStart			; de = pointer to RAM area to save the song data to
		ld	bc, zTracksSaveEnd-zTracksSaveStart		; Number of bytes to copy
		ldir								; while (bc-- > 0) *de++ = *hl++;
		ld	hl, zTracksSaveStart			; hl = pointer to saved song's RAM area
		ld	de, zTrack.len					; Spacing between tracks
		ld	b, zNumSaveTracks				; Number of tracks

.loop:
		ld	a, (hl)							; Get playback control byte for song
		and	(~(1<<bitTrackPlaying))&0FFh	; Strip the 'playing' bit
		or	1<<bitSFXOverride				; Set bit 2 (SFX overriding)
		ld	(hl), a							; And save it all
		add	hl, de							; Advance to next track
		djnz	.loop						; Loop for all tracks

		ld	a, MusID_ExtraLife-1			; a = 1-up id-1
		ld	(zFadeToPrevFlag), a			; Set fade-to-prev flag to it
		ld	hl, (zVoiceTblPtr)				; Get voice table pointer
		ld	(zVoiceTblPtrSave), hl			; Save it
		call	zMusicFadeSimple
		jp	zBGMLoad
; ---------------------------------------------------------------------------

zPlayMusic_DoFade:
		call	zMusicFadeKeepSFX			; Stop all music

;loc_5DE
zBGMLoad:
		pop	af								; Restore af
		push	af							; Then save it back again
		ld	hl, z80_MusicBanks				; hl = table of music banks
		; The following block adds the music index to the table address as a 16-bit offset
		add	a, l							; a += l
		ld	l, a							; l = low byte of offset into music entry
		adc	a, h							; a += h, plus 1 if a + l overflowed the 8-bit register
		sub	l								; Now, a = high byte of offset into music entry
		ld	h, a							; hl is the offset to the music bank
		ld	a, (hl)							; Get bank for the song to play
		ld	(zSongBank), a					; Save the song's bank...
		bankswitch							; ... then bank switch to it
		ld	a, ymPanningAMSensFMSens|ymFM3	; Set Panning / AMS / FMS
		ld	(zYM2612_A1), a					; Write destination address to YM2612 address register
		nop
		ld	a, maskPanning					; default Panning / AMS / FMS settings (only stereo L/R enabled)
		ld	(zYM2612_D1), a					; Write to YM2612 data register
		pop	af								; Restore af
		ld	c, zID_MusicPointers			; c = 4 (music pointer table)
		rst	GetPointerTable					; hl = pointer to song data
		push	hl							; Save hl...
		push	hl							; ... twice
		rst	ReadPointer						; Dereference pointer, so that hl = pointer to voice table
		ld	(zVoiceTblPtr), hl				; Store voice table pointer
		pop	hl								; Restore hl to pointer to song data
		pop	iy								; Also set iy = pointer to song data
		ld	a, (iy+5)						; Main tempo value
		ld	(zTempoAccumulator), a			; Set starting accumulator value
		ld	(zCurrentTempo), a				; Store current song tempo
		ld	de, 6							; Offset into DAC pointer
		add	hl, de							; hl = pointer to DAC pointer
		ld	(zSongPosition), hl				; Save it to RAM
		ld	hl, zFMDACInitBytes				; Load pointer to init data
		ld	(zTrackInitPos), hl				; Save it to RAM
		ld	de, zTracksStart				; de = pointer to track RAM
		ld	b, (iy+2)						; b = number of FM + DAC channels
		ld	a, (iy+4)						; a = tempo divider

.fm_dac_loop:
		push	bc							; Save bc (gets damaged by ldi instructions)
		ld	hl, (zTrackInitPos)				; Restore saved position for init bytes
		ldi									; *de++ = *hl++	(copy initial playback control)
		ex	af, af'							; Save tempo divider
		push	hl							; Save track data
		ld	a, (hl)							; Get initial channel assignment bits
		call	zIsSFXTrackOverriding_Part2	; Is SFX overriding?
		pop	hl								; Restore track data
		jp	p, .not_overriding_fm			; Branch if not
		ex	hl, de							; Swap hl and de
		dec	hl								; Point to track playback control
		set	bitSFXOverride, (hl)			; Set 'SFX is overriding this track' bit
		inc	hl								; Point back to channel assignment bits
		ex	hl, de							; Swap hl and de

.not_overriding_fm:
		ldi									; *de++ = *hl++	(copy channel assignment bits)

.continue_fm_init:
		ex	af, af'							; Restore tempo divider
		ld	(de), a							; Copy tempo divider
		inc	de								; Advance pointer
		ld	(zTrackInitPos), hl				; Save current position in channel assignment bits
		ld	hl, (zSongPosition)				; Load current position in BGM data
		ldi									; *de++ = *hl++ (copy track address low byte)
		ldi									; *de++ = *hl++ (copy track address high byte)
		ldi									; *de++ = *hl++ (default transposition)
		ldi									; *de++ = *hl++ (track default volume)
		ld	(zSongPosition), hl				; Store current position in BGM data
		call	zInitFMDACTrack				; Init the remainder of the track RAM
		pop	bc								; Restore bc
		djnz	.fm_dac_loop				; Loop for all tracks (stored in b)

		ld	a, (iy+2)						; a = number of FM + DAC channels
		sub	7								; Does it equal 7? (6 FM channels)
		jr	z, .set_dac						; If yes, skip this next part

.got_dac:
		; Setup FM Channel 6 specifically if it's not in use
		ld	hl, zSongFM6					; Get FM3 track
		ld	b, zTrack.len-2					; Loop counter
		ld	(hl), maskFM6Unused				; Set 'SFX is overriding this track' and 'Track is resting' bits, clear 'Track is playing' bit
		inc	hl								; Point to voice control byte
		ld	(hl), ymFM6						; This is FM6
		xor	a								; Clear 'a'

.loop:
		inc	hl								; Advance to next byte
		ld	(hl), a							; Put 0 into this byte
		djnz	.loop						; Loop until end of track

		ld	a, maskDACEnable				; FM Channel 6 is NOT in use (will enable DAC)

.set_dac:
		ld	c, a							; Set this as value to be used in FM register write coming up...
		ld	(zDACEnable), a					; Note whether FM Channel 6 is in use (enables DAC if not)
		ld	a, ymDACEnable					; Set DAC Enable appropriately
		call	zWriteFMI
		; End of DAC/FM init, begin PSG init

		ld	a, (iy+3)						; Get number of PSG tracks
		or	a								; Do we have any PSG channels?
		jp	z, zClearNextSound				; Branch if not
		ld	b, a							; b = number of PSG tracks
		ld	hl, zPSGInitBytes				; Load pointer to init data
		ld	(zTrackInitPos), hl				; Save it to RAM
		ld	de, zSongPSG1					; de = pointer to RAM for song PSG tracks
		ld	a, (iy+4)						; a = tempo divider

.psg_loop:
		push	bc							; Save bc (gets damaged by ldi instructions)
		ld	hl, (zTrackInitPos)				; Restore saved position for init bytes
		ldi									; *de++ = *hl++	(copy initial playback control)
		ex	af, af'							; Save tempo divider
		push	hl							; Save track data
		ld	a, (hl)							; Get initial channel assignment bits
		call	zIsSFXTrackOverriding_Part2	; Is SFX overriding?
		pop	hl								; Restore track data
		jp	p, .not_overriding_psg			; Branch if not
		ex	hl, de							; Swap hl and de
		dec	hl								; Point to track playback control
		set	bitSFXOverride, (hl)			; Set 'SFX is overriding this track' bit
		inc	hl								; Point back to channel assignment bits
		ex	hl, de							; Swap hl and de

.not_overriding_psg:
		ldi									; *de++ = *hl++	(copy channel assignment bits)

.continue_psg_init:
		ex	af, af'							; Restore tempo divider
		ld	(de), a							; Copy tempo divider
		inc	de								; Advance pointer
		ld	(zTrackInitPos), hl				; Save current position in channel assignment bits
		ld	hl, (zSongPosition)				; Load current position in BGM data
		ld	bc, 6							; Copy 6 bytes
		ldir								; while (bc-- > 0) *de++ = *hl++; (copy track address, default transposition, default volume, modulation control, default PSG tone)
		ld	(zSongPosition), hl				; Store current potition in BGM data
		call	zZeroFillTrackRAM			; Init the remainder of the track RAM
		pop	bc								; Restore bc
		djnz	.psg_loop					; Loop for all tracks (stored in b)
		; FALL THROUGH

; =============== S U B	R O U T	I N E =======================================
; Clears next sound to play.
;sub_690
zClearNextSound:
		xor	a
		ld	(zNextSound), a
		ret
; End of function zClearNextSound
; ---------------------------------------------------------------------------
;loc_695
; FM/DAC channel assignment bits
; The first byte in every pair (always 80h) is default value for playback control bits.
; The second byte in every pair goes as follows:
; The first is for DAC; then 0, 1, 2 then 4, 5, 6 for the FM channels (the missing 3
; is the gap between part I and part II for YM2612 port writes).
zFMDACInitBytes:
		db (1<<bitTrackPlaying), ymDAC
		db (1<<bitTrackPlaying), ymFM1
		db (1<<bitTrackPlaying), ymFM2

zFMDACInitBytesFM3:
		db (1<<bitTrackPlaying), ymFM3
		db (1<<bitTrackPlaying), ymFM4
		db (1<<bitTrackPlaying), ymFM5
		db (1<<bitTrackPlaying), ymFM6
;loc_6A3
; Default values for PSG tracks
; The first byte in every pair (always 80h) is default value for playback control bits.
; The second byte in every pair is the default values for PSG tracks.
zPSGInitBytes:
		db (1<<bitTrackPlaying), snPSG1
		db (1<<bitTrackPlaying), snPSG2
		db (1<<bitTrackPlaying), snPSG3
; ---------------------------------------------------------------------------
;loc_6A9
zPlaySound_CheckRing:
		sub	SndID__First					; Make it a 0-based index
	if SndID_Ring==SndID__First
		or	a								; Is it the ring sound?
	else
		cp	SndID_Ring-SndID__First			; Is it the ring sound?
	endif
		jp	nz, zPlaySound_Bankswitch		; Branch if not
	if RingSoundsAdjacent==0
		ld	c, a							; Save SFX ID
	endif
		ld	a, (zRingSpeaker)				; Get speaker on which ring sound is played
		xor	1								; Toggle bit 0
		ld	(zRingSpeaker), a				; Save it
	if RingSoundsAdjacent==1
		if SndID_Ring<>SndID__First
			add	a, SndID_Ring-SndID__First
		endif
	else
		or	a								; 0 plays left, 1 plays right
		jr	nz, .play_right
		ld	c, SndID_RingLeft-SndID__First	; Play on left speaker
.play_right:
		ld	a, c							; Get ring sound to play
	endif

;loc_6B7
zPlaySound_Bankswitch:
		ex	af, af'							; Save af
		ld	a, zmake68kBank(SndBank)		; Load SFX sound bank address
		bankswitch							; Bank switch to it
		xor	a								; a = 0
		ld	c, zID_SFXPointers				; SFX table index
		ld	(zUpdatingSFX), a				; Clear flag to update SFX
		ex	af, af'							; Restore af
		cp	SndID_SpindashRev-SndID__First	; Is this the spindash sound?
		jp	z, zPlaySound					; Branch if yes
		cp	SndID__FirstContinuous-SndID__First	; Is this before sound 0BCh?
		jp	c, zPlaySound_Normal			; Branch if yes
		push	af							; Save af
		ld	b, a							; b = sound index
		ld	a, (zContinuousSFX)				; Load last continuous SFX played
		sub	b								; Is this the same continuous sound that was playing?
		jp	nz, zPlaySound_NotCont			; Branch if not
		; If we got here, a is zero.
		inc	a								; a = 1
		ld	(zContinuousSFXFlag), a			; Flag continuous SFX as being extended
		pop	af								; Restore af
		rst	GetPointerTable					; hl = pointer to SFX data
		inc	hl								; Skip low byte of voice pointer
		inc	hl								; Skip high byte of voice pointer
		inc	hl								; Skip timing divisor
		ld	a, (hl)							; Get number of SFX tracks
		ld	(zContSFXLoopCnt), a			; Save it to RAM (loop counter for continuous SFX)
		jp	zClearNextSound
; ---------------------------------------------------------------------------
;loc_6FB
zPlaySound_NotCont:
		xor	a								; a = 0
		ld	(zContinuousSFXFlag), a			; Clear continue continuous SFX flag
		pop	af								; Restore af
		ld	(zContinuousSFX), a				; Store SFX index
		jp	zPlaySound
; ---------------------------------------------------------------------------
;loc_706
zPlaySound_Normal:
		push	af							; Save af
		xor	a								; a = 0
		ld	(zSpindashRev), a				; Reset spindash rev
		pop		af							; Restore af

;loc_70C
zPlaySound:
		rst	GetPointerTable					; hl = pointer to SFX data
		push	hl							; Save hl
		rst	ReadPointer						; hl = voice table pointer
		ld	(zSFXVoiceTblPtr), hl			; Save to RAM
		pop	hl								; hl = pointer to SFX data
		push	hl							; Save it again
		pop	iy								; iy = pointer to SFX data
		ld	a, (iy+2)						; a = tempo divider
		ld	(zSFXTempoDivider), a			; Save to RAM
		ld	de, 4							; de = 4
		add	hl, de							; hl = pointer to SFX track data
		ld	b, (iy+3)						; b = number of tracks (FM + PSG) used by SFX
		ld	a, b							; Copy to a
		ld	(zContSFXLoopCnt), a			; Save to RAM (loop counter for continuous SFX)

;loc_72C
zSFXTrackInitLoop:
		push	bc							; Save bc; damaged by ldi instructions below
		push	hl							; Save hl
		inc	hl								; hl = pointer to channel identifier
		ld	c, (hl)							; c = channel identifier
		call	zGetSFXChannelPointers		; Get track pointers for track RAM (ix) and overridden song track (hl)
		set	bitSFXOverride, (hl)			; Set 'SFX is overriding this track' bit
		push	ix							; Save pointer to SFX track data in RAM

		pop		de							; de = pointer to SFX track data in RAM (unless you consider the above effectively dead code)
		pop		hl							; hl = pointer to SFX track data
		ldi									; *de++ = *hl++ (initial playback control)
		ld	a, (de)							; Get the voice control byte from track RAM (to deal with SFX already there)
		cp	ymFM3							; Is this FM3?
		call	z, zFM3NormalMode			; Set FM3 to normal mode if so
		ldi									; *de++ = *hl++ (copy channel identifier)
		ld	a, (zSFXTempoDivider)			; Get SFX tempo divider
		ld	(de), a							; Store it to RAM
		inc	de								; Advance pointer
		ldi									; *de++ = *hl++ (low byte of channel data pointer)
		ldi									; *de++ = *hl++ (high byte of channel data pointer)
		ldi									; *de++ = *hl++ (transposition)
		ldi									; *de++ = *hl++ (channel volume)
		call	zInitFMDACTrack				; Init the remainder of the track RAM

		push	hl							; Save hl
		ld	hl, (zSFXVoiceTblPtr)			; hl = pointer to voice data

		ld	(ix+zTrack.VoicesLow), l		; Low byte of voice pointer
		ld	(ix+zTrack.VoicesHigh), h		; High byte of voice pointer
		call	zKeyOffIfActive				; Kill channel notes
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		call	z, zFMClearSSGEGOps			; Clear SSG-EG operators for track's channels if not
		call	zSilencePSGChannel			; Silence PSG channel
		pop		hl							; Restore hl
		pop		bc							; Restore bc
		djnz	zSFXTrackInitLoop			; Loop for all SFX tracks
		jp	zClearNextSound

; =============== S U B	R O U T	I N E =======================================
; Gets SFX channel index for given channel assignment bits
;
; Input:  a     Channel assignment bits
; Output: a     SFX channel index
;         f     m for FM1/FM2, z for FM3, p for FM4-FM6 or PSG1-PSG3
zGetSFXChannelIndex:
		or	a								; Is this a PSG track?
		jp	m, .is_psg						; Branch if yes
		sub	3								; Is this FM4, FM5 or FM6?
		ret	nc								; Branch if yes
		inc	a								; Is this FM3?
		ret
; ---------------------------------------------------------------------------
.is_psg:
		; Shift high 3 bits to low bits so that we can convert it to a table index
		rlca
		rlca
		rlca
		and	7
		ret

; =============== S U B	R O U T	I N E =======================================
; Gets SFX channel and overridden channel for given channel assignment bits
;
; Input:  c     Channel assignment bits
; Output: ix    SFX channel
;         hl    Overridden channel
;sub_78F
zGetSFXChannelPointers:
		ld	a, c							; a = channel identifier
		call	zGetSFXChannelIndex			; Get channel index
		ret	m								; Return if FM1 or FM2
		push	af							; Save af
		ld	hl, zSFXChannelData				; Pointer table for track RAM
		rst	PointerTableOffset				; hl = track RAM
		push	hl							; Save hl
		pop	ix								; ix = track RAM
		pop	af								; Restore af
		; This is where there is code in other drivers to load the special SFX
		; channel pointers to iy
		ld	hl, zSFXOverriddenChannel		; Pointer table for the overridden music track
		jp	PointerTableOffset				; hl = RAM destination to mark as overridden
; End of function zGetSFXChannelPointers

; =============== S U B	R O U T	I N E =======================================
; Checks if matching SFX channel is overriding the channel pointed to by ix.
;
; Input:  ix    Pointer to channel data
; Output: a     Playback control byte of matching SFX track or 0 for FM1/FM2
;         f     m if matching SFX track is playing, 0 otherwise
zIsSFXTrackOverriding:
		ld	a, (ix+zTrack.VoiceControl)		; Fetch channel assignment byte

zIsSFXTrackOverriding_Part2:
		call	zGetSFXChannelIndex			; Get channel index
		jp	m, .is_fm1fm2					; Return if FM1 or FM2
		ld	hl, zSFXChannelData				; Pointer table for track RAM
		rst	PointerTableOffset				; hl = track RAM
		ld	a, (hl)							; Get playback control byte for SFX track
		or	a								; Is SFX track overriding this?
		ret
; ---------------------------------------------------------------------------
.is_fm1fm2:
		xor	a								; Return 0 (aka 'SFX track not playing')
		ret

; =============== S U B	R O U T	I N E =======================================
;
;sub_7C5
zInitFMDACTrack:
		ex	af, af'							; Save af
		xor	a								; a = 0
		ld	(de), a							; Set modulation to inactive
		inc	de								; Advance to next byte
		ld	(de), a							; Set FM instrument/PSG tone to zero too
		inc	de								; Advance to next byte again
		ex	af, af'							; Restore af

;loc_7CC
zZeroFillTrackRAM:
		ex	de, hl							; Exchange the contents of de and hl
		ld	(hl), zTrack.len				; Call subroutine stack pointer
		inc	hl								; Advance to next byte
		ld	(hl), maskPanning				; default Panning / AMS / FMS settings (only stereo L/R enabled)
		inc	hl								; Advance to next byte
		ld	(hl), 1							; Current note duration timeout

		ld	b, zTrack.len-zTrack.DurationTimeout-1	; Loop counter

.loop:
		inc	hl								; Advance to next byte
		ld	(hl), 0							; Put 0 into this byte
		djnz	.loop						; Loop until end of track

		inc	hl								; Make hl point to next track
		ex	de, hl							; Exchange the contents of de and hl
		ret
; End of function zInitFMDACTrack
; ---------------------------------------------------------------------------
;zloc_7DF
zSFXChannelData:
		dw zSFX_FM3						; FM3
		dw zSFX_FM4						; FM4
		dw zSFX_FM5						; FM5
		dw zSFX_FM6						; FM6
		dw zSFX_PSG1					; PSG1
		dw zSFX_PSG2					; PSG2
		dw zSFX_PSG3					; PSG3
		dw zSFX_PSG3					; PSG3/Noise
;zloc_7EF
zSFXOverriddenChannel:
		dw zSongFM3						; FM3
		dw zSongFM4						; FM4
		dw zSongFM5						; FM5
		dw zSongFM6						; FM6
		dw zSongPSG1					; PSG1
		dw zSongPSG2					; PSG2
		dw zSongPSG3					; PSG3
		dw zSongPSG3					; PSG3/Noise

; =============== S U B	R O U T	I N E =======================================
; Pauses/unpauses sound.
;
;sub_7FF
zPauseUnpause:
		ld	hl, zPauseFlag					; hl = pointer to pause flag
		ld	a, (hl)							; a = pause flag
		or	a								; Is sound driver paused?
		ret	z								; Return if not
		jp	m, .unpause						; Branch if pause flag is negative (unpause)
		pop	de								; Pop return value from the stack, so that a 'ret' will go back to zVInt
		dec	a								; Decrease a
		ret	nz								; Return if nonzero
		ld	(hl), 2							; Set pause flag to 2 (i.e., stay paused but don't pause again)
		jp	zPauseAudio						; Pause all but DAC
; ---------------------------------------------------------------------------
.unpause:
		xor	a								; a = 0
		ld	(hl), a							; Clear pause flag
		ld	(zContinuousSFX), a				; Clear continuous SFX ID
		ld	(zContinuousSFXFlag), a			; Clear continuous SFX flag
		ld	(zContSFXLoopCnt), a				; Clear continuous SFX counter
		ld	a, (zFadeOutTimeout)			; Get fade timeout
		or	a								; Is it zero?
		jp	nz, zMusicFade					; Stop all music if not
		ld	ix, zSongFM1					; Start with FM1 track
		ld	b, zNumMusicFMTracks			; Number of FM tracks
		ld	a, (zDACEnable)					; Get DAC enable
		or	a								; Is it supposed to be on?
		jr	z, .song_loop					; Branch if not
		ld	ix, zSongDAC					; Start with DAC instead

.song_loop:
		ld	a, (zHaltFlag)					; Get halt flag
		or	a								; Is song halted?
		jr	nz, .set_pan					; Branch if yes
		bit	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Is track playing?
		jr	z, .skip_song_track				; Branch if not

.set_pan:
		ld	c, (ix+zTrack.AMSFMSPan)		; Get track AMS/FMS/panning
		ld	a, ymPanningAMSensFMSens		; Command to select AMS/FMS/panning register
		call	zWriteFMIorII				; Write data to YM2612

.skip_song_track:
		ld	de, zTrack.len					; Spacing between tracks
		add	ix, de							; Advance to next track
		djnz	.song_loop					; Loop for all tracks

		ld	ix, zTracksSFXStart				; Start at the start of SFX track data
		ld	b, zNumSFXTracks				; Number of tracks

.sfx_loop:
		bit	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Is track playing?
		jr	z, .skip_sfx_track				; Branch if not
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		jr	nz, .skip_sfx_track				; Branch if yes
		ld	c, (ix+zTrack.AMSFMSPan)		; Get track AMS/FMS/panning
		ld	a, ymPanningAMSensFMSens		; Command to select AMS/FMS/panning register
		call	zWriteFMIorII				; Write data to YM2612

.skip_sfx_track:
		ld	de, zTrack.len					; Spacing between tracks
		add	ix, de							; Go to next track
		djnz	.sfx_loop					; Loop for all tracks

		ret
; End of function zPauseUnpause

; =============== S U B	R O U T	I N E =======================================
; Fades out music.
;sub_85C
zFadeOutMusic:
		ld	a, 28h							; a = 28h
		ld	(zFadeOutTimeout), a			; Set fade timeout to this (start fading out music)
		ld	a, 6							; a = 6
		ld	(zFadeDelayTimeout), a			; Set fade delay timeout
		ld	(zFadeDelay), a					; Set fade delay and fall through

; =============== S U B	R O U T	I N E =======================================
; Halts FM6, DAC, PSG1, PSG2, PSG3.
;sub_869
zHaltDACPSG:
		xor	a								; a = 0
		ld	(zSongDAC), a					; Halt DAC
		ld	(zSongPSG3), a					; Halt PSG3
		ld	(zSongPSG1), a					; Halt PSG1
		ld	(zSongPSG2), a					; Halt PSG2
		jp	zPSGSilenceAll
; End of function zHaltDACPSG


; =============== S U B	R O U T	I N E =======================================
; Fade out music slowly.
;
;sub_879
zDoMusicFadeOut:
		ld	hl, zFadeOutTimeout				; hl = pointer to fade timeout
		ld	a, (hl)							; a = fade counter
		or	a								; Is fade counter zero?
		ret	z								; Return if yes
		call	m, zHaltDACPSG				; Kill DAC and PSG channels if negative
		res	7, (hl)							; Clear sign bit
		ld	a, (zFadeDelayTimeout)			; Get fade delay timeout
		dec	a								; Decrement it
		jr	z, .timer_expired				; Branch if it zero now
		ld	(zFadeDelayTimeout), a			; Store it back
		ret
; ---------------------------------------------------------------------------
.timer_expired:
		ld	a, (zFadeDelay)					; Get fade delay
		ld	(zFadeDelayTimeout), a			; Restore counter to initial value
		ld	hl, zFadeOutTimeout				; (hl) = fade timeout
		dec	(hl)							; Decrement it
		jp	z, zMusicFade					; Stop all music if it is zero
		bankswitchToMusic
		ld	ix, zTracksStart				; ix = pointer to track RAM
		ld	b, zNumMusicFMorDACTracks		; Number of FM+DAC tracks

.loop:
		inc	(ix+zTrack.Volume)				; Decrease volume
		jp	p, .chk_change_volume			; If still positive, branch
		dec	(ix+zTrack.Volume)				; Increase it back to minimum volume (127)
		jr	.next_track
; ---------------------------------------------------------------------------
.chk_change_volume:
		bit	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Is track still playing?
		jr	z, .next_track					; Branch if not
		push	bc							; Save bc
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is SFX overriding track?
		call	z, zSendTL.active			; Send new volume if not
		pop	bc								; Restore bc

.next_track:
		ld	de, zTrack.len					; Spacing between tracks
		add	ix, de							; Advance to next track
		djnz	.loop						; Loop for all tracks
		ret
; End of function zDoMusicFadeOut


; =============== S U B	R O U T	I N E =======================================
; Fades music in.
;
;sub_8DF
zDoMusicFadeIn:
		ld	a, (zFadeInTimeout)				; Get fading timeout
		or	a								; Is music being faded?
		ret	z								; Return if not
		bankswitchToMusic
		ld	hl, zFadeDelay					; Get fade delay
		dec	(hl)							; Decrement it
		ret	nz								; Return if it is not yet zero
		ld	a, (zFadeDelayTimeout)			; Get current fade delay timeout
		ld	(zFadeDelay), a					; Reset to starting fade delay
		ld	b, zNumMusicFMTracks			; Number of FM tracks
		ld	ix, zSongFM1					; ix = start of FM1 RAM
		ld	de, zTrack.len					; Spacing between tracks

.fm_loop:
		dec	(ix+zTrack.Volume)				; Increase track volume
		push	bc							; Save bc
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is 'SFX is overriding' bit set?
		call	z, zSendTL.active			; Send new volume if not
		pop	bc								; Restore bc
		add	ix, de							; Advance to next track
		djnz	.fm_loop					; Loop for all tracks

		ld	hl, zFadeInTimeout				; Get fading timeout
		dec	(hl)							; Decrement it
		ret	nz								; Return if still fading
		ld	b, zNumMusicPSGTracks			; Number of PSG tracks
		ld	ix, zSongPSG1					; ix = start of PSG RAM
		ld	de, zTrack.len					; Spacing between tracks

.psg_loop:
		res	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Clear 'SFX is overriding' bit
		add	ix, de							; Advance to next track
		djnz	.psg_loop					; Loop for all tracks

		ld	a, (zDACEnable)					; Get DAC enable
		or	a
		ret	z
		ld	ix, zSongDAC					; ix = start of DAC RAM
		res	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Clear 'SFX is overriding' bit
		ret
; End of function zDoMusicFadeIn

; =============== S U B	R O U T	I N E =======================================
; Wipes music data (except SFX stuff) and fades all channels not overridden by
; SFX channels.
zMusicFadeKeepSFX:
		; The following block sets to zero the z80 RAM that keeps music and SFX state
		ld	hl, zFadeOutTimeout				; Starting source address for copy
		ld	de, zFadeDelay					; Starting destination address for copy
		ld	bc, zTracksEnd-zFadeDelay		; Length of copy
		jp	zMusicFade.common

; =============== S U B	R O U T	I N E =======================================
; Wipes music data and fades all FM, PSG and DAC channels.
;sub_944
zMusicFade:
		; The following block sets to zero the z80 RAM that keeps music and SFX state
		ld	hl, zContinuousSFX				; Starting source address for copy
		ld	de, zContinuousSFXFlag			; Starting destination address for copy
		ld	bc, zTracksSaveEnd-zFadeDelay	; Length of copy

.common:
		xor	a								; a = 0
		ld	(hl), a							; Initial value of zero
		ldir								; while (--length) *de++ = *hl++
		ld	a, (zTempoSpeedupReq)			; Get flag indicating if tempo is to be kept
		or	a								; Is it set?
		jr	nz, .keep_tempo					; Branch if yes
		ld	(zTempoSpeedup), a				; Fade in normal speed

.keep_tempo:
		xor	a								; a = 0
		ld	(zTempoSpeedupReq), a			; Clear for next time around

zMusicFadeSimple:
		ld	ix, zFMDACInitBytes				; Initialization data for channels
		ld	b, zNumMusicFMTracks			; Number of FM channels

.loop:
		push	bc							; Save bc for loop
		call	zIsSFXTrackOverriding		; Is SFX overriding?
		jp	m, .skip_fmchannel				; Branch if yes
		call	zFMSilenceChannel			; Silence track's channel
		call	zFMClearSSGEGOps			; Clears the SSG-EG operators for this channel
		ld	a, (ix+zTrack.VoiceControl)		; Fetch channel assignment byte
		cp	ymFM3							; Is this FM3?
		jr	nz, .skip_fmchannel				; Branch if yes
		ld	c, maskFM3Normal				; FM3 mode: normal mode
		ld	a, ymTimerControlFm3Mode		; FM3 special settings
		call	zWriteFMI					; Set it

.skip_fmchannel:
		inc	ix								; Go to next channel byte
		inc	ix								; But skip the 80h
		pop	bc								; Restore bc for loop counter
		djnz	.loop						; Loop while b > 0

		ld	ix, zPSGInitBytes				; Initialization data for channels
		ld	b, zNumMusicPSGTracks			; Number of PSG tracks

.looppsg:
		push	bc							; Save bc for loop
		call	zIsSFXTrackOverriding		; Is SFX overriding?
		call	p, zSilencePSGChannel		; Silence if not
		inc	ix								; Go to next channel byte
		inc	ix								; But skip the 80h
		pop	bc								; Restore bc for loop counter
		djnz	.looppsg					; Loop for all PSG channels

		xor	a								; a = 0
		ld	(zFadeOutTimeout), a			; Set fade timeout to zero... again
		ld	c, a							; Write a zero...
		ld	a, ymDACEnable					; ... to DAC enable register
		call	zWriteFMI					; Disable DAC
		jp	zClearNextSound

;loc_979
zFM3NormalMode:
		ld	c, maskFM3Normal				; FM3 mode: normal mode
		ld	a, ymTimerControlFm3Mode		; FM3 special settings
		call	zWriteFMI					; Set it
		jp	zClearNextSound
; End of function zMusicFade

; =============== S U B	R O U T	I N E =======================================
; Sets the SSG-EG registers (90h+) for all operators on this track to 0.
;
; Input:  ix    Pointer to track RAM
; Output: a     Damaged
;         b     Damaged
;         c     Damaged
;sub_986
zFMClearSSGEGOps:
		ld	a, ymSSGEG1						; Set SSG-EG registers...
		ld	c, 0							; ... set to zero (as docs say it should)...
		jp	zFMOperatorWriteLoop			; ... for all operators of this track's channel
; End of function zFMClearSSGEGOps

; =============== S U B	R O U T	I N E =======================================
; Pauses all audio.
;loc_98D
zPauseAudio:
		push	bc							; Save bc
		push	af							; Save af
		ld	b, zNumMusicFM1Tracks			; FM1/FM2/FM3
		ld	a, ymPanningAMSensFMSens		; Command to select AMS/FMS/panning register (FM1)
		ld	c, 0							; AMS=FMS=panning=0

.loop1:
		push	af							; Save af
		call	zWriteFMI					; Write reg/data pair to YM2612
		pop	af								; Restore af
		inc	a								; Advance to next channel
		djnz	.loop1						; Loop for all channels

		ld	b, zNumMusicFM2Tracks			; FM4/FM5/FM6
		ld	a, ymPanningAMSensFMSens		; Command to select AMS/FMS/panning register

.loop2:
		push	af							; Save af
		call	zWriteFMII					; Write reg/data pair to YM2612
		pop	af								; Restore af
		inc	a								; Advance to next channel
		djnz	.loop2						; Loop for all channels

		ld	c, 0							; Note off for all operators
		ld	b, zNumMusicFMTracks+1			; FM channels + gap between FM3 and FM4
		ld	a, ymKeyOnOff					; Command to send note on/off

.loop3:
		push	af							; Save af
		call	zWriteFMI					; Write reg/data pair to YM2612
		inc	c								; Next channel
		pop	af								; Restore af
		djnz	.loop3						; Loop for all channels

		pop	af								; Restore af
		pop	bc								; restore bc and fall through

; =============== S U B	R O U T	I N E =======================================
; Silences all PSG channels, including the noise channel.
;
; Output: a    Damaged
;sub_9BC
zPSGSilenceAll:
		push	bc							; Save bc
		ld	b, zNumMusicPSGTracks+1			; Loop 4 times: 3 PSG channels + noise channel
		ld	a, snPSG1|snPSGVol|0Fh			; Command to silence PSG1

.loop:
		ld	(zPSG), a						; Write command
		add	a, snPSG2-snPSG1				; Next channel
		djnz	.loop						; Loop for all PSG channels
		pop	bc								; Restore bc
		jp	zClearNextSound
; End of function zPSGSilenceAll


; =============== S U B	R O U T	I N E =======================================
; Tempo works as divisions of the 60Hz clock (there is a fix supplied for
; PAL that "kind of" keeps it on track.) Every time the internal music clock
; does NOT overflow, it will update. So a tempo of 80h will update every
; other frame, or 30 times a second.
;sub_9CC:
TempoWait:
		ld	a, (zCurrentTempo)				; Get current tempo value
		ld	hl, zTempoAccumulator			; hl = pointer to tempo accumulator
		add	a, (hl)							; a += tempo accumulator
		ld	(hl), a							; Store it as new accumulator value
		ret	nc								; If the addition did not overflow, return
		ld	hl, zTracksStart+zTrack.DurationTimeout	; Duration timeout of first track
		ld	de, zTrack.len					; Spacing between tracks
		ld	b, zNumMusicTracks				; Number of tracks

.loop:
		inc	(hl)							; Delay notes another frame
		add	hl, de							; Advance to next track
		djnz	.loop						; Loop for all channels
		ret
; End of function TempoWait


; =============== S U B	R O U T	I N E =======================================
; Copies over M68K input to the sound queue and clears the input variables
;sub_9E2
zFillSoundQueue:
		ld	hl, zMusicNumber				; M68K input
		ld	de, zSoundQueue0				; Sound queue
		ldi									; *de++ = *hl++
		ldi									; *de++ = *hl++
		ldi									; *de++ = *hl++
		xor	a								; a = 0
		dec	hl								; Point to zSFXNumber1
		ld	(hl), a							; Clear it
		dec	hl								; Point to zSFXNumber0
		ld	(hl), a							; Clear it
		dec	hl								; Point to zMusicNumber
		ld	(hl), a							; Clear it
		ret
; End of function zFillSoundQueue


; =============== S U B	R O U T	I N E =======================================
; Sets D1L to minimum, RR to maximum and TL to minimum amplitude for all
; operators on this track's channel, then sends note off for the same channel.
;
; Input:  ix    Pointer to track RAM
; Output: a     Damaged
;         b     Damaged
;         c     Damaged
;sub_9F6
zFMSilenceChannel:
		call	zSetMaxRelRate
		ld	a, ymTotalLevel1				; Set total level...
		ld	c, 7Fh							; ... to minimum envelope amplitude...
		call	zFMOperatorWriteLoop		; ... for all operators of this track's channel
		ld	c, (ix+zTrack.VoiceControl)		; Send key off
		jp	zKeyOnOff
; End of function zFMSilenceChannel


; =============== S U B	R O U T	I N E =======================================
; Sets D1L to minimum and RR to maximum for all operators on this track's
; channel.
;
; Input:  ix    Pointer to track RAM
; Output: a     Damaged
;         b     Damaged
;         c     Damaged
;sub_A06
;zSetFMMinD1LRR
zSetMaxRelRate:
		ld	a, ymSustainLevelReleaseRate1	; Set D1L to minimum and RR to maximum...
		ld	c, maxSustainLevel|maxReleaseRate	; ... for all operators on this track's channel (fall through)
; End of function zSetMaxRelRate


; =============== S U B	R O U T	I N E =======================================
; Loops through all of a channel's operators and sets them to the desired value.
;
; Input:  ix    Pointer to track RAM
;         a     YM2612 register to write to
;         c     Value to write to register
; Output: b     Damaged
;sub_A0A
zFMOperatorWriteLoop:
		ld	b, 4							; Loop 4 times

.loop:
		push	af							; Save af
		call	zWriteFMIorII				; Write to part I or II, as appropriate
		pop	af								; Restore af
		add	a, 4							; a += 4
		djnz	.loop						; Loop
		ret
; End of function zFMOperatorWriteLoop
; ---------------------------------------------------------------------------
;loc_A16
zPlaySegaSound:
		call	zMusicFade					; Fade music before playing the sound
		xor	a								; a = 0
		ld	(zMusicNumber), a				; Clear M68K input queue...
		ld	(zSFXNumber0), a				; ... including SFX slot 0...
		ld	(zSFXNumber1), a				; ... and SFX slot 1
		ld	(zSoundQueue0), a				; Also clear music queue entry 0...
		ld	(zSoundQueue1), a				; ... and entry 1...
		ld	(zSoundQueue2), a				; ... and entry 2
		inc	a								; a = 1
		ld	(PlaySegaPCMFlag), a			; Set flag to play SEGA sound
		pop	hl								; Don't return to caller of zCycleSoundQueue
		ret

; =============== S U B	R O U T	I N E =======================================
; Performs massive restoration and starts fade in of previous music.
;
;sub_A20
zFadeInToPrevious:
		xor	a								; a = 0
		ld	(zFadeToPrevFlag), a			; Clear fade-to-prev flag
		ld	a, (zCurrentTempoSave)			; Get saved current tempo
		ld	(zCurrentTempo), a				; Restore it
		ld	a, (zTempoSpeedupSave)			; Get saved tempo speed-up
		ld	(zTempoSpeedup), a				; Restore it
		ld	hl, (zVoiceTblPtrSave)			; Get saved voice pointer
		ld	(zVoiceTblPtr), hl				; Restore it
		ld	a, (zSongBankSave)				; Get saved song bank ID
		ld	(zSongBank), a					; Restore it
		bankswitch							; Bank switch to previous song's bank
		ld	hl, zTracksSaveStart			; Start of saved track data
		ld	de, zTracksStart				; Start of track data
		ld	bc, zTracksSaveEnd-zTracksSaveStart	; Number of bytes to copy
		ldir								; while (bc-- > 0) *de++ = *hl++;
		xor	a								; a = 0
		ld	hl, zTracksSaveStart			; Start of saved track data
		ld	de, zTracksSaveStart+1			; Start of track data
		ld	(hl), a							; Prepare to zero-fill save RAM
		ld	bc, zTracksSaveEnd-zTracksSaveStart-1	; Number of bytes to copy
		ldir								; while (bc-- > 0) *de++ = *hl++;
		ld	a, (zDACEnableSave)				; Get saved DAC enable
		ld	(zDACEnable), a					; Restore it
		or	a
		jr	z, .no_dac
		ld	ix, zSongDAC
		xor	a
		ld	(ix+zTrack.DACSFXPlaying), a
		ld	a, maskPlayRest					; a = 'track is playing' and 'track is resting' flags
		or	(ix+zTrack.PlaybackControl)		; Add in track playback control bits
		ld	(ix+zTrack.PlaybackControl), a	; Save everything
		ld	c, ymFM6						; Get voice control byte for FM6
		ld	a, ymKeyOnOff					; Write to KEY ON/OFF port
		call	zWriteFMI

.no_dac:
		ld	ix, zSongFM1					; ix = pointer to FM1 track RAM
		ld	b, zNumMusicFMorPSGTracks		; Number of FM+PSG tracks

.loop:
		ld	a, (ix+zTrack.VoiceControl)		; Get voice bits
		cp	ymFM6
		jr	nz, .not_fm6
		ld	a, (zDACEnable)					; Get DAC enable
		or	a
		jr	nz, .skip_track

.not_fm6:
		ld	a, (ix+zTrack.PlaybackControl)	; a = track playback control
		or	maskPlayRest					; Set 'track is playing' and 'track is resting' flags
		ld	(ix+zTrack.PlaybackControl), a	; Set new value
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		jp	nz, .skip_track					; Branch if yes
		res	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Clear 'SFX is overriding track' flag
		ld	a, (ix+zTrack.Volume)			; Get track volume
		add	a, 40h							; Lower volume by 40h
		ld	(ix+zTrack.Volume), a			; Store new volume
		ld	a, (ix+zTrack.VoiceIndex)		; a = FM instrument
		push	bc							; Save bc
		ld	b, a							; b = FM instrument
		call	zGetFMInstrumentPointer		; hl = pointer to instrument data
		call	zSendFMInstrument.active	; Send instrument
		pop	bc								; Restore bc

.skip_track:
		ld	de, zTrack.len					; Spacing between tracks
		add	ix, de							; ix = pointer to next track
		djnz	.loop						; Loop for all tracks

		ld	a, 40h							; a = 40h
		ld	(zFadeInTimeout), a				; Start fade
		ld	a, 2							; a = 2
		ld	(zFadeDelayTimeout), a			; Set fade delay timeout
		ld	(zFadeDelay), a					; Set fade delay
		ret
; End of function zFadeInToPrevious
; ---------------------------------------------------------------------------
;loc_AA5
zPSGFrequencies:
		; This table differs from the one in Sonic 1 and 2's drivers by
		; having an extra octave at the start and two extra notes at
		; the end, allowing it to span notes c-0 to b-7.
		dw 3FFh,3FFh,3FFh,3FFh,3FFh,3FFh,3FFh,3FFh,3FFh,3F7h,3BEh,388h
		dw 356h,326h,2F9h,2CEh,2A5h,280h,25Ch,23Ah,21Ah,1FBh,1DFh,1C4h
		dw 1ABh,193h,17Dh,167h,153h,140h,12Eh,11Dh,10Dh,0FEh,0EFh,0E2h
		dw 0D6h,0C9h,0BEh,0B4h,0A9h,0A0h,097h,08Fh,087h,07Fh,078h,071h
		dw 06Bh,065h,05Fh,05Ah,055h,050h,04Bh,047h,043h,040h,03Ch,039h
		dw 036h,033h,030h,02Dh,02Bh,028h,026h,024h,022h,020h,01Fh,01Dh
		dw 01Bh,01Ah,018h,017h,016h,015h,013h,012h,011h,010h,000h,000h
;loc_B4D
zFMFrequencies:
		; This table spans only a single octave, as the octave frequency
		; is calculated at run-time unlike in Sonic 1 and 2's drivers.
		dw 284h,2ABh,2D3h,2FEh,32Dh,35Ch,38Fh,3C5h,3FFh,43Ch,47Ch,4C0h
; ---------------------------------------------------------------------------

; =============== S U B	R O U T	I N E =======================================
;
;sub_B98
zUpdateDACTrack:
		dec	(ix+zTrack.DurationTimeout)		; Advance track duration timer
		ret	nz								; Return if note is still going
		ld	e, (ix+zTrack.DataPointerLow)	; e = low byte of track data pointer
		ld	d, (ix+zTrack.DataPointerHigh)	; d = high byte of track data pointer

;loc_BA2
zUpdateDACTrack_cont:
		ld	a, (de)							; Get next byte from track
		inc	de								; Advance pointer
		cp	FirstCoordFlag					; Is it a coordination flag?
		jp	nc, zHandleDACCoordFlag			; Branch if yes
		or	a								; Is it a note?
		jp	m, .got_sample					; Branch if yes
		dec	de								; We got a duration, so go back to it
		ld	a, (ix+zTrack.SavedDAC)			; Reuse previous DAC sample

.got_sample:
		ld	(ix+zTrack.SavedDAC), a			; Store new DAC sample
		ld	a, (ix+zTrack.DACSFXPlaying)
		or	a
		jr	nz, .get_duration
		ld	a, (ix+zTrack.SavedDAC)
		sub	NoteRest						; Is it a rest?
		jp	z, .get_duration				; Branch if yes
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is SFX overriding DAC channel?
		jp	nz, .get_duration				; Branch if yes
		ld	(zDACIndex), a					; Queue DAC sample
		push	ix							; Save track pointer
		ld	ix, zSongFM6					; Get pointer to FM6 track data
		set	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Mark track as being overridden
		call	zKeyOffIfActive				; Kill note (will do nothing if 'do not attack' is on)
		pop	ix								; Restore track pointer

.get_duration:
		ld	a, (de)							; Get note duration
		inc	de								; Advance pointer
		or	a								; Is it a duration?
		jp	p, zStoreDuration				; Branch if yes
		dec	de								; Put the byte back to the stream
		ld	a, (ix+zTrack.SavedDuration)	; Reuse last duration
		ld	(ix+zTrack.DurationTimeout), a	; Set new duration timeout
		jp	zFinishTrackUpdate
; ---------------------------------------------------------------------------
;loc_BE3
zHandleDACCoordFlag:
		ld	hl, loc_BE9						; hl = desired return address
		jp	zHandleCoordFlag
; ---------------------------------------------------------------------------
loc_BE9:
		inc	de								; Advance to next byte in track
		jp	zUpdateDACTrack_cont			; Continue processing DAC track
; ---------------------------------------------------------------------------
;loc_BED
zHandleFMorPSGCoordFlag:
		ld	hl, loc_BF9						; hl = desired return address

;loc_BF0
zHandleCoordFlag:
		push	hl							; Set return location (ret) to location stored in hl
		sub	FirstCoordFlag					; Make it a zero-based index
		ld	hl, zCoordFlagSwitchTable		; Load switch table into hl
		rst	PointerTableOffset				; hl = pointer to target location
		ld	a, (de)							; a = coordination flag parameter
		jp	(hl)							; Indirect jump to coordination flag handler
; End of function zUpdateDACTrack
; ---------------------------------------------------------------------------
loc_BF9:
		inc	de								; Advance to next byte in track
		jp	zGetNextNote_cont				; Continue processing FM/PSG track
; ---------------------------------------------------------------------------
;loc_BFD
zCoordFlagSwitchTable:
		dw cfPanningAMSFMS					; 0E0h
		dw cfDetune							; 0E1h
		dw cfFadeInToPrevious				; 0E2h
		dw cfSilenceStopTrack				; 0E3h
		dw cfSetVolume						; 0E4h
		dw cfChangeVolume2					; 0E5h
		dw cfChangeVolume					; 0E6h
		dw cfPreventAttack					; 0E7h
		dw cfNoteFill						; 0E8h
		dw cfSpindashRev					; 0E9h
		dw cfPlayDACSample					; 0EAh
		dw cfConditionalJump				; 0EBh
		dw cfChangePSGVolume				; 0ECh
		dw cfSetKey							; 0EDh
		dw cfSendFMI						; 0EEh
		dw cfSetVoice						; 0EFh
		dw cfModulation						; 0F0h
		dw cfAlterModulation				; 0F1h
		dw cfStopTrack						; 0F2h
		dw cfSetPSGNoise					; 0F3h
		dw cfSetModulation					; 0F4h
		dw cfSetPSGVolEnv					; 0F5h
		dw cfJumpTo							; 0F6h
		dw cfRepeatAtPos					; 0F7h
		dw cfJumpToGosub					; 0F8h
		dw cfJumpReturn						; 0F9h
		dw cfDisableModulation				; 0FAh
		dw cfChangeTransposition			; 0FBh
		dw cfLoopContinuousSFX				; 0FCh
		dw cfToggleAltFreqMode				; 0FDh
		dw cfFM3SpecialMode					; 0FEh
		dw cfMetaCF							; 0FFh
;loc_C3D
zExtraCoordFlagSwitchTable:
		dw cfSetTempo						; 0FFh 00h
		dw cfPlaySFXByIndex					; 0FFh 01h
		dw cfHaltSound						; 0FFh 02h
		dw cfCopyData						; 0FFh 03h
		dw cfSetTempoDivider				; 0FFh 04h
		dw cfSetSSGEG						; 0FFh 05h
		dw cfFMVolEnv						; 0FFh 06h
		dw cfResetSpindashRev				; 0FFh 07h
		dw cfChanSetTempoDivider			; 0FFh 08h
		dw cfChanFMCommand					; 0FFh 09h
		dw cfNoteFillSet					; 0FFh 0Ah
		dw cfPitchSlide						; 0FFh 0Bh
		dw cfSetLFO							; 0FFh 0Ch
		dw cfPlayMusicByIndex				; 0FFh 0Dh
; =============== S U B	R O U T	I N E =======================================
; Sets a new DAC sample for play.
;
; Has one parameter, the index (1-based) of the DAC sample to play.
;
;sub_C4D
cfPlayDACSample:
		ld	(zDACIndex), a					; Set next DAC sample to the parameter byte
		ld	hl, zSongDAC					; Get pointer to DAC track
		set	bitSFXOverride, (hl)			; Mark track as being overridden
		ld	hl, zSongFM6					; Get pointer to FM6 track
		set	bitSFXOverride, (hl)			; Mark track as being overridden
		ret
; End of function cfPlayDACSample


; =============== S U B	R O U T	I N E =======================================
; Sets panning for track. By accident, you can sometimes set AMS and FMS
; flags -- but only if the bits in question were zero.
;
; Has one parameter byte, the AMS/FMS/panning bits.
;
;sub_C51
cfPanningAMSFMS:
		ld	c, (~maskPanning)&0FFh			; Mask for all but panning

zDoChangePan:
		ld	a, (ix+zTrack.AMSFMSPan)		; Get current AMS/FMS/panning
		and	c								; Mask out L+R
		push	de							; Store de
		ex	de, hl							; Exchange de and hl
		or	(hl)							; Mask in the new panning; may also add AMS/FMS
		ld	(ix+zTrack.AMSFMSPan), a		; Store new value in track RAM
		ld	c, a							; c = new AMS/FMS/panning
		ld	a, ymPanningAMSensFMSens		; a = YM2612 register to write to
		call	zWriteFMIorII				; Set new panning/AMS/FMS
		pop	de								; Restore de
		ret
; End of function cfPanningAMSFMS

; =============== S U B	R O U T	I N E =======================================
; Enables or disables the LFO.
;
; Has two parameter bytes: the first one is sent directly to the LFO enable
; register: bit 3 is the enable flag, bits 0-2 are the frequency of the LFO.
; Second parameter byte specifies AMS/FMS sensibility for the channel.

cfSetLFO:
		ld	c, a							; Copy parameter byte
		ld	a, ymLFO						; LFO enable/frequency
		call	zWriteFMI					; Send it
		inc	de								; Advance pointer
		ld	c, maskPanning					; Mask for only panning
		jr	zDoChangePan

; =============== S U B	R O U T	I N E =======================================
; Performs an escalating transposition ("revving") of the track.
;
; The saved value for the spindash rev is reset to zero every time a "normal"
; SFX is played (i.e., not a continuous SFX and not the spindash sound).
; Every time this function is called, the spindash rev value is added to the
; track transposition; unless this sum is exactly 10h, then the spindash rev is
; further increased by 1 for future calls.
;
; Has no parameter bytes.
;
;sub_C65
cfSpindashRev:
		ld	hl, zSpindashRev				; hl = pointer to escalating transposition
		ld	a, (hl)							; a = value of escalating transposition
		add	a, (ix+zTrack.Transpose)		; Add in current track transposition
		ld	(ix+zTrack.Transpose), a		; Store result as new track transposition
		cp	10h								; Is the current transposition 10h?
		jp	z, .skip_rev					; Branch if yes
		inc	(hl)							; Otherwise, increase escalating transposition

.skip_rev:
		dec	de								; Put parameter byte back
		ret
; End of function cfSpindashRev


; =============== S U B	R O U T	I N E =======================================
; Sets detune (signed). The final note frequency is shifted
; by this value.
;
; Has one parameter byte, the new detune.
;
;sub_C77 cfAlterNoteFreq
cfDetune:
		ld	(ix+zTrack.Detune), a			; Set detune
		ret
; End of function cfDetune


; =============== S U B	R O U T	I N E =======================================
; Fade in to previous song.
;
; Has one parameter byte. If the parameter byte if FFh, the engine will fade
; to the previous song. If the parameter byte is equal to 29h (1-Up ID - 1),
; the driver will prevent new music or SFX from playing as long as the 1-Up
; music is playing (but will not clear the M68K queue). For all other values,
; the queue will work as normal, but no fade-in will be done.
;
;sub_C7B
cfFadeInToPrevious:
		ld	(zFadeToPrevFlag), a
		ret
; End of function cfFadeInToPrevious

; =============== S U B	R O U T	I N E =======================================
; Silences FM channel and stops track. Expanded form of coord. flag 0F2h.
;
; Technically, it has a parameter byte, but it is irrelevant and unused.
;
;loc_C7F
cfSilenceStopTrack:
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		call	z, zFMSilenceChannel		; If so, don't mess with the YM2612
		jp	cfStopTrack
; End of function cfSilenceStopTrack

; =============== S U B	R O U T	I N E =======================================
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
;loc_C85
cfSetVolume:
		cpl									; Invert parameter byte
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG channel?
		jr	z, .not_psg						; Branch if not
		; The following code gets bits 3, 4, 5 and 6 from the parameter byte,
		; puts them in positions 0 to 3 and inverts them, discarding all other
		; bits in the parameter byte.
		; Shift the parameter byte 3 bits to the right
		srl	a
		srl	a
		srl	a
		and	0Fh								; Clear out high nibble
		jp	zStoreTrackVolume
; ---------------------------------------------------------------------------
.not_psg:
		and	7Fh								; Strip irrelevant sign bit
		ld	(ix+zTrack.Volume), a			; Set as new track volume
		jr	zSendTL							; Begin using new volume immediately

; =============== S U B	R O U T	I N E =======================================
; Clamps value of FM volume attenuation to [0, 7Fh] range if needed.
;
; Input:  a    Volume attenuation after being changed
;         f    Flags for change of to volume attenuation
; Output: a    Clamped volume attenuation
zDoFMVolumeClamp:
		ret	p								; Return if result is still positive
		jp	pe, .overflowed					; Branch if addition overflowed into more than 127 positive
		xor	a								; Set maximum volume
		ret
; ---------------------------------------------------------------------------
.overflowed:
		ld	a, 7Fh							; Set minimum volume
		ret

; =============== S U B	R O U T	I N E =======================================
; Change track volume for a FM track.
;
; Has two parameter bytes: the first byte is ignored, the second is the signed
; change in volume. Positive lowers volume, negative increases it.
;
;loc_CA1
cfChangeVolume2:
		inc	de								; Advance pointer
		ld	a, (de)							; Get change in volume then fall-through

; =============== S U B	R O U T	I N E =======================================
; Change track volume for a FM track.
;
; Has one parameter byte, the signed change in volume. Positive lowers volume,
; negative increases it.
;
;loc_CA3
cfChangeVolume:
		; S2 places this check further down (and S1 lacks it altogether),
		; allowing PSG channels to change their volume. This means the
		; likes of S2's SFX $F0 will sound different in this driver
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		ret	nz								; Return if yes
		add	a, (ix+zTrack.Volume)			; Add in track's current volume
		call	zDoFMVolumeClamp			; Clamp if needed
		ld	(ix+zTrack.Volume), a			; Store new volume

; =============== S U B	R O U T	I N E =======================================
; Subroutine to send TL information to YM2612.
;
;sub_CBA
zSendTL:
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is SFX overriding this track?
		ret	nz								; Is so, quit

.active:
		push	iy							; Save iy
		push	de							; Save de
		ld	de, zFMInstrumentTLTable		; de = pointer to FM TL register table
		zGetFMPartPointer					; Point iy to appropriate FM part
		ld	l, (ix+zTrack.TLPtrLow)			; l = low byte of pointer to instrument's TL data
		ld	h, (ix+zTrack.TLPtrHigh)		; h = high byte of pointer to instrument's TL data

.got_pointers:
		ld	b, zFMInstrumentTLTable_End-zFMInstrumentTLTable	; Number of entries

.loop:
		zFastWriteFM (de), (hl), calcVolume
		inc	de								; Advance pointer
		inc	hl								; Advance pointer
		djnz	.loop						; Loop

		pop	de								; Restore de
		pop	iy								; Restore iy
		ret
; End of function zSendTL

; =============== S U B	R O U T	I N E =======================================
; Prevents next note from attacking.
;
; Has no parameter bytes.
;
;loc_CDB
cfPreventAttack:
		set	bitNoAttack, (ix+zTrack.PlaybackControl)	; Set flag to prevent attack
		dec	de								; Put parameter byte back
		ret

; =============== S U B	R O U T	I N E =======================================
; Sets the note fill.
;
; Has one parameter byte, the new note fill. This value is multiplied by the
; tempo divider, and so may overflow.
;
;loc_CE1
cfNoteFill:
		call	zComputeNoteDuration		; Multiply note fill by tempo divider

; =============== S U B	R O U T	I N E =======================================
; Sets the note fill.
;
; Has one parameter byte, the new note fill. This value is stored as is.
;
cfNoteFillSet:
		ld	(ix+zTrack.NoteFillTimeout), a	; Store result into note fill timeout
		ld	(ix+zTrack.NoteFillMaster), a	; Store master copy of note fill
		ret

; =============== S U B	R O U T	I N E =======================================
; Jump timeout. Shares the same loop counters as coord. flag 0E7h, so it has
; to be coordinated with these. Each time this coord. flag is encountered, it
; tests if the associated loop counter is 1. If it is, it will jump to the
; target location and the loop counter will be set to zero; otherwise, nothing
; happens.
;
; Has 3 parameter bytes: a loop counter index (identical to that of coord. flag
; 0E7h), and a 2-byte jump target.
;
;loc_CEB
cfConditionalJump:
		inc	de								; Advance track pointer
		add	a, zTrack.LoopCounters			; Add offset into loop counters
		ld	c, a							; c = offset of current loop counter
		ld	b, 0							; bc = sign-extended offset to current loop counter
		push	ix							; Save track RAM pointer
		pop	hl								; hl = pointer to track RAM
		add	hl, bc							; hl = pointer in RAM to current loop counter
		ld	a, (hl)							; a = value of current loop counter
		dec	a								; Decrement loop counter (note: value is not saved!)
		jp	z, .do_jump						; Branch if result is zero
		inc	de								; Skip another byte
		ret
; ---------------------------------------------------------------------------
.do_jump:
		xor	a								; a = 0
		ld	(hl), a							; Clear loop counter
		jp	cfJumpTo

; =============== S U B	R O U T	I N E =======================================
; Change PSG volume. Has no effect on FM or DAC channels.
;
; Has one parameter byte, the change in volume. The value is signed, but any
; result greater than 0Fh will result in no output, while any result less than
; 0 will result in maximum volume.
;
;loc_D01
cfChangePSGVolume:
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG channel?
		ret	z								; Return if not
		res	bitTrackAtRest, (ix+zTrack.PlaybackControl)	; Clear 'track is resting' flag
		dec	(ix+zTrack.VolEnv)				; Decrement envelope index
		call	zDoPSGVolumeClamp			; Add track's current volume and clamp

;loc_D17
zStoreTrackVolume:
		ld	(ix+zTrack.Volume), a			; Store new volume
		ret

; =============== S U B	R O U T	I N E =======================================
; Adds value to PSG volume attenuation and clamps to [0, 0Fh] range
; if needed.
;
; Input:  a    Change in volume attenuation
;         ix   Pointer to track data
; Output: a    Clamped volume attenuation
zDoPSGVolumeClamp:
		add	a, (ix+zTrack.Volume)			; Add track's current volume
		jp	p, .check_clamp					; Branch if result is positive
		jp	pe, .do_clamp					; Branch if addition overflowed
		xor	a								; Set maximum volume
		ret
; ---------------------------------------------------------------------------
.check_clamp:
		cp	0Fh								; Is it 0Fh or more?
		ret	c								; Return if not

.do_clamp:
		ld	a, 0Fh							; Limit to 0Fh (silence)
		ret

; =============== S U B	R O U T	I N E =======================================
; Changes the track's transposition.
;
; There is a single parameter byte, the new track transposition + 40h (that is,
; 40h is subtracted from the parameter byte before the transposition is set)
;
;loc_D1B
cfSetKey:
		sub	40h								; Subtract 40h from transposition
		ld	(ix+zTrack.Transpose), a		; Store result as new transposition
		ret

; =============== S U B	R O U T	I N E =======================================
; Sends an FM command to the YM2612. The command is sent to part I, so not all
; registers can be set using this coord. flag (in particular, channels FM4,
; FM5 and FM6 cannot (in general) be affected).
;
; Has 2 parameter bytes: a 1-byte register selector and a 1-byte register data.
;
;loc_D21
cfSendFMI:
		call	zGetFMParams				; Get parameters for FM command
		jp	zWriteFMI						; Send it to YM2612

;loc_D28
zGetFMParams:
		ex	de, hl							; Exchange de and hl
		ld	a, (hl)							; Get YM2612 register selector
		inc	hl								; Advance pointer
		ld	c, (hl)							; Get YM2612 register data
		ex	de, hl							; Exchange back de and hl
		ret
; End of function cfSendFMI

; =============== S U B	R O U T	I N E =======================================
; Change current instrument (FM), tone (PSG) or sample (DAC).
;
; Has either a single positive parameter byte or a pair of parameter bytes of
; which the first is negative.
;
; If positive, the first parameter byte is the index of voice to use.
;
; If negative, and on a PSG track, then the first parameter byte is the index
; of voice to use while the second parameter byte is ignored.
;
; If negative and on a FM or DAC track, the first parameter byte is 80h + index
; of voice to use, while the second parameter byte is 7Fh + index of song whose
; voice bank is to be used (here, the AIZ1 song is index 1, not zero).
;
; The uploading of an FM instrument is irrelevant for the DAC.
;
;loc_D2E
cfSetVoice:
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		jr	nz, zSetVoicePSG				; Branch if yes
		call	zSetMaxRelRate				; Set minimum D1L/RR for channel
		ld	a, (de)							; Get voice index
		ld	(ix+zTrack.VoiceIndex), a		; Store to track RAM
		or	a								; Is it negative?
		jp	p, zSetVoiceUpload				; Branch if not
		inc	de								; Advance pointer
		ld	a, (de)							; Get song ID whose bank is desired
		ld	(ix+zTrack.VoiceSongID), a		; Store to track RAM and fall-through

; =============== S U B	R O U T	I N E =======================================
; Uploads the FM instrument from another song's voice bank.
;
;sub_D44
zSetVoiceUploadAlter:
		push	de							; Save de
		ld	a, (ix+zTrack.VoiceSongID)		; Get saved song ID for instrument data
		sub	81h								; Convert it to a zero-based index
		ld	c, zID_MusicPointers			; Value for music pointer table
		rst	GetPointerTable					; hl = pointer to music data
		rst	ReadPointer						; hl = pointer to music voice data
		ld	a, (ix+zTrack.VoiceIndex)		; Get voice index
		and	7Fh								; Strip sign bit
		ld	b, a							; b = voice index
		call	zGetFMInstrumentOffset		; hl = pointer to voice data
		jr	zSetVoiceDoUpload
; ---------------------------------------------------------------------------
;loc_D5A
zSetVoiceUpload:
		push	de							; Save de
		ld	b, a							; b = instrument index
		call	zGetFMInstrumentPointer		; hl = pointer to instrument data

zSetVoiceDoUpload:
		call	zSendFMInstrument			; Upload instrument data to YM2612
		pop	de								; Restore de
		ret
; End of function cfSetVoice
; ---------------------------------------------------------------------------
;loc_D64:
zSetVoicePSG:
		or	a								; Is the voice index positive?
		jp	p, cfStoreNewVoice				; Branch if yes
		inc	de								; Otherwise, advance song data pointer
		jp	cfStoreNewVoice
; ---------------------------------------------------------------------------

; =============== S U B	R O U T	I N E =======================================
; Turns on modulation on the channel.
;
; Has four 1-byte parameters: delay before modulation starts, modulation speed,
; modulation change per step, number of steps in modulation.
;
;loc_D6D
cfModulation:
		ld	(ix+zTrack.ModulationPtrLow), e		; Store low byte of modulation data pointer
		ld	(ix+zTrack.ModulationPtrHigh), d	; Store high byte of modulation data pointer
		ld	(ix+zTrack.ModulationCtrl), 80h	; Toggle modulation on
		inc	de								; Advance pointer...
		inc	de								; ... again...
		inc	de								; ... and again.
		ret

; =============== S U B	R O U T	I N E =======================================
; Sets modulation status according to parameter bytes.
;
; Has 2 1-byte parameters: the first byte is the new modulation state for PSG
; tracks, while the second byte is the new modulation state for FM tracks.
;
;loc_D7B
cfAlterModulation:
		inc	de								; Advance track pointer
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		jr	nz, cfSetModulation				; Branch if yes
		ld	a, (de)							; Get new modulation status

; =============== S U B	R O U T	I N E =======================================
; Sets modulation status.
;
; Has one parameter byte, the new modulation status.
;
;loc_D83
cfSetModulation:
		ld	(ix+zTrack.ModulationCtrl), a	; Set modulation status
		ret

; =============== S U B	R O U T	I N E =======================================
; Stops the current track.
;
; Technically, it has a parameter byte, but it is irrelevant and unused.
;
;loc_D87
cfStopTrack:
		res	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Clear 'track playing' flag
		call	zKeyOffIfActive				; Send key off for track channel
		call	zSilencePSGChannel			; Silence PSG channel
		ld	c, (ix+zTrack.VoiceControl)		; c = voice control bits
		push	ix							; Save track pointer
		call	zGetSFXChannelPointers		; ix = track pointer, hl = overridden track pointer
		ld	a, (zUpdatingSFX)				; Get flag
		or	a								; Are we updating SFX?
		jp	z, zStopCleanExit				; Exit if not
		push	hl							; Save hl
		ld	hl, (zVoiceTblPtr)				; hl = pointer to voice table
		pop	ix								; ix = overridden track's pointer
		res	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Clear 'SFX is overriding' bit
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG channel?
		jr	nz, zStopPSGTrack				; Branch if yes
		bit	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Is 'track playing' bit set?
		jr	z, zStopCleanExit				; Exit if not
		ld	a, ymFM3						; a = 2 (FM3)
		cp	(ix+zTrack.VoiceControl)		; Is this track for FM3?
		jr	nz, .not_fm3					; Branch if not
		ld	a, maskFM3Special|maskEnableLoadTimers	; FM3 settings: special mode, enable and load A/B
		bit	bitFM3Special, (ix+zTrack.PlaybackControl)	; Is FM3 in special mode?
		jr	nz, .do_fm3_settings			; Branch if yes
		and	maskFM3Normal|maskEnableLoadTimers	; FM3 settings: normal mode, enable and load A/B

.do_fm3_settings:
		call	zWriteFM3Settings			; Set the above FM3 settings

.not_fm3:
		ld	a, (ix+zTrack.VoiceIndex)		; Get FM instrument
		or	a								; Is it positive?
		jp	p, .switch_to_music				; Branch if yes
		call	zSetVoiceUploadAlter		; Upload the voice from another song's voice bank
		jr	.send_ssg_eg
; ---------------------------------------------------------------------------
.switch_to_music:
		ld	b, a							; b = FM instrument
		push	hl							; Save hl
		bankswitchToMusic					; Bank switch to song bank
		pop	hl								; Restore hl
		call	zGetFMInstrumentOffset		; hl = pointer to instrument data
		call	zSendFMInstrument.active	; Send FM instrument
		ld	a, zmake68kBank(SndBank)		; Get SFX bank
		bankswitch							; Bank switch to it
		ld	a, (ix+zTrack.HaveSSGEGFlag)	; Get custom SSG-EG flag
		or	a								; Does track have custom SSG-EG data?
		jp	p, zStopCleanExit				; Exit if not
		ld	e, (ix+zTrack.SSGEGPointerLow)	; e = low byte of pointer to SSG-EG data
		ld	d, (ix+zTrack.SSGEGPointerHigh)	; d = high byte of pointer to SSG-EG data

.send_ssg_eg:
		call	zSendSSGEGData				; Upload custom SSG-EG data

;loc_E22
zStopCleanExit:
		pop	ix								; Restore ix
		pop	hl								; Pop return value from stack
		pop	hl								; Pop another return value from stack
		ret
; ---------------------------------------------------------------------------
;loc_E27
zStopPSGTrack:
		bit	bitPSGNoise, (ix+zTrack.PlaybackControl)	; Is this a noise channel?
		jr	z, zStopCleanExit				; Exit if not
		ld	a, (ix+zTrack.PSGNoise)			; Get track's PSG noise setting
		or	a								; Is it an actual noise?
		jp	p, .skip_command				; Branch if not
		ld	(zPSG), a						; Send it to PSG

.skip_command:
		jr	zStopCleanExit

; =============== S U B	R O U T	I N E =======================================
; Change PSG noise to parameter, and silences PSG3 channel.
;
; Has one parameter byte: if zero, the channel is changed back to a normal PSG
; channel and the noise is silenced; if non-zero, it must be in the 0E0h-0E7h
; range, and sets the noise type to use (and sets the channel as being a noise
; channel).
;
;loc_E39
cfSetPSGNoise:
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		ret	z								; Return if not
		ld	(ix+zTrack.PSGNoise), a			; Store to track RAM
		set	bitPSGNoise, (ix+zTrack.PlaybackControl)	; Mark PSG track as being noise
		or	a								; Test noise value
		ld	a, snPSG3|snPSGVol|0Fh			; Command to silence PSG3
		jr	nz, .skip_noise_silence			; If nonzero, branch
		res	bitPSGNoise, (ix+zTrack.PlaybackControl)	; Otherwise, mark track as not being a noise channel
		ld	a, snNoise|snPSGVol|0Fh			; Command to silence the noise channel

.skip_noise_silence:
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is SFX overriding this track?
		ret	nz								; Return if yes
		ld	(zPSG), a						; Execute it
		ld	a, (de)							; Get PSG noise value
		ld	(zPSG), a						; Send command to PSG
		ret

; =============== S U B	R O U T	I N E =======================================
; Set PSG tone.
;
; Has one parameter byte, the new PSG tone to use.
;
;loc_E58
;cfSetPSGTone
cfSetPSGVolEnv:
		bit	bitIsPSG, (ix+zTrack.VoiceControl)	; Is this a PSG track?
		ret	z								; Return if not

;loc_E5D
cfStoreNewVoice:
		ld	(ix+zTrack.VoiceIndex), a		; Store voice
		ret

; =============== S U B	R O U T	I N E =======================================
; Jump to specified location.
;
; Has a 2-byte parameter, indicating target location for jump.
;
;loc_E61
cfJumpTo:
		ex	de, hl							; Exchange de and hl
		ld	e, (hl)							; e = low byte of target location
		inc	hl								; Advance pointer
		ld	d, (hl)							; d = high byte of target location
		dec	de								; Put destination byte back
		ret

; =============== S U B	R O U T	I N E =======================================
; Starts or stops pitch sliding. Ported from Battletoads driver.
;
; Has a single parameter byte: if nonzero enables pitch slide, disables otherwise.
cfPitchSlide:
		or	a								; Is parameter nonzero?
		jr	z, .disable_slide				; Branch if not
		set	bitPitchSlide, (ix+zTrack.PlaybackControl)	; Enable pitch slide
		ret
; ---------------------------------------------------------------------------
.disable_slide:
		res	bitNoAttack, (ix+zTrack.PlaybackControl)	; Clear 'don't attack' flag
		res	bitPitchSlide, (ix+zTrack.PlaybackControl)	; Stop pitch slide
		ld	(ix+zTrack.Detune), a			; Clear detune (we already know a is zero)
		ret

; =============== S U B	R O U T	I N E =======================================
; Loop section of music.
;
; Has four parameter bytes: a loop counter index (exactly like coord. flag 0EBh),
; a repeat count, and a 2-byte jump target.
;
;loc_E67
cfRepeatAtPos:
		inc	de								; Advance track pointer
		add	a, zTrack.LoopCounters			; Add offset into loop counters
		ld	c, a							; c = offset of current loop counter
		ld	b, 0							; bc = sign-extended offset to current loop counter
		push	ix							; Save track RAM pointer
		pop	hl								; hl = pointer to track RAM
		add	hl, bc							; hl = pointer in RAM to current loop counter
		ld	a, (hl)							; a = value of current loop counter
		or	a								; Is loop counter zero?
		jr	nz, .run_counter				; Branch if not
		ld	a, (de)							; Get repeat counter
		ld	(hl), a							; Reset loop counter to it

.run_counter:
		inc	de								; Advance track pointer
		dec	(hl)							; Decrement loop counter
		jp	nz, cfJumpTo					; Loop if it is nonzero
		inc	de								; Advance track pointer
		ret

; =============== S U B	R O U T	I N E =======================================
; Call subroutine. Stores current location on track-specific stack so that
; coord. flag 0F9h can be used to return to current location.
;
; Has one 2-byte parameter, the target subroutine's address.
;
;loc_E7E
cfJumpToGosub:
		ld	c, a							; c = low byte of target address
		inc	de								; Advance track pointer
		ld	a, (de)							; a = high byte of target address
		ld	b, a							; bc = target address
		push	bc							; Save bc
		push	ix							; Save ix
		pop	hl								; hl = pointer to track RAM
		dec	(ix+zTrack.StackPointer)		; Decrement track stack pointer
		ld	c, (ix+zTrack.StackPointer)		; c = track stack pointer
		dec	(ix+zTrack.StackPointer)		; Decrement track stack pointer again
		ld	b, 0							; b = 0
		add	hl, bc							; hl = offset of high byte of return address
		ld	(hl), d							; Store high byte of return address
		dec	hl								; Move pointer to target location
		ld	(hl), e							; Store low byte of return address
		pop	de								; de = jump target address
		dec	de								; Put back the byte
		ret

; =============== S U B	R O U T	I N E =======================================
; Returns from subroutine call. Does NOT check for stack overflows!
;
; Has no parameter bytes.
;
;loc_E98
cfJumpReturn:
		push	ix							; Save track RAM address
		pop	hl								; hl = pointer to track RAM
		ld	c, (ix+zTrack.StackPointer)		; c = offset to top of return stack
		ld	b, 0							; b = 0
		add	hl, bc							; hl = pointer to top of return stack
		ld	e, (hl)							; e = low byte of return address
		inc	hl								; Advance pointer
		ld	d, (hl)							; de = return address
		inc	(ix+zTrack.StackPointer)		; Pop byte from return stack
		inc	(ix+zTrack.StackPointer)		; Pop byte from return stack
		ret

; =============== S U B	R O U T	I N E =======================================
; Clears sign bit of modulation control, disabling normal modulation.
;
; Has no parameter bytes.
;
;loc_EAB
cfDisableModulation:
		res	7, (ix+zTrack.ModulationCtrl)	; Clear bit 7 of modulation control
		dec	de								; Put byte back
		ret

; =============== S U B	R O U T	I N E =======================================
; Adds a signed value to channel transposition.
;
; Has one parameter byte, the change in channel transposition.
;
;loc_EB1 cfAddKey
cfChangeTransposition:
		add	a, (ix+zTrack.Transpose)		; Add current transposition to parameter
		ld	(ix+zTrack.Transpose), a		; Store result as new transposition
		ret

; =============== S U B	R O U T	I N E =======================================
; If a continuous SFX is playing, it will continue playing from target address.
; A loop counter is decremented (it is initialized to number of SFX tracks)
; for continuous SFX; if the result is zero, the continuous SFX will be flagged
; to stop.
; Non-continuous SFX do not loop.
;
; Has a 2-byte parameter, the jump target address.
;
;loc_EB8
cfLoopContinuousSFX:
		ld	a, (zContinuousSFXFlag)			; Get 'continuous sound effect' flag
		or	a								; Is it set?
		jp	nz, .run_counter				; Branch if yes
		; If we got here, a is zero.
		ld	(zContinuousSFX), a				; Clear last continuous SFX played
		inc	de								; Skip a byte
		ret
; ---------------------------------------------------------------------------
.run_counter:
		ld	hl, zContSFXLoopCnt				; Get number loops to perform
		dec	(hl)							; Decrement it...
		jp	nz, cfJumpTo					; If result is non-zero, jump to target address
		xor	a								; a = 0
		ld	(zContinuousSFXFlag), a			; Clear continuous sound effect flag
		jp	cfJumpTo						; Jump to target address

; =============== S U B	R O U T	I N E =======================================
; Toggles alternate frequency mode according to parameter.
;
; Has a single byte parameter: is 1, enables alternate frequency mode, otherwise
; disables it.
;
;loc_EDA
;cfToggleAlternateSMPS
cfToggleAltFreqMode:
		or	a								; Is parameter equal to 0?
		jr	z, .stop_altfreq_mode			; Branch if so
		set	bitAltFreqMode, (ix+zTrack.PlaybackControl)	; Start alternate frequency mode for track
		ret
; ---------------------------------------------------------------------------
.stop_altfreq_mode:
		res	bitAltFreqMode, (ix+zTrack.PlaybackControl)	; Stop alternate frequency mode for track
		ret

; =============== S U B	R O U T	I N E =======================================
; If current track is FM3, it is put into special mode.
;
; It has 4 1-byte parameters: all of them are indexes into a lookup table of
; frequency shifts, and must be in the 0-7 range. Each parameter corresponds
; to one of the operators for channel 3.
;
;loc_EE8
cfFM3SpecialMode:
		ld	a, (ix+zTrack.VoiceControl)		; Get track's voice control
		cp	ymFM3							; Is this FM3?
		jr	nz, zTrackSkip3bytes			; Branch if not
		set	bitFM3Special, (ix+zTrack.PlaybackControl)	; Put FM3 in special mode
		ex	de, hl							; Exchange de and hl
		call	zGetSpecialFM3DataPointer	; de = pointer to saved FM3 frequency shifts
		ld	b, 4							; Loop counter: 4 parameter bytes

.loop:
		push	bc							; Save bc
		ld	a, (hl)							; Get parameter byte
		inc	hl								; Advance pointer
		push	hl							; Save hl
		ld	hl, zFM3FreqShiftTable			; hl = pointer to lookup table
		add	a, a							; Multiply a by 2
		ld	c, a							; c = a
		ld	b, 0							; b = 0
		add	hl, bc							; hl = offset into lookup table
		ldi									; *de++ = *hl++
		ldi									; *de++ = *hl++
		pop	hl								; Restore hl
		pop	bc								; Restore bc
		djnz	.loop						; Loop for all parameters

		ex	de, hl							; Exchange back de and hl
		dec	de								; Put back last byte
		ld	a, 4Fh							; FM3 settings: special mode, enable and load A/B

; =============== S U B	R O U T	I N E =======================================
; Set up FM3 special settings
;
; Input:   a    Settings for FM3
; Output:  c    Damaged
;sub_F11
zWriteFM3Settings:
		ld	c, a							; c = FM3 settings
		ld	a, ymTimerControlFm3Mode		; Write data to FM3 settings register
		jp	zWriteFMI						; Do it
; End of function zWriteFM3Settings

; =============== S U B	R O U T	I N E =======================================
; Eats 3 bytes from the song.
zTrackSkip3bytes:
		inc	de								; Advance pointer...
		inc	de								; ... again...
		inc	de								; ... and again.
		ret
; ---------------------------------------------------------------------------
; Frequency shift data used in cfFM3SpecialMode, above.
;loc_F1F
zFM3FreqShiftTable:
		dw    0, 132h, 18Eh, 1E4h, 234h, 27Eh, 2C2h, 2F0h

; =============== S U B	R O U T	I N E =======================================
; Meta coordination flag: the first parameter byte is an index into an extra
; coord. flag handler table.
;
; Has at least one parameter byte, the index into the jump table.
;
;loc_F2F
cfMetaCF:
		ld	hl, zExtraCoordFlagSwitchTable	; Load extra coordination flag switch table
		rst	PointerTableOffset				; hl = jump target for parameter
		inc	de								; Advance track pointer
		ld	a, (de)							; Get another parameter byte
		jp	(hl)							; Jump to coordination flag handler

; =============== S U B	R O U T	I N E =======================================
; Sets current tempo to parameter byte.
;
; Has one parameter byte, the new value for current tempo.
;
;loc_F36
cfSetTempo:
		ld	(zCurrentTempo), a				; Set current tempo to parameter
		ret

; =============== S U B	R O U T	I N E =======================================
; Plays another SFX.
;
; Has one parameter byte, the ID of what is to be played.
;
; DO NOT USE THIS TO PLAY THE SEGA PCM! It tampers with the stack pointer, and
; will wreak havok with the track update.
;
;loc_F3A:
cfPlaySFXByIndex:
		push	ix							; Save track pointer
		call	zPlaySFXByIndex				; Play sound specified by parameter
		pop	ix								; Restore track pointer
		ret

; =============== S U B	R O U T	I N E =======================================
; Plays another song.
;
; Has one parameter byte, the ID of what is to be played.
;
; DO NOT USE THIS TO PLAY THE SEGA PCM! It tampers with the stack pointer, and
; will wreak havok with the track update.
;
;loc_F3A:
cfPlayMusicByIndex:
		push	ix							; Save track pointer
		call	zPlaySoundByIndex			; Play sound specified by parameter
		pop	ix								; Restore track pointer
		ret

; =============== S U B	R O U T	I N E =======================================
; Halts or resumes all tracks according to parameter.
;
; Has one parameter byte, which is zero to resume all tracks and non-zero to
; halt them.
;
;loc_F42
cfHaltSound:
		ld	(zHaltFlag), a					; Set new mute flag
		or	a								; Is it set now?
		jr	z, .resume						; Branch if not
		push	ix							; Save ix
		push	de							; Save de
		ld	ix, zTracksStart				; Start of song RAM
		ld	b, zNumMusicTracks				; Number of tracks
		ld	de, zTrack.len					; Spacing between tracks

.loop1:
		res	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Clear 'track is playing' bit
		call	zKeyOff						; Stop current note
		add	ix, de							; Advance to next track
		djnz	.loop1						; Loop for all tracks
		pop	de								; Restore de
		pop	ix								; Restore ix
		jp	zPSGSilenceAll
; ---------------------------------------------------------------------------
.resume:
		push	ix							; Save ix
		push	de							; Save de
		ld	ix, zTracksStart				; Start of song RAM
		ld	b, zNumMusicTracks				; Number of tracks
		ld	de, zTrack.len					; Spacing between tracks

.loop2:
		set	bitTrackPlaying, (ix+zTrack.PlaybackControl)	; Set 'track is playing' bit
		add	ix, de							; Advance to next track
		djnz	.loop2						; Loop for all tracks
		pop	de								; Restore de
		pop	ix								; Restore ix
		ret

; =============== S U B	R O U T	I N E =======================================
; Copies data from selected location to current track. Playback will continue
; after the last byte copied.
;
; Has 3 parameter bytes, a 2-byte pointer to data to be copied and a 1-byte
; number of bytes to copy. The data is copied to the track's byte stream,
; starting after the parameters of this coord. flag, and will overwrite the data
; that what was there before. This likely will not work unless the song/SFX was
; copied to Z80 RAM in the first place.
;
;loc_F7D
cfCopyData:
		ex	de, hl							; Exchange de and hl
		ld	e, (hl)							; e = low byte of pointer to new song data
		inc	hl								; Advance track pointer
		ld	d, (hl)							; d = high byte of pointer to new song data
		inc	hl								; Advance track pointer
		ld	c, (hl)							; c = number of bytes to copy
		ld	b, 0							; b = 0
		inc	hl								; Advance track pointer
		ex	de, hl							; Exchange back de and hl
		ldir								; while (bc-- > 0) *de++ = *hl++;
		dec	de								; Put back last byte
		ret

; =============== S U B	R O U T	I N E =======================================
; Sets tempo divider for all tracks. Does not take effect until the next note
; duration is set.
;
; Has one parameter, the new tempo divider.
;
;loc_F8B
cfSetTempoDivider:
		ld	b, zNumMusicTracks				; Number of tracks
		ld	hl, zTracksStart+zTrack.TempoDivider	; Want to change tempo dividers

.loop:
		push	bc							; Save bc
		ld	bc, zTrack.len					; Spacing between tracks
		ld	(hl), a							; Set tempo divider for track
		add	hl, bc							; Advance to next track
		pop	bc								; Restore bc
		djnz	.loop
		ret

; =============== S U B	R O U T	I N E =======================================
; Sets SSG-EG data for current track.
;
; Has 4 parameter bytes, the operator parameters for SSG-EG data desired.
;
;loc_F9A
cfSetSSGEG:
		ld	(ix+zTrack.HaveSSGEGFlag), 80h	; Set custom SSG-EG data flag
		ld	(ix+zTrack.SSGEGPointerLow), e	; Save low byte of SSG-EG data pointer
		ld	(ix+zTrack.SSGEGPointerHigh), d	; Save high byte of SSG-EG data pointer

; =============== S U B	R O U T	I N E =======================================
; Sends SSG-EG data pointed to by de to appropriate registers in YM2612.
;
;sub_FA4
zSendSSGEGData:
		; This fix is even better than what is done in Ristar's sound driver:
		; we preserve rate scaling, whereas that driver sets it to 0.
		ld	l, (ix+zTrack.TLPtrLow)			; l = low byte of pointer to TL data
		ld	h, (ix+zTrack.TLPtrHigh)		; hl = pointer to TL data
		ld	bc, zFMInstrumentRSARTable-zFMInstrumentTLTable	; bc = -10h
		add	hl, bc							; hl = pointer to RS/AR data
		push	hl							; Save hl (**)
		ld	hl, zFMInstrumentSSGEGTable		; hl = pointer to registers for SSG-EG data
		ld	b, zFMInstrumentSSGEGTable_End-zFMInstrumentSSGEGTable	; Number of entries

.loop:
		ld	a, (de)							; Get data to sent to SSG-EG register
		inc	de								; Advance pointer
		ld	c, a							; c = data to send
		ld	a, (hl)							; a = register to send to
		call	zWriteFMIorII				; Send data to correct channel
		ex	(sp), hl						; Save hl, hl = pointer to RS/AR data (see line marked (**) above)
		ld	a, (hl)							; a = RS/AR value for operator
		inc	hl								; Advance pointer
		ex	(sp), hl						; Save hl, hl = pointer to registers for SSG-EG data
		or	maxAttackRate					; Set AR to maximum, but keep RS intact
		ld	c, a							; c = RS/AR
		ld	a, (hl)							; a = register to send to
		sub	ymSSGEG1-ymRateScaleAttackRate1	; Convert into command to set RS/AR
		inc	hl								; Advance pointer
		call	zWriteFMIorII				; Send data to correct channel
		djnz	.loop						; Loop for all registers
		pop	hl								; Remove from stack (see line marked (**) above)
		dec	de								; Rewind data pointer a bit
		ret
; End of function zSendSSGEGData

; =============== S U B	R O U T	I N E =======================================
; Starts or controls FM volume envelope effects, according to the parameters.
;
; Has two parameter bytes: the first is a (1-based) index into the PSG envelope
; table indicating how the envelope should go, while the second is a bitmask
; indicating which operators should be affected (in the form %00004231) for
; the current channel.
;
;loc_FB5
;cfFMFlutter
cfFMVolEnv:
		ld	(ix+zTrack.FMVolEnv), a			; Store envelope index
		inc	de								; Advance track pointer
		ld	a, (de)							; Get envelope mask
		ld	(ix+zTrack.FMVolEnvMask), a		; Store envelope bitmask
		ret

; =============== S U B	R O U T	I N E =======================================
; Resets spindash rev counter.
;
; Has no parameter bytes.
;
;loc_FBE
cfResetSpindashRev:
		xor	a								; a = 0
		ld	(zSpindashRev), a				; Reset spindash rev
		dec	de								; Put byte back
		ret

; =============== S U B	R O U T	I N E =======================================
; Sets tempo divider of a single track.
;
; Has one parameter, the new tempo divider.
;
cfChanSetTempoDivider:
		ld	(ix+zTrack.TempoDivider), a		; Set tempo divider for this track
		ret

; =============== S U B	R O U T	I N E =======================================
; Sends an FM command to the YM2612. The command is sent to the adequate part
; for the current track, so it is only appropriate for those registers that
; affect specific channels.
;
; Has 2 parameter bytes: a 1-byte register selector and a 1-byte register data.
;
;loc_D21
cfChanFMCommand:
		call	zGetFMParams				; Get parameters for FM command
		jp	zWriteFMIorII					; Send it to YM2612
; End of function cfChanFMCommand

; =============== S U B	R O U T	I N E =======================================
; Updates a PSG track.
;
; Input:   ix    Pointer to track RAM
;
;loc_FC4
zUpdatePSGTrack:
		dec	(ix+zTrack.DurationTimeout)		; Run note timer
		jr	nz, .note_going					; Branch if note hasn't expired yet
		call	zGetNextNote				; Get next note for PSG track
		bit	bitTrackAtRest, (ix+zTrack.PlaybackControl)	; Is track resting?
		ret	nz								; Return if yes
		call	zPrepareModulation			; Initialize modulation
		jr	.skip_fill
; ---------------------------------------------------------------------------
.note_going:
		ld	a, (ix+zTrack.NoteFillTimeout)	; Get note fill
		or	a								; Has timeout expired?
		jr	z, .skip_fill					; Branch if yes
		dec	(ix+zTrack.NoteFillTimeout)		; Update note fill
		jp	z, zRestTrack					; Put PSG track at rest if needed

.skip_fill:
		call	zDoPitchSlide				; Apply pitch slide and detune
		call	zDoModulation				; Do modulation
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is SFX overriding this track?
		ret	nz								; Return if yes
		ld	c, (ix+zTrack.VoiceControl)		; c = voice control byte
		ld	a, l							; a = low byte of new frequency
		and	0Fh								; Get only lower nibble
		or	c								; OR in PSG channel bits
		ld	(zPSG), a						; Send to PSG, latching register
		ld	a, l							; a = low byte of new frequency
		and	0F0h							; Get high nibble now
		or	h								; OR in the high byte of the new frequency
		; Swap nibbles
		rrca
		rrca
		rrca
		rrca
		ld	(zPSG), a						; Send to PSG, to latched register
		ld	a, (ix+zTrack.VoiceIndex)		; Get PSG tone
		or	a								; Test if it is zero
		ld	c, 0							; c = 0
		jr	z, .no_volenv					; Branch if no PSG tone
		dec	a								; Make it into a 0-based index
		ld	c, zID_VolEnvPointers			; Value for volume envelope pointer table
		rst	GetPointerTable					; hl = pointer to volume envelope for track
		call	zDoVolEnv					; Get new volume envelope
		ld	c, a							; c = new volume envelope

.no_volenv:
		bit	bitTrackAtRest, (ix+zTrack.PlaybackControl)	; Is track resting?
		ret	nz								; Return if yes
		ld	a, c							; Copy volume attenuation
		call	zDoPSGVolumeClamp			; Add track's current volume and clamp
		or	(ix+zTrack.VoiceControl)		; Mask in the PSG channel bits
		add	a, snPSGVol						; Flag to latch volume
		bit	bitPSGNoise, (ix+zTrack.PlaybackControl)	; Is this a noise channel?
		jr	z, .not_noise					; Branch if not
		add	a, snNoise-snPSG3				; Change to noise channel

.not_noise:
		ld	(zPSG), a						; Set channel volume
		ret
; ---------------------------------------------------------------------------
;loc_1037
;zDoFlutterSetValue
zDoVolEnvSetValue:
		ld	(ix+zTrack.VolEnv), a			; Set new value for PSG envelope index and fall through

; =============== S U B	R O U T	I N E =======================================
; Get next PSG volume envelope value.
;
; Input:   ix    Pointer to track RAM
;          hl    Pointer to current PSG volume envelope
; Output:  a     New volume envelope value
;          bc    Trashed
;
;sub_103A
;zDoFlutter
zDoVolEnv:
		push	hl							; Save hl
		ld	c, (ix+zTrack.VolEnv)			; Get current PSG envelope index
		ld	b, 0							; b = 0
		add	hl, bc							; Offset into PSG envelope table
		; Fix based on similar code from Space Harrier II's sound driver.
		; This is better than the previous fix, which was based on Ristar's driver.
		ld	c, l
		ld	b, h
		ld	a, (bc)							; a = PSG volume envelope
		pop	hl								; Restore hl
		bit	7, a							; Is it a terminator?
		jr	z, zDoVolEnvAdvance				; Branch if not
		cp	VolEnvRestTrack					; Is it a command to set rest flag on PSG channel?
		jr	z, zDoVolEnvRest				; Branch if yes
		cp	VolEnvReset						; Is it a command to reset envelope?
		jr	z, zDoVolEnvReset				; Branch if yes
		cp	VolEnvStopTrack					; Is it a command to put PSG channel to rest?
		jr	z, zDoVolEnvFullRest			; Branch if yes
		jr	nc, zDoVolEnvAdvance			; Branch if more than 83h
		; Only 82h can get here.
		inc	bc								; Increment envelope position
		ld	a, (bc)							; Get next byte from volume envelope
		jr	zDoVolEnvSetValue				; Use this as new envelope index
; ---------------------------------------------------------------------------
;loc_1057
;zDoFlutterFullRest
zDoVolEnvFullRest:
		pop	hl								; Pop return value from stack (causes a 'ret' to return to caller of zUpdatePSGTrack)
		jp	zRestTrack						; Put track at rest
; ---------------------------------------------------------------------------
;loc_105F
;zDoFlutterReset
zDoVolEnvReset:
		xor	a								; a = 0
		jr	zDoVolEnvSetValue
; ---------------------------------------------------------------------------
;loc_1062
;zDoFlutterRest
zDoVolEnvRest:
		pop	hl								; Pop return value from stack (causes a 'ret' to return to caller of zUpdatePSGTrack)
		set	bitTrackAtRest, (ix+zTrack.PlaybackControl)	; Set 'track is resting' bit
		ret									; Do NOT silence PSG channel
; ---------------------------------------------------------------------------
;loc_1068
;zDoFlutterAdvance
zDoVolEnvAdvance:
		inc	(ix+zTrack.VolEnv)				; Advance envelope
		ret
; End of function zDoVolEnv


; =============== S U B	R O U T	I N E =======================================
;
;sub_106C
zRestTrack:
		set	bitTrackAtRest, (ix+zTrack.PlaybackControl)	; Set 'track is resting' bit
		bit	bitSFXOverride, (ix+zTrack.PlaybackControl)	; Is SFX overriding this track?
		ret	nz								; Return if so
; End of function zRestTrack


; =============== S U B	R O U T	I N E =======================================
;
;sub_1075
zSilencePSGChannel:
		ld	a, snPSGVol|0Fh					; Set volume to zero on PSG channel
		add	a, (ix+zTrack.VoiceControl)		; Add in the PSG channel selector
		or	a								; Is it an actual PSG channel?
		ret	p								; Return if not
		ld	(zPSG), a						; Silence this channel
		cp	snPSG3|snPSGVol|0Fh				; Was this PSG3/Noise?
		ret	nz								; Return if not
		ld	a, snNoise|snPSGVol|0Fh			; Command to silence Noise channel
		ld	(zPSG), a						; Do it
		ret
; End of function zSilencePSGChannel


; =============== S U B	R O U T	I N E =======================================
;
; Plays digital audio on the DAC, if any is queued. The z80 will be stuck in
; this function unless an interrupt occurs (that is, V-Int); after the V-Int
; is processed, the z80 will return back here.
;loc_108A
zPlayDigitalAudio:
		di									; Disable interrupts
		ld	a, ymDACEnable					; DAC enable/disable register
		ld	c, maskDACDisable				; Value to disable DAC
		call	zWriteFMI					; Send YM2612 command
		ld	hl, zSongFM6					; Get pointer to FM6 track
		ld	a, (zDACEnable)					; Get DAC enable
		or	a								; Is DAC supposed to be enabled?
		jr	z, .enabletrack					; Branch if not
		ld	hl, zSongDAC					; Get pointer to DAC track
		; Don't allow music DAC to be re-enabled by DAC SFX ending during fading
		ld	a, (zFadeInTimeout)				; Get fading timeout
		or	a								; Is music being faded?
		jr	nz, .dac_idle_loop				; Branch if yes

.enabletrack:
		res	bitSFXOverride, (hl)			; Mark track as no longer being overridden

.dac_idle_loop:
		ei									; Enable interrupts
		ld	a, (PlaySegaPCMFlag)			; a = play SEGA PCM flag
		or	a								; Is SEGA sound being played?
		jp	nz, zPlaySEGAPCM				; Branch if yes
		ld	a, (zDACIndex)					; a = DAC index/flag
		or	a								; Is DAC channel being used?
		jr	z, .dac_idle_loop				; Loop if not
		ld	a, ymDACEnable					; DAC enable/disable register
		ld	c, maskDACEnable				; Value to enable DAC
		di									; Disable interrupts
		call	zWriteFMI					; Send YM2612 command
		ei									; Re-enable interrupts
		ld	iy, DecTable					; iy = pointer to jman2050 decode lookup table
		ld	hl, zDACIndex					; hl = pointer to DAC index/flag
		ld	a, (hl)							; a = DAC index
		dec	a								; a -= 1
		set	7, (hl)							; Set bit 7 to indicate that DAC sample is being played
		ld	hl, zmake68kPtr(DACPointers)	; hl = pointer to ROM window
		ld	c, a
		ld	b, 0
		add	hl, bc
		add	hl, bc
		add	hl, bc
		add	hl, bc
		add	hl, bc
		ld	c, 80h							; c is an accumulator below; this initializes it to 80h
		ld	a, (hl)							; a = DAC rate
		ld	(.sample1_rate+1), a			; Store into following instruction (self-modifying code)
		ld	(.sample2_rate+1), a			; Store into following instruction (self-modifying code)
		inc	hl								; hl = pointer to low byte of DAC sample's length
		ld	e, (hl)							; e = low byte of DAC sample's length
		inc	hl								; hl = pointer to high byte of DAC sample's length
		ld	d, (hl)							; d = high byte of DAC sample's length
		inc	hl								; hl = pointer to low byte of DAC sample's in-bank location
		ld	a, (hl)							; a = low byte of DAC sample's in-bank location
		inc	hl								; hl = pointer to high byte of DAC sample's in-bank location
		ld	h, (hl)							; h = high byte of DAC sample's in-bank location
		ld	l, a							; l = low byte of DAC sample's in-bank location
		; hl is now pointer to DAC data, while de is the DAC sample's length

.dac_playback_loop:
.sample1_rate:
		ld	b, 0Ah							; self-modified code; b is set to DAC rate
		ei									; Enable interrupts
		djnz	$							; Loop in this instruction, decrementing b each iteration, until b = 0

		di									; Disable interrupts
		ld	a, ymDACPCM						; DAC channel register
		ld	(zYM2612_A0), a					; Send to YM2612
		ld	a, (hl)							; a = next byte of DAC sample
		; Want only the high nibble now, so shift it into position
		rlca
		rlca
		rlca
		rlca
		and	0Fh								; Get only low nibble (which was the high nibble originally)
		ld	(.sample1_index+2), a			; Store into following instruction (self-modifying code)
		ld	a, c							; a = c

.sample1_index:
		add	a, (iy+0)						; Self-modified code: the index offset is not zero, but what was set above
		ld	(zYM2612_D0), a					; Send byte to DAC
		ld	c, a							; Set c to the new value of a

.sample2_rate:
		ld	b, 0Ah							; self-modified code; b is set to DAC rate
		ei									; Enable interrupts
		djnz	$							; Loop in this instruction, decrementing b each iteration, until b = 0

		di									; Disable interrupts
		ld	a, ymDACPCM						; DAC channel register
		ld	(zYM2612_A0), a					; Send to YM2612
		ld	a, (hl)							; a = next byte of DAC sample
		and	0Fh								; Want only the low nibble
		ld	(.sample2_index+2), a			; Store into following instruction (self-modifying code)
		ld	a, c							; a = c

.sample2_index:
		add	a, (iy+0)						; Self-modified code: the index offset is not zero, but what was set above
		ld	(zYM2612_D0), a					; Send byte to DAC
		ei									; Enable interrupts
		ld	c, a							; Set c to the new value of a
		ld	a, (zDACIndex)					; a = DAC index/flag
		or	a								; Is playing flag set?
		jp	p, .dac_idle_loop				; Branch if not

		inc	hl								; Advance to next sample byte
		dec	de								; Mark one byte as being done
		ld	a, d							; a = d
		or	e								; Is length zero?
		jp	nz, .dac_playback_loop			; Loop if not

		xor	a								; a = 0
		ld	(zDACIndex), a					; Mark DAC as being idle
		ld	(zSongDAC.DACSFXPlaying),a
		jp	zPlayDigitalAudio				; Loop
; ---------------------------------------------------------------------------
; ===========================================================================
; JMan2050's DAC decode lookup table
; ===========================================================================
DecTable:
		db	   0,  1,   2,   4,   8,  10h,  20h,  40h
		db	 80h, -1,  -2,  -4,  -8, -10h, -20h, -40h
; ---------------------------------------------------------------------------

; =============== S U B	R O U T	I N E =======================================
;
; Plays the SEGA PCM sound. The z80 will be "stuck" in this function (as it
; disables interrupts) until either of the following conditions hold:
;
;	(1)	The SEGA PCM is fully played
;	(2)	The next song to play is 0FEh (MusID_StopSega)
;loc_1126
zPlaySEGAPCM:
		di									; Disable interrupts
		xor	a								; a = 0
		ld	(PlaySegaPCMFlag), a			; Clear flag
		ld	a, ymDACEnable					; DAC enable/disable register
		ld	(zYM2612_A0), a					; Select the register
		nop									; Delay
		ld	a, maskDACEnable				; Value to enable DAC
		ld	(zYM2612_D0), a					; Enable DAC
		ld	a, zmake68kBank(SEGA_PCM)		; a = sound bank index
		bankswitchLoop						; Bank switch to sound bank
		ld	hl, zmake68kPtr(SEGA_PCM)		; hl = pointer to SEGA PCM
		ld	de, SEGA_PCM_End-SEGA_PCM		; de = length of SEGA PCM
		ld	a, ymDACPCM						; DAC channel register
		ld	(zYM2612_A0), a					; Send to YM2612
		nop									; Delay

.loop:
		ld	a, (hl)							; a = next byte of SEGA PCM
		ld	(zYM2612_D0), a					; Send to DAC
		ld	a, (zMusicNumber)				; Check next song number
		cp	MusID_StopSega					; Is it the command to stop playing SEGA PCM?
		jr	z, .done						; Break the loop if yes
		nop
		nop

		ld	b, 0Ah							; Loop counter
		djnz	$							; Loop in this instruction, decrementing b each iteration, until b = 0

		inc	hl								; Advance to next byte of SEGA PCM
		dec	de								; Mark one byte as being done
		ld	a, d							; a = d
		or	e								; Is length zero?
		jr	nz, .loop						; Loop if not

.done:
		jp	zPlayDigitalAudio				; Go back to normal DAC code
; ---------------------------------------------------------------------------
; ===========================================================================
; DAC BANKS
; ===========================================================================
; Note: this table has a dummy first entry for the case when there is no DAC
; sample being played -- the code still results in a valid bank switch, and
; does not need to worry about special cases.
DAC_Banks:
; Set to zero to not use S3/S&K DAC samples:
	if (use_s3_samples<>0)||(use_sk_samples<>0)||(use_s3d_samples<>0)
		db	zmake68kBank(DacBank1)
	else
		db	zmake68kBank(DacBank4)
	endif
	if (use_s3_samples<>0)||(use_sk_samples<>0)||(use_s3d_samples<>0)
		db	zmake68kBank(DAC_81_Data)
		db	zmake68kBank(DAC_82_83_84_85_Data)
		db	zmake68kBank(DAC_82_83_84_85_Data)
		db	zmake68kBank(DAC_82_83_84_85_Data)
		db	zmake68kBank(DAC_82_83_84_85_Data)
		db	zmake68kBank(DAC_86_Data)
		db	zmake68kBank(DAC_87_Data)
		db	zmake68kBank(DAC_88_Data)
		db	zmake68kBank(DAC_89_Data)
		db	zmake68kBank(DAC_8A_8B_Data)
		db	zmake68kBank(DAC_8A_8B_Data)
		db	zmake68kBank(DAC_8C_Data)
		db	zmake68kBank(DAC_8D_8E_Data)
		db	zmake68kBank(DAC_8D_8E_Data)
		db	zmake68kBank(DAC_8F_Data)
		db	zmake68kBank(DAC_90_91_92_93_Data)
		db	zmake68kBank(DAC_90_91_92_93_Data)
		db	zmake68kBank(DAC_90_91_92_93_Data)
		db	zmake68kBank(DAC_90_91_92_93_Data)
		db	zmake68kBank(DAC_94_95_96_97_Data)
		db	zmake68kBank(DAC_94_95_96_97_Data)
		db	zmake68kBank(DAC_94_95_96_97_Data)
		db	zmake68kBank(DAC_94_95_96_97_Data)
		db	zmake68kBank(DAC_98_99_9A_Data)
		db	zmake68kBank(DAC_98_99_9A_Data)
		db	zmake68kBank(DAC_98_99_9A_Data)
		db	zmake68kBank(DAC_9B_Data)
		db	zmake68kBank(DAC_9C_Data)
		db	zmake68kBank(DAC_9D_Data)
		db	zmake68kBank(DAC_9E_Data)
	endif
	if (use_s3_samples<>0)||(use_sk_samples<>0)
		db	zmake68kBank(DAC_9F_Data)
		db	zmake68kBank(DAC_A0_Data)
		db	zmake68kBank(DAC_A1_Data)
		db	zmake68kBank(DAC_A2_Data)
		db	zmake68kBank(DAC_A3_Data)
		db	zmake68kBank(DAC_A4_Data)
		db	zmake68kBank(DAC_A5_Data)
		db	zmake68kBank(DAC_A6_Data)
		db	zmake68kBank(DAC_A7_Data)
		db	zmake68kBank(DAC_A8_Data)
		db	zmake68kBank(DAC_A9_Data)
		db	zmake68kBank(DAC_AA_Data)
		db	zmake68kBank(DAC_AB_Data)
		db	zmake68kBank(DAC_AC_Data)
		db	zmake68kBank(DAC_AD_AE_Data)
		db	zmake68kBank(DAC_AD_AE_Data)
		db	zmake68kBank(DAC_AF_B0_Data)
		db	zmake68kBank(DAC_AF_B0_Data)
		db	zmake68kBank(DAC_B1_Data)
		db	zmake68kBank(DAC_B2_B3_Data)
		db	zmake68kBank(DAC_B2_B3_Data)
		db	zmake68kBank(DAC_B4_C1_C2_C3_C4_Data)
		db	zmake68kBank(DAC_B5_Data)
		db	zmake68kBank(DAC_B6_Data)
		db	zmake68kBank(DAC_B7_Data)
		db	zmake68kBank(DAC_B8_B9_Data)
		db	zmake68kBank(DAC_B8_B9_Data)
		db	zmake68kBank(DAC_BA_Data)
		db	zmake68kBank(DAC_BB_Data)
		db	zmake68kBank(DAC_BC_Data)
		db	zmake68kBank(DAC_BD_Data)
		db	zmake68kBank(DAC_BE_Data)
		db	zmake68kBank(DAC_BF_Data)
		db	zmake68kBank(DAC_C0_Data)
		db	zmake68kBank(DAC_B4_C1_C2_C3_C4_Data)
		db	zmake68kBank(DAC_B4_C1_C2_C3_C4_Data)
		db	zmake68kBank(DAC_B4_C1_C2_C3_C4_Data)
		db	zmake68kBank(DAC_B4_C1_C2_C3_C4_Data)
	endif
	if (use_s2_samples<>0)
		db	zmake68kBank(DAC_C5_Data)
		db	zmake68kBank(DAC_C6_Data)
		db	zmake68kBank(DAC_C7_Data)
		db	zmake68kBank(DAC_C8_Data)
		db	zmake68kBank(DAC_C9_CC_CD_CE_CF_Data)
		db	zmake68kBank(DAC_CA_D0_D1_D2_Data)
		db	zmake68kBank(DAC_CB_D3_D4_D5_Data)
		db	zmake68kBank(DAC_C9_CC_CD_CE_CF_Data)
		db	zmake68kBank(DAC_C9_CC_CD_CE_CF_Data)
		db	zmake68kBank(DAC_C9_CC_CD_CE_CF_Data)
		db	zmake68kBank(DAC_C9_CC_CD_CE_CF_Data)
		db	zmake68kBank(DAC_CA_D0_D1_D2_Data)
		db	zmake68kBank(DAC_CA_D0_D1_D2_Data)
		db	zmake68kBank(DAC_CA_D0_D1_D2_Data)
		db	zmake68kBank(DAC_CB_D3_D4_D5_Data)
		db	zmake68kBank(DAC_CB_D3_D4_D5_Data)
		db	zmake68kBank(DAC_CB_D3_D4_D5_Data)
	endif
	if (use_s3d_samples<>0)
		db	zmake68kBank(DAC_D6_Data)
		db	zmake68kBank(DAC_D7_Data)
	endif
	if (use_s3_samples<>0)
		db	zmake68kBank(DAC_D8_D9_Data)
		db	zmake68kBank(DAC_D8_D9_Data)
	endif
; ---------------------------------------------------------------------------
; ===========================================================================
; Pointers
; ===========================================================================
z80_SoundDriverPointers:
		dw	zmake68kPtr(MusicPointers)
		dw	zmake68kPtr(SFXPointers)
		dw	z80_ModEnvPointers
		dw	z80_VolEnvPointers
; ---------------------------------------------------------------------------
; ===========================================================================
; Modulation Envelope Pointers
; ===========================================================================
;z80_FreqFlutterPointers
z80_ModEnvPointers:
		dw	ModEnv_00
		dw	ModEnv_01
		dw	ModEnv_02
		dw	ModEnv_03
		dw	ModEnv_04
		dw	ModEnv_05
		dw	ModEnv_06
		dw	ModEnv_07
ModEnv_01:	db    0
ModEnv_00:	db    1,   2,   1,   0,  -1,  -2,  -3,  -4,  -3,  -2,  -1, ModEnvSustain
ModEnv_02:	db    0,   0,   0,   0, 13h, 26h, 39h, 4Ch, 5Fh, 72h, 7Fh, 72h, ModEnvSustain
ModEnv_03:	db    1,   2,   3,   2,   1,   0,  -1,  -2,  -3,  -2,  -1,   0, ModEnvJumpTo,   0
ModEnv_04:	db    0,   0,   1,   3,   1,   0,  -1,  -3,  -1,   0, ModEnvJumpTo,   2
ModEnv_05:	db    0,   0,   0,   0,   0, 0Ah, 14h, 1Eh, 14h, 0Ah,   0, -10, -20, -30, -20, -10
	db  ModEnvJumpTo,   4
ModEnv_06:	db    0,   0,   0,   0, 16h, 2Ch, 42h, 2Ch, 16h,   0, -22, -44, -66, -44, -22
	db    ModEnvJumpTo, 3
ModEnv_07:	db    1,   2,   3,   4,   3,   2,   1,   0,  -1,  -2,  -3,  -4,  -3,  -2,  -1,   0
	db  ModEnvJumpTo,   1
; ---------------------------------------------------------------------------
; ===========================================================================
; Volume Envelope Pointers
; ===========================================================================
;z80_PSGTonePointers
z80_VolEnvPointers:
		dw		VolEnv_00,VolEnv_01,VolEnv_02,VolEnv_03,VolEnv_04,VolEnv_05
		dw		VolEnv_06,VolEnv_07,VolEnv_08,VolEnv_09,VolEnv_0A,VolEnv_0B
		dw		VolEnv_0C,VolEnv_0D,VolEnv_0E,VolEnv_0F,VolEnv_10,VolEnv_11
		dw		VolEnv_12,VolEnv_13,VolEnv_14,VolEnv_15,VolEnv_16,VolEnv_17
		dw		VolEnv_18,VolEnv_19,VolEnv_1A,VolEnv_1B,VolEnv_1C,VolEnv_1D
		dw		VolEnv_1E,VolEnv_1F,VolEnv_20,VolEnv_21,VolEnv_22,VolEnv_23
		dw		VolEnv_24,VolEnv_25,VolEnv_26,VolEnv_27,VolEnv_28,VolEnv_29
		dw		VolEnv_2A,VolEnv_2B,VolEnv_2C,VolEnv_2D,VolEnv_2E,VolEnv_2F
		dw		VolEnv_30,VolEnv_31,VolEnv_32,VolEnv_33
VolEnv_00:	db    2, VolEnvStopTrack
VolEnv_01:
VolEnv_0E:	db    0,   2,   4,   6,   8, 10h, VolEnvStopTrack
VolEnv_02:	db    2,   1,   0,   0,   1,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2
	db    2,   3,   3,   3,   4,   4,   4,   5, VolEnvRestTrack
VolEnv_03:	db    0,   0,   2,   3,   4,   4,   5,   5,   5,   6,   6, VolEnvRestTrack
VolEnv_04:	db    3,   0,   1,   1,   1,   2,   3,   4,   4,   5, VolEnvRestTrack
VolEnv_05:	db    0,   0,   1,   1,   2,   3,   4,   5,   5,   6,   8,   7,   7,   6, VolEnvRestTrack
VolEnv_06:	db    1, 0Ch,   3, 0Fh,   2,   7,   3, 0Fh, VolEnvReset
VolEnv_07:	db    0,   0,   0,   2,   3,   3,   4,   5,   6,   7,   8,   9, 0Ah, 0Bh, 0Eh, 0Fh
	db  VolEnvStopTrack
VolEnv_08:	db    3,   2,   1,   1,   0,   0,   1,   2,   3,   4, VolEnvRestTrack
VolEnv_09:	db    1,   0,   0,   0,   0,   1,   1,   1,   2,   2,   2,   3,   3,   3,   3,   4
	db    4,   4,   5,   5, VolEnvRestTrack
VolEnv_0A:	db  10h, 20h, 30h, 40h, 30h, 20h, 10h,   0,-10h, VolEnvReset
VolEnv_0B:	db    0,   0,   1,   1,   3,   3,   4,   5, VolEnvStopTrack
VolEnv_0C:	db    0, VolEnvRestTrack
VolEnv_0D:	db    2, VolEnvStopTrack
VolEnv_0F:	db    9,   9,   9,   8,   8,   8,   7,   7,   7,   6,   6,   6,   5,   5,   5,   4
	db    4,   4,   3,   3,   3,   2,   2,   2,   1,   1,   1,   0,   0,   0, VolEnvRestTrack
VolEnv_10:	db    1,   1,   1,   0,   0,   0, VolEnvRestTrack
VolEnv_11:	db    3,   0,   1,   1,   1,   2,   3,   4,   4,   5, VolEnvRestTrack
VolEnv_12:	db    0,   0,   1,   1,   2,   3,   4,   5,   5,   6,   8,   7,   7,   6, VolEnvRestTrack
VolEnv_13:	db  0Ah,   5,   0,   4,   8, VolEnvStopTrack
VolEnv_14:	db    0,   0,   0,   2,   3,   3,   4,   5,   6,   7,   8,   9, 0Ah, 0Bh, 0Eh, 0Fh
	db  VolEnvStopTrack
VolEnv_15:	db    3,   2,   1,   1,   0,   0,   1,   2,   3,   4, VolEnvRestTrack
VolEnv_16:	db    1,   0,   0,   0,   0,   1,   1,   1,   2,   2,   2,   3,   3,   3,   3,   4
	db    4,   4,   5,   5, VolEnvRestTrack
VolEnv_17:	db  10h, 20h, 30h, 40h, 30h, 20h, 10h,   0, VolEnvReset
VolEnv_18:	db    0,   0,   1,   1,   3,   3,   4,   5, VolEnvStopTrack
VolEnv_19:	db    0,   2,   4,   6,   8, 16h, VolEnvStopTrack
VolEnv_1A:	db    0,   0,   1,   1,   3,   3,   4,   5, VolEnvStopTrack
VolEnv_1B:	db    4,   4,   4,   4,   3,   3,   3,   3,   2,   2,   2,   2,   1,   1,   1,   1
	db  VolEnvStopTrack
VolEnv_1C:	db    0,   0,   0,   0,   1,   1,   1,   1,   2,   2,   2,   2,   3,   3,   3,   3
	db    4,   4,   4,   4,   5,   5,   5,   5,   6,   6,   6,   6,   7,   7,   7,   7
	db    8,   8,   8,   8,   9,   9,   9,   9, 0Ah, 0Ah, 0Ah, 0Ah, VolEnvRestTrack
VolEnv_1D:	db    0, 0Ah, VolEnvStopTrack
VolEnv_1E:	db    0,   2,   4, VolEnvRestTrack
VolEnv_1F:	db  30h, 20h, 10h,   0,   0,   0,   0,   0,   8, 10h, 20h, 30h, VolEnvRestTrack
VolEnv_20:	db    0,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   6,   6,   6,   8,   8
	db  0Ah, VolEnvStopTrack
VolEnv_21:	db    0,   2,   3,   4,   6,   7, VolEnvRestTrack
VolEnv_22:	db    2,   1,   0,   0,   0,   2,   4,   7, VolEnvRestTrack
VolEnv_23:	db  0Fh,   1,   5, VolEnvStopTrack
VolEnv_24:	db    8,   6,   2,   3,   4,   5,   6,   7,   8,   9, 0Ah, 0Bh, 0Ch, 0Dh, 0Eh, 0Fh
	db  10h, VolEnvStopTrack
VolEnv_25:	db    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   1
	db    1,   1,   1,   1,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   3,   3
	db    3,   3,   3,   3,   3,   3,   3,   3,   4,   4,   4,   4,   4,   4,   4,   4
	db    4,   4,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   6,   6,   6,   6
	db    6,   6,   6,   6,   6,   6,   7,   7,   7,   7,   7,   7,   7,   7,   7,   7
	db    8,   8,   8,   8,   8,   8,   8,   8,   8,   8,   9,   9,   9,   9,   9,   9
	db    9,   9, VolEnvStopTrack
VolEnv_26:	db    0,   2,   2,   2,   3,   3,   3,   4,   4,   4,   5,   5, VolEnvStopTrack
VolEnv_27:	db	  0,   0,   0,   1,   1,   1,   2,   2,   2,   3,   3,   3,   4,   4,   4,   5
	db	  5,   5,   6,   6,   6,   7, VolEnvRestTrack
VolEnv_28:	db    0,   2,   4,   6,   8, 10h, VolEnvRestTrack
VolEnv_29:	db	  0,   0,   1,   1,   2,   2,   3,   3,   4,   4,   5,   5,   6,   6,   7,   7, VolEnvRestTrack
VolEnv_2A:	db	  0,   0,   2,   3,   4,   4,   5,   5,   5,   6, VolEnvRestTrack
VolEnv_2C:	db	  3,   3,   3,   2,   2,   2,   2,   1,   1,   1,   0,   0,   0,   0, VolEnvRestTrack
VolEnv_2B:	db	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1
	db	  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   2,   2,   2
	db	  2,   2,   2,   2,   3,   3,   3,   3,   3,   3,   3,   3,   4, VolEnvRestTrack
VolEnv_2D:	db	  0,   0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2
	db	  3,   3,   3,   4,   4,   4,   5,   5,   5,   6,   7, VolEnvRestTrack
VolEnv_2E:	db	  0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2,   2
	db	  3,   3,   3,   3,   3,   4,   4,   4,   4,   4,   5,   5,   5,   5,   5,   6
	db	  6,   6,   6,   6,   7,   7,   7, VolEnvRestTrack
VolEnv_2F:	db	  0,   1,   2,   3,   4,   5,   6,   7,   8,   9, 0Ah, 0Bh, 0Ch, 0Dh, 0Eh, 0Fh, VolEnvRestTrack
VolEnv_30:	db	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   1,   1,   1,   1,   1,   1
	db	  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1
	db	  1,   1,   1,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2,   2,   2,   2
	db	  2,   2,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   4, VolEnvRestTrack
VolEnv_31:	db	  4,   4,   4,   3,   3,   3,   2,   2,   2,   1,   1,   1,   1,   1,   1,   1
	db	  2,   2,   2,   2,   2,   3,   3,   3,   3,   3,   4, VolEnvRestTrack
VolEnv_32:	db	  4,   4,   3,   3,   2,   2,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1
	db	  1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2,   2,   2,   2,   2,   2
	db	  2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   3,   3
	db	  3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3,   3
	db	  3,   3,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   4
	db	  4,   4,   4,   4,   4,   4,   5,   5,   5,   5,   5,   5,   5,   5,   5,   5
	db	  5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   6,   6,   6,   6,   6,   6
	db	  6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   6,   7, VolEnvRestTrack
VolEnv_33:	db	0Eh, 0Dh, 0Ch, 0Bh, 0Ah,   9,   8,   7,   6,   5,   4,   3,   2,   1,   0, VolEnvRestTrack
; ---------------------------------------------------------------------------
; ===========================================================================
; MUSIC BANKS
; ===========================================================================
z80_MusicBanks:

	; Levels
	db zmake68kBank(MusData_DEZ)

	; Bosses
	db zmake68kBank(MusData_Boss)
	db zmake68kBank(MusData_Boss2)

	; Main
	db zmake68kBank(MusData_Invin)

	; End
	db zmake68kBank(MusData_Through)
	db zmake68kBank(MusData_Drowning)
; ---------------------------------------------------------------------------
	if $ > z80_stack_top
		fatal "Your Z80 tables won't fit before the z80 stack. It's \{$-z80_stack_top}h bytes past the start of the bottom of the stack, at \{z80_stack_top}h"
	elseif MOMPASS=1
		message "Z80 free space before stack: \{z80_stack_top-$}h bytes"
	endif

z80_SoundDriverPointersEnd:
; ---------------------------------------------------------------------------
; ===========================================================================
; END OF SOUND DRIVER
; ===========================================================================
		restore
		padding off
		!org		z80_SoundDriver+Size_of_Snd_driver_guess

Z80_Snd_Driver_End:

little_endian function x,((x)<<8)&$FF00|((x)>>8)&$FF

; Function to make a little endian (z80) pointer
k68z80Pointer function addr,little_endian((addr&$7FFF)+$8000)

startBank macro {INTLABEL}
	set	soundBankDecl,*
	align	$8000
__LABEL__ label *
	set	soundBankStart,__LABEL__
	set	soundBankPadding,soundBankStart - soundBankDecl
	set	soundBankName,"__LABEL__"
	endm

DebugSoundbanks = 1

finishBank macro
	if * > soundBankStart + $8000
		fatal "soundBank \{soundBankName} must fit in $8000 bytes but was $\{*-soundBankStart}. Try moving something to the other bank."
	elseif (DebugSoundbanks<>0)&&(MOMPASS=1)
		message "soundBank \{soundBankName} has $\{$8000+soundBankStart-*} bytes free at end, needed $\{soundBankPadding} bytes padding at start."
	endif
	endm

; macro to declare an entry in an offset table rooted at a bank
offsetBankTableEntry macro ptr
	dc.ATTRIBUTE k68z80Pointer(ptr)
	endm

; Special BINCLUDE wrapper function
DACBINCLUDE macro file,{INTLABEL}
__LABEL__ label *
	BINCLUDE file
__LABEL___Len  = little_endian(*-__LABEL__)
__LABEL___Ptr  = k68z80Pointer(__LABEL__-soundBankStart)
__LABEL___Bank = soundBankStart
	endm

; Setup macro for DAC samples.
DAC_Setup macro rate,dacptr
	dc.b	rate
	dc.w	dacptr_Len
	dc.w	dacptr_Ptr
	endm

; Macro for printing the DAC master table
DAC_Master_Table macro
	ifndef DACPointers
DACPointers label *
	elseif (DACPointers&$7FFF)<>((*)&$7FFF)
		fatal "Inconsistent placement of DAC_Master_Table macro on bank \{soundBankName}"
	endif
	if (use_s3_samples<>0)||(use_sk_samples<>0)||(use_s3d_samples<>0)
		DAC_Setup $04,DAC_81_Data
		DAC_Setup $0E,DAC_82_83_84_85_Data
		DAC_Setup $14,DAC_82_83_84_85_Data
		DAC_Setup $1A,DAC_82_83_84_85_Data
		DAC_Setup $20,DAC_82_83_84_85_Data
		DAC_Setup $04,DAC_86_Data
		DAC_Setup $04,DAC_87_Data
		DAC_Setup $06,DAC_88_Data
		DAC_Setup $0A,DAC_89_Data
		DAC_Setup $14,DAC_8A_8B_Data
		DAC_Setup $1B,DAC_8A_8B_Data
		DAC_Setup $08,DAC_8C_Data
		DAC_Setup $0B,DAC_8D_8E_Data
		DAC_Setup $11,DAC_8D_8E_Data
		DAC_Setup $08,DAC_8F_Data
		DAC_Setup $03,DAC_90_91_92_93_Data
		DAC_Setup $07,DAC_90_91_92_93_Data
		DAC_Setup $0A,DAC_90_91_92_93_Data
		DAC_Setup $0E,DAC_90_91_92_93_Data
		DAC_Setup $06,DAC_94_95_96_97_Data
		DAC_Setup $0A,DAC_94_95_96_97_Data
		DAC_Setup $0D,DAC_94_95_96_97_Data
		DAC_Setup $12,DAC_94_95_96_97_Data
		DAC_Setup $0B,DAC_98_99_9A_Data
		DAC_Setup $13,DAC_98_99_9A_Data
		DAC_Setup $16,DAC_98_99_9A_Data
		DAC_Setup $0C,DAC_9B_Data
		DAC_Setup $0A,DAC_9C_Data
		DAC_Setup $18,DAC_9D_Data
		DAC_Setup $18,DAC_9E_Data
	endif
	if (use_s3_samples<>0)||(use_sk_samples<>0)
		DAC_Setup $0C,DAC_9F_Data
		DAC_Setup $0C,DAC_A0_Data
		DAC_Setup $0A,DAC_A1_Data
		DAC_Setup $0A,DAC_A2_Data
		DAC_Setup $18,DAC_A3_Data
		DAC_Setup $18,DAC_A4_Data
		DAC_Setup $0C,DAC_A5_Data
		DAC_Setup $09,DAC_A6_Data
		DAC_Setup $18,DAC_A7_Data
		DAC_Setup $18,DAC_A8_Data
		DAC_Setup $0C,DAC_A9_Data
		DAC_Setup $0A,DAC_AA_Data
		DAC_Setup $0D,DAC_AB_Data
		DAC_Setup $06,DAC_AC_Data
		DAC_Setup $10,DAC_AD_AE_Data
		DAC_Setup $18,DAC_AD_AE_Data
		DAC_Setup $09,DAC_AF_B0_Data
		DAC_Setup $12,DAC_AF_B0_Data
		DAC_Setup $18,DAC_B1_Data
		DAC_Setup $16,DAC_B2_B3_Data
		DAC_Setup $20,DAC_B2_B3_Data
		DAC_Setup $0C,DAC_B4_C1_C2_C3_C4_Data
		DAC_Setup $0C,DAC_B5_Data
		DAC_Setup $0C,DAC_B6_Data
		DAC_Setup $18,DAC_B7_Data
		DAC_Setup $0C,DAC_B8_B9_Data
		DAC_Setup $0C,DAC_B8_B9_Data
		DAC_Setup $18,DAC_BA_Data
		DAC_Setup $18,DAC_BB_Data
		DAC_Setup $18,DAC_BC_Data
		DAC_Setup $0C,DAC_BD_Data
		DAC_Setup $0C,DAC_BE_Data
		DAC_Setup $1C,DAC_BF_Data
		DAC_Setup $0B,DAC_C0_Data
		DAC_Setup $0F,DAC_B4_C1_C2_C3_C4_Data
		DAC_Setup $11,DAC_B4_C1_C2_C3_C4_Data
		DAC_Setup $12,DAC_B4_C1_C2_C3_C4_Data
		DAC_Setup $0B,DAC_B4_C1_C2_C3_C4_Data
	endif
	if (use_s2_samples<>0)
		DAC_Setup $17,DAC_C5_Data
		DAC_Setup $01,DAC_C6_Data
		DAC_Setup $06,DAC_C7_Data
		DAC_Setup $08,DAC_C8_Data
		DAC_Setup $1B,DAC_C9_CC_CD_CE_CF_Data
		DAC_Setup $0A,DAC_CA_D0_D1_D2_Data
		DAC_Setup $1B,DAC_CB_D3_D4_D5_Data
		DAC_Setup $12,DAC_C9_CC_CD_CE_CF_Data
		DAC_Setup $15,DAC_C9_CC_CD_CE_CF_Data
		DAC_Setup $1C,DAC_C9_CC_CD_CE_CF_Data
		DAC_Setup $1D,DAC_C9_CC_CD_CE_CF_Data
		DAC_Setup $02,DAC_CA_D0_D1_D2_Data
		DAC_Setup $05,DAC_CA_D0_D1_D2_Data
		DAC_Setup $08,DAC_CA_D0_D1_D2_Data
		DAC_Setup $08,DAC_CB_D3_D4_D5_Data
		DAC_Setup $0B,DAC_CB_D3_D4_D5_Data
		DAC_Setup $12,DAC_CB_D3_D4_D5_Data
	endif
	if (use_s3d_samples<>0)
		DAC_Setup $01,DAC_D6_Data
		DAC_Setup $12,DAC_D7_Data
	endif
	if (use_s3_samples<>0)
		DAC_Setup $16,DAC_D8_D9_Data
		DAC_Setup $20,DAC_D8_D9_Data
	endif
	endm

declsong macro song
	ifndef song_Ptr
song_Ptr	label *
	endif
	dc.w	k68z80Pointer(song)
	endm

Music_Master_Table macro
	ifndef MusicPointers
MusicPointers label *
	elseif (MusicPointers&$7FFF)<>((*)&$7FFF)
		fatal "Inconsistent placement of Music_Master_Table macro on bank"
	endif
	declsong MusData_DEZ
	declsong MusData_Boss
	declsong MusData_Boss2
	declsong MusData_Invin
	declsong MusData_Through
	declsong MusData_Drowning

	ifndef zMusIDPtr__End
zMusIDPtr__End label *
	endif
	endm
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; ===========================================================================
; DAC Banks
; ===========================================================================

	if (use_s3_samples<>0)||(use_sk_samples<>0)||(use_s3d_samples<>0)
; ---------------------------------------------------------------------------
; DAC Bank 1
; ---------------------------------------------------------------------------
DacBank1:			startBank
	DAC_Master_Table

DAC_86_Data:			DACBINCLUDE "Sound/DAC/86.dpcm"
DAC_81_Data:			DACBINCLUDE "Sound/DAC/81.dpcm"
DAC_82_83_84_85_Data:	DACBINCLUDE "Sound/DAC/82-85.dpcm"
DAC_94_95_96_97_Data:	DACBINCLUDE "Sound/DAC/94-97.dpcm"
DAC_90_91_92_93_Data:	DACBINCLUDE "Sound/DAC/90-93.dpcm"
DAC_88_Data:			DACBINCLUDE "Sound/DAC/88.dpcm"
DAC_8A_8B_Data:			DACBINCLUDE "Sound/DAC/8A-8B.dpcm"
DAC_8C_Data:			DACBINCLUDE "Sound/DAC/8C.dpcm"
DAC_8D_8E_Data:			DACBINCLUDE "Sound/DAC/8D-8E.dpcm"
DAC_87_Data:			DACBINCLUDE "Sound/DAC/87.dpcm"
DAC_8F_Data:			DACBINCLUDE "Sound/DAC/8F.dpcm"
DAC_89_Data:			DACBINCLUDE "Sound/DAC/89.dpcm"
DAC_98_99_9A_Data:		DACBINCLUDE "Sound/DAC/98-9A.dpcm"
DAC_9B_Data:			DACBINCLUDE "Sound/DAC/9B.dpcm"
	endif

	if (use_s3_samples<>0)||(use_sk_samples<>0)
DAC_B2_B3_Data:			DACBINCLUDE "Sound/DAC/B2-B3.dpcm"

	if (use_s3_samples<>0)
DAC_D8_D9_Data:			DACBINCLUDE "Sound/DAC/D8-D9.dpcm"
	endif

	finishBank

; ---------------------------------------------------------------------------
; Dac Bank 2
; ---------------------------------------------------------------------------
DacBank2:			startBank
	DAC_Master_Table
	endif

	if (use_s3_samples<>0)||(use_sk_samples<>0)||(use_s3d_samples<>0)
DAC_9C_Data:			DACBINCLUDE "Sound/DAC/9C.dpcm"
DAC_9D_Data:			DACBINCLUDE "Sound/DAC/9D.dpcm"
DAC_9E_Data:			DACBINCLUDE "Sound/DAC/9E.dpcm"
	endif

	if (use_s3_samples<>0)||(use_sk_samples<>0)
DAC_9F_Data:			DACBINCLUDE "Sound/DAC/9F.dpcm"
DAC_A0_Data:			DACBINCLUDE "Sound/DAC/A0.dpcm"
DAC_A1_Data:			DACBINCLUDE "Sound/DAC/A1.dpcm"
DAC_A2_Data:			DACBINCLUDE "Sound/DAC/A2.dpcm"
DAC_A3_Data:			DACBINCLUDE "Sound/DAC/A3.dpcm"
DAC_A4_Data:			DACBINCLUDE "Sound/DAC/A4.dpcm"
DAC_A5_Data:			DACBINCLUDE "Sound/DAC/A5.dpcm"
DAC_A6_Data:			DACBINCLUDE "Sound/DAC/A6.dpcm"
DAC_A7_Data:			DACBINCLUDE "Sound/DAC/A7.dpcm"
DAC_A8_Data:			DACBINCLUDE "Sound/DAC/A8.dpcm"
DAC_A9_Data:			DACBINCLUDE "Sound/DAC/A9.dpcm"
DAC_AA_Data:			DACBINCLUDE "Sound/DAC/AA.dpcm"

	finishBank

; ---------------------------------------------------------------------------
; Dac Bank 3
; ---------------------------------------------------------------------------
DacBank3:			startBank
	DAC_Master_Table

DAC_AB_Data:			DACBINCLUDE "Sound/DAC/AB.dpcm"
DAC_AC_Data:			DACBINCLUDE "Sound/DAC/AC.dpcm"
DAC_AD_AE_Data:			DACBINCLUDE "Sound/DAC/AD-AE.dpcm"
DAC_AF_B0_Data:			DACBINCLUDE "Sound/DAC/AF-B0.dpcm"
DAC_B1_Data:			DACBINCLUDE "Sound/DAC/B1.dpcm"
DAC_B4_C1_C2_C3_C4_Data:DACBINCLUDE "Sound/DAC/B4C1-C4.dpcm"
DAC_B5_Data:			DACBINCLUDE "Sound/DAC/B5.dpcm"
DAC_B6_Data:			DACBINCLUDE "Sound/DAC/B6.dpcm"
DAC_B7_Data:			DACBINCLUDE "Sound/DAC/B7.dpcm"
DAC_B8_B9_Data:			DACBINCLUDE "Sound/DAC/B8-B9.dpcm"
DAC_BA_Data:			DACBINCLUDE "Sound/DAC/BA.dpcm"
DAC_BB_Data:			DACBINCLUDE "Sound/DAC/BB.dpcm"
DAC_BC_Data:			DACBINCLUDE "Sound/DAC/BC.dpcm"
DAC_BD_Data:			DACBINCLUDE "Sound/DAC/BD.dpcm"
DAC_BE_Data:			DACBINCLUDE "Sound/DAC/BE.dpcm"
DAC_BF_Data:			DACBINCLUDE "Sound/DAC/BF.dpcm"
DAC_C0_Data:			DACBINCLUDE "Sound/DAC/C0.dpcm"

	finishBank
	endif

	if (use_s2_samples<>0)||(use_s3d_samples<>0)
; ---------------------------------------------------------------------------
; Dac Bank 4
; ---------------------------------------------------------------------------
DacBank4:			startBank
	DAC_Master_Table
	if (use_s2_samples<>0)
DAC_C5_Data:			DACBINCLUDE "Sound/DAC/C5.dpcm"
DAC_C6_Data:			DACBINCLUDE "Sound/DAC/C6.dpcm"
DAC_C7_Data:			DACBINCLUDE "Sound/DAC/C7.dpcm"
DAC_C8_Data:			DACBINCLUDE "Sound/DAC/C8.dpcm"
DAC_C9_CC_CD_CE_CF_Data:DACBINCLUDE "Sound/DAC/C9CC-CF.dpcm"
DAC_CA_D0_D1_D2_Data:	DACBINCLUDE "Sound/DAC/CAD0-D2.dpcm"
DAC_CB_D3_D4_D5_Data:	DACBINCLUDE "Sound/DAC/CBD3-D5.dpcm"
	endif

	if (use_s3d_samples<>0)
DAC_D6_Data:			DACBINCLUDE "Sound/DAC/D6.dpcm"
DAC_D7_Data:			DACBINCLUDE "Sound/DAC/D7.dpcm"
	endif

	finishBank
	endif

; ---------------------------------------------------------------------------
	include "Sound/_smps2asm_inc.asm"
; ---------------------------------------------------------------------------
; ===========================================================================
; Sound Bank
; ===========================================================================
SndBank:			startBank

; ===========================================================================
; SFX Pointers
; ===========================================================================
SFXPointers:
Sound_01_Ptr:	offsetBankTableEntry.w Sound_01
Sound_02_Ptr:	offsetBankTableEntry.w Sound_02
Sound_03_Ptr:	offsetBankTableEntry.w Sound_03
Sound_04_Ptr:	offsetBankTableEntry.w Sound_04
Sound_05_Ptr:	offsetBankTableEntry.w Sound_05
Sound_06_Ptr:	offsetBankTableEntry.w Sound_06
Sound_07_Ptr:	offsetBankTableEntry.w Sound_07
Sound_08_Ptr:	offsetBankTableEntry.w Sound_08
Sound_09_Ptr:	offsetBankTableEntry.w Sound_09
Sound_0A_Ptr:	offsetBankTableEntry.w Sound_0A
Sound_0B_Ptr:	offsetBankTableEntry.w Sound_0B
Sound_0C_Ptr:	offsetBankTableEntry.w Sound_0C
Sound_0D_Ptr:	offsetBankTableEntry.w Sound_0D
Sound_0E_Ptr:	offsetBankTableEntry.w Sound_0E
Sound_0F_Ptr:	offsetBankTableEntry.w Sound_0F
Sound_10_Ptr:	offsetBankTableEntry.w Sound_10
Sound_11_Ptr:	offsetBankTableEntry.w Sound_11
Sound_12_Ptr:	offsetBankTableEntry.w Sound_12
Sound_13_Ptr:	offsetBankTableEntry.w Sound_13
Sound_14_Ptr:	offsetBankTableEntry.w Sound_14
Sound_15_Ptr:	offsetBankTableEntry.w Sound_15
Sound_16_Ptr:	offsetBankTableEntry.w Sound_16
Sound_17_Ptr:	offsetBankTableEntry.w Sound_17
Sound_18_Ptr:	offsetBankTableEntry.w Sound_18
Sound_19_Ptr:	offsetBankTableEntry.w Sound_19
Sound_1A_Ptr:	offsetBankTableEntry.w Sound_1A
Sound_1B_Ptr:	offsetBankTableEntry.w Sound_1B
Sound_1C_Ptr:	offsetBankTableEntry.w Sound_1C
Sound_1D_Ptr:	offsetBankTableEntry.w Sound_1D
Sound_1E_Ptr:	offsetBankTableEntry.w Sound_1E

Sound_End_Ptr
; ---------------------------------------------------------------------------
SEGA_PCM:	binclude "Sound/Sega PCM.pcm"
SEGA_PCM_End
		even
Sound_01:	include "Sound/SFX/Snd - Ring.asm"
Sound_02:	include "Sound/SFX/Snd - Ring Left Speaker.asm"
Sound_03:	include "Sound/SFX/Snd - Ring Loss.asm"
Sound_04:	include "Sound/SFX/Snd - Jump.asm"
Sound_05:	include "Sound/SFX/Snd - Roll.asm"
Sound_06:	include "Sound/SFX/Snd - Skid.asm"
Sound_07:	include "Sound/SFX/Snd - Death.asm"
Sound_08:	include "Sound/SFX/Snd - SpinDash.asm"
Sound_09:	include "Sound/SFX/Snd - Splash.asm"
Sound_0A:	include "Sound/SFX/Snd - Insta Attack.asm"
Sound_0B:	include "Sound/SFX/Snd - Fire Shield.asm"
Sound_0C:	include "Sound/SFX/Snd - Bubble Shield.asm"
Sound_0D:	include "Sound/SFX/Snd - Lightning Shield.asm"
Sound_0E:	include "Sound/SFX/Snd - Fire Attack.asm"
Sound_0F:	include "Sound/SFX/Snd - Bubble Attack.asm"
Sound_10:	include "Sound/SFX/Snd - Electric Attack.asm"
Sound_11:	include "Sound/SFX/Snd - Spike Hit.asm"
Sound_12:	include "Sound/SFX/Snd - Spike Move.asm"
Sound_13:	include "Sound/SFX/Snd - Drown.asm"
Sound_14:	include "Sound/SFX/Snd - StarPost.asm"
Sound_15:	include "Sound/SFX/Snd - Spring.asm"
Sound_16:	include "Sound/SFX/Snd - Dash.asm"
Sound_17:	include "Sound/SFX/Snd - Break.asm"
Sound_18:	include "Sound/SFX/Snd - Boss Hit.asm"
Sound_19:	include "Sound/SFX/Snd - Air Ding.asm"
Sound_1A:	include "Sound/SFX/Snd - Bubble.asm"
Sound_1B:	include "Sound/SFX/Snd - Explode.asm"
Sound_1C:	include "Sound/SFX/Snd - Signpost.asm"
Sound_1D:	include "Sound/SFX/Snd - Switch.asm"
Sound_1E:	include "Sound/SFX/Snd - Register.asm"

	finishBank

; ---------------------------------------------------------------------------
; ===========================================================================
; Music Banks
; ===========================================================================
; Music Bank 1
; ---------------------------------------------------------------------------
Mus_Bank1_Start:	startBank
	Music_Master_Table
z80_UniVoiceBank:		include "Sound/UniBank.asm"
MusData_DEZ:			include "Sound/Music/Mus - DEZ1.asm"
MusData_Boss:			include "Sound/Music/Mus - Miniboss.asm"
MusData_Boss2:			include "Sound/Music/Mus - Zone Boss.asm"
MusData_Invin:			include "Sound/Music/Mus - Invincibility.asm"
MusData_Through:		include "Sound/Music/Mus - Sonic Got Through.asm"
MusData_Drowning:		include "Sound/Music/Mus - Drowning.asm"

	finishBank
