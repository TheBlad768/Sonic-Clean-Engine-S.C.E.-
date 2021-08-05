; ===========================================================================
; Macros
; ===========================================================================

; ---------------------------------------------------------------------------
; simplifying macros and functions
; nameless temporary symbols should NOT be used inside macros because they can interfere with the surrounding code
; normal labels should be used instead (which automatically become local to the macro)
; ---------------------------------------------------------------------------

; makes a VDP address difference
vdpCommDelta function addr,((addr&$3FFF)<<16)|((addr&$C000)>>14)

; makes a VDP command
vdpComm function addr,type,rwd,(((type&rwd)&3)<<30)|((addr&$3FFF)<<16)|(((type&rwd)&$FC)<<2)|((addr&$C000)>>14)

; sign-extends a 32-bit integer to 64-bit
; all RAM addresses are run through this function to allow them to work in both 16-bit and 32-bit addressing modes
ramaddr function x,(-(x&$80000000)<<1)|x

; values for the type argument
VRAM = %100001
CRAM = %101011
VSRAM = %100101

; values for the rwd argument
READ = %001100
WRITE = %000111
DMA = %100111

; tells the VDP to copy a region of 68k memory to VRAM or CRAM or VSRAM
dma68kToVDP macro source,dest,length,type
	lea	(VDP_control_port).l,a5
	move.l	#(($9400|((((length)>>1)&$FF00)>>8))<<16)|($9300|(((length)>>1)&$FF)),VDP_control_port-VDP_control_port(a5)
	move.l	#(($9600|((((source)>>1)&$FF00)>>8))<<16)|($9500|(((source)>>1)&$FF)),VDP_control_port-VDP_control_port(a5)
	move.w	#$9700|(((((source)>>1)&$FF0000)>>16)&$7F),VDP_control_port-VDP_control_port(a5)
	move.w	#((vdpComm(dest,type,DMA)>>16)&$FFFF),VDP_control_port-VDP_control_port(a5)
	move.w	#(vdpComm(dest,type,DMA)&$FFFF),(DMA_trigger_word).w
	move.w	(DMA_trigger_word).w,VDP_control_port-VDP_control_port(a5)
    endm

; tells the VDP to fill a region of VRAM with a certain byte
dmaFillVRAM macro byte,addr,length
	lea	(VDP_control_port).l,a5
	move.w	#$8F01,VDP_control_port-VDP_control_port(a5) ; VRAM pointer increment: $0001
	move.l	#(($9400|((((length)-1)&$FF00)>>8))<<16)|($9300|(((length)-1)&$FF)),VDP_control_port-VDP_control_port(a5) ; DMA length ...
	move.w	#$9780,VDP_control_port-VDP_control_port(a5) ; VRAM fill
	move.l	#$40000080|(((addr)&$3FFF)<<16)|(((addr)&$C000)>>14),VDP_control_port-VDP_control_port(a5) ; Start at ...
	move.w	#(byte)<<8,(VDP_data_port).l ; Fill with byte
.loop:
	move.w	VDP_control_port-VDP_control_port(a5),d1
	btst	#1,d1
	bne.s	.loop	; busy loop until the VDP is finished filling...
	move.w	#$8F02,VDP_control_port-VDP_control_port(a5) ; VRAM pointer increment: $0002
    endm

; -------------------------------------------------------------
; Macro to check button presses
; Arguments:
; 1 - buttons to check
; -------------------------------------------------------------

tpress:	macro press,player
		if player=2
	move.b	(Ctrl_2_pressed).w,d0
		else
	move.b	(Ctrl_1_pressed).w,d0
		endif
	andi.b	#(press),d0
    endm

; -------------------------------------------------------------
; Macro to check if buttons are held
; Arguments:
; 1 - buttons to check
; -------------------------------------------------------------

theld:	macro press,player
		if player=2
	move.b	(Ctrl_2_held).w,d0
		else
	move.b	(Ctrl_1_held).w,d0
		endif
	andi.b	#(press),d0
    endm

; ---------------------------------------------------------------------------
; Set a VRAM address via the VDP control port.
; input: 16-bit VRAM address, control port (default is ($C00004).l)
; ---------------------------------------------------------------------------

locVRAM:	macro loc,controlport
	if ("controlport"=="")
	move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),(VDP_control_port).l
	else
	move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),controlport
	endif
    endm

; macro for a debug object list header
; must be on the same line as a label that has a corresponding _End label later
dbglistheader macro {INTLABEL}
__LABEL__ label *
	dc.w ((__LABEL___End - __LABEL__ - 2) / $A)
    endm

; macro to define debug list object data
dbglistobj macro   obj, mapaddr, subtype, frame, vram
	dc.l frame<<24|obj
	dc.l subtype<<24|mapaddr
	dc.w vram
    endm

palp macro paladdress,ramaddress,colours
	dc.l paladdress
	dc.w ramaddress, (colours>>1)-1
	endm

; macro for declaring a "main level load block" (MLLB)
levartptrs macro art,map16x16,map128x128,palette
	dc.l palette<<24|art
	dc.l map16x16
	dc.l map128x128
    endm

; macro to declare sub-object data
subObjData macro mappings,vram,priority,width,height,frame,collision
	dc.l mappings
	dc.w vram,priority
	dc.b width,height,frame,collision
    endm

; macro to declare sub-object slotted data
subObjSlotData macro slots,vram,offset,index,mappings,priority,width,height,frame,collision
	dc.w slots,vram,offset,index
	dc.l mappings
	dc.w priority
	dc.b width,height,frame,collision
    endm

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 4 bytes per iteration
bytesTo4Lcnt function n,n>>4

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 4 bytes per iteration
bytesTo2Lcnt function n,n>>2

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 4 bytes per iteration
bytesToLcnt function n,n>>2-1

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 2 bytes per iteration
bytesToWcnt function n,n>>1-1

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at x bytes per iteration
bytesToXcnt function n,x,n/x-1

; fills a region of 68k RAM with 0
clearRAM macro startaddr,endaddr
    if ((startaddr)&$8000)==0
	lea	(startaddr).l,a1
    else
	lea	(startaddr).w,a1
    endif
	moveq	#0,d0
    if ((startaddr)&1)
	move.b	d0,(a1)+
    endif
	move.w	#bytesToLcnt((endaddr-startaddr) - ((startaddr)&1)),d1
-	move.l	d0,(a1)+
	dbf	d1,-
    if (((endaddr-startaddr) - ((startaddr)&1))&2)
	move.w	d0,(a1)+
    endif
    if (((endaddr-startaddr) - ((startaddr)&1))&1)
	move.b	d0,(a1)+
    endif
    endm

; fills a region of 68k RAM with 0
clearRAM2 macro startaddr,endaddr
    if ((startaddr)&$8000)==0
	lea	(startaddr).l,a1
    else
	lea	(startaddr).w,a1
    endif
	moveq	#0,d0
    if ((startaddr)&1)
	move.b	d0,(a1)+
    endif
    rept bytesTo2Lcnt((endaddr-startaddr) - ((startaddr)&1))
	move.l	d0,(a1)+
    endm
    if (((endaddr-startaddr) - ((startaddr)&1))&2)
	move.w	d0,(a1)+
    endif
    if (((endaddr-startaddr) - ((startaddr)&1))&1)
	move.b	d0,(a1)+
    endif
    endm

; fills a region of 68k RAM with 0 (4 bytes at a time)
clearRAM3 macro addr,length
    if ((addr)&$8000)==0
	lea	(addr).l,a1
    else
	lea	(addr).w,a1
    endif
	moveq	#0,d0
	move.w	#bytesTo4Lcnt(length-addr),d1
-	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	dbf	d1,-
    endm

; ---------------------------------------------------------------------------
; clear the Z80 RAM
; ---------------------------------------------------------------------------

clearZ80RAM macro
	lea	(Z80_RAM).l,a0
	move.w	#$1FFF,d0
-	clr.b (a0)+
	dbf	d0,-
    endm

paddingZ80RAM macro
	moveq	#0,d0
-	move.b	d0,(a1)+
	cmpa.l	#(Z80_RAM_end),a1
	bne.s	-
    endm

; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------

; tells the Z80 to stop, and waits for it to finish stopping (acquire bus)
stopZ80 macro

	if OptimiseStopZ80=0
	move.w	#$100,(Z80_bus_request).l ; stop the Z80
	nop
	nop
	nop
-	btst	#0,(Z80_bus_request).l
	bne.s	- 	; loop until it says it's stopped
	endif

    endm

; tells the Z80 to stop, and waits for it to finish stopping (acquire bus)
stopZ80a macro

	if OptimiseStopZ80=0
	move.w	#$100,(Z80_bus_request).l ; stop the Z80
	endif

    endm

; ---------------------------------------------------------------------------
; wait for Z80 to stop
; ---------------------------------------------------------------------------

; tells the Z80 to wait for it to finish stopping (acquire bus)
waitZ80 macro

	if OptimiseStopZ80=0
-	btst	#0,(Z80_bus_request).l
	bne.s	- 	; loop until
	endif

    endm

; ---------------------------------------------------------------------------
; reset the Z80
; ---------------------------------------------------------------------------

; tells the Z80 to reset
resetZ80 macro

	if OptimiseStopZ80=0
	move.w	#$100,(Z80_reset).l
	endif

    endm

; tells the Z80 to reset
resetZ80a macro

	if OptimiseStopZ80=0
	clr.w	(Z80_reset).l
	endif

    endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------

; tells the Z80 to start again
startZ80 macro

	if OptimiseStopZ80=0
	clr.w	(Z80_bus_request).l    ; start the Z80
	endif

    endm

; ---------------------------------------------------------------------------
; stop the Z80 (2)
; ---------------------------------------------------------------------------

; tells the Z80 to stop, and waits for it to finish stopping (acquire bus)
stopZ802 macro

	if OptimiseStopZ80=2
	move.w	#$100,(Z80_bus_request).l ; stop the Z80
	nop
	nop
	nop
-	btst	#0,(Z80_bus_request).l
	bne.s	- 	; loop until it says it's stopped
	endif

    endm

; ---------------------------------------------------------------------------
; start the Z80 (2)
; ---------------------------------------------------------------------------

; tells the Z80 to start again
startZ802 macro

	if OptimiseStopZ80=2
	clr.w	(Z80_bus_request).l    ; start the Z80
	endif

    endm

; ---------------------------------------------------------------------------
; wait for the Z80
; ---------------------------------------------------------------------------

waitZ80time macro time
	move.w	#(time),d0
-	nop
	dbf	d0,-
    endm

; ---------------------------------------------------------------------------
; disable interrupts
; ---------------------------------------------------------------------------

disableInts macro
	move	#$2700,sr
    endm

; ---------------------------------------------------------------------------
; enable interrupts
; ---------------------------------------------------------------------------

enableInts macro
	move	#$2300,sr
    endm

; ---------------------------------------------------------------------------
; disable interrupts
; ---------------------------------------------------------------------------

disableIntsSave macro
	move.w	sr,-(sp)		; Save current interrupt mask
	disableInts			; Mask off interrupts
    endm

; ---------------------------------------------------------------------------
; enable interrupts
; ---------------------------------------------------------------------------

enableIntsSave macro
	move.w	(sp)+,sr		; Restore interrupts to previous state
    endm

; ---------------------------------------------------------------------------
; disable screen
; ---------------------------------------------------------------------------

disableScreen macro
		move.w	(VDP_reg_1_command).w,d0
		andi.b	#%10111111,d0
		move.w	d0,(VDP_control_port).l
    endm

; ---------------------------------------------------------------------------
; enable screen
; ---------------------------------------------------------------------------

enableScreen macro
		moveq	#%1000000,d0
		or.w	(VDP_reg_1_command).w,d0
		move.w	d0,(VDP_control_port).l
    endm

; ---------------------------------------------------------------------------
; long conditional jumps
; ---------------------------------------------------------------------------

jhi:		macro loc
		bls.s	.nojump
		jmp	loc
.nojump:
	    endm

jcc:		macro loc
		bcs.s	.nojump
		jmp	loc
.nojump:
	    endm

jhs:		macro loc
		jcc	loc
	    endm

jls:		macro loc
		bhi.s	.nojump
		jmp	loc
.nojump:
	    endm

jcs:		macro loc
		bcc.s	.nojump
		jmp	loc
.nojump:
	    endm

jlo:		macro loc
		jcs	loc
	    endm

jeq:		macro loc
		bne.s	.nojump
		jmp	loc
.nojump:
	    endm

jne:		macro loc
		beq.s	.nojump
		jmp	loc
.nojump:
	    endm

jgt:		macro loc
		ble.s	.nojump
		jmp	loc
.nojump:
	    endm

jge:		macro loc
		blt.s	.nojump
		jmp	loc
.nojump:
	    endm

jle:		macro loc
		bgt.s	.nojump
		jmp	loc
.nojump:
	    endm

jlt:		macro loc
		bge.s	.nojump
		jmp	loc
.nojump:
	    endm

jpl:		macro loc
		bmi.s	.nojump
		jmp	loc
.nojump:
	    endm

jmi:		macro loc
		bpl.s	.nojump
		jmp	loc
.nojump:
	    endm

; macros to convert from tile index to art tiles, block mapping or VRAM address.
make_art_tile function addr,pal,pri,((pri&1)<<15)|((pal&3)<<13)|(addr&tile_mask)
tiles_to_bytes function addr,((addr&$7FF)<<5)

; function to calculate the location of a tile in plane mappings with a width of 40 cells
planeLocH32 function col,line,(($40 * line) + (2 * col))

; function to calculate the location of a tile in plane mappings with a width of 40 cells
planeLocH28 function col,line,(($50 * line) + (2 * col))

; function to calculate the location of a tile in plane mappings with a width of 64 cells
planeLocH40 function col,line,(($80 * line) + (2 * col))

; function to calculate the location of a tile in plane mappings with a width of 128 cells
planeLocH80 function col,line,(($100 * line) + (2 * col))
; ---------------------------------------------------------------------------

_Kos_UseLUT := 1
_Kos_LoopUnroll := 3
_Kos_ExtremeUnrolling := 1

_Kos_RunBitStream macro
	dbra	d2,.skip
	moveq	#7,d2				; Set repeat count to 8.
	move.b	d1,d0				; Use the remaining 8 bits.
	not.w	d3					; Have all 16 bits been used up?
	bne.s	.skip				; Branch if not.
	move.b	(a0)+,d0				; Get desc field low-byte.
	move.b	(a0)+,d1				; Get desc field hi-byte.
	if _Kos_UseLUT==1
		move.b	(a4,d0.w),d0		; Invert bit order...
		move.b	(a4,d1.w),d1		; ... for both bytes.
	endif
.skip
    endm

_Kos_ReadBit macro
	if _Kos_UseLUT==1
		add.b	d0,d0			; Get a bit from the bitstream.
	else
		lsr.b	#1,d0				; Get a bit from the bitstream.
	endif
    endm
; ---------------------------------------------------------------------------

; macros for defining animated PLC script lists
zoneanimstart macro {INTLABEL}
__LABEL__ label *
zoneanimcount := 0
zoneanimcur := "__LABEL__"
	dc.w zoneanimcount___LABEL__	; Number of scripts for a zone (-1)
    endm

watertransheader macro {INTLABEL}
__LABEL__ label *
; Number of entries in list minus one
	dc.w (((__LABEL___End - __LABEL__ - 2) / 2) - 1)
	endm

zoneanimend macro
zoneanimcount_{"\{zoneanimcur}"} = zoneanimcount-1
    endm

zoneanimdeclanonid := 0

zoneanimdecl macro duration,artaddr,vramaddr,numentries,numvramtiles
zoneanimdeclanonid := zoneanimdeclanonid + 1
start:
	dc.l (duration&$FF)<<24|artaddr
	dc.w tiles_to_bytes(vramaddr)
	dc.b numentries, numvramtiles
zoneanimcount := zoneanimcount + 1
    endm
; ---------------------------------------------------------------------------

tribyte macro val
	if "val"<>""
		dc.b (val >> 16)&$FF,(val>>8)&$FF,val&$FF
		shift
		tribyte ALLARGS
	endif
    endm
; ---------------------------------------------------------------------------

; macro to define a palette script pointer
palscriptptr	macro header, data
	dc.w data-header, 0
	dc.l header
._headpos :=	header
    endm

; macro to define a palette script header
palscripthdr	macro palette, entries, value
	dc.w (palette)&$FFFF
	dc.b entries-1, value
    endm

; macro to define a palette script data
palscriptdata	macro frames, data
.framec :=	frames-1
	shift
	dc.w ALLARGS
	dc.w .framec
    endm

; macro to repeat script from start
palscriptrept	macro header
	dc.w -4
    endm

; macro to define loop from start for x number of times, then initialize with new header
palscriptloop	macro header
	dc.w -8, header-._headpos
._headpos :=	header
    endm

; macro to run the custom script routine
palscriptrun	macro header
	dc.w -$C
    endm

; ---------------------------------------------------------------------------
; play a sound effect or music
; input: track, terminate routine, branch or jump, move operand size
; ---------------------------------------------------------------------------

music:		macro track,terminate,branch,byte
		  if (OptimiseSound<>0)
			move.b	#track,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1).w
		    if ("terminate"<>"0")
			rts
		    endif
		  else
	 	    if ("byte"<>"0")
			moveq	#signextendB(track),d0
		    else
			move.w	#track,d0
		    endif
		    if ("branch"<>"0")
		      if ("terminate"="0")
			bsr.w	PlaySound
		      else
			bra.w	PlaySound
		      endif
		    else
		      if ("terminate"="0")
			jsr	(PlaySound).w
		      else
			jmp	(PlaySound).w
		      endif
		    endif
		  endif
	    endm

music2:		macro track,terminate,branch,byte
		  if (OptimiseSound<>0)
			move.b	#track,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd4).w
		    if ("terminate"<>"0")
			rts
		    endif
		  else
	 	    if ("byte"<>"0")
			moveq	#signextendB(track),d0
		    else
			move.w	#track,d0
		    endif
		    if ("branch"<>"0")
		      if ("terminate"="0")
			bsr.w	PlaySound
		      else
			bra.w	PlaySound
		      endif
		    else
		      if ("terminate"="0")
			jsr	(PlaySound).w
		      else
			jmp	(PlaySound).w
		      endif
		    endif
		  endif
	    endm

sfx:		macro track,terminate,branch,byte
		  if (OptimiseSound<>0)
			move.b	#track,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd2).w
		    if ("terminate"<>"0")
			rts
		    endif
		  else
	 	    if ("byte"<>"0")
			moveq	#signextendB(track),d0
		    else
			move.w	#track,d0
		    endif
		    if ("branch"<>"0")
		      if ("terminate"="0")
			bsr.w	PlaySound_Special
		      else
			bra.w	PlaySound_Special
		      endif
		    else
		      if ("terminate"="0")
			jsr	(PlaySound_Special).w
		      else
			jmp	(PlaySound_Special).w
		      endif
		    endif
		  endif
	    endm

sfx2:		macro track,terminate,branch,byte
		  if (OptimiseSound<>0)
			move.b	#track,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd3).w
		    if ("terminate"<>"0")
			rts
		    endif
		  else
	 	    if ("byte"<>"0")
			moveq	#signextendB(track),d0
		    else
			move.w	#track,d0
		    endif
		    if ("branch"<>"0")
		      if ("terminate"="0")
			bsr.w	PlaySound_Special
		      else
			bra.w	PlaySound_Special
		      endif
		    else
		      if ("terminate"="0")
			jsr	(PlaySound_Special).w
		      else
			jmp	(PlaySound_Special).w
		      endif
		    endif
		  endif
	    endm

; ---------------------------------------------------------------------------
; macro to declare a mappings table (taken from Sonic 2 Hg disassembly)
; ---------------------------------------------------------------------------

SonicMappingsVer := 3

mappingsTable macro {INTLABEL}
current_mappings_table := __LABEL__
__LABEL__ label *
    endm

; macro to declare an entry in a mappings table (taken from Sonic 2 Hg disassembly)
mappingsTableEntry macro ptr
	dc.ATTRIBUTE ptr-current_mappings_table
    endm

spriteHeader macro {INTLABEL}
__LABEL__ label *
	if SonicMappingsVer==1
	dc.b ((__LABEL___End - __LABEL__ - 1) / 5)
	elseif SonicMappingsVer==2
	dc.w ((__LABEL___End - __LABEL__ - 2) / 8)
	else
	dc.w ((__LABEL___End - __LABEL__ - 2) / 6)
	endif
    endm

spritePiece macro xpos,ypos,width,height,tile,xflip,yflip,pal,pri
	if SonicMappingsVer==1
	dc.b	ypos
	dc.b	(((width-1)&3)<<2)|((height-1)&3)
	dc.b	((pri&1)<<7)|((pal&3)<<5)|((yflip&1)<<4)|((xflip&1)<<3)|((tile&$700)>>8)
	dc.b	tile&$FF
	dc.b	xpos
	elseif SonicMappingsVer==2
	dc.w	((ypos&$FF)<<8)|(((width-1)&3)<<2)|((height-1)&3)
	dc.w	((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11)|(tile&$7FF)
	dc.w	((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11)|((tile>>1)&$7FF)
	dc.w	xpos
	else
	dc.w	((ypos&$FF)<<8)|(((width-1)&3)<<2)|((height-1)&3)
	dc.w	((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11)|(tile&$7FF)
	dc.w	xpos
	endif
    endm

spritePiece2P macro xpos,ypos,width,height,tile,xflip,yflip,pal,pri,tile2,xflip2,yflip2,pal2,pri2
	if SonicMappingsVer==1
	dc.b	ypos
	dc.b	(((width-1)&3)<<2)|((height-1)&3)
	dc.b	((pri&1)<<7)|((pal&3)<<5)|((yflip&1)<<4)|((xflip&1)<<3)|((tile&$700)>>8)
	dc.b	tile&$FF
	dc.b	xpos
	elseif SonicMappingsVer==2
	dc.w	((ypos&$FF)<<8)|(((width-1)&3)<<2)|((height-1)&3)
	dc.w	((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11)|(tile&$7FF)
	dc.w	((pri2&1)<<15)|((pal2&3)<<13)|((yflip2&1)<<12)|((xflip2&1)<<11)|(tile2&$7FF)
	dc.w	xpos
	else
	dc.w	((ypos&$FF)<<8)|(((width-1)&3)<<2)|((height-1)&3)
	dc.w	((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11)|(tile&$7FF)
	dc.w	xpos
	endif
    endm

dplcHeader macro {INTLABEL}
__LABEL__ label *
	if SonicMappingsVer==1
	dc.b ((__LABEL___End - __LABEL__ - 1) / 2)
	elseif SonicMappingsVer==2
	dc.w ((__LABEL___End - __LABEL__ - 2) / 2)
	else
	dc.w ((__LABEL___End - __LABEL__ - 4) / 2)
	endif
    endm

dplcEntry macro tiles,offset
	if SonicMappingsVer==3
	dc.w	((offset&$FFF)<<4)|((tiles-1)&$F)
	else
	dc.w	(((tiles-1)&$F)<<12)|(offset&$FFF)
	endif
    endm

; I don't know why, but S3K uses Sonic 2's DPLC format for players, and its own for everything else
; So to avoid having to set and reset SonicMappingsVer I'll just make special macros
s3kPlayerDplcHeader macro {INTLABEL}
__LABEL__ label *
	dc.w ((__LABEL___End - __LABEL__ - 2) / 2)
    endm

s3kPlayerDplcEntry macro tiles,offset
	dc.w	(((tiles-1)&$F)<<12)|(offset&$FFF)
    endm
; ---------------------------------------------------------------------------
; bankswitch between SRAM and ROM
; (remember to enable SRAM in the header first!)
; ---------------------------------------------------------------------------

gotoSRAM macro
	move.b  #1,(SRAM_access_flag).l
    endm

gotoROM macro
	move.b  #0,(SRAM_access_flag).l
    endm
; ---------------------------------------------------------------------------
; Copy a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: source, destination, width [cells], height [cells]
; ---------------------------------------------------------------------------

copyTilemap	macro loc,width,height
	locVRAM	loc,d0
	moveq	#(width/8-1),d1
	moveq	#(height/8-1),d2
	jsr	(Plane_Map_To_VRAM).w
    endm
; ---------------------------------------------------------------------------
; Copy a tilemap2 from 68K (ROM/RAM) to the VRAM without using DMA
; input: source, destination, width [cells], height [cells]
; ---------------------------------------------------------------------------

copyTilemap2	macro loc,address,width,height
	locVRAM	loc,d0
	moveq	#(width/8-1),d1
	moveq	#(height/8-1),d2
	move.w	#(address),d3
	jsr	(Plane_Map_To_Add_VRAM).w
    endm
; ---------------------------------------------------------------------------
; Copy a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: source, destination, width [cells], height [cells]
; ---------------------------------------------------------------------------

copyTilemap3		macro loc,width,height
	locVRAM	loc,d0
	moveq	#(width/8-1),d1
	moveq	#(height/8-1),d2
	jsr	(Plane_Map_To_VRAM_3).w
    endm
; ---------------------------------------------------------------------------

LoadArtUnc macro offset,size,vram
	locVRAM	vram,VDP_control_port-VDP_data_port(a6)
	lea	(offset).l,a0
	move.w	#((size)>>4),d0
-	move.l	(a0)+,VDP_data_port-VDP_data_port(a6)
	move.l	(a0)+,VDP_data_port-VDP_data_port(a6)
	move.l	(a0)+,VDP_data_port-VDP_data_port(a6)
	move.l	(a0)+,VDP_data_port-VDP_data_port(a6)
	dbf	d0,-
    endm
; ---------------------------------------------------------------------------

LoadMapUnc	macro offset,size,arg,vram,width,height
	lea	(offset).l,a0
	lea	(RAM_start).l,a1
	move.w	#arg,d0
	move.w	#((size)>>4),d1
- rept 4
	move.l	(a0)+,(a1)
	add.w	d0,(a1)+
	add.w	d0,(a1)+
 endm
	dbf	d1,-
	lea	(RAM_start).l,a1
	locVRAM	vram,d0
	moveq	#(width/8-1),d1
	moveq	#(height/8-1),d2
	jsr	(Plane_Map_To_VRAM).w
    endm
; ---------------------------------------------------------------------------

; macro for a pattern load request list header
; must be on the same line as a label that has a corresponding _End label later
plrlistheader macro {INTLABEL}
__LABEL__ label *
	dc.w (((__LABEL___End - __LABEL__Plc) / 6) - 1)
__LABEL__Plc:
    endm

; macro for a pattern load request
plreq macro toVRAMaddr,fromROMaddr
	dc.l	fromROMaddr
	dc.w	tiles_to_bytes(toVRAMaddr)
    endm
; ---------------------------------------------------------------------------
; compare the size of an index with ZoneCount constant
; (should be used immediately after the index)
; input: index address, element size
; ---------------------------------------------------------------------------

zonewarning:	macro loc,elementsize
._end:
	if (._end-loc)-(ZoneCount*elementsize)<>0
	fatal "Size of loc (\{(._end-loc)/elementsize}) does not match ZoneCount (\{ZoneCount})."
	endif
    endm
; ---------------------------------------------------------------------------

; macro to replace the destination with its absolute value
abs macro destination
	tst.ATTRIBUTE	destination
	bpl.s	.skip
	neg.ATTRIBUTE	destination
.skip:
    endm

    if 0|AllOptimizations
absw macro destination	; use a short branch instead
	abs.ATTRIBUTE	destination
    endm
    else
; macro to replace the destination with its absolute value using a word-sized branch
absw macro destination
	tst.ATTRIBUTE	destination
	bpl.w	.skip
	neg.ATTRIBUTE	destination
.skip:
    endm
    endif

; macro to move the absolute value of the source in the destination
mvabs macro source,destination
	move.ATTRIBUTE	source,destination
	bpl.s	.skip
	neg.ATTRIBUTE	destination
.skip:
    endm
; ---------------------------------------------------------------------------

; macro to declare an offset table
offsetTable macro {INTLABEL}
current_offset_table := __LABEL__
__LABEL__ label *
    endm

; macro to declare an entry in an offset table
offsetTableEntry macro ptr
	dc.ATTRIBUTE ptr-current_offset_table
    endm
offsetEntry macro ptr
	dc.ATTRIBUTE ptr-*
    endm
; ---------------------------------------------------------------------------

dScroll_header macro {INTLABEL}
__LABEL__ label *
	dc.w (((__LABEL___End - __LABEL__Plc) / 6) - 1)
__LABEL__Plc:
    endm

dScroll_Data macro plane,pixel,speed,size
		if plane=0
	dc.w H_scroll_buffer+(pixel<<2)
		elseif plane=1
	dc.w H_scroll_buffer+((pixel<<2)+2)
		else
			fatal "Error! Non-existent plan."
		endif
	dc.w speed, size
    endm
; ---------------------------------------------------------------------------

; macro for generating standard strings
standardstr macro str
	save
	codepage	STANDARD
	dc.b strlen(str)-1, str
	restore
    endm

; macro for generating level select strings
levselstr macro str
	save
	codepage	LEVELSCREEN
	dc.b strlen(str)-1, str
	restore
    endm

; Codepage for level select
	save
	codepage LEVELSCREEN
	CHARSET ' ', 51
	CHARSET '0','9', 8
	CHARSET 'A','Z', 25
	CHARSET 'a','z', 25
	CHARSET '*', 18
	CHARSET ':', 20
	CHARSET '-', 21
	CHARSET '.', 22
	CHARSET '/', 23
	restore
