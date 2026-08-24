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
; Constants
; ===========================================================================

; ---------------------------------------------------------------------------
z80SegmentStart   = *
; ---------------------------------------------------------------------------
fHW_Version =				$A10001
; ---------------------------------------------------------------------------
; Z80 addresses
fZ80_RAM =					$A00000 ; start of Z80 RAM
fZ80_RAM_End =				$A02000 ; end of non-reserved Z80 RAM
fZ80_Bus_Request =			$A11100
fZ80_RELEASE_BUS =			$000
fZ80_REQUEST_BUS =			$100
fZ80_Reset =				$A11200
fZ80_ASSERT_RESET =			$000
fZ80_RELEASE_RESET =		$100
; ---------------------------------------------------------------------------
; Playback control bits:
	enum     bitPSGNoise=0,bitFM3Special=0,bitNoAttack,bitSFXOverride,bitAltFreqMode
	nextenum bitTrackAtRest,bitPitchSlide,bitSustainFreq,bitTrackPlaying
maskSkipFMNoteOn  = (1<<bitTrackAtRest)|(1<<bitSFXOverride)|(1<<bitNoAttack)
maskSkipFMNoteOff = (1<<bitSFXOverride)|(1<<bitNoAttack)
maskPlayRest      = (1<<bitTrackPlaying)|(1<<bitTrackAtRest)
maskFM6Unused     = (1<<bitSFXOverride)|(1<<bitTrackAtRest)
; ---------------------------------------------------------------------------
; Voice control values:
	enum     ymFM1=0,ymFM2,ymFM3                ; Part 1 channels
	enum     ymFM4=4,ymFM5,ymFM6,ymDAC=ymFM6    ; Part 2 channels
	enumconf $20
	enum     snPSG1=$80,snPSG2,snPSG3,snNoise   ; PSG channels
	enumconf 1
ymPartII          = 2       ; Bit value
bitIsPSG          = 7       ; Bit value
snPSGTone         = (0<<4)  ; For latching PSG tone data
snPSGVol          = (1<<4)  ; For latching PSG volume data
; ---------------------------------------------------------------------------
; equates: standard (for Genesis games) addresses in the memory map
	enum zYM2612_A0=$4000,zYM2612_D0,zYM2612_A1,zYM2612_D1
zBankRegister	           = $6000
zPSG                       = $7F11
zROMWindow                 = $8000
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
ModEnvReset         = $80
ModEnvSustain1      = $81
ModEnvJumpTo        = $82
ModEnvSustain       = $83
ModEnvAlterSens     = $84

VolEnvReset         = $80
VolEnvRestTrack     = $81
VolEnvJumpTo        = $82
VolEnvStopTrack     = $83
; ---------------------------------------------------------------------------
; Values for zUpdatingSFX
; During zUpdateEverything and related functions
flagMusicUpdate = 0
flagSfxUpdate = 1
flagContinuousSfxUpdate = $80

; During zPlaySoundByIndex and related functions
flagSFXInit = 0
flagContinuousSfxInit = $80
; ---------------------------------------------------------------------------
; z80 RAM:
zDataStart				=	$1C10
		phase zDataStart
z80_stack_top:			ds.b $60
z80_stack:
zSFXSaveIndex:			ds.b 1
						ds.b 1
zDACEnable:				ds.b 1
zDACEnableSave:			ds.b 1
zSpecFM3Freqs:			ds.b 8
zSpecFM3FreqsSFX:		ds.b 8
zSpecFM3FreqsContSFX:	ds.b 8
zQueueVariables:
zPalFlag:				ds.b 1
zPalDblUpdCounter:		ds.b 1
zSoundQueue0:			ds.b 1
zSoundQueue1:			ds.b 1
zSoundQueue2:			ds.b 1
zTempoSpeedup:			ds.b 1
zNextSound:				ds.b 1
; The following 3 variables are used for M68K input
zMusicNumber:			ds.b 1	; Play_Sound
zSFXNumber0:			ds.b 1	; Play_Sound_2
zSFXNumber1:			ds.b 1	; Play_Sound_2
	shared zQueueVariables,zMusicNumber,zSFXNumber0,zSFXNumber1
	if (zQueueVariables&1)<>0
		fatal "zQueueVariables must be at an even address."
	endif

zTempVariablesStart:

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

zTracksContSFXStart:
zContSFX_FM3:		zTrack
zContSFX_FM4:		zTrack
zContSFX_PSG3:		zTrack
zTracksContSFXEnd:
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

zTempVariablesEnd:
; ---------------------------------------------------------------------------
	if (zQueueVariables&1)<>0
		fatal "zQueueVariables must be at an even address as it is used as a longword by the 68k!"
	endif
	if * > $2000	; Don't declare more space than the RAM can contain!
		fatal "The RAM variable declarations are too large by $\{$} bytes."
	endif
		dephase
; ---------------------------------------------------------------------------
zNumMusicTracks = (zTracksEnd-zTracksStart)/zTrack.len
zNumMusicFMorPSGTracks = (zTracksEnd-zSongFM1)/zTrack.len
zNumMusicFMorDACTracks = (zSongPSG1-zTracksStart)/zTrack.len
zNumMusicFMTracks = (zSongPSG1-zSongFM1)/zTrack.len
zNumMusicFM1Tracks = (zSongFM4-zSongFM1)/zTrack.len
zNumMusicFM2Tracks = (zSongPSG1-zSongFM4)/zTrack.len
zNumMusicPSGTracks = (zTracksEnd-zSongPSG1)/zTrack.len
zNumSFXTracks = (zTracksSFXEnd-zTracksSFXStart)/zTrack.len
zNumContSFXTracks = (zTracksContSFXEnd-zTracksContSFXStart)/zTrack.len
zNumAllSFXTracks = zNumSFXTracks + zNumContSFXTracks
zNumSaveTracks = (zTracksSaveEnd-zTracksSaveStart)/zTrack.len
zNumSpecialFreqCommands = zSpecialFreqCommands_End-zSpecialFreqCommands
zNumFMInstrumentTLCommands = zFMInstrumentTLTable_End-zFMInstrumentTLTable
zNumFMInstrumentSSGEGCommands = zFMInstrumentSSGEGTable_End-zFMInstrumentSSGEGTable
zNumFMInstrumentOperatorCommands = zFMInstrumentOperatorTable_End-zFMInstrumentOperatorTable
zNumFMInstrumentRSARCommands = zFMInstrumentRSARTable-zFMInstrumentOperatorTable
zNumFMInstrumentAMD1RCommands = zFMInstrumentAMD1RTable-zFMInstrumentRSARTable
zNumFMInstrumentOperatorAfterAMD1RCommands = zFMInstrumentOperatorTable_End-zFMInstrumentAMD1RTable
zNumBytesSave = zTracksSaveEnd-zTracksSaveStart
zNumBytesKeepSFX = zTracksEnd-zFadeOutTimeout
zNumBytesStopSFX = zTracksSaveEnd-zContinuousSFX
zPSGChannelDelta = snPSG2-snPSG1
zNumBytesSEGA_PCM = SEGA_PCM_End-SEGA_PCM
; ---------------------------------------------------------------------------
NoteRest				= $80
FirstCoordFlag			= $E0
; ---------------------------------------------------------------------------
zID_MusicPointers  = 0
zID_SFXPointers    = 2
zID_ModEnvPointers = 4
zID_VolEnvPointers = 6
; ---------------------------------------------------------------------------
	GenSampleIDs
	GenMusicIDs
	GenSndIDs
; ---------------------------------------------------------------------------
; Internal equates for use in the driver.
zMus__First           = {mus_prefix}__First
zMus_ExtraLife        = 0
zMus__End             = {mus_prefix}__End
zSFX__First           = {sfx_prefix}__First
zSFX__FirstContinuous = {sfx_prefix}__FirstContinuous
zSFX__End             = {sfx_prefix}__End
zSFX_Ring             = {sfx_prefix}_Ring
zSFX_RingLeft         = {sfx_prefix}_RingLeft
zSFX_Spindash         = {sfx_prefix}_Spindash
; ---------------------------------------------------------------------------
; Definitions for playable PCMs. This needs work.
{pcm_prefix}__First = zSFX__End
{pcm_prefix}__End   = zSFX__End
; ---------------------------------------------------------------------------
; Internal equates for use in the driver.
zPCM__First           = {pcm_prefix}__First
zPCM__End             = {pcm_prefix}__End
; ---------------------------------------------------------------------------
; See definitions of fade_prefix and cmd_prefix in "Config.asm".
	enum     {fade_prefix}__First=zMus__End,{cmd_prefix}_FadeOut={fade_prefix}__First
	nextenum {cmd_prefix}_MusicFade,{cmd_prefix}_Stop={cmd_prefix}_MusicFade
	nextenum {cmd_prefix}_PSGSilenceAll,{cmd_prefix}_MutePSG={cmd_prefix}_PSGSilenceAll
	nextenum {cmd_prefix}_StopSFX,{cmd_prefix}_zFadeOutMusic2
	nextenum {cmd_prefix}_zFadeOut2={cmd_prefix}_zFadeOutMusic2
	nextenum {cmd_prefix}_StopContSFX,{fade_prefix}__End
{cmd_prefix}_StopSega  = $FE
{cmd_prefix}_SegaSound = $FF
; ---------------------------------------------------------------------------
; Internal equates for use in the driver.
zCmd__First           = {fade_prefix}__First
zCmd__End             = {fade_prefix}__End
zCmd_StopSega         = {cmd_prefix}_StopSega
zCmd_SegaSound        = {cmd_prefix}_SegaSound
	if MOMPASS>1
		if zCmd__End > zCmd_StopSega
			fatal "You have too many songs: zCmd__End ($\{zCmd__End}) can't exceed zCmd_StopSega ($\{zCmd_StopSega})."
		endif
	endif
; ---------------------------------------------------------------------------
		!org		z80SegmentStart
; ---------------------------------------------------------------------------
