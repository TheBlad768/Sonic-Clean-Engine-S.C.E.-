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

; calc VDP address
vdpCalc function loc,($40000000|vdpCommDelta(loc))

; sign-extends a 32-bit integer to 64-bit
; all RAM addresses are run through this function to allow them to work in both 16-bit and 32-bit addressing modes
ramaddr function x,-(-x)&$FFFFFFFF

; function using these variables
id function ptr,((ptr-offset)/ptrsize+idstart)

; function to convert two separate nibble into a byte
nibbles_to_byte function nibble1,nibble2,(((nibble1)<<4)&$F0)|((nibble2)&$FF)

; function to convert two separate bytes into a word
bytes_to_word function byte1,byte2,(((byte1)<<8)&$FF00)|((byte2)&$FF)

; function to convert two separate word into a long
words_to_long function word1,word2,(((word1)<<16)&$FFFF0000)|((word2)&$FFFF)

; function to convert two separate bytes and word into a word
bytes_word_to_long function byte1,byte2,word,((((byte1)<<24)&$FF000000)|(((byte2)<<16)&$FF0000)|((word)&$FFFF))

; function to convert four separate bytes into a long
bytes_to_long function byte1,byte2,byte3,byte4,(((byte1)<<24)&$FF000000)|(((byte2)<<16)&$FF0000)|(((byte3)<<8)&$FF00)|((byte4)&$FF)

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at x bytes per iteration
bytesToXcnt function n,x,n/x-1

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 4 bytes per iteration
bytesToLcnt function n,bytesToXcnt(n,4)

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 2 bytes per iteration
bytesToWcnt function n,bytesToXcnt(n,2)

; calculates initial loop counter value for a normal loop
; that writes n bytes total at x bytes per iteration
bytesTo2Xcnt function n,x,n/x

; calculates initial loop counter value for a normal loop
; that writes n bytes total at 4 bytes per iteration
bytesTo2Lcnt function n,bytesTo2Xcnt(n,4)

; calculates initial loop counter value for a normal loop
; that writes n bytes total at 2 bytes per iteration
bytesTo2Wcnt function n,bytesTo2Xcnt(n,2)

; macros to convert from tile index to art tiles, block mapping or VRAM address
sprite_priority function x,((x&7)<<7)
make_art_tile function addr,pal,pri,((pri&1)<<15)|((pal&3)<<13)|(addr&tile_mask)
make_block_tile function addr,flx,fly,pal,pri,((pri&1)<<15)|((pal&3)<<13)|((fly&1)<<12)|((flx&1)<<11)|(addr&tile_mask)
make_block_tile_pair function addr,flx,fly,pal,pri,((make_block_tile(addr,flx,fly,pal,pri)<<16)|make_block_tile(addr,flx,fly,pal,pri))
tiles_to_bytes function addr,((addr&$7FF)<<5)

; function to calculate the location of a tile in plane mappings
planeLoc function width,col,line,(((width * line) + col) * 2)

; function to calculate the location of a tile in plane mappings with a width of 40 cells
planeLocH32 function col,line,(($40 * line) + (2 * col))

; function to calculate the location of a tile in plane mappings with a width of 40 cells
planeLocH28 function col,line,(($50 * line) + (2 * col))

; function to calculate the location of a tile in plane mappings with a width of 64 cells
planeLocH40 function col,line,(($80 * line) + (2 * col))

; function to calculate the location of a tile in plane mappings with a width of 128 cells
planeLocH80 function col,line,(($100 * line) + (2 * col))

; function to make a little-endian 16-bit pointer for the Z80 sound driver
z80_ptr function x,(x)<<8&$FF00|(x)>>8&$7F|$80
; ---------------------------------------------------------------------------

; tells the VDP to copy a region of 68k memory to VRAM or CRAM or VSRAM
dma68kToVDP macro source,dest,length,type
	move.l	#(($9400|((((length)>>1)&$FF00)>>8))<<16)|($9300|(((length)>>1)&$FF)),VDP_control_port-VDP_control_port(a5)
	move.l	#(($9600|((((source)>>1)&$FF00)>>8))<<16)|($9500|(((source)>>1)&$FF)),VDP_control_port-VDP_control_port(a5)
	move.w	#$9700|(((((source)>>1)&$FF0000)>>16)&$7F),VDP_control_port-VDP_control_port(a5)
	move.w	#(vdpComm(dest,type,DMA)>>16)&$FFFF,VDP_control_port-VDP_control_port(a5)
	move.w	#vdpComm(dest,type,DMA)&$FFFF,-(sp)
	move.w	(sp)+,VDP_control_port-VDP_control_port(a5)
	; From '  § 7  DMA TRANSFER' of https://emu-docs.org/Genesis/sega2f.htm:
	;
	; "In the case of ROM to VRAM transfers,
	; a hardware feature causes occasional failure of DMA unless the
	; following two conditions are observed:
	;
	; --The destination address write (to address $C00004) must be a word
	;   write.
	;
	; --The final write must use the work RAM.
	;   There are two ways to accomplish this, by copying the DMA program
	;   into RAM or by doing a final "move.w ram address $C00004""
    endm

; tells the VDP to fill a region of VRAM with a certain byte
dmaFillVRAM macro byte,addr,length
	move.w	#$8F01,VDP_control_port-VDP_control_port(a5)				; VRAM pointer increment: $0001
	move.l	#(($9400|((((length)-1)&$FF00)>>8))<<16)|($9300|(((length)-1)&$FF)),VDP_control_port-VDP_control_port(a5)	; DMA length ...
	move.w	#$9780,VDP_control_port-VDP_control_port(a5)				; VRAM fill
	move.l	#vdpComm(addr,VRAM,DMA),VDP_control_port-VDP_control_port(a5)		; start at ...
	move.w	#bytes_to_word(byte,byte),(VDP_data_port).l				; fill with byte

.loop
	moveq	#2,d1
	and.w	VDP_control_port-VDP_control_port(a5),d1
	bne.s	.loop									; busy loop until the VDP is finished filling...
	move.w	#$8F02,VDP_control_port-VDP_control_port(a5)				; VRAM pointer increment: $0002
    endm

; ---------------------------------------------------------------------------
; set a VRAM address via the VDP control port
; input: 16-bit VRAM address, control port (default is (VDP_control_port).l)
; ---------------------------------------------------------------------------

locVRAM macro loc,controlport=(VDP_control_port).l
	move.l	#vdpCalc(loc),controlport
    endm

; ---------------------------------------------------------------------------
; calc VDP address
; input: 16-bit VRAM address (default is d0)
; ---------------------------------------------------------------------------

CalcVRAM macro reg=d0
	lsl.l	#2,reg
	lsr.w	#2,reg
	ori.w	#vdpComm(0,VRAM,WRITE)>>16,reg
	swap	reg
    endm

; ---------------------------------------------------------------------------
; Macro to check button presses
; Arguments:
; 1 - buttons to check
; ---------------------------------------------------------------------------

tpress macro press,player
	if player=2
		move.b	(Ctrl_2_pressed).w,d0
	else
		move.b	(Ctrl_1_pressed).w,d0
	endif
	andi.b	#(press),d0
    endm

; ---------------------------------------------------------------------------
; Macro to check if buttons are held
; Arguments:
; 1 - buttons to check
; ---------------------------------------------------------------------------

theld macro press,player
	if player=2
		move.b	(Ctrl_2_held).w,d0
	else
		move.b	(Ctrl_1_held).w,d0
	endif
	andi.b	#(press),d0
    endm

; ---------------------------------------------------------------------------
; macro for a debug object list header
; must be on the same line as a label that has a corresponding _end label later
; ---------------------------------------------------------------------------

dbglistheader macro {INTLABEL}
__LABEL__ label *
	dc.w ((__LABEL___end - __LABEL__ - 2) / $A)
    endm

; macro to define debug list object data
dbglistobj macro obj,mapaddr,subtype,frame,vram,pal,pri
	dc.l frame<<24|((obj)&$FFFFFF)
	dc.l subtype<<24|((mapaddr)&$FFFFFF)
	dc.w make_art_tile(vram,pal,pri)
    endm

; ---------------------------------------------------------------------------
; macro for declaring a "main level load block" (MLLB)
; ---------------------------------------------------------------------------

levartptrs macro \
	art1, \
	art2, \
	map16x16r, \
	map16x161, \
	map16x162, \
	map128x128r, \
	map128x1281, \
	map128x1282, \
	layoutr,layout1, \
	layout2,solidr, \
	solid1,solid2, \
	objectsr, \
	objects1, \
	objects2, \
	ringsr, \
	rings1, \
	rings2, \
	palette, \
	wpalette, \
	music

	dc.l (palette)<<24|((art1)&$FFFFFF),art2
	dc.l (wpalette)<<24|((map16x16r)&$FFFFFF),map16x161,map16x162
	dc.l (music)<<24|((map128x128r)&$FFFFFF),map128x1281,map128x1282
	dc.l layoutr,layout1,layout2
	dc.l solidr,solid1,solid2
	dc.l objectsr,objects1,objects2
	dc.l ringsr,rings1,rings2
    endm
; ---------------------------------------------------------------------------

palptr macro ptr,lineno
	dc.l ptr
	dc.w (Normal_palette+lineno*palette_line_size)&$FFFF
	dc.w bytesToLcnt(ptr_end-ptr)
    endm
; ---------------------------------------------------------------------------

; macro to declare sub-object data
subObjData macro mappings=FALSE,vram=FALSE,pal,pri,height,width,prio,frame,collision
    if upstring("mappings")<>"FALSE"
	dc.l mappings
    endif
    if upstring("vram")<>"FALSE"
	dc.w make_art_tile(vram,pal,pri)
    endif
	dc.b (height/2),(width/2)
	dc.w sprite_priority(prio)
	dc.b frame,collision
    endm

; macro to declare sub-object slotted data
subObjSlotData macro slots,vram,pal,pri,offset,index,mappings,height,width,prio,frame,collision
	dc.w slots,make_art_tile(vram,pal,pri),offset,index
	dc.l mappings
	dc.b (height/2),(width/2)
	dc.w sprite_priority(prio)
	dc.b frame,collision
    endm

; macro to declare sub-object data
subObjMainData macro address=FALSE,render,routine,height,width,prio,vram,pal,pri,mappings,frame,collision
    if upstring("address")<>"FALSE"
	dc.l address
    endif
	dc.b render,routine,(height/2),(width/2)
	dc.w sprite_priority(prio),make_art_tile(vram,pal,pri)
	dc.l mappings
    ifnb frame
	dc.b frame
    endif
    ifnb collision
	dc.b collision
    endif
    endm
; ---------------------------------------------------------------------------

zoneAnimals macro first,second
	dc.ATTRIBUTE (Obj_Animal_Properties_first - Obj_Animal_Properties), (Obj_Animal_Properties_second - Obj_Animal_Properties)
    endm

objanimaldecl macro mappings,address,xvel,yvel,{INTLABEL}
Obj_Animal_Properties___LABEL__: label *
	dc.l mappings, address
	dc.w xvel, yvel
    endm

objanimalending macro address,mappings,vram,xvel,yvel
	dc.l address, mappings
	dc.w vram, xvel, yvel
	dc.w 0	; even
    endm
; ---------------------------------------------------------------------------

titlecardresultsheader macro {INTLABEL}
__LABEL__ label *
	dc.w ((__LABEL___end - __LABEL__) / $E)-1
    endm

titlecardresultsobjdata macro address,xdest,xpos,ypos,frame,width,exit
	dc.l address									; object address
	dc.w 128+xdest,128+xpos,128+ypos						; x destination, xpos, ypos
	dc.b frame,(width/2)								; mapping frame, width
	dc.w exit									; place in exit queue
    endm
; ---------------------------------------------------------------------------

; fills a region of 68k RAM with 0
clearRAM macro startaddr,endaddr
    if startaddr>endaddr
	fatal "Starting address of clearRAM \{startaddr} is after ending address \{endaddr}."
    elseif startaddr=endaddr
	warning "clearRAM is clearing zero bytes. Turning this into a nop instead."
	exitm
    endif
    if ((startaddr)&$8000)=0
	lea	(startaddr).l,a1
    else
	lea	(startaddr).w,a1
    endif
	moveq	#0,d0
    if ((startaddr)&1)
	move.b	d0,(a1)+
    endif
    if ((bytesToLcnt((endaddr-startaddr) - ((startaddr)&1)))<=$7F)
	moveq	#bytesToLcnt((endaddr-startaddr) - ((startaddr)&1)),d1
    else
	move.w	#bytesToLcnt((endaddr-startaddr) - ((startaddr)&1)),d1
    endif

.clear
	move.l	d0,(a1)+
	dbf	d1,.clear
    if (((endaddr-startaddr) - ((startaddr)&1))&2)
	move.w	d0,(a1)+
    endif
    if (((endaddr-startaddr) - ((startaddr)&1))&1)
	move.b	d0,(a1)+
    endif
    endm

; fills a region of 68k RAM with 0
clearRAM2 macro startaddr,endaddr
    if startaddr>endaddr
	fatal "Starting address of clearRAM2 \{startaddr} is after ending address \{endaddr}."
    elseif startaddr=endaddr
	warning "clearRAM2 is clearing zero bytes. Turning this into a nop instead."
	exitm
    endif
    if ((startaddr)&$8000)=0
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
    endr
    if (((endaddr-startaddr) - ((startaddr)&1))&2)
	move.w	d0,(a1)+
    endif
    if (((endaddr-startaddr) - ((startaddr)&1))&1)
	move.b	d0,(a1)+
    endif
    endm

; fills a region of 68k RAM with 0
clearRAM3 macro startaddr,endaddr
    if startaddr>endaddr
	fatal "Starting address of clearRAM \{startaddr} is after ending address \{endaddr}."
    elseif startaddr=endaddr
	warning "clearRAM is clearing zero bytes. Turning this into a nop instead."
	exitm
    endif
    if ((startaddr)&$8000)=0
	lea	(startaddr).l,a1
    else
	lea	(startaddr).w,a1
    endif
	moveq	#0,d0
    if ((startaddr)&1)
	move.b	d0,(a1)+
    endif
    if ((bytesToXcnt(((endaddr-startaddr) - ((startaddr)&1)),(16*4)))<=$7F)
	moveq	#bytesToXcnt(((endaddr-startaddr) - ((startaddr)&1)),(16*4)),d1
    else
	move.w	#bytesToXcnt(((endaddr-startaddr) - ((startaddr)&1)),(16*4)),d1
    endif

.clear
    rept 16
	move.l	d0,(a1)+
    endr
	dbf	d1,.clear
    if (((endaddr-startaddr) - ((startaddr)&1))&2)
	move.w	d0,(a1)+
    endif
    if (((endaddr-startaddr) - ((startaddr)&1))&1)
	move.b	d0,(a1)+
    endif
    endm

; copy 68k RAM
copyRAM macro startaddr,endaddr,startaddr2
    if startaddr>endaddr
	fatal "Starting address of copyRAM \{startaddr} is after ending address \{endaddr}."
    elseif startaddr=endaddr
	warning "copyRAM is copy zero bytes. Turning this into a nop instead."
	exitm
    endif
    if ((startaddr)&$8000)=0
	lea	(startaddr).l,a1
    else
	lea	(startaddr).w,a1
    endif
    if ((startaddr2)&$8000)=0
	lea	(startaddr2).l,a2
    else
	lea	(startaddr2).w,a2
    endif
	moveq	#0,d0
    if ((startaddr)&1)
	move.b	(a1)+,(a2)+
    endif
    if ((bytesToLcnt((endaddr-startaddr) - ((startaddr)&1)))<=$7F)
	moveq	#bytesToLcnt((endaddr-startaddr) - ((startaddr)&1)),d1
    else
	move.w	#bytesToLcnt((endaddr-startaddr) - ((startaddr)&1)),d1
    endif

.clear
	move.l	(a1)+,(a2)+
	dbf	d1,.clear
    if (((endaddr-startaddr) - ((startaddr)&1))&2)
	move.w	(a1)+,(a2)+
    endif
    if (((endaddr-startaddr) - ((startaddr)&1))&1)
	move.b	(a1)+,(a2)+
    endif
    endm

; copy 68k RAM
copyRAM2 macro startaddr,endaddr,startaddr2
    if startaddr>endaddr
	fatal "Starting address of copyRAM2 \{startaddr} is after ending address \{endaddr}."
    elseif startaddr=endaddr
	warning "copyRAM2 is copy zero bytes. Turning this into a nop instead."
	exitm
    endif
    if ((startaddr)&$8000)=0
	lea	(startaddr).l,a1
    else
	lea	(startaddr).w,a1
    endif
    if ((startaddr2)&$8000)=0
	lea	(startaddr2).l,a2
    else
	lea	(startaddr2).w,a2
    endif
	moveq	#0,d0
    if ((startaddr)&1)
	move.b	(a1)+,(a2)+
    endif
    rept bytesTo2Lcnt((endaddr-startaddr) - ((startaddr)&1))
	move.l	(a1)+,(a2)+
    endr
    if (((endaddr-startaddr) - ((startaddr)&1))&2)
	move.w	(a1)+,(a2)+
    endif
    if (((endaddr-startaddr) - ((startaddr)&1))&1)
	move.b	(a1)+,(a2)+
    endif
    endm

; ---------------------------------------------------------------------------
; load Kosinski Plus
; ---------------------------------------------------------------------------

; load Kosinski Plus data to RAM
KosPlusDecomp macro data,ram,terminate
	lea	(data).l,a0
    if ((ram)&$8000)=0
	lea	(ram).l,a1
    else
	lea	(ram).w,a1
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(KosPlus_Decomp).w
    else
	jmp	(KosPlus_Decomp).w
    endif
    endm

; ---------------------------------------------------------------------------
; load Kosinski Plus and Kosinski Plus Moduled Queue
; ---------------------------------------------------------------------------

; load Kosinski Plus data to RAM
QueueKosPlus macro data,ram,terminate
	lea	(data).l,a1
    if ((ram)&$8000)=0
	lea	(ram).l,a2
    else
	lea	(ram).w,a2
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Queue_KosPlus).w
    else
	jmp	(Queue_KosPlus).w
    endif
    endm

; load Kosinski Plus Moduled art to VRAM
QueueKosPlusModule macro art,vram,terminate
	lea	(art).l,a1
    if ((vram)<=3)
	moveq	#tiles_to_bytes(vram),d2
    else
	move.w	#tiles_to_bytes(vram),d2
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Queue_KosPlus_Module).w
    else
	jmp	(Queue_KosPlus_Module).w
    endif
    endm

; ---------------------------------------------------------------------------
; load Enigma
; ---------------------------------------------------------------------------

; load Enigma data to RAM
EniDecomp macro data,ram,vram,palette,pri,terminate
	lea	(data).l,a0
    if ((ram)&$8000)=0
	lea	(ram).l,a1
    else
	lea	(ram).w,a1
    endif
    if ((make_art_tile(vram,palette,pri))<=$7F)
	moveq	#make_art_tile(vram,palette,pri),d0
    else
	move.w	#make_art_tile(vram,palette,pri),d0
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Eni_Decomp).w
    else
	jmp	(Eni_Decomp).w
    endif
    endm

; ---------------------------------------------------------------------------
; load DMA
; ---------------------------------------------------------------------------

; load DMA
AddToDMAQueue macro art,vram,size,terminate
		move.l	#dmaSource(art),d1
    if ((vram)<=3)
	moveq	#tiles_to_bytes(vram),d2
    else
	move.w	#tiles_to_bytes(vram),d2
    endif
    if ((size/2)<=$7F)
		moveq	#(size/2),d3
    else
		move.w	#(size/2),d3
    endif
    if ("terminate"="0") || ("terminate"="")
		jsr	(Add_To_DMA_Queue).w
    else
		jmp	(Add_To_DMA_Queue).w
    endif
    endm

; ---------------------------------------------------------------------------
; check if object moves out of range
; input: location to jump to if out of range, x-axis pos (x_pos(a0) by default)
; ---------------------------------------------------------------------------

out_of_xrange macro exit,xpos
	moveq	#-$80,d0								; round down to nearest $80
    ifnb xpos
		and.w	xpos,d0								; get object position (if specified as not x_pos)
    else
		and.w	x_pos(a0),d0							; get object position
    endif
	out_of_xrange2.ATTRIBUTE	exit
    endm

out_of_xrange2 macro exit
	sub.w	(Camera_X_pos_coarse_back).w,d0						; get screen position
	cmpi.w	#$80+320+$40+$80,d0							; this gives an object $80 pixels of room offscreen before being unloaded (the $40 is there to round up 320 to a multiple of $80)
	bhi.ATTRIBUTE	exit
    endm

; ---------------------------------------------------------------------------
; check if object moves out of range
; input: location to jump to if out of range, x-axis pos (y_pos(a0) by default)
; ---------------------------------------------------------------------------

out_of_yrange macro exit,ypos
	moveq	#-$80,d0								; round down to nearest $80
    ifnb ypos
		and.w	ypos,d0								; get object position (if specified as not y_pos)
    else
		and.w	y_pos(a0),d0							; get object position
    endif
	out_of_yrange2.ATTRIBUTE	exit
    endm

out_of_yrange2 macro exit
	sub.w	(Camera_Y_pos_coarse_back).w,d0
	cmpi.w	#$80+256+$80,d0
	bhi.ATTRIBUTE	exit
    endm

; ---------------------------------------------------------------------------
; object respawn delete
; ---------------------------------------------------------------------------

respawn_delete macro terminate
	move.w	respawn_addr(a0),d0							; get address in respawn table
	beq.s	.delete									; if it's zero, it isn't remembered
	movea.w	d0,a2									; load address into a2
	bclr	#7,(a2)

.delete
    if ("terminate"="0") <> ("terminate"="")
	jmp	(Delete_Current_Sprite).w
    endif
    endm

; ---------------------------------------------------------------------------
; macros for frequently used subroutines
; ---------------------------------------------------------------------------

getobjectRAMslot macro address
    ifb address
	fatal "Error! Empty value!"
    endif
	move.w	#Dynamic_object_RAM_end,d0
	sub.w	a0,d0
	lsr.w	#6,d0									; divide by $40... even though SSTs are $4A bytes long in this game
	lea	(Create_New_Sprite3.table).w,address
	move.b	(address,d0.w),d0							; use a look-up table to get the right loop counter
    endm

MoveSprite macro address,gravity,terminate
    ifb address
	fatal "Error! Empty value!"
    endif
	movem.w	x_vel(address),d0/d2							; load xy speed
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	asl.l	#8,d2									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,x_pos(address)							; add to x-axis position ; note this affects the subpixel position x_sub(address) = 2+x_pos(address)
	add.l	d2,y_pos(address)							; add to y-axis position ; note this affects the subpixel position y_sub(address) = 2+y_pos(address)
    ifnb gravity
	addi.w	#gravity,y_vel(address)							; increase vertical speed (apply gravity)
	else
	addi.w	#$38,y_vel(address)							; increase vertical speed (apply gravity)
    endif
    ifnb terminate
	rts
    endif
    endm

MoveSprite2 macro address,terminate
    ifb address
	fatal "Error! Empty value!"
    endif
	movem.w	x_vel(address),d0/d2							; load xy speed
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	asl.l	#8,d2									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,x_pos(address)							; add to x-axis position ; note this affects the subpixel position x_sub(address) = 2+x_pos(address)
	add.l	d2,y_pos(address)							; add to y-axis position ; note this affects the subpixel position y_sub(address) = 2+y_pos(address)
    ifnb terminate
	rts
    endif
    endm

MoveSpriteXOnly macro address,terminate
    ifb address
	fatal "Error! Empty value!"
    endif
	move.w	x_vel(address),d0							; load x speed
	ext.l	d0
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,x_pos(address)							; add to x-axis position ; note this affects the subpixel position x_sub(address) = 2+x_pos(address)
    ifnb terminate
	rts
    endif
    endm

MoveSpriteYOnly macro address,gravity,terminate
    ifb address
	fatal "Error! Empty value!"
    endif
	move.w	y_vel(address),d0							; load y speed
	ext.l	d0
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,y_pos(address)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
    ifnb gravity
	addi.w	#gravity,y_vel(address)							; increase vertical speed (apply gravity)
	else
	addi.w	#$38,y_vel(address)							; increase vertical speed (apply gravity)
    endif
    ifnb terminate
	rts
    endif
    endm

MoveSprite2YOnly macro address,terminate
    ifb address
	fatal "Error! Empty value!"
    endif
	move.w	y_vel(address),d0							; load y speed
	ext.l	d0
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,y_pos(address)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
    ifnb terminate
	rts
    endif
    endm

Add_SpriteToCollisionResponseList macro address,terminate
    ifb address
	fatal "Error! Empty value!"
    endif
	lea	(Collision_response_list).w,address
	move.w	(address),d0								; get list to d0
	addq.b	#2,d0									; is list full? ($80)
	bmi.s	.full									; if so, return
	move.w	d0,(address)								; save list ($7E)
	move.w	a0,(address,d0.w)							; store RAM address in list

.full
    ifnb terminate
	rts
    endif
    endm

CreateNewSprite macro obj,terminate
	jsr	(Create_New_Sprite).w
	bne.s	.skip
	move.l	#obj,address(a1)

.skip
    ifnb terminate
	rts
    endif
    endm

CreateNewSprite3 macro obj,terminate
	jsr	(Create_New_Sprite3).w
	bne.s	.skip
	move.l	#obj,address(a1)

.skip
    ifnb terminate
	rts
    endif
    endm

; ---------------------------------------------------------------------------
; macro for marking the boundaries of an object layout file
; ---------------------------------------------------------------------------

ObjectLayoutBoundary macro
	dc.w -1, 0, 0
    endm

; ---------------------------------------------------------------------------
; macro for marking the boundaries of an ring layout file
; ---------------------------------------------------------------------------

RingLayoutBoundary macro
	dc.w 0, 0, -1, -1
    endm

; ---------------------------------------------------------------------------
; macro to declare a little-endian 16-bit pointer for the Z80 sound driver
; ---------------------------------------------------------------------------

rom_ptr_z80 macro addr
	dc.w z80_ptr(addr)
    endm

; ---------------------------------------------------------------------------
; clear the Z80 RAM
; ---------------------------------------------------------------------------

clearZ80RAM macro
	moveq	#0,d1
	lea	(Z80_RAM).l,a1
	move.w	#bytesToXcnt(Z80_RAM_end-Z80_RAM,8),d0

.clear
	movep.l	d1,0(a1)
	movep.l	d1,1(a1)
	addq.w	#4*2,a1									; next bytes
	dbf	d0,.clear
    endm

paddingZ80RAM macro
	moveq	#0,d0

.clear
	move.b	d0,(a1)+
	cmpa.l	#(Z80_RAM_end),a1
	bne.s	.clear
    endm

; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------

; tells the Z80 to stop, and waits for it to finish stopping (acquire bus)
stopZ80 macro

	if OptimiseStopZ80=0
		move.w	#$100,(Z80_bus_request).l					; stop the Z80

.wait
		btst	#0,(Z80_bus_request).l
		bne.s	.wait								; loop until it says it's stopped
	endif

    endm

; tells the Z80 to stop, and waits for it to finish stopping (acquire bus)
stopZ80a macro

	if OptimiseStopZ80=0
		move.w	#$100,(Z80_bus_request).l					; stop the Z80
	endif

    endm

; ---------------------------------------------------------------------------
; wait for Z80 to stop
; ---------------------------------------------------------------------------

; tells the Z80 to wait for it to finish stopping (acquire bus)
waitZ80 macro

	if OptimiseStopZ80=0
.wait
		btst	#0,(Z80_bus_request).l
		bne.s	.wait								; loop until
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
		move.w	#0,(Z80_reset).l
	endif

    endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------

; tells the Z80 to start again
startZ80 macro

	if OptimiseStopZ80=0
		move.w	#0,(Z80_bus_request).l						; start the Z80
	endif

    endm

; ---------------------------------------------------------------------------
; stop the Z80 (2)
; ---------------------------------------------------------------------------

; tells the Z80 to stop, and waits for it to finish stopping (acquire bus)
stopZ802 macro

	if OptimiseStopZ80=2
		move.w	#$100,(Z80_bus_request).l					; stop the Z80

.wait
		btst	#0,(Z80_bus_request).l
		bne.s	.wait								; loop until it says it's stopped
	endif

    endm

; ---------------------------------------------------------------------------
; start the Z80 (2)
; ---------------------------------------------------------------------------

; tells the Z80 to start again
startZ802 macro

	if OptimiseStopZ80=2
		move.w	#0,(Z80_bus_request).l						; start the Z80
	endif

    endm

; ---------------------------------------------------------------------------
; wait for the Z80
; ---------------------------------------------------------------------------

waitZ80time macro time
	move.w	#(time),d0

.wait
	nop
	nop
	nop
	nop
	dbf	d0,.wait
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
	move.w	sr,-(sp)								; save current interrupt mask
	disableInts									; mask off interrupts
    endm

; ---------------------------------------------------------------------------
; enable interrupts
; ---------------------------------------------------------------------------

enableIntsSave macro
	move.w	(sp)+,sr								; restore interrupts to previous state
    endm

; ---------------------------------------------------------------------------
; disable screen
; ---------------------------------------------------------------------------

disableScreen macro
	moveq	#signextendB(%10111111),d0
	and.w	(VDP_reg_1_command).w,d0
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

jhi macro loc
	bls.s	.nojump
	jmp	(loc).l

.nojump
    endm

jcc macro loc
	blo.s	.nojump
	jmp	(loc).l

.nojump
    endm

jhs macro loc
	jcc	loc
    endm

jls macro loc
	bhi.s	.nojump
	jmp	(loc).l

.nojump
    endm

jcs macro loc
	bhs.s	.nojump
	jmp	(loc).l

.nojump
    endm

jlo macro loc
	jcs	loc
    endm

jeq macro loc
	bne.s	.nojump
	jmp	(loc).l

.nojump
    endm

jne macro loc
	beq.s	.nojump
	jmp	(loc).l

.nojump
    endm

jgt macro loc
	ble.s	.nojump
	jmp	(loc).l

.nojump
    endm

jge macro loc
	blt.s	.nojump
	jmp	(loc).l

.nojump
    endm

jle macro loc
	bgt.s	.nojump
	jmp	(loc).l

.nojump
    endm

jlt macro loc
	bge.s	.nojump
	jmp	(loc).l

.nojump
    endm

jpl macro loc
	bmi.s	.nojump
	jmp	(loc).l

.nojump
    endm

jmi macro loc
	bpl.s	.nojump
	jmp	(loc).l

.nojump
    endm
; ---------------------------------------------------------------------------

_KosPlus_LoopUnroll := 3

_KosPlus_ReadBit macro
	dbf	d2,.skip
	moveq	#7,d2									; we have 8 new bits, but will use one up below
	move.b	(a0)+,d0								; get desc field low-byte

.skip
	add.b	d0,d0									; get a bit from the bitstream
    endm
; ---------------------------------------------------------------------------

; macros for defining animated PLC script lists
zoneanimstart macro {INTLABEL}
__LABEL__ label *
zoneanimcount := 0
zoneanimcur := "__LABEL__"
	dc.w zoneanimcount___LABEL__							; number of scripts for a zone (-1)
    endm

watertransheader macro {INTLABEL}
__LABEL__ label *
; Number of entries in list minus one
	dc.w (((__LABEL___end - __LABEL__ - 2) / 2) - 1)
    endm

zoneanimend macro
zoneanimcount_{"\{zoneanimcur}"} = zoneanimcount-1
    endm

zoneanimdeclanonid := 0

zoneanimplcdecl macro duration,artaddr,vramaddr,numentries,numvramtiles
zoneanimdeclanonid := zoneanimdeclanonid + 1
start:
	dc.l (duration&$FF)<<24|dmaSource(artaddr)
	dc.w tiles_to_bytes(vramaddr)
	dc.b numentries, numvramtiles
zoneanimcount := zoneanimcount + 1
    endm

zoneanimpaldecl macro duration,paladdr,palram,numentries,numcolors
zoneanimdeclanonid := zoneanimdeclanonid + 1
start:
	dc.l (duration&$FF)<<24|paladdr
	dc.w ((palram)&$FFFF)
	dc.b numentries, numcolors
zoneanimcount := zoneanimcount + 1
    endm
; ---------------------------------------------------------------------------

tribyte macro val
	ifnb val
		dc.b (val >> 16)&$FF,(val>>8)&$FF,val&$FF
		shift
		tribyte ALLARGS
	endif
    endm
; ---------------------------------------------------------------------------

; macro to define a palette script pointer
palscriptptr macro header,data
	dc.w data-header, 0
	dc.l header
._headpos :=	header
    endm

; macro to define a palette script header
palscripthdr macro palette,entries,value
	dc.w (palette)&$FFFF
	dc.b entries-1, value
    endm

; macro to define a palette script data
palscriptdata macro frames
.framec :=	frames-1
	shift
	dc.w ALLARGS
	dc.w .framec
    endm

; macro to define a palette script data from an external file
palscriptfile macro frames
.framec :=	frames-1
	shift
	binclude ALLARGS
	dc.w .framec
    endm

; macro to repeat script from start
palscriptrept macro header
	dc.w -2
    endm

; macro to define loop from start for x number of times, then initialize with new header
palscriptloop macro header
	dc.w -4, header-._headpos
._headpos :=	header
    endm

; macro to run the custom script routine
palscriptrun macro header
	dc.w -6
    endm

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
	moveq	#signextendB(wait),d1
    if ("terminate"="0") || ("terminate"="")
	jsr	(Play_SFX_Continuous).w
    else
	jmp	(Play_SFX_Continuous).w
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
; macro to declare a mappings table (taken from Sonic 2 Hg disassembly)
; ---------------------------------------------------------------------------

SonicMappingsVer := 3

mappingsTable macro {INTLABEL}
__LABEL__ label *
.current_mappings_table := __LABEL__
    endm

mappingsTableEntry macro ptr
	dc.ATTRIBUTE ptr-.current_mappings_table
    endm

spriteHeader macro {INTLABEL}
__LABEL__ label *
	if SonicMappingsVer=1
		dc.b ((__LABEL___End - __LABEL___Begin) / 5)
	elseif SonicMappingsVer=2
		dc.w ((__LABEL___End - __LABEL___Begin) / 8)
	else
		dc.w ((__LABEL___End - __LABEL___Begin) / 6)
	endif
__LABEL___Begin label *
    endm

spritePiece macro xpos,ypos,width,height,tile,xflip,yflip,pal,pri
	if SonicMappingsVer=1
		dc.b ypos
		dc.b (((width-1)&3)<<2)|((height-1)&3)
		dc.b ((((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11))+(tile))>>8
		dc.b tile&$FF
		dc.b xpos
	elseif SonicMappingsVer=2
		dc.w ((ypos&$FF)<<8)|(((width-1)&3)<<2)|((height-1)&3)
		dc.w (((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11))+(tile)
		dc.w (((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11))+(((tile)>>1)|((tile)&$8000))
		dc.w xpos
	else
		dc.w ((ypos&$FF)<<8)|(((width-1)&3)<<2)|((height-1)&3)
		dc.w (((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11))+(tile)
		dc.w xpos
	endif
    endm

spritePiece2P macro xpos,ypos,width,height,tile,xflip,yflip,pal,pri,tile2,xflip2,yflip2,pal2,pri2
	if SonicMappingsVer=1
		dc.b ypos
		dc.b (((width-1)&3)<<2)|((height-1)&3)
		dc.b ((((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11))+(tile))>>8
		dc.b tile&$FF
		dc.b xpos
	elseif SonicMappingsVer=2
		dc.w ((ypos&$FF)<<8)|(((width-1)&3)<<2)|((height-1)&3)
		dc.w (((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11))+(tile)
		dc.w (((pri2&1)<<15)|((pal2&3)<<13)|((yflip2&1)<<12)|((xflip2&1)<<11))+(tile2)
		dc.w xpos
	else
		dc.w ((ypos&$FF)<<8)|(((width-1)&3)<<2)|((height-1)&3)
		dc.w (((pri&1)<<15)|((pal&3)<<13)|((yflip&1)<<12)|((xflip&1)<<11))+(tile)
		dc.w xpos
	endif
    endm

dplcHeader macro {INTLABEL}
__LABEL__ label *
	if SonicDplcVer=1
		dc.b ((__LABEL___End - __LABEL___Begin) / 2)
	elseif SonicDplcVer=3
		dc.w (((__LABEL___End - __LABEL___Begin) / 2)-1)
	else
		dc.w ((__LABEL___End - __LABEL___Begin) / 2)
	endif
__LABEL___Begin label *
    endm

dplcEntry macro tiles,offset
	if SonicDplcVer=3
		dc.w ((offset&$FFF)<<4)|((tiles-1)&$F)
	elseif SonicDplcVer=4
		dc.w (((tiles-1)&$F)<<12)|((offset&$FFF)<<4)
	else
		dc.w (((tiles-1)&$F)<<12)|(offset&$FFF)
	endif
    endm

; I don't know why, but S3K uses Sonic 2's DPLC format for players, and its own for everything else
; so to avoid having to set and reset SonicMappingsVer I'll just make special macros
s3kPlayerDplcHeader macro {INTLABEL}
__LABEL__ label *
	dc.w ((__LABEL___end - __LABEL__ - 2) / 2)
    endm

s3kPlayerDplcEntry macro tiles,offset
	dc.w (((tiles-1)&$F)<<12)|(offset&$FFF)
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
; copy a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: destination, width [cells], height [cells], terminate
; ---------------------------------------------------------------------------

copyTilemap macro loc,width,height,terminate
	locVRAM	loc,d0
	moveq	#bytesToXcnt(width,8),d1
	moveq	#bytesToXcnt(height,8),d2
    if ("terminate"="0") || ("terminate"="")
	jsr	(Plane_Map_To_VRAM).w
    else
	jmp	(Plane_Map_To_VRAM).w
    endif
    endm

; ---------------------------------------------------------------------------
; copy a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: destination, VRAM shift, width [cells], height [cells], terminate
; ---------------------------------------------------------------------------

copyTilemap2 macro loc,address,width,height,terminate
	locVRAM	loc,d0
	moveq	#bytesToXcnt(width,8),d1
	moveq	#bytesToXcnt(height,8),d2
    if ((address)<=$7F)
	moveq	#(address),d3
    else
	move.w	#(address),d3
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Plane_Map_To_Add_VRAM).w
    else
	jmp	(Plane_Map_To_Add_VRAM).w
    endif
    endm

; ---------------------------------------------------------------------------
; copy a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: destination, width [cells], height [cells], terminate
; ---------------------------------------------------------------------------

copyTilemap3 macro loc,width,height,terminate
	locVRAM	loc,d0
	moveq	#bytesToXcnt(width,8),d1
	moveq	#bytesToXcnt(height,8),d2
    if ("terminate"="0") || ("terminate"="")
	jsr	(Plane_Map_To_VRAM_3).w
    else
	jmp	(Plane_Map_To_VRAM_3).w
    endif
    endm

; ---------------------------------------------------------------------------
; copy a tilemap from 68K (ROM/RAM) to the RAM
; input: destination, width [cells], height [cells], terminate
; ---------------------------------------------------------------------------

copyTilemapToRAM macro width,height,row,terminate
	moveq	#bytesToXcnt(width,8),d1
	moveq	#bytesToXcnt(height,8),d2
    if ((row)<=$7F)
	moveq	#row,d3
    else
	move.w	#row,d3
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Plane_Map_To_RAM).w
    else
	jmp	(Plane_Map_To_RAM).w
    endif
    endm

; ---------------------------------------------------------------------------
; clear a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: source, destination, width [cells], height [cells], terminate
; ---------------------------------------------------------------------------

clearTilemap macro loc,width,height,terminate
	locVRAM	loc,d0
	moveq	#bytesToXcnt(width,8),d1
	moveq	#bytesToXcnt(height,8),d2
    if ("terminate"="0") || ("terminate"="")
	jsr	(Clear_Plane_Map).w
    else
	jmp	(Clear_Plane_Map).w
    endif
    endm
; ---------------------------------------------------------------------------

LoadArtUnc macro offset,size,vram
	lea	(VDP_data_port).l,a6							; load VDP data address to a6
	lea	VDP_control_port-VDP_data_port(a6),a5					; load VDP control address to a5
	locVRAM	vram,VDP_control_port-VDP_control_port(a5)
	lea	(offset).l,a0
	moveq	#(size>>5)-1,d0

.load

	rept 8
		move.l	(a0)+,VDP_data_port-VDP_data_port(a6)
	endr

	dbf	d0,.load
    endm
; ---------------------------------------------------------------------------

LoadMapUnc macro offset,size,arg,loc,width,height
	lea	(offset).l,a0
	move.w	#arg,d0
	move.w	#((size)>>4),d1

.load

	rept 4
		move.l	(a0)+,(a1)
		add.w	d0,(a1)+
		add.w	d0,(a1)+
	endr

	dbf	d1,.load
	locVRAM	loc,d0
	moveq	#bytesToXcnt(width,8),d1
	moveq	#bytesToXcnt(height,8),d2
	jsr	(Plane_Map_To_VRAM).w
    endm

; ---------------------------------------------------------------------------
; macro for a pattern load request list header
; must be on the same line as a label that has a corresponding _end label later
; ---------------------------------------------------------------------------

plrlistheader macro {INTLABEL}
__LABEL__ label *
	dc.w (((__LABEL___end - __LABEL__Plc) / 6) - 1)
__LABEL__Plc:
    endm

; macro for a pattern load request
plreq macro toVRAMaddr,fromROMaddr
	dc.l fromROMaddr
	dc.w tiles_to_bytes(toVRAMaddr)
    endm

; ---------------------------------------------------------------------------
; compare the size of an index with ZoneCount constant
; (should be used immediately after the index)
; input: index address, element size
; ---------------------------------------------------------------------------

zonewarning macro loc,elementsize
._end
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

.skip
    endm

; macro to move the absolute value of the source in the destination
mvabs macro source,destination
	move.ATTRIBUTE	source,destination
	bpl.s	.skip
	neg.ATTRIBUTE	destination

.skip
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

ptrTableEntry macro loc,{GLOBALSYMBOLS}
ptr_loc:	dc.ATTRIBUTE loc-current_offset_table
    endm

offsetEntry macro ptr
	dc.ATTRIBUTE ptr-*
    endm

GameModeEntry macro ptr,{GLOBALSYMBOLS}
GameMode_ptr:	dc.l ptr
    endm

bincludeEntry macro {INTLABEL},{GLOBALSYMBOLS}
__LABEL__:	binclude ALLARGS
__LABEL___end
    endm
; ---------------------------------------------------------------------------

dScroll_Header macro {INTLABEL}
__LABEL__ label *
	dc.w (((__LABEL___end - __LABEL__Scroll) / 6) - 1)
__LABEL__Scroll:
    endm

dScroll_Data macro pixel,size,velocity,plane
	dc.w velocity, size
	if upstring("plane")="FG"
		dc.w H_scroll_buffer+(pixel<<2)
	elseif upstring("plane")="BG"
		dc.w (H_scroll_buffer+2)+(pixel<<2)
	else
		fatal "Error! Non-existent plan."
	endif
    endm
; ---------------------------------------------------------------------------

; macro for defining title card letters in conjunction with the remapped character set
titlecardLetters macro opt,str
	save
	codepage TITLECARD
.llookup := " ABCDEFGHIJKLMNOPQRSTUVWXYZ.()0123456789!"					; letter lookup string
.ignore := " ZONE0"									; set to initial state
.used := ""										; string to store already used characters
    irpc char,.ignore
.used := .used + "char"									; mark ignored characters as used
    endm
    if opt
	; not sort letters (S2 style)
	irpc char,str
	    if strstr(.used,"char") < 0
.used := .used + "char"									; mark as used
		if strstr(.ignore,"char") < 0
		    dc.b upstring("char")						; output letter code
		endif
	    endif
	endm
    else
	; letters in alphabetical order (S3K style)
	irpc char,str
	    if strstr(.used,"char") < 0
.used := .used + "char"									; mark as used
	    endif
	endm
	irpc char,.llookup
	    if strstr(.used,"char") >= 0
		if strstr(.ignore,"char") < 0
		    dc.b upstring("char")						; output letter code
		endif
	    endif
	endm
    endif
	dc.b -1	; end marker
	restore
    endm
; ---------------------------------------------------------------------------

; macro for title card letters from a string
creditsletters macro str
	save
	codepage CREDITSCREEN3
.narrow := "IJL.1!"
.wide := "MOQW069"
    irpc char,str
	if strstr(.narrow,"char") >= 0
	    dc.w 'char', 1-1								; narrow (8x24)
	elseif strstr(.wide,"char") >= 0
	    dc.w 'char', 3-1								; wide (24x24)
	else
	    dc.w 'char', 2-1								; normal (16x24)
	endif
    endm
	restore
    endm
; ---------------------------------------------------------------------------

; macro for generating standard strings
standardstr macro str
	save
	codepage STANDARD
	dc.b strlen(str)-1, str
	restore
    endm

; macro for generating level select strings
levselstr macro str
	save
	codepage LEVELSCREEN
	dc.b strlen(str)-1, str
	restore
    endm
; ---------------------------------------------------------------------------

	; codepage for level select
	save
	codepage LEVELSCREEN
	charset ' ', 43
	charset '0','9', 1
	charset 'A','Z', 17
	charset 'a','z', 17
	charset '*', 11
	charset '@', 12
	charset ':', 13
	charset '-', 14
	charset '/', 15
	charset '.', 16
	restore

	; codepage for title card
	save
	codepage TITLECARD
	charset ' ', 0
	charset 'A','Z', 1
	charset 'a','z', 1
	charset '.', 27
	charset '(', 28
	charset ')', 29
	charset '0','9', 30
	charset '!', 40
	restore

	; codepage for credits
	save
	codepage CREDITSCREEN3
	charset 'A',0
	charset 'B',"\6\xC\x12\x18\x1E\x24\x2A\x30\x33\x36\x3C\x3F\x48\x4E\x57\x5D\x66\x6C\x72\x78\x7E\x84\x8D\x93\x99"
	charset '.', $9F
	charset '(', $A2
	charset ')', $A8
	charset '0', $4E
	charset '1',"\xAE\xB1\xB7\xBD\xC3\xC9\xD2\xD8\xDE"
	charset '!', $E7
	restore

	; codepage for HUD
	save
	codepage HUD
	charset ' ',$FF
	charset '0',0
	charset '1',2
	charset '2',4
	charset '3',6
	charset '4',8
	charset '5',$A
	charset '6',$C
	charset '7',$E
	charset '8',$10
	charset '9',$12
	charset '*',$14
	charset ':',$16
	charset 'E',$18
	restore
