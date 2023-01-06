; ---------------------------------------------------------------------------
; Subroutine to initialise game
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

EntryPoint:
		tst.l	(HW_Port_1_Control-1).l
		bne.s	+
		tst.w	(HW_Expansion_Control-1).l
+
		bne.s	Init_SkipPowerOn	; in case of a soft reset
		lea	SetupValues(pc),a5
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	HW_Version-Z80_bus_request(a1),d0	; get hardware version
		andi.b	#$F,d0
		beq.s	SkipSecurity ; branch if hardware is older than Genesis III
		move.l	(Header).w,Security_addr-Z80_bus_request(a1) ; satisfy the TMSS

SkipSecurity:
		move.w	(a4),d0	; check if VDP works
		moveq	#0,d0
		movea.l	d0,a6
		move.l	a6,usp	; set usp to $0
		moveq	#VDPInitValues_End-VDPInitValues-1,d1

Init_VDPRegs:
		move.b	(a5)+,d5
		move.w	d5,(a4)
		add.w	d7,d5
		dbf	d1,Init_VDPRegs	; set all 24 registers

		move.l	(a5)+,(a4)	; set VRAM write mode
		move.w	d0,(a3)	; clear the screen
		move.w	d7,(a1)	; stop the Z80
		move.w	d7,(a2)	; reset the Z80

WaitForZ80:
		btst	d0,(a1)	; has the Z80 stopped?
		bne.s	WaitForZ80	; if not, branch
		moveq	#Z80StartupCodeEnd-Z80StartupCodeBegin-1,d2

Init_SoundRAM:
		move.b	(a5)+,(a0)+
		dbf	d2,Init_SoundRAM

		move.w	d0,(a2)
		move.w	d0,(a1)	; start the Z80
		move.w	d7,(a2)	; reset the Z80

Init_ClearRAM:
		move.l	d0,-(a6)		; Clear normal RAM
		dbf	d6,Init_ClearRAM
		move.l	(a5)+,(a4)	; set VDP display mode and increment
		move.l	(a5)+,(a4)	; set VDP to CRAM write
		moveq	#bytesToLcnt($80),d3

Init_ClearCRAM:
		move.l	d0,(a3)			; Clear CRAM
		dbf	d3,Init_ClearCRAM
		move.l	(a5)+,(a4)
		moveq	#bytesToLcnt($50),d4

Init_ClearVSRAM:
		move.l	d0,(a3)			; Clear VSRAM
		dbf	d4,Init_ClearVSRAM
		moveq	#PSGInitValues_End-PSGInitValues-1,d5

Init_InputPSG:
		move.b	(a5)+,PSG_input-VDP_data_port(a3) ; reset the PSG
		dbf	d5,Init_InputPSG
		move.w	d0,(a2)
		movem.l	(a6),d0-a6	; clear all registers
		disableInts			; set the sr

Init_SkipPowerOn:
		bra.s	Game_Program	; begin game
; ---------------------------------------------------------------------------
; InitArray:
SetupValues:
		dc.w $8000,bytesToLcnt($10000),$100

.ram	dc.l Z80_RAM
.bus		dc.l Z80_bus_request
.reset	dc.l Z80_reset
.data	dc.l VDP_data_port
.control	dc.l VDP_control_port

VDPInitValues:		; values for VDP registers
		dc.b 4		; Command $8004 - HInt off, Enable HV counter read
		dc.b $14		; Command $8114 - Display off, VInt off, DMA on, PAL off
		dc.b $30		; Command $8230 - Scroll A Address $C000
		dc.b $3C		; Command $833C - Window Address $F000
		dc.b 7		; Command $8407 - Scroll B Address $E000
		dc.b $6C		; Command $856C - Sprite Table Addres $D800
		dc.b 0		; Command $8600 - Null
		dc.b 0		; Command $8700 - Background color Pal 0 Color 0
		dc.b 0		; Command $8800 - Null
		dc.b 0		; Command $8900 - Null
		dc.b $FF		; Command $8AFF - Hint timing $FF scanlines
		dc.b 0		; Command $8B00 - Ext Int off, VScroll full, HScroll full
		dc.b $81		; Command $8C81 - 40 cell mode, shadow/highlight off, no interlace
		dc.b $37		; Command $8D37 - HScroll Table Address $DC00
		dc.b 0		; Command $8E00 - Null
		dc.b 1		; Command $8F01 - VDP auto increment 1 byte
		dc.b 1		; Command $9001 - 64x32 cell scroll size
		dc.b 0		; Command $9100 - Window H left side, Base Point 0
		dc.b 0		; Command $9200 - Window V upside, Base Point 0
		dc.b $FF		; Command $93FF - DMA Length Counter $FFFF
		dc.b $FF		; Command $94FF - See above
		dc.b 0		; Command $9500 - DMA Source Address $0
		dc.b 0		; Command $9600 - See above
		dc.b $80		; Command $9700 - See above + VRAM fill mode
VDPInitValues_End:

		dc.l	vdpComm($0000,VRAM,DMA) ; value for VRAM write mode

		; Z80 instructions (not the sound driver; that gets loaded later)
Z80StartupCodeBegin:
	if (*)+$26 < $10000
	save
	CPU Z80 ; start assembling Z80 code
	phase 0 ; pretend we're at address 0
		xor	a	; clear a to 0
		ld	bc,((Z80_RAM_end-Z80_RAM)-zStartupCodeEndLoc)-1 ; prepare to loop this many times
		ld	de,zStartupCodeEndLoc+1	; initial destination address
		ld	hl,zStartupCodeEndLoc	; initial source address
		ld	sp,hl	; set the address the stack starts at
		ld	(hl),a	; set first byte of the stack to 0
		ldir		; loop to fill the stack (entire remaining available Z80 RAM) with 0
		pop	ix	; clear ix
		pop	iy	; clear iy
		ld	i,a	; clear i
		ld	r,a	; clear r
		pop	de	; clear de
		pop	hl	; clear hl
		pop	af	; clear af
		ex	af,af'	; swap af with af'
		exx		; swap bc/de/hl with their shadow registers too
		pop	bc	; clear bc
		pop	de	; clear de
		pop	hl	; clear hl
		pop	af	; clear af
		ld	sp,hl	; clear sp
		di		; clear iff1 (for interrupt handler)
		im	1	; interrupt handling mode = 1
		ld	(hl),0E9h ; replace the first instruction with a jump to itself
		jp	(hl)	  ; jump to the first instruction (to stay there forever)
zStartupCodeEndLoc:
	dephase ; stop pretending
		restore
	padding off ; unfortunately our flags got reset so we have to set them again...
	else ; due to an address range limitation I could work around but don't think is worth doing so:
		message "Warning: using pre-assembled Z80 startup code."
		dc.w $AF01,$D91F,$1127,$0021,$2600,$F977,$EDB0,$DDE1,$FDE1,$ED47,$ED4F,$D1E1,$F108,$D9C1,$D1E1,$F1F9,$F3ED,$5636,$E9E9
	endif
Z80StartupCodeEnd:

		dc.w	$8104	; value for VDP display mode
		dc.w	$8F02	; value for VDP increment
		dc.l	vdpComm($0000,CRAM,WRITE)	; value for CRAM write mode
		dc.l	vdpComm($0000,VSRAM,WRITE)	; value for VSRAM write mode

PSGInitValues:
		dc.b	$9F,$BF,$DF,$FF	; values for PSG channel volumes
PSGInitValues_End:
; ---------------------------------------------------------------------------

Game_Program:
		move.w	#$4EF9,(V_int_jump).w					; machine code for jmp
		move.l	#VInt,(V_int_addr).w
		move.w	#$4EF9,(H_int_jump).w
		move.l	#HInt,(H_int_addr).w

.wait
		move.w	(VDP_control_port).l,d1
		btst	#1,d1
		bne.s	.wait	; wait till a DMA is completed
		lea	((RAM_start&$FFFFFF)).l,a6
		moveq	#0,d7
		move.w	#bytesToLcnt(System_stack&$FFFF),d6

.clear
		move.l	d7,(a6)+
		dbf	d6,.clear
		btst	#6,(HW_Expansion_Control).l
		beq.s	.skip
		cmpi.l	#Ref_Checksum_String,(Checksum_string).w	; has checksum routine already run?
		beq.s	.init										; if yes, branch

.skip
		move.b	(HW_Version).l,d6
		andi.b	#$C0,d6
		move.b	d6,(Graphics_flags).w						; get region setting
		move.l	#Ref_Checksum_String,(Checksum_string).w	; set flag so checksum won't run again

.init
		jsr	(Init_MSU_Driver).l
		seq	(SegaCD_Mode).w
		bsr.w	Init_DMA_Queue
		bsr.s	Init_VDP
		bsr.w	SoundDriverLoad
		bsr.w	Init_Controllers
		move.b	#id_LevelSelectScreen,(Game_mode).w		; set Game Mode

.loop
		move.b	(Game_mode).w,d0						; load Game Mode
		andi.w	#$7C,d0
		movea.l	Game_Modes(pc,d0.w),a0
		jsr	(a0)
		bra.s	.loop
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

Game_Modes:
ptr_LevelSelect:	dc.l LevelSelect_Screen		; Level Select ($00)
ptr_Level:		dc.l Level_Screen			; Level ($04)
