; ---------------------------------------------------------------------------
; Subroutine to initialise game
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

EntryPoint:
		tst.l	(HW_Port_1_Control-1).l
		bne.s	.check
		tst.w	(HW_Expansion_Control-1).l

.check
		bne.s	Init_SkipPowerOn						; in case of a soft reset
		lea	SetupValues(pc),a5						; load setup values array address
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		moveq	#$F,d0								; compare
		and.b	HW_Version-Z80_bus_request(a1),d0				; get hardware version
		beq.s	SkipSecurity							; if the console has no tmss, skip the security stuff
		move.l	(Header).w,Security_addr-Z80_bus_request(a1)			; satisfy the TMSS

SkipSecurity:
		move.w	(a4),d0								; check if VDP works
		moveq	#0,d0								; clear d0
		movea.l	d0,a6								; clear a6
		move.l	a6,usp								; set usp to $0
		moveq	#VDPInitValues_end-VDPInitValues-1,d1				; run the following loop 24 times

Init_VDPRegs:
		move.b	(a5)+,d5							; add $8000 to value
		move.w	d5,(a4)								; move value to VDP register
		add.w	d7,d5								; next register
		dbf	d1,Init_VDPRegs							; set all 24 registers

		move.l	(a5)+,(a4)							; set VRAM write mode
		move.w	d0,(a3)								; clear the screen
		move.w	d7,(a1)								; stop the Z80
		move.w	d7,(a2)								; reset the Z80

WaitForZ80:
		btst	d0,(a1)								; has the Z80 stopped?
		bne.s	WaitForZ80							; if not, branch
		moveq	#Z80StartupCode_end-Z80StartupCodeBegin-1,d2

Init_SoundRAM:
		move.b	(a5)+,(a0)+
		dbf	d2,Init_SoundRAM

		move.w	d0,(a2)
		move.w	d0,(a1)								; start the Z80
		move.w	d7,(a2)								; reset the Z80

Init_ClearRAM:
		move.l	d0,-(a6)							; clear normal RAM
		dbf	d6,Init_ClearRAM						; repeat until the entire RAM is clear
		move.l	(a5)+,(a4)							; set VDP display mode and increment
		move.l	(a5)+,(a4)							; set VDP to CRAM write
		moveq	#bytesToLcnt($80),d3						; set repeat times

Init_ClearCRAM:
		move.l	d0,(a3)								; clear CRAM
		dbf	d3,Init_ClearCRAM						; repeat until the entire CRAM is clear
		move.l	(a5)+,(a4)							; set VDP to VSRAM write
		moveq	#bytesToLcnt($50),d4						; set repeat times

Init_ClearVSRAM:
		move.l	d0,(a3)								; clear VSRAM
		dbf	d4,Init_ClearVSRAM						; repeat until the entire VSRAM is clear
		moveq	#PSGInitValues_end-PSGInitValues-1,d5				; set repeat times

Init_InputPSG:
		move.b	(a5)+,PSG_input-VDP_data_port(a3)				; reset the PSG
		dbf	d5,Init_InputPSG						; repeat for other channels
		move.w	d0,(a2)
		movem.l	(a6),d0-a6							; clear all registers
		disableInts								; set the sr

Init_SkipPowerOn:
		bra.s	Game_Program							; branch to game program
; ---------------------------------------------------------------------------

SetupValues:
		dc.w $8000, bytesToLcnt($10000), $100					; VDP init, clear RAM, VDP init and Z80

.zram	dc.l Z80_RAM
.zbus	dc.l Z80_bus_request
.zreset	dc.l Z80_reset
.vdata	dc.l VDP_data_port
.vcontrol	dc.l VDP_control_port

		; values for VDP registers
VDPInitValues:
		dc.b 4									; command $8004 - HInt off, enable HV counter read
		dc.b $14								; command $8114 - display off, VInt off, DMA on, PAL off
		dc.b $30								; command $8230 - scroll A address $C000
		dc.b $3C								; command $833C - window address $F000
		dc.b 7									; command $8407 - scroll B address $E000
		dc.b $6C								; command $856C - sprite table addres $D800
		dc.b 0									; command $8600 - null
		dc.b 0									; command $8700 - background color Pal 0 Color 0
		dc.b 0									; command $8800 - null
		dc.b 0									; command $8900 - null
		dc.b $FF								; command $8AFF - Hint timing 256-1 scanlines
		dc.b 0									; command $8B00 - Ext Int off, VScroll full, HScroll full
		dc.b $81								; command $8C81 - 40 cell mode, shadow/highlight off, no interlace
		dc.b $37								; command $8D37 - HScroll table address $DC00
		dc.b 0									; command $8E00 - null
		dc.b 1									; command $8F01 - VDP auto increment 1 byte
		dc.b 1									; command $9001 - 64x32 cell scroll size
		dc.b 0									; command $9100 - window H left side, base point 0
		dc.b 0									; command $9200 - window V upside, base point 0
		dc.b $FF								; command $93FF - DMA length counter $FFFF
		dc.b $FF								; command $94FF - see above
		dc.b 0									; command $9500 - DMA source address $0
		dc.b 0									; command $9600 - see above
		dc.b $80								; command $9700 - see above + VRAM fill mode
VDPInitValues_end

		dc.l vdpComm(0,VRAM,DMA)						; value for VRAM write mode

		; Z80 instructions (not the sound driver; that gets loaded later)
Z80StartupCodeBegin:
		save
		CPU Z80									; start assembling Z80 code
		phase 0									; pretend we're at address 0

		xor	a								; clear a to 0
		ld	bc,((Z80_RAM_end-Z80_RAM)-zStartupCodeEndLoc)-1			; prepare to loop this many times
		ld	de,zStartupCodeEndLoc+1						; initial destination address
		ld	hl,zStartupCodeEndLoc						; initial source address
		ld	sp,hl								; set the address the stack starts at
		ld	(hl),a								; set first byte of the stack to 0
		ldir									; loop to fill the stack (entire remaining available Z80 RAM) with 0
		pop	ix								; clear ix
		pop	iy								; clear iy
		ld	i,a								; clear i
		ld	r,a								; clear r
		pop	de								; clear de
		pop	hl								; clear hl
		pop	af								; clear af
		ex	af,af'								; swap af with af'
		exx									; swap bc/de/hl with their shadow registers too
		pop	bc								; clear bc
		pop	de								; clear de
		pop	hl								; clear hl
		pop	af								; clear af
		ld	sp,hl								; clear sp
		di									; clear iff1 (for interrupt handler)
		im	1								; interrupt handling mode = 1
		ld	(hl),0E9h							; replace the first instruction with a jump to itself
		jp	(hl)								; jump to the first instruction (to stay there forever)
zStartupCodeEndLoc:
		dephase									; stop pretending
		restore
		padding off								; unfortunately our flags got reset so we have to set them again...
Z80StartupCode_end

		dc.w $8104								; value for VDP display mode
		dc.w $8F02								; value for VDP increment
		dc.l vdpComm(0,CRAM,WRITE)						; value for CRAM write mode
		dc.l vdpComm(0,VSRAM,WRITE)						; value for VSRAM write mode

PSGInitValues:
		dc.b $9F,$BF,$DF,$FF							; values for PSG channel volumes
PSGInitValues_end
