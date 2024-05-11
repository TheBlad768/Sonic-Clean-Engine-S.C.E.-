; ---------------------------------------------------------------------------
; Subroutine to initialise game
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

EntryPoint:
		tst.l	(HW_Port_1_Control-1).l
		bne.s	+
		tst.w	(HW_Expansion_Control-1).l
+
		bne.s	Init_SkipPowerOn									; in case of a soft reset
		lea	SetupValues(pc),a5
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		moveq	#$F,d0
		and.b	HW_Version-Z80_bus_request(a1),d0				; get hardware version
		beq.s	SkipSecurity										; branch if hardware is older than Genesis III
		move.l	(Header).w,Security_addr-Z80_bus_request(a1)		; satisfy the TMSS

SkipSecurity:
		move.w	(a4),d0											; check if VDP works
		moveq	#0,d0
		movea.l	d0,a6
		move.l	a6,usp											; set usp to $0
		moveq	#VDPInitValues_End-VDPInitValues-1,d1

Init_VDPRegs:
		move.b	(a5)+,d5
		move.w	d5,(a4)
		add.w	d7,d5
		dbf	d1,Init_VDPRegs										; set all 24 registers

		move.l	(a5)+,(a4)										; set VRAM write mode
		move.w	d0,(a3)											; clear the screen
		move.w	d7,(a1)											; stop the Z80
		move.w	d7,(a2)											; reset the Z80

WaitForZ80:
		btst	d0,(a1)												; has the Z80 stopped?
		bne.s	WaitForZ80										; if not, branch
		moveq	#Z80StartupCodeEnd-Z80StartupCodeBegin-1,d2

Init_SoundRAM:
		move.b	(a5)+,(a0)+
		dbf	d2,Init_SoundRAM

		move.w	d0,(a2)
		move.w	d0,(a1)											; start the Z80
		move.w	d7,(a2)											; reset the Z80

Init_ClearRAM:
		move.l	d0,-(a6)											; clear normal RAM
		dbf	d6,Init_ClearRAM
		move.l	(a5)+,(a4)										; set VDP display mode and increment
		move.l	(a5)+,(a4)										; set VDP to CRAM write
		moveq	#bytesToLcnt($80),d3

Init_ClearCRAM:
		move.l	d0,(a3)											; clear CRAM
		dbf	d3,Init_ClearCRAM
		move.l	(a5)+,(a4)
		moveq	#bytesToLcnt($50),d4

Init_ClearVSRAM:
		move.l	d0,(a3)											; clear VSRAM
		dbf	d4,Init_ClearVSRAM
		moveq	#PSGInitValues_End-PSGInitValues-1,d5

Init_InputPSG:
		move.b	(a5)+,PSG_input-VDP_data_port(a3)				; reset the PSG
		dbf	d5,Init_InputPSG
		move.w	d0,(a2)
		movem.l	(a6),d0-a6										; clear all registers
		disableInts												; set the sr

Init_SkipPowerOn:
		bra.s	Game_Program									; begin game
; ---------------------------------------------------------------------------
; InitArray:
SetupValues:
		dc.w $8000, bytesToLcnt($10000), $100						; VDP init, clear RAM, VDP init and Z80

.zram	dc.l Z80_RAM
.zbus	dc.l Z80_bus_request
.zreset	dc.l Z80_reset
.vdata	dc.l VDP_data_port
.vcontrol	dc.l VDP_control_port

VDPInitValues:													; values for VDP registers
		dc.b 4													; command $8004 - HInt off, Enable HV counter read
		dc.b $14													; command $8114 - Display off, VInt off, DMA on, PAL off
		dc.b $30													; command $8230 - Scroll A Address $C000
		dc.b $3C													; command $833C - Window Address $F000
		dc.b 7													; command $8407 - Scroll B Address $E000
		dc.b $6C													; command $856C - Sprite Table Addres $D800
		dc.b 0													; command $8600 - Null
		dc.b 0													; command $8700 - Background color Pal 0 Color 0
		dc.b 0													; command $8800 - Null
		dc.b 0													; command $8900 - Null
		dc.b $FF													; command $8AFF - Hint timing $FF scanlines
		dc.b 0													; command $8B00 - Ext Int off, VScroll full, HScroll full
		dc.b $81													; command $8C81 - 40 cell mode, shadow/highlight off, no interlace
		dc.b $37													; command $8D37 - HScroll Table Address $DC00
		dc.b 0													; command $8E00 - Null
		dc.b 1													; command $8F01 - VDP auto increment 1 byte
		dc.b 1													; command $9001 - 64x32 cell scroll size
		dc.b 0													; command $9100 - Window H left side, Base Point 0
		dc.b 0													; command $9200 - Window V upside, Base Point 0
		dc.b $FF													; command $93FF - DMA Length Counter $FFFF
		dc.b $FF													; command $94FF - See above
		dc.b 0													; command $9500 - DMA Source Address $0
		dc.b 0													; command $9600 - See above
		dc.b $80													; command $9700 - See above + VRAM fill mode
VDPInitValues_End

		dc.l vdpComm($0000,VRAM,DMA)							; value for VRAM write mode

		; Z80 instructions (not the sound driver; that gets loaded later)
Z80StartupCodeBegin:
	save
	CPU Z80														; start assembling Z80 code
	phase 0														; pretend we're at address 0
		xor	a													; clear a to 0
		ld	bc,((Z80_RAM_end-Z80_RAM)-zStartupCodeEndLoc)-1	; prepare to loop this many times
		ld	de,zStartupCodeEndLoc+1								; initial destination address
		ld	hl,zStartupCodeEndLoc								; initial source address
		ld	sp,hl												; set the address the stack starts at
		ld	(hl),a												; set first byte of the stack to 0
		ldir														; loop to fill the stack (entire remaining available Z80 RAM) with 0
		pop	ix													; clear ix
		pop	iy													; clear iy
		ld	i,a													; clear i
		ld	r,a													; clear r
		pop	de													; clear de
		pop	hl													; clear hl
		pop	af													; clear af
		ex	af,af'												; swap af with af'
		exx														; swap bc/de/hl with their shadow registers too
		pop	bc													; clear bc
		pop	de													; clear de
		pop	hl													; clear hl
		pop	af													; clear af
		ld	sp,hl												; clear sp
		di														; clear iff1 (for interrupt handler)
		im	1													; interrupt handling mode = 1
		ld	(hl),0E9h											; replace the first instruction with a jump to itself
		jp	(hl)													; jump to the first instruction (to stay there forever)
zStartupCodeEndLoc:
	dephase														; stop pretending
		restore
	padding off													; unfortunately our flags got reset so we have to set them again...
Z80StartupCodeEnd:

		dc.w	$8104												; value for VDP display mode
		dc.w	$8F02												; value for VDP increment
		dc.l vdpComm($0000,CRAM,WRITE)						; value for CRAM write mode
		dc.l vdpComm($0000,VSRAM,WRITE)						; value for VSRAM write mode

PSGInitValues:
		dc.b	$9F,$BF,$DF,$FF										; values for PSG channel volumes
PSGInitValues_End
