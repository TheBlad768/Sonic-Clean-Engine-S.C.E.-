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
; Macros
; ===========================================================================
; Macros for controlling the z80.

; tells the Z80 to stop
zHaltZ80 macro
	move.w	#fZ80_REQUEST_BUS,(fZ80_Bus_Request).l ; stop the Z80
	endm

zWaitZ80Bus macro
.loop:
	btst	#0,(fZ80_Bus_Request).l
	bne.s	.loop ; loop until it says it's stopped
	endm

; tells the Z80 to stop, and waits for it to finish stopping (acquire bus)
zStopZ80 macro
	zHaltZ80
	zWaitZ80Bus
	endm

; tells the Z80 to start again
zStartZ80 macro
	move.w	#fZ80_RELEASE_BUS,(fZ80_Bus_Request).l    ; start the Z80
	endm

zReleaseZ80Reset macro
	move.w	#fZ80_RELEASE_RESET,(fZ80_Reset).l	; release reset
	endm

zResetZ80 macro
	move.w	#fZ80_ASSERT_RESET,(fZ80_Reset).l	; reset Z80
	nop
	nop
	nop
	nop
	zReleaseZ80Reset
	endm
; ===========================================================================
; Bank switching macros.

; MACRO bankswitch
; Performs a bank switch to the specified bank. This is done through an inlined
; loop that writes the bank number to the bank register 8 times, with the
; 9th bit assumed to be 0.
;
; Note: Since a bank is 9 bits, but 'a' register is only 8 bits, the 9th bit is
; assumed to be 0. This means that music banks must be in the first 8MB of
; the ROM. This is not an issue generally because most ROMs will be 4MB or
; less, but it must be kept in mind.
;
; Input:
;     a = bank number to switch to
; Output:
;     None
; Modifies:
;     a, hl
bankswitch macro
		ld	hl, zBankRegister
		ld	(hl), a
		rept 7
			rrca
			ld	(hl), a
		endm
		ld	(hl), h			; Micro-optimization: the low bit of h is 0
	endm

; MACRO bankswitchLoop
; Performs a bank switch to the specified bank. This is done through a dnjz
; loop that writes the bank number to the bank register 8 times, with the
; 9th bit assumed to be 0.
;
; Note: Since a bank is 9 bits, but 'a' register is only 8 bits, the 9th bit is
; assumed to be 0. This means that music banks must be in the first 8MB of
; the ROM. This is not an issue generally because most ROMs will be 4MB or
; less, but it must be kept in mind.
;
; Input:
;     a = bank number to switch to
; Output:
;     None
; Modifies:
;     a, b
bankswitchLoop macro
		ld	b, 8
.bankloop:
		ld	(zBankRegister), a
		rrca
		djnz	.bankloop
		xor	a
		ld	(zBankRegister), a
	endm

; MACRO bankswitchToMusic
; Performs a bank switch to the current music bank.
;
; Note: Uses bankswitch macro internally, so all the same rules apply.
;
; Input:
;     a = bank number to switch to
; Output:
;     None
; Modifies:
;     a, hl
bankswitchToMusic macro
		ld	a, (zSongBank)
		bankswitch
	endm
; ---------------------------------------------------------------------------
; MACRO rsttarget
; Defines the label to be a target of a `rst` call. This is meant to ensure
; that it is properly aligned, and give good error messages.
rsttarget macro {INTLABEL}
	if ($&7)||($>38h)
		fatal "Function __LABEL__ is at 0\{$}h, but must be at a multiple of 8 bytes <= 38h to be used with the rst instruction."
	endif
	if "__LABEL__"<>""
__LABEL__ label $
	endif
	endm
; ---------------------------------------------------------------------------
; Second order macros for the sound driver. These are used as parameters to
; other macros, and are not meant to be used directly.

; MACRO setMaxAR
; Sets the attack rate of the current channel to the maximum value.
;
; Input:
;    a = current attack rate
; Output:
;    a = maximum attack rate
; Modifies:
;    a
setMaxAR macro
		or	maxAttackRate					; Set AR to maximum
	endm

; MACRO calcVolume
; Calculates the volume for the current track. If the input volume is negative,
; it adds the track's volume to it. If the result overflows, it clamps the
; volume to 0. If the input volume is positive, it does nothing.
;
; Input:
;    a = current volume
; Output:
;    a = calculated volume
; Modifies:
;    a
calcVolume macro
		or	a								; Is it positive?
		jp	p, .skip_track_vol				; Branch if yes
		add	a, (ix+zTrack.Volume)			; Add track's volume to it
		jr	nc, .skip_track_vol
		sbc	a, a							; Clamp volume attenuation as it overflowed
.skip_track_vol:
	endm
; ---------------------------------------------------------------------------
; MACRO zFastWriteFM
; Writes a register/data pair to the YM2612. This is meant to be used instead
; of inlining the contents so that any optimizations can be done in one place.
;
; Input:
;    reg = register with the data we wish to write.
;    data = data to write to the register.
;    dataMacro = optional macro to run before writing the data. This is used
;                to perform any calculations on the data before writing it.
;    iy = pointer to the YM2612 registers. One of zYM2612_A0 or zYM2612_A1.
;    c = channel assignment bits.
; Output:
;    None
; Modifies:
;    a
;    Any registers modified by dataMacro
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
; ---------------------------------------------------------------------------
; MACRO zGetFMPartPointer
; Gets the pointer to the YM2612 part that the current track is assigned to.
;
; Input:
;    ix = pointer to the current track
; Output:
;    iy = pointer to the YM2612 part that the current track is assigned to.
; Modifies:
;    a, c, iy
zGetFMPartPointer macro
		ld	c, (ix+zTrack.VoiceControl)		; Get voice control bits for future use
		ld	iy, zYM2612_A0					; Point to part I
		bit	ymPartII, c						; Is this the DAC channel or FM4 or FM5 or FM6?
		jr	z, .notFMII						; If not, write reg/data pair to part I
		res	ymPartII, c						; Strip 'bound to part II regs' bit
		ld	iy, zYM2612_A1					; Point to part II
.notFMII:
	endm
; ---------------------------------------------------------------------------
; Utility functions to convert m68k addresses to Z80 addresses and banks.
; These are used to generate the master tables for music and DAC samples.

; FUNCTION zmake68kPtr
; Converts the low 15-bits of a m68k address into an address where the z80
; can access the data after bank-switching to the appropriate bank.
;
; This is meant to be used inside the z80 driver.
;
; Input:
;    addr = m68k address to convert
; Output:
;    Returns the corresponding z80 address.
zmake68kPtr function addr,zROMWindow+(addr&7FFFh)

; FUNCTION zmake68kBank
; Isolates bits 15-22 of a m68k address into a bank number for the z80's
; bankswitch register.
;
; This is meant to be used inside the z80 driver.
;
; Note: This discards a bit (should be 0FF8000h instead of 7F8000h). This is
; relatively harmless since the driver only uses 8 bits anyway.
;
; Input:
;    addr = m68k address to convert
; Output:
;    Returns the corresponding z80 bank number.
zmake68kBank function addr,(((addr&7F8000h)>>15))

; FUNCTION little_endian
; Converts a 16-bit value into little-endian format for the z80.
;
; This is meant to be used for data definitions in the 68k side.
;
; Input:
;    x = 16-bit value to convert
; Output:
;    Returns the corresponding little-endian value.
little_endian function x,((x)<<8)&$FF00|((x)>>8)&$FF

; FUNCTION k68z80Pointer
; Function to make a little endian (z80) pointer
;
; This is meant to be used for data definitions in the 68k side.
;
; Input:
;    addr = 68k address
; Output:
;    Returns the corresponding little-endian z80 pointer.
k68z80Pointer function addr,little_endian((addr&$7FFF)+$8000)
; ---------------------------------------------------------------------------
; Bank definition macros. They handle aligning the banks and checking that they
; fit in the 32KB bank size of the z80 ROM window.

; MACRO startBank
; Starts a new bank. This aligns the bank to a 32KB boundary, and sets up some
; variables for later use.
;
; Input:
;    INTLABEL = internal label for the bank
; Output:
;    None
startBank macro {INTLABEL}
	set	soundBankDecl,*
	align	$8000
__LABEL__ label *
	set	soundBankStart,__LABEL__
	set	soundBankPadding,soundBankStart - soundBankDecl
	set	soundBankName,"__LABEL__"
	endm

; CONSTANT DebugSoundbanks
; Set to 1 to enable debug messages for sound banks.
; This will print out the amount of free space at the end of each bank, and
; how much padding was needed at the start of the bank.
DebugSoundbanks = 1

; MACRO finishBank
; Finishes a bank. This checks that the bank fits in the 32KB bank size.
;
; Input:
;    None
; Output:
;    None
finishBank macro
	if * > soundBankStart + $8000
		fatal "soundBank \{soundBankName} must fit in $8000 bytes but was $\{*-soundBankStart}. Try moving something to the other bank."
	elseif (DebugSoundbanks<>0)&&(MOMPASS>1)
		message "soundBank \{soundBankName} has $\{$8000+soundBankStart-*} bytes free at end, needed $\{soundBankPadding} bytes padding at start."
	endif
	endm

; MACRO offsetBankTableEntry
; Macro to declare an entry in an offset table rooted at a bank
;
; Input:
;    ptr = pointer to the data
; Output:
;    None
offsetBankTableEntry macro ptr
	dc.ATTRIBUTE k68z80Pointer(ptr)
	endm

; MACRO DACBINCLUDE
; Special BINCLUDE wrapper macro. Does a BINCLUDE for the input file, and
; creates book-keeping variables for later use.
;
; Input:
;    file = file to include
;    INTLABEL = internal label for the data
; Output:
;    None
DACBINCLUDE macro file,{INTLABEL}
__LABEL__ label *
	BINCLUDE file
__LABEL___Len  = little_endian(*-__LABEL__)
__LABEL___Ptr  = k68z80Pointer(__LABEL__-soundBankStart)
__LABEL___Bank = soundBankStart
	endm

; ---------------------------------------------------------------------------
; Second order macros for DAC definitions. These are meant to be expanded by
; other macros, notably Gen_Sample_Table.

; MACRO zDeclSamplePtr
; Setup macro for DAC sample rate/length/pointer data.
;
; Input:
;    rate = sample rate for the DAC sample
;    dacptr = pointer to the DAC sample data
;    sample = name of the DAC sample
; Output:
;    None
zDeclSamplePtr macro rate,dacptr,sample
	dc.b	rate
	dc.w	dacptr_Len
	dc.w	dacptr_Ptr
	endm

; MACRO zDeclSampleBank
; Setup macro for DAC sample bank.
;
;    rate = sample rate for the DAC sample
;    dacptr = pointer to the DAC sample data
;    sample = name of the DAC sample
; Output:
;    None
zDeclSampleBank macro rate,dacptr,sample
	db zmake68kBank(dacptr)
	endm

; MACRO zDeclSampleID
; Setup macro for DAC sample ID constant.
;
; Input:
;    rate = sample rate for the DAC sample
;    dacptr = pointer to the DAC sample data
;    sampleid = name of the DAC sample
; Output:
;    None
zDeclSampleID macro rate,dacptr,sampleid
	ifdef sampleid
		if sampleid <> zLastSampleID
			fatal "DAC ID sampleid=$\{sampleid} is not equal to the expected value $\{zLastSampleID}."
		endif
	else
sampleid = zLastSampleID
	endif
zLastSampleID := zLastSampleID + 1
	endm
; ---------------------------------------------------------------------------
; Second order macros for Music definitions. These are meant to be expanded by
; other macros, notably Gen_Music_Table.

; MACRO zDeclSongPtr
; Setup macro for music pointer data.
;
; Input:
;    song = name of the music track
; Output:
;    None
zDeclSongPtr macro song
	ifndef Mus_song_Ptr
Mus_song_Ptr	label *
	endif
	dc.w	k68z80Pointer(MusData_song)
	endm

; MACRO zDeclSongBank
; Setup macro for music bank data.
;
; Input:
;    song = name of the music track
; Output:
;    None
zDeclSongBank macro song
	db zmake68kBank(MusData_song)
	endm

; MACRO zDeclSongID
; Setup macro for music ID constant.
;
; Input:
;    song = name of the music track
; Output:
;    None
zDeclSongID macro song
{mus_prefix}_song = zLastMusicID
zLastMusicID := zLastMusicID + 1
	endm
; ---------------------------------------------------------------------------
; Second order macros for SFX definitions. These ar meant to be expanded by
; other macros, notably Gen_Sound_Table.

; MACRO zDeclSndPtr
; Setup macro for SFX pointer data.
;
; Input:
;    sfx = name of the SFX
; Output:
;    None
zDeclSndPtr macro sfxname
	ifndef Sound_sfxname_Ptr
Sound_sfxname_Ptr	label *
	endif
	dc.w	k68z80Pointer(Sound_sfxname)
	endm

; MACRO zDeclSndID
; Setup macro for SFX ID constant.
;
; Input:
;    sfx = name of the SFX
; Output:
;    None
zDeclSndID macro sfxname
{sfx_prefix}_sfxname = zLastSndID
zLastSndID := zLastSndID + 1
	endm
; ---------------------------------------------------------------------------
; Macros for defining sample tables.

; MACRO Gen_Sample_Table
; Generates IDs for DAC samples.
;
; Uses zDeclSampleID macro to generate the sample ID constants.
;
; Input:
;    None
; Output:
;    None
GenSampleIDs macro
zLastSampleID := $81
SampleID__First = zLastSampleID
	Gen_Sample_Table zDeclSampleID
SampleID__End = zLastSampleID
	endm

; MACRO Gen_Sample_Bank_Table
; Generates a table of DAC sample banks.
;
; Uses zDeclSampleBank macro to generate the sample bank table.
;
; Input:
;    None
; Output:
;    None
GenSampleBankTable macro
	Gen_Sample_Table zDeclSampleBank
	endm

; MACRO DAC_Master_Table
; Generates the master table of DAC samples.
;
; Uses zDeclSamplePtr macro to generate the sample pointer table.
;
; Input:
;    None
; Output:
;    None
DAC_Master_Table macro
	ifndef DACPointers
DACPointers label *
	elseif (DACPointers&$7FFF)<>((*)&$7FFF)
		fatal "Inconsistent placement of DAC_Master_Table macro on bank \{soundBankName}"
	endif
	Gen_Sample_Table zDeclSamplePtr
	endm
; ---------------------------------------------------------------------------
; Macros for defining music tables.

; MACRO Gen_Music_Table
; Generates IDs for music tracks.
;
; Uses zDeclSongID macro to generate the music ID constants.
;
; Input:
;    None
; Output:
;    None
GenMusicIDs macro
zLastMusicID := 1
{mus_prefix}__First = zLastMusicID
	Gen_Music_Table zDeclSongID
{mus_prefix}__End = zLastMusicID
	endm

; MACRO Gen_Music_Bank_Table
; Generates a table of music banks.
;
; Uses zDeclSongBank macro to generate the music bank table.
;
; Input:
;    None
; Output:
;    None
GenMusicBankTable macro
	Gen_Music_Table zDeclSongBank
	endm

; MACRO Music_Master_Table
; Generates the master table of music tracks.
;
; Uses zDeclSongPtr macro to generate the music pointer table.
;
; Input:
;    None
; Output:
;    None
Music_Master_Table macro
	ifndef MusicPointers
MusicPointers label *
	elseif (MusicPointers&$7FFF)<>((*)&$7FFF)
		fatal "Inconsistent placement of Music_Master_Table macro on bank"
	endif
	Gen_Music_Table zDeclSongPtr
	ifndef zMusIDPtr__End
zMusIDPtr__End label *
	endif
	endm
; ---------------------------------------------------------------------------
; Macros for defining SFX tables.

; MACRO Gen_Sound_Table
; Generates IDs for SFX.
;
; Uses zDeclSndID macro to generate the SFX ID constants.
;
; Input:
;    None
; Output:
;    None
GenSndIDs macro {INTLABEL}
zLastSndID := 1
{sfx_prefix}__First = zLastSndID
	Gen_Sound_Table zDeclSndID
{sfx_prefix}__FirstContinuous = zLastSndID
	Gen_ContinuousSound_Table zDeclSndID
{sfx_prefix}__End = zLastSndID
	ifndef {sfx_prefix}_Ring
{sfx_prefix}_Ring = {sfx_prefix}_RingRight
	endif
	if {sfx_prefix}_RingLeft=={sfx_prefix}_Ring+1
RingSoundsAdjacent := 1
	else
RingSoundsAdjacent := 0
		warning "You should make sure \{sfx_prefix}_RingLeft is immediately after \{sfx_prefix}_Ring"
	endif
	endm

; MACRO Snd_Master_Table
; Generates the master table of SFX.
;
; Uses zDeclSndPtr macro to generate the SFX pointer table.
;
; Input:
;    None
; Output:
;    None
Snd_Master_Table macro
	ifndef SFXPointers
SFXPointers label *
	elseif (SFXPointers&$7FFF)<>((*)&$7FFF)
		fatal "Inconsistent placement of SFX_Master_Table macro on bank"
	endif
	Gen_Sound_Table zDeclSndPtr
	Gen_ContinuousSound_Table zDeclSndPtr
	ifndef Sound_End_Ptr
Sound_End_Ptr label *
	endif
	endm
; ---------------------------------------------------------------------------
; MACRO Gen_Sample_Table
; Meta-macro to generates the DAC sample data. Takes one macro as a parameter,
; which is used to generate the sample data.
;
; Note: do not use this directly; use one of GenSampleIDs, GenSampleBankTable,
; or DAC_Master_Table instead. This is meant to be edited to fit the needs of
; the game, while these other macros use it so as to ensure consistency.
;
; Input:
;    declsample = macro to use to generate the sample data. This should be one
;                 of zDeclSampleID, zDeclSamplePtr, or zDeclSampleBank.
; Output:
;    None
Gen_Sample_Table macro declsample
	if (use_s3_samples<>0)||(use_sk_samples<>0)||(use_s3d_samples<>0)
		declsample $04,DAC_81_Data,dSnareS3
		declsample $0E,DAC_82_83_84_85_Data,dHighTom
		declsample $14,DAC_82_83_84_85_Data,dMidTomS3
		declsample $1A,DAC_82_83_84_85_Data,dLowTomS3
		declsample $20,DAC_82_83_84_85_Data,dFloorTomS3
		declsample $04,DAC_86_Data,dKickS3
		declsample $04,DAC_87_Data,dMuffledSnare
		declsample $06,DAC_88_Data,dCrashCymbal
		declsample $0A,DAC_89_Data,dRideCymbal
		declsample $14,DAC_8A_8B_Data,dLowMetalHit
		declsample $1B,DAC_8A_8B_Data,dMetalHit
		declsample $08,DAC_8C_Data,dHighMetalHit
		declsample $0B,DAC_8D_8E_Data,dHigherMetalHit
		declsample $11,DAC_8D_8E_Data,dMidMetalHit
		declsample $08,DAC_8F_Data,dClapS3
		declsample $03,DAC_90_91_92_93_Data,dElectricHighTom
		declsample $07,DAC_90_91_92_93_Data,dElectricMidTom
		declsample $0A,DAC_90_91_92_93_Data,dElectricLowTom
		declsample $0E,DAC_90_91_92_93_Data,dElectricFloorTom
		declsample $06,DAC_94_95_96_97_Data,dTightSnare
		declsample $0A,DAC_94_95_96_97_Data,dMidpitchSnare
		declsample $0D,DAC_94_95_96_97_Data,dLooseSnare
		declsample $12,DAC_94_95_96_97_Data,dLooserSnare
		declsample $0B,DAC_98_99_9A_Data,dHiTimpaniS3
		declsample $13,DAC_98_99_9A_Data,dLowTimpaniS3
		declsample $16,DAC_98_99_9A_Data,dMidTimpaniS3
		declsample $0C,DAC_9B_Data,dQuickLooseSnare
		declsample $0A,DAC_9C_Data,dClick
		declsample $18,DAC_9D_Data,dPowerKick
		declsample $18,DAC_9E_Data,dQuickGlassCrash
	endif
	if (use_s3_samples<>0)||(use_sk_samples<>0)
		declsample $0C,DAC_9F_Data,dGlassCrashSnare
		declsample $0C,DAC_A0_Data,dGlassCrash
		declsample $0A,DAC_A1_Data,dGlassCrashKick
		declsample $0A,DAC_A2_Data,dQuietGlassCrash
		declsample $18,DAC_A3_Data,dOddSnareKick
		declsample $18,DAC_A4_Data,dKickExtraBass
		declsample $0C,DAC_A5_Data,dComeOn
		declsample $09,DAC_A6_Data,dDanceSnare
		declsample $18,DAC_A7_Data,dLooseKick
		declsample $18,DAC_A8_Data,dModLooseKick
		declsample $0C,DAC_A9_Data,dWoo
		declsample $0A,DAC_AA_Data,dGo
		declsample $0D,DAC_AB_Data,dSnareGo
		declsample $06,DAC_AC_Data,dPowerTom
		declsample $10,DAC_AD_AE_Data,dHiWoodBlock
		declsample $18,DAC_AD_AE_Data,dLowWoodBlock
		declsample $09,DAC_AF_B0_Data,dHiHitDrum
		declsample $12,DAC_AF_B0_Data,dLowHitDrum
		declsample $18,DAC_B1_Data,dMetalCrashHit
		declsample $16,DAC_B2_B3_Data,dEchoedClapHit
		declsample $20,DAC_B2_B3_Data,dLowerEchoedClapHit
		declsample $0C,DAC_B4_C1_C2_C3_C4_Data,dHipHopHitKick
		declsample $0C,DAC_B5_Data,dHipHopHitPowerKick
		declsample $0C,DAC_B6_Data,dBassHey
		declsample $18,DAC_B7_Data,dDanceStyleKick
		declsample $0C,DAC_B8_B9_Data,dHipHopHitKick2
		declsample $0C,DAC_B8_B9_Data,dHipHopHitKick3
		declsample $18,DAC_BA_Data,dReverseFadingWind
		declsample $18,DAC_BB_Data,dScratchS3
		declsample $18,DAC_BC_Data,dLooseSnareNoise
		declsample $0C,DAC_BD_Data,dPowerKick2
		declsample $0C,DAC_BE_Data,dCrashingNoiseWoo
		declsample $1C,DAC_BF_Data,dQuickHit
		declsample $0B,DAC_C0_Data,dKickHey
		declsample $0F,DAC_B4_C1_C2_C3_C4_Data,dPowerKickHit
		declsample $11,DAC_B4_C1_C2_C3_C4_Data,dLowPowerKickHit
		declsample $12,DAC_B4_C1_C2_C3_C4_Data,dLowerPowerKickHit
		declsample $0B,DAC_B4_C1_C2_C3_C4_Data,dLowestPowerKickHit
	endif
	if (use_s2_samples<>0)
		declsample $17,DAC_C5_Data,dKick
		declsample $01,DAC_C6_Data,dSnare
		declsample $06,DAC_C7_Data,dClap
		declsample $08,DAC_C8_Data,dScratch
		declsample $1B,DAC_C9_CC_CD_CE_CF_Data,dTimpani
		declsample $0A,DAC_CA_D0_D1_D2_Data,dHiTom
		declsample $1B,DAC_CB_D3_D4_D5_Data,dVLowClap
		declsample $12,DAC_C9_CC_CD_CE_CF_Data,dHiTimpani
		declsample $15,DAC_C9_CC_CD_CE_CF_Data,dMidTimpani
		declsample $1C,DAC_C9_CC_CD_CE_CF_Data,dLowTimpani
		declsample $1D,DAC_C9_CC_CD_CE_CF_Data,dVLowTimpani
		declsample $02,DAC_CA_D0_D1_D2_Data,dMidTom
		declsample $05,DAC_CA_D0_D1_D2_Data,dLowTom
		declsample $08,DAC_CA_D0_D1_D2_Data,dFloorTom
		declsample $08,DAC_CB_D3_D4_D5_Data,dHiClap
		declsample $0B,DAC_CB_D3_D4_D5_Data,dMidClap
		declsample $12,DAC_CB_D3_D4_D5_Data,dLowClap
	endif
	if (use_s3d_samples<>0)
		declsample $01,DAC_D6_Data,dFinalFightMetalCrash
		declsample $12,DAC_D7_Data,dIntroKick
	endif
	if (use_s3_samples<>0)
		declsample $16,DAC_D8_D9_Data,dEchoedClapHit_S3
		declsample $20,DAC_D8_D9_Data,dLowerEchoedClapHit_S3
	endif
	endm
; ---------------------------------------------------------------------------
; MACRO Gen_Music_Table
; Meta-macro to generates the music data. Takes one macro as a parameter,
; which is used to generate the sample data.
;
; Note: do not use this directly; use one of GenMusicIDs, GenMusicBankTable,
; or Music_Master_Table instead. This is meant to be edited to fit the needs of
; the game, while these other macros use it so as to ensure consistency.
;
; Input:
;    declsong = macro to use to generate the music data. This should be one
;                 of zDeclSongID, zDeclSongPtr, or zDeclSongBank.
; Output:
;    None
Gen_Music_Table macro declsong

	; Levels
	declsong DEZ1

	; Main
	declsong Invincible

	; Bosses
	declsong MidBoss
	declsong ZoneBoss

	; End
	declsong GotThrough
	declsong Drowning
	endm
; ---------------------------------------------------------------------------
; MACRO Gen_Sound_Table
; Meta-macro to generates the SFX data. Takes one macro as a parameter,
; which is used to generate the sample data.
;
; Note: do not use this directly; use one of GenSndIDs,
; or Snd_Master_Table instead. This is meant to be edited to fit the needs of
; the game, while these other macros use it so as to ensure consistency.
;
; Input:
;    declsfx = macro to use to generate the SFX data. This should be one
;                 of zDeclSndID or zDeclSndPtr.
; Output:
;    None
Gen_Sound_Table macro declsfx
	declsfx RingRight
	declsfx RingLeft
	declsfx RingLoss
	declsfx Jump
	declsfx Roll
	declsfx Skid
	declsfx Death
	declsfx Spindash
	declsfx Splash
	declsfx InstaAttack
	declsfx FireShield
	declsfx BubbleShield
	declsfx LightningShield
	declsfx FireAttack
	declsfx BubbleAttack
	declsfx ElectricAttack
	declsfx SpikeHit
	declsfx SpikeMove
	declsfx Drown
	declsfx StarPost
	declsfx Spring
	declsfx Dash
	declsfx Break
	declsfx BossHit
	declsfx AirDing
	declsfx Bubble
	declsfx Explode
	declsfx Signpost
	declsfx Switch
	declsfx Register
	declsfx GroundSlide
	endm

; MACRO Gen_Sound_Table
; Meta-macro to generates the continuous SFX data. Takes one macro as a parameter,
; which is used to generate the sample data.
;
; Note: do not use this directly; use one of GenSndIDs,
; or Snd_Master_Table instead. This is meant to be edited to fit the needs of
; the game, while these other macros use it so as to ensure consistency.
;
; Input:
;    declsfx = macro to use to generate the SFX data. This should be one
;                 of zDeclSndID or zDeclSndPtr.
; Output:
;    None
Gen_ContinuousSound_Table macro declsfx
	; Empty
	endm
; ---------------------------------------------------------------------------

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
    if (wait)<>$F
	moveq	#signextendB(wait),d1
    endif
    if ("terminate"="0") || ("terminate"="")
	if (wait)<>$F
	    jsr	(Play_SFX_Continuous.main).w
	else
	    jsr	(Play_SFX_Continuous).w
	endif
    else
	if (wait)<>$F
	    jmp	(Play_SFX_Continuous.main).w
	else
	    jmp	(Play_SFX_Continuous).w
	endif
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
; Pause music
; ---------------------------------------------------------------------------

SMPS_PauseMusic macro
	zStopZ80
	move.b	#1,(Z80_RAM+zPauseFlag).l	; pause the music
	zStartZ80
    endm

; ---------------------------------------------------------------------------
; Unpause music
; ---------------------------------------------------------------------------

SMPS_UnpauseMusic macro
	zStopZ80
	move.b	#$80,(Z80_RAM+zPauseFlag).l	; unpause music
	zStartZ80
    endm
