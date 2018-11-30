; ===============================================================
; ---------------------------------------------------------------
; Mega PCM v.1.1
; (C) 2012, Vladikcomper
; http://forums.sonicretro.org/index.php?showtopic=29057
; ---------------------------------------------------------------

	!org 0 ; Z80 code starting at address 0 has special meaning to s2p2bin.exe

	cpu	z80undoc
	listing purecode

; ---------------------------------------------------------------
; Constants
; ---------------------------------------------------------------

; Memory variables

MegaPCM_Stack		equ	0DFEh
MegaPCM_Ptr_InitPlayback equ	MegaPCM_Event_InitPlayback+1	; Init Playback event pointer
MegaPCM_Ptr_SoundProc	equ	MegaPCM_Event_SoundProc+1	; Sound process event pointer
MegaPCM_Ptr_Interrupt	equ	MegaPCM_Event_Interrupt+1	; Sound interrupt event pointer
MegaPCM_Ptr_EndPlayback	equ	MegaPCM_Event_EndPlayback+1	; End playback event pointer
MegaPCM_DAC_Number	equ	0DFFh				; Number of DAC sample to play ($81-based)
MegaPCM_Busy_Flag	equ	0DFEh				; Set if the driver is in the middle of a YM2612 operation

; Look-up tables

MegaPCM_DPCM_LowNibble	equ	0E00h
MegaPCM_DPCM_HighNibble	equ	0F00h
MegaPCM_VolumeTbls	equ	1000h

; System ports

MegaPCM_YM_Port0_Ctrl	equ	4000h
MegaPCM_YM_Port0_Data	equ	4001h
MegaPCM_YM_Port1_Ctrl	equ	4002h
MegaPCM_YM_Port1_Data	equ	4003h
MegaPCM_BankRegister	equ	6000h

; Sample struct vars

MegaPCM_flags	equ	0	; playback flags
MegaPCM_pitch	equ	1	; pitch value
MegaPCM_s_bank	equ	2	; start bank
MegaPCM_e_bank	equ	3	; end bank
MegaPCM_s_pos	equ	4	; start offset (in first bank)
MegaPCM_e_pos	equ	6	; end offset (in last bank)


; ===============================================================
; ---------------------------------------------------------------
; Driver initialization code
; ---------------------------------------------------------------

	di				; disable interrupts
;	di				; Clownacy | Aren't these redundant?
;	di				; Might as well save the space and cycles

	; Setup variables
	ld	sp,MegaPCM_Stack		; init SP
	call	MegaPCM_GenerateTables
	xor	a			; a = 0
	ld	(MegaPCM_DAC_Number),a		; reset DAC to play
	ld	h,a
	ld	l,a
	ld	(MegaPCM_Ptr_InitPlayback),hl	; reset 'InitPlayback' event
	ld	(MegaPCM_Ptr_SoundProc),hl	; reset 'SoundProc' event
	ld	(MegaPCM_Ptr_Interrupt),hl	; reset 'Interrupt' event
	ld	(MegaPCM_Ptr_EndPlayback),hl	; reset 'PlayOver' event
	ld	iy,MegaPCM_YM_Port0_Ctrl

; ---------------------------------------------------------------
; Idle loop, waiting DAC number input
; ---------------------------------------------------------------

MegaPCM_Idle_Loop:
	ld	hl,MegaPCM_DAC_Number

MegaPCM_Idle_WaitDAC:
	ld	a,(hl)			; load DAC number
;	or	a			; test it
;	jp	p,MegaPCM_Idle_WaitDAC	; if it's positive, branch

; ---------------------------------------------------------------
; Load DAC sample according to its number and play it
; ---------------------------------------------------------------

MegaPCM_LoadDAC:
	sub	81h			; subtract 81h from DAC number
	jr	c,MegaPCM_Idle_WaitDAC	; if a = 80h, branch
	ld	b,0h			; Clownacy | Moved this here so it can be used to clear the other areas quicker
	ld	(hl),b			; reset DAC number in RAM	; Clownacy | Now uses reg b (faster and smaller)

	; Load DAC table entry
	ld	ix,MegaPCM_DAC_Table	; ix = DAC Table
	ld	h,b			; Clownacy | Now uses reg b (faster and smaller)
	ld	l,a			; hl = DAC
	add	hl,hl			; hl = DAC*2
	add	hl,hl			; hl = DAC*4
	add	hl,hl			; hl = DAC*8
	ex	de,hl
	add	ix,de			; ix = DAC_Table + DAC*8

	; Init events table according to playback mode
	ld	a,(ix+MegaPCM_flags)	; a = Flags
	and	7h			; mask only Mode
	add	a,a			; a = Mode*2
	add	a,a			; a = Mode*4
	add	a,a			; a = Mode*8
	ld	c,a			; bc = Mode*8
	ld	hl,MegaPCM_Events_List
	add	hl,bc			; hl = Events_List + Mode*8
	ld	de,MegaPCM_Ptr_InitPlayback	; de = Events Pointers
	ld	bc,4FFh			; do 4 times, 'c' should never borrow 'b' on decrement
-	ldi				; transfer event pointer
	ldi				;
	inc	de			; skip a byte in events table ('jp' opcode)
	djnz	-

	jp	MegaPCM_Event_InitPlayback	; launch 'InitPlayback' event

; ---------------------------------------------------------------
; Setup YM to playback DAC
; ---------------------------------------------------------------

MegaPCM_WaitForYM2612:
	bit	7,(iy+0)
	jr	nz,MegaPCM_WaitForYM2612
	ret

; ---------------------------------------------------------------
; Setup YM to playback DAC
; ---------------------------------------------------------------

MegaPCM_SetupDAC:
	call	MegaPCM_WaitForYM2612
	ld	a,1
	ld	(MegaPCM_Busy_Flag),a
	ld	(iy+0),2Bh		;
	ld	(iy+1),80h		; YM => Enable DAC
	ld	a,(ix+MegaPCM_flags)		; load flags
	and	0C0h			; are pan bits set?
	jr	z,+			; if not, branch
	ld	(iy+2),0B6h		;
	ld	(iy+3),a		; YM => Set Pan
+
	xor	a
	ld	(MegaPCM_Busy_Flag),a
	call	MegaPCM_WaitForYM2612
	ld	(iy+0),2Ah		; setup YM to fetch DAC bytes
	ret

; ---------------------------------------------------------------
; Generate tables used by driver
; ---------------------------------------------------------------

MegaPCM_GenerateTables:
	; First, generate DPCM_LowNibble
	ld	de,MegaPCM_DPCM_LowNibble
	ld	b,10h
-
	push	bc
	ld	hl,MegaPCM_DPCM_DeltaArray
	ld	bc,MegaPCM_DPCM_DeltaArray_End-MegaPCM_DPCM_DeltaArray
	ldir
	pop	bc
	djnz	-

	; Now for DPCM_HighNibble
	ld	de,MegaPCM_DPCM_HighNibble
	ld	hl,MegaPCM_DPCM_DeltaArray
	ld	b,10h
-
	push	bc
	ld	a,(hl)
	ld	b,10h
-
	ld	(de),a
	inc	de
	djnz	-
	inc	hl
	pop	bc
	djnz	--

	; And finally the volume table

	; First, we construct the 80h-0FFh values of each volume level
	ld	iy,MegaPCM_Volume_DeltaArray
	ld	de,MegaPCM_VolumeTbls+80h
	ld	b,10h		; Volume level counter

-	push	bc
	ld	hl,8000h	; Volume accumulator
	ld	b,80h		; Index counter

-	push	bc

	; Send volume value to LUT
	ex	de,hl
	ld	(hl),d
	inc	hl
	ex	de,hl
	; Get delta, and add it to accumulator
	ld	c,(iy+0)
	ld	b,(iy+1)
	add	hl,bc

	pop	bc
	djnz	-

	; Next delta
	inc	iy
	inc	iy
	; Next volume LUT
	ld	bc,80h
	ex	de,hl
	add	hl,bc
	ex	de,hl

	pop	bc
	djnz	--

	; Now we make the 00h-7Fh values (we cheat, and just invert the 80h-0FFh values)
	ld	hl,MegaPCM_VolumeTbls+80h	; hl = source
	ld	b,10h		; Volume level counter

-	push	bc
	ld	d,h
	ld	e,l		; de = destination
	ld	b,80h		; Index counter

-	dec	de
	ld	a,(hl)	; Get value
	cpl	a	; Invert it
	ld	(de),a	; Send it
	inc	hl
	djnz	-

	; Next volume LUT
	ld	bc,80h
	add	hl,bc

	pop	bc
	djnz	--

	ret

MegaPCM_DPCM_DeltaArray:
	db	0, 1, 2, 4, 8, 10h, 20h, 40h
	db	-80h, -1, -2, -4, -8, -10h, -20h, -40h
MegaPCM_DPCM_DeltaArray_End

MegaPCM_Volume_DeltaArray:
	dw	100h*100h/100h, 0F0h*0F0h/100h, 0E0h*0E0h/100h, 0D0h*0D0h/100h
	dw	0C0h*0C0h/100h, 0B0h*0B0h/100h, 0A0h*0A0h/100h, 090h*090h/100h
	dw	080h*080h/100h, 070h*070h/100h, 060h*060h/100h, 050h*050h/100h
	dw	040h*040h/100h, 030h*030h/100h, 020h*020h/100h, 010h*010h/100h

; ---------------------------------------------------------------

MegaPCM_Events_List:
	;	Initplayback,		SoundProc,		Interrupt,		EndPlayback	;
	dw	MegaPCM_Init_PCM,	MegaPCM_Process_PCM,	MegaPCM_Int_Normal,	MegaPCM_StopDAC		; Mode 0
	dw	MegaPCM_Init_PCM,	MegaPCM_Process_PCM,	MegaPCM_Int_NoOverride,	MegaPCM_StopDAC		; Mode 1
	dw	MegaPCM_Init_PCM,	MegaPCM_Process_PCM,	MegaPCM_Int_Normal,	MegaPCM_Reload_PCM	; Mode 2
	dw	MegaPCM_Init_PCM,	MegaPCM_Process_PCM,	MegaPCM_Int_NoOverride,	MegaPCM_Reload_PCM	; Mode 3
	dw	MegaPCM_Init_DPCM,	MegaPCM_Process_DPCM,	MegaPCM_Int_Normal,	MegaPCM_StopDAC		; Mode 4
	dw	MegaPCM_Init_DPCM,	MegaPCM_Process_DPCM,	MegaPCM_Int_NoOverride,	MegaPCM_StopDAC		; Mode 5
	dw	MegaPCM_Init_DPCM,	MegaPCM_Process_DPCM,	MegaPCM_Int_Normal,	MegaPCM_Reload_DPCM	; Mode 6
	dw	MegaPCM_Init_DPCM,	MegaPCM_Process_DPCM,	MegaPCM_Int_NoOverride,	MegaPCM_Reload_DPCM	; Mode 7

; ===============================================================
; ---------------------------------------------------------------
; Dynamic Events Table, filled from 'Events_List'
; ---------------------------------------------------------------

MegaPCM_Event_InitPlayback:
	jp	0h

MegaPCM_Event_SoundProc:
	jp	0h
	
MegaPCM_Event_Interrupt:
	jp	0h

MegaPCM_Event_EndPlayback:
	jp	0h


; ===============================================================
; ---------------------------------------------------------------
; Routines to control sound playback (stop/pause/interrupt)
; ---------------------------------------------------------------
; NOTICE:
;	The following routines are 'Interrupt' event handlers,
;	they must't use any registers except A. If they does, 
;	it will break sample playback code.
;	You may do push/pop from stack though.
;	'StopDAC' is expection, as it breaks playback anyway.
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; DAC Interrupt: Normal Priority
; ---------------------------------------------------------------
; INPUT:
;	a	= Ctrl byte
; ---------------------------------------------------------------

MegaPCM_Int_Normal:
	cp	80h			; stop flag?
	jp	z,MegaPCM_StopDAC	; if yes, branch
	jp	m,MegaPCM_PauseDAC	; if < 80h, branch
	ld	hl,MegaPCM_DAC_Number
	jp	MegaPCM_LoadDAC

; ---------------------------------------------------------------
; DAC Interrupt: High Priority
; ---------------------------------------------------------------
; INPUT:
;	a	= Ctrl byte
; ---------------------------------------------------------------

MegaPCM_Int_NoOverride:
	cp	80h			; stop flag?
	jr	z,MegaPCM_StopDAC	; if yes, branch	; Clownacy | jp -> jr
	jp	m,MegaPCM_PauseDAC	; if < 80h, branch
	xor	a			; a = 0
	ld	(MegaPCM_DAC_Number),a	; clear DAC number to prevent later ints
	jr	MegaPCM_Event_SoundProc	; Clownacy | (jp -> jr)

; ---------------------------------------------------------------
; Code to wait while playback is paused
; ---------------------------------------------------------------

MegaPCM_PauseDAC:
	ld	(iy+1),80h		; stop sound

-	ld	a,(MegaPCM_DAC_Number)	; load ctrl byte
	or	a			; is byte zero?
	jr	nz,-			; if not, branch

	call	MegaPCM_SetupDAC	; setup YM for playback
	jr	MegaPCM_Event_SoundProc	; go on playing	; Clownacy | (jp -> jr)

; ---------------------------------------------------------------
; Stop DAC playback and get back to idle loop
; ---------------------------------------------------------------

MegaPCM_StopDAC:
	ld	(iy+1),80h		; stop sound
	jp	MegaPCM_Idle_Loop

; ---------------------------------------------------------------
; Routines to control bank-switching
; ---------------------------------------------------------------
; Bank-Switch Registers Set:
;	b'	= Current Bank Number
;	c'	= Last Bank Number
;	de'	= Bank Register
;	hl'	= End offset (bytes to play in last bank)
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; Inits bank-switch system and loads first bank
; ---------------------------------------------------------------

MegaPCM_InitBankSwitching:
	exx
	ld	d,(ix+MegaPCM_s_pos+1)
	ld	e,(ix+MegaPCM_s_pos)	; de' = start offset (in first bank)
	ld	h,(ix+MegaPCM_e_pos+1)
	ld	l,(ix+MegaPCM_e_pos)	; hl' = end offset (in last bank)
	ld	b,(ix+MegaPCM_s_bank)	; b'  = start bank number
	ld	c,(ix+MegaPCM_e_bank)	; c'  = end bank number

	ld	a,b			; load start bank number
	cp	c			; does the sample end in the first bank?
	jr	nz,.notLastBank		; if not, branch

;.lastBank:
	sbc	hl,de			; hl' = end offset - start offset
	set	7,h			; make the number 8000h-based
	call	MegaPCM_LastBankReached
	ld	a,b			; load start bank number
	jr	MegaPCM_LoadBank

.notLastBank:
	call	MegaPCM_LastBankNotReached
	ld	a,b			; load start bank number
	jr	MegaPCM_LoadBank

; ---------------------------------------------------------------
; Subroutine to switch to the next bank
; ---------------------------------------------------------------

MegaPCM_LoadNextBank:
	exx
	inc	b		; increase bank number

	; Check if last bank has been reached, and self-modify the PCM loops if so
	ld	a,c				; load last bank no.
	sub	b				; compare to current bank no.
	call	z,MegaPCM_LastBankReached	; if last bank is reached, branch

	ld	a,b		; load bank number

MegaPCM_LoadBank:
	ld	de,MegaPCM_BankRegister	; de' = bank register
	ld	(de), a	; A15
	rrca
	ld	(de), a	; A16
	rrca
	ld	(de), a	; A17
	rrca
	ld	(de), a	; A18
	rrca
	ld	(de), a	; A19
	rrca
	ld	(de), a	; A20
	rrca
	ld	(de), a	; A21
	rrca
	ld	(de), a	; A22
    if SMPS_IsOn32X
	ld	a,1
    else
	xor	a	; a = 0
    endif
	ld	(de), a	; A23
.volume:	; Clownacy | Modified by SetupVolume
	ld	d,MegaPCM_VolumeTbls>>8		; high byte of volume table pointer
	exx
	ret

; ===============================================================
; ---------------------------------------------------------------
; Routines to process PCM sound playback
; ---------------------------------------------------------------
; PCM Registers Set:
;	B	= Pitch Counter
;	C	= Pitch
;	DE	= Volume byte pointer
;	HL	= PCM byte pointer
;	B'	= Current bank
;	C'	= Final bank
;	HL'	= Number of bytes in last bank
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; Init PCM playback or reload PCM file
; ---------------------------------------------------------------

MegaPCM_Reload_PCM:

MegaPCM_Init_PCM:
	call	MegaPCM_SetupDAC
	call	MegaPCM_InitBankSwitching
	ld	c,(ix+MegaPCM_pitch)		; c  = pitch
	ld	h,(ix+MegaPCM_s_pos+1)		;
	ld	l,(ix+MegaPCM_s_pos)		; hl = Start offset
	set	7,h				; make it 8000h-based if it's not (perverts memory damage if playing corrupted slots)
.volume:	; Clownacy | Modified by SetupVolume
	ld	d,MegaPCM_VolumeTbls>>8		; high byte of volume table pointer
	ld	(iy+0),2Ah			; YM => prepare to fetch DAC bytes

; ---------------------------------------------------------------
; PCM Playback Loop
; ---------------------------------------------------------------

MegaPCM_Process_PCM:

	; Read sample's byte and send it to DAC with pitching
	ld	e,(hl)			; 7	; Clownacy | get PCM byte, de = pointer to volume data
	ld	b,c			; 4	; b = Pitch
	djnz	$			; 8/13+	; wait until pitch zero
	ld	a,(de)			; 7	; Clownacy | get volume-adjusted PCM byte
	ld	(MegaPCM_YM_Port0_Data),a	; 13	; write to DAC
	; Cycles: 39

	; Increment PCM byte pointer and switch the bank if necessary
	inc	hl			; 6	; next PCM byte
	bit	7,h			; 8	; has the bank warped?
	jr	z,+			; 7/12	; if yes, switch the bank
	; Cycles: 21

	; Check if sample playback is finished
	exx				; 4	;
MegaPCM_Process_PCM_writeme:
	; jp	MegaPCM_Process_PCM_idle	; 10	; Self-modified code that overwrites the following when we're on the last bank
	dec	hl			; 6	; decrease number of bytes to play in last bank
	bit	7,h			; 8	; is hl positive?
	jr	z,++			; 7/12	; if yes, quit playback loop
-	exx				; 4	;
	; Cycles: 29

	; Check if we should play a new sample
-	ld	a,(MegaPCM_DAC_Number)		; 13	; load DAC number
	or	a			; 4	; test it
	jp	z,MegaPCM_Process_PCM		; 10	; if zero, go on playing
	jp	MegaPCM_Event_Interrupt		;	; otherwise, interrupt playback
	; Cycles: 27

	; Synchronization loop (10 cycles)
MegaPCM_Process_PCM_idle:
	jp	--			; 10

	; Switch to next bank
+	ld	h,80h			; restore base addr
	call	MegaPCM_LoadNextBank
	jp	-

	; Quit playback loop
+	exx
	jp	MegaPCM_Event_EndPlayback

; ---------------------------------------------------------------
; Best cycles per loop:	116
; Max Possible rate:	3,579.545 kHz / 116 = 30.8 kHz (NTSC)
; ---------------------------------------------------------------

; ===============================================================
; ---------------------------------------------------------------
; Routines to process DPCM sound playback
; ---------------------------------------------------------------
; DPCM Registers Set:
;	B	= Pitch Counter / also DAC Value
;	C	= Pitch
;	DE	= DPCM byte pointer
;	HL	= Delta Table
;	B'	= Current bank
;	C'	= Final bank
;	DE'	= Volume byte pointer
;	HL'	= Number of bytes in last bank
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; Init DPCM playback or reload DPCM file
; ---------------------------------------------------------------

MegaPCM_Reload_DPCM:

MegaPCM_Init_DPCM:
	call	MegaPCM_SetupDAC
	call	MegaPCM_InitBankSwitching
	ld	c,(ix+MegaPCM_pitch)	; c  = pitch
	ld	d,(ix+MegaPCM_s_pos+1)	;
	ld	e,(ix+MegaPCM_s_pos)	; de = start offset
	set	7,d			; make it 8000h-based if it's not (perverts memory damage if playing corrupted slots)
	ld	(iy+0),2Ah		; YM => prepare to fetch DAC bytes
	ld	b,80h			; init DAC value
	ld	h,MegaPCM_DPCM_LowNibble>>8	; load delta table base

MegaPCM_Process_DPCM:

	; Calculate and send 2 values to DAC
	ld	a,(de)			; 7	; get a byte from DPCM stream
	inc	h			; 4	; load DPLC high nibble delta table base
	ld	l,a			; 4	; setup delta table index
	ld	a,b			; 4	; load DAC Value
	add	a,(hl)			; 7	; add delta to it
	ld	b,c			; 4	; b = Pitch
	djnz	$			; 8/13+	; wait until pitch zero
	ld	b,a			; 4	; b = DAC Value
	exx				; 4
	ld	e,a			; 4	; Clownacy | get address of volume-adjusted PCM byte
	ld	a,(de)			; 7	; Clownacy | get volume-adjusted PCM byte
	ld	(MegaPCM_YM_Port0_Data),a	; 13	; write to DAC
	exx				; 4
	; Cycles: 74

	dec	h			; 4	; load DPLC low nibble delta table base
	ld	a,b			; 4	; load DAC Value
	add	a,(hl)			; 7	; add delta to it
	ld	b,c			; 4	; b = Pitch
	djnz	$			; 8/13+	; wait until pitch zero
	ld	b,a			; 4	; b = DAC Value
	exx				; 4
	ld	e,a			; 4	; Clownacy | get address of volume-adjusted PCM byte
	ld	a,(de)			; 7	; Clownacy | get volume-adjusted PCM byte
	ld	(MegaPCM_YM_Port0_Data),a	; 13	; write to DAC
	exx				; 4
	; Cycles: 63

	; Increment DPCM byte pointer and switch the bank if necessary
	inc	de			; 6	; next DPCM byte
	bit	7,d			; 8	; has the bank warped?
	jr	z,+			; 7/12	; if no, switch the bank
	; Cycles: 21

	; Check if sample playback is finished
	exx				; 4	;
MegaPCM_Process_DPCM_writeme:
	; jp	MegaPCM_Process_DPCM_idle	; 10	; Self-modified code that overwrites the following when we're on the last bank
	dec	hl			; 6	; decrease number of bytes to play in last bank
	bit	7,h			; 8	; is hl positive?
	jr	z,++			; 7/12	; if yes, quit playback loop
-	exx				; 4	;
	; Cycles: 29

	; Check if we should play a new sample
-	ld	a,(MegaPCM_DAC_Number)	; 13	; load DAC number
	or	a			; 4	; test it
	jp	z,MegaPCM_Process_DPCM	; 10	; if zero, go on playing
	jp	MegaPCM_Event_Interrupt	;	; otherwise, interrupt playback
	; Cycles: 27

	; Synchronization loop (10 cycles)
MegaPCM_Process_DPCM_idle:
	jp	--			; 10

	; Switch to next bank
+	ld	d,80h			; restore base address
	call	MegaPCM_LoadNextBank
	jp	-

	; Quit playback loop
+	exx
	jp	MegaPCM_Event_EndPlayback

; ---------------------------------------------------------------
; Best cycles per loop:	214/2
; Max possible rate:	3,579.545 kHz / 107 = 33.4 kHz (NTSC)
; ---------------------------------------------------------------

MegaPCM_LastBankNotReached:
	ld	a,0C3h
	ld	(MegaPCM_Process_PCM_writeme),a
	ld	(MegaPCM_Process_DPCM_writeme),a
	ld	de,MegaPCM_Process_PCM_idle
	ld	(MegaPCM_Process_PCM_writeme+1),de
	ld	de,MegaPCM_Process_DPCM_idle
	ld	(MegaPCM_Process_DPCM_writeme+1),de
	ret

MegaPCM_LastBankReached:
	ld	a,2Bh
	ld	(MegaPCM_Process_PCM_writeme),a
	ld	(MegaPCM_Process_DPCM_writeme),a
	ld	de,07CCBh
	ld	(MegaPCM_Process_PCM_writeme+1),de
	ld	(MegaPCM_Process_DPCM_writeme+1),de
	ret

; ---------------------------------------------------------------
; NOTICE ABOUT PLAYBACK RATES:
;	YM is only capable of producing DAC sound @ ~26 kHz
;	frequency, overpassing it leads to missed writes!
;	The fact playback code can play faster than that
;	means there is a good amount of room for more features,
;	i.e. to waste even more processor cycles! ;)
; ---------------------------------------------------------------

; ===============================================================

; Table of DAC samples goes right after the code.

zmake68kPtr  function addr,8000h+(addr&7FFFh)
zmake68kBank function addr,(((addr&3F8000h)/8000h))

DAC_Entry macro vPitch,vOffset,vFlags
	db	vFlags			; 00h	- Flags

	; Lemme explain what's going on here: the Z80 is clocked at 3579545Hz.
	; 1Hz means 1 cycle per second. So, we divide the clock by the playback speed
	; we want. This gets us a kind of delta: the amount of cycles the Z80 needs to occupy
	; itself before sending the next sample, to get the correct playback speed.
	; Our way of controlling playback speed is through a 'djnz' instruction, so we need to
	; get a djnz counter from this delta. First, we subtract the number of cycles the actual
	; update loop takes - which, in the case of the PCM loop, is 130 - that will leave us
	; with the cycles that really matter: these are the 'spare' cycles, ones that won't
	; otherwise be used by the normal update loop. Instead, we artificially use them with
	; the aforementioned djnz loop. To get the djnz loop counter, we divide our remaining
	; cycles by the amount of cycles one djnz loop takes, which is 13. We also add 1,
	; because 1 to a djnz instruction technically means 0 (and 0 means 255, so we obviously
	; can't use that).
	; We use '*2' in the DPCM converter a couple of times because the DPCM loop updates
	; the sample twice (one for each nibble in a byte of sample data).
	; An extra thing we do is perform rounding, to get more-accurate conversions, hence
	; the '*10's and '+5'.

	if vFlags&MegaPCM_dpcm
		db	(((((((3579545*10)*2)/vPitch)-(214*10))/(13*2))+5)/10)+1	; 01h	- Pitch (DPCM-converted)
	else
		db	((((((3579545*10)/vPitch)-(116*10))/13)+5)/10)+1		; 01h	- Pitch (PCM-converted)
	endif
	db	zmake68kBank(vOffset)		; 02h	- Start Bank
	db	zmake68kBank(vOffset_End)	; 03h	- End Bank
	dw	zmake68kPtr(vOffset)		; 04h	- Start Offset (in Start bank)
	dw	zmake68kPtr(vOffset_End-1)	; 06h	- End Offset (in End bank)
	endm

DAC_Entry2 macro vPitch,vOffset,vFlags
	db	vFlags						; 00h	- Flags
	db	vPitch						; 01h	- Pitch
	db	zmake68kBank(vOffset)		; 02h	- Start Bank
	db	zmake68kBank(vOffset_End)	; 03h	- End Bank
	dw	zmake68kPtr(vOffset)			; 04h	- Start Offset (in Start bank)
	dw	zmake68kPtr(vOffset_End-1)	; 06h	- End Offset (in End bank)
	endm

; ---------------------------------------------------------------
; Variables used in DAC table
; ---------------------------------------------------------------

; flags
MegaPCM_panLR	= 0C0h
MegaPCM_panL	= 80h
MegaPCM_panR	= 40h
MegaPCM_pcm	= 0
MegaPCM_dpcm	= 4
MegaPCM_loop	= 2
MegaPCM_pri	= 1

	include "Sound/MegaPCM - DAC Table.asm"

	if $ > MegaPCM_Stack
		fatal "There's too much data before the stack! There should be less than \{MegaPCM_Stack}h bytes of data, but you're using \{$}h bytes!"
	endif
