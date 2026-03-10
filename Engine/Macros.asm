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
; that writes n bytes total at 2 bytes per iteration
bytesToWcnt function n,bytesToXcnt(n,2)

; calculates initial loop counter value for a dbf loop
; that writes n bytes total at 4 bytes per iteration
bytesToLcnt function n,bytesToXcnt(n,4)

; calculates initial loop counter value for a normal loop
; that writes n bytes total at x bytes per iteration
bytesTo2Xcnt function n,x,n/x

; calculates initial loop counter value for a normal loop
; that writes n bytes total at 2 bytes per iteration
bytesTo2Wcnt function n,bytesTo2Xcnt(n,2)

; calculates initial loop counter value for a normal loop
; that writes n bytes total at 4 bytes per iteration
bytesTo2Lcnt function n,bytesTo2Xcnt(n,4)

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

; the VDP's sprite coordinates place the top-left pixel of the screen at $80,$80,
; these constants are to help deobfuscate that
spriteScreenPositionX function pos,sprite_left_boundary+pos
spriteScreenPositionY function pos,sprite_top_boundary+pos
spriteScreenPositionXCentered function pos,spriteScreenPositionX(screen_width/2+(pos))
spriteScreenPositionYCentered function pos,spriteScreenPositionY(screen_height/2+(pos))

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
; macro for a debug object list header
; must be on the same line as a label that has a corresponding _end label later
; ---------------------------------------------------------------------------

dbglistheader macro {INTLABEL}
__LABEL__ label *
dbglistcount := 0
dbglistcur := "__LABEL__"
	dc.w dbglistcount___LABEL__							; number of debug object list
    endm

; macro to define debug list object data
dbglistobj macro obj,mapaddr,subtype,frame,vram,pal,pri
	dc.l frame<<24|((obj)&$FFFFFF)
	dc.l subtype<<24|((mapaddr)&$FFFFFF)
	dc.w make_art_tile(vram,pal,pri)
dbglistcount := dbglistcount + 1
    endm

dbglistend macro
dbglistcount_{"\{dbglistcur}"} = dbglistcount
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
	music, \
	water=FALSE

	dc.l (palette)<<24|((art1)&$FFFFFF),art2
	dc.l (wpalette)<<24|((map16x16r)&$FFFFFF),map16x161,map16x162
	dc.l (music)<<24|((map128x128r)&$FFFFFF),map128x1281,map128x1282
	dc.l (water)<<24|((layoutr)&$FFFFFF),layout1,layout2
	dc.l solidr,solid1,solid2
	dc.l objectsr,objects1,objects2
	dc.l ringsr,rings1,rings2
    endm
; ---------------------------------------------------------------------------

palptr macro ptr,lineno
	dc.l ptr
	dc.w ((Normal_palette+lineno*palette_line_size)&$FFFF),bytesToLcnt(ptr_end-ptr)
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
subObjMainData macro addr=FALSE,render,routine,height,width,prio,vram,pal,pri,mappings,frame,collision
    if upstring("addr")<>"FALSE"
	dc.l addr
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

; macro to declare DPLC data
DPLCEntry macro art,mappings
	dc.l dmaSource(art),mappings
    endm
; ---------------------------------------------------------------------------

zoneanimals macro first,second
	dc.ATTRIBUTE (Obj_Animal_Properties_first - Obj_Animal_Properties),(Obj_Animal_Properties_second - Obj_Animal_Properties)
    endm

objanimaldecl macro map,addr,xvel,yvel,{INTLABEL}
Obj_Animal_Properties___LABEL__: label *
	dc.l map,addr
	dc.w xvel,yvel
    endm

objanimalending macro addr,map,vram,xvel,yvel
	dc.l addr,map
	dc.w vram,xvel,yvel
	dc.w 0	; even
    endm
; ---------------------------------------------------------------------------

titlecardresultsheader macro {INTLABEL}
__LABEL__ label *
titlecardresultscount := 0
titlecardresultscur := "__LABEL__"
	dc.w titlecardresultscount___LABEL__						; number of titlecard and results object list (-1)
    endm

titlecardresultsobjdata macro addr,xdest,xpos,ypos,frame,width,exit
	dc.l addr									; object address
	dc.w 128+xdest,128+xpos,128+ypos						; x destination, xpos, ypos
	dc.b frame,(width/2)								; mapping frame, width
	dc.w exit									; place in exit queue
titlecardresultscount := titlecardresultscount + 1
    endm

titlecardresultsend macro
titlecardresultscount_{"\{titlecardresultscur}"} = titlecardresultscount - 1
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
EniDecomp macro data,ram,vram,pal,pri,terminate
	lea	(data).l,a0
    if ((ram)&$8000)=0
	lea	(ram).l,a1
    else
	lea	(ram).w,a1
    endif
    if ((make_art_tile(vram,pal,pri))<=$7F)
	moveq	#make_art_tile(vram,pal,pri),d0
    else
	move.w	#make_art_tile(vram,pal,pri),d0
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
	and.w	xpos,d0									; get object position (if specified as not x_pos)
    else
	and.w	x_pos(a0),d0								; get object position
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
	and.w	ypos,d0									; get object position (if specified as not y_pos)
    else
	and.w	y_pos(a0),d0								; get object position
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
	bclr	#respawn_addr.state,(a2)						; turn on the slot

.delete
    if ("terminate"="0") <> ("terminate"="")
	jmp	(Delete_Current_Object).w
    endif
    endm

; ---------------------------------------------------------------------------
; macros for frequently used subroutines
; ---------------------------------------------------------------------------

getobjectSlot macro reg
    ifb reg
	fatal "Error! Empty value!"
    endif
	move.w	#Dynamic_object_RAM_end,d0
	sub.w	a0,d0
	lsr.w	#6,d0									; divide by $40... even though SSTs are $50 bytes long in this game
	lea	(Create_New_Object_3.table).w,reg
	move.b	(reg,d0.w),d0								; use a look-up table to get the right loop counter
    endm

MoveSprite macro reg=a0,gravity,terminate
    ifb reg
	fatal "Error! Empty value!"
    endif
	movem.w	x_vel(reg),d0/d2							; load xy speed
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	asl.l	#8,d2									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,x_pos(reg)								; add to x-axis position ; note this affects the subpixel position x_sub(reg) = 2+x_pos(reg)
	add.l	d2,y_pos(reg)								; add to y-axis position ; note this affects the subpixel position y_sub(reg) = 2+y_pos(reg)
    ifnb gravity
	addi.w	#gravity,y_vel(reg)							; increase vertical speed (apply gravity)
	else
	addi.w	#$38,y_vel(reg)								; increase vertical speed (apply gravity)
    endif
    ifnb terminate
	rts
    endif
    endm

MoveSprite2 macro reg=a0,terminate
    ifb reg
	fatal "Error! Empty value!"
    endif
	movem.w	x_vel(reg),d0/d2							; load xy speed
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	asl.l	#8,d2									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,x_pos(reg)								; add to x-axis position ; note this affects the subpixel position x_sub(reg) = 2+x_pos(reg)
	add.l	d2,y_pos(reg)								; add to y-axis position ; note this affects the subpixel position y_sub(reg) = 2+y_pos(reg)
    ifnb terminate
	rts
    endif
    endm

MoveSpriteXOnly macro reg=a0,terminate
    ifb reg
	fatal "Error! Empty value!"
    endif
	move.w	x_vel(reg),d0								; load x speed
	ext.l	d0
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,x_pos(reg)								; add to x-axis position ; note this affects the subpixel position x_sub(reg) = 2+x_pos(reg)
    ifnb terminate
	rts
    endif
    endm

MoveSpriteYOnly macro reg=a0,gravity,terminate
    ifb reg
	fatal "Error! Empty value!"
    endif
	move.w	y_vel(reg),d0								; load y speed
	ext.l	d0
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,y_pos(reg)								; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
    ifnb gravity
	addi.w	#gravity,y_vel(reg)							; increase vertical speed (apply gravity)
	else
	addi.w	#$38,y_vel(reg)								; increase vertical speed (apply gravity)
    endif
    ifnb terminate
	rts
    endif
    endm

MoveSprite2YOnly macro reg=a0,terminate
    ifb reg
	fatal "Error! Empty value!"
    endif
	move.w	y_vel(reg),d0								; load y speed
	ext.l	d0
	asl.l	#8,d0									; shift velocity to line up with the middle 16 bits of the 32-bit position
	add.l	d0,y_pos(reg)								; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
    ifnb terminate
	rts
    endif
    endm

Draw_Sprite macro prio=0,terminate
	lea	(Sprite_table_input+sprite_priority(prio)).w,a1
    if ("terminate"="0") || ("terminate"="")
	jsr	(Draw_Sprite.find).w
    else
	jmp	(Draw_Sprite.find).w
    endif
    endm

Add_SpriteToCollisionResponseList macro reg,terminate
    ifb reg
	fatal "Error! Empty value!"
    endif
	lea	(Collision_response_list).w,reg
	move.w	(reg),d0								; get list to d0
	addq.b	#2,d0									; is list full? ($80)
	bmi.s	.full									; if so, return
	move.w	d0,(reg)								; save list ($7E)
	move.w	a0,(reg,d0.w)								; store RAM address in list

.full
    ifnb terminate
	rts
    endif
    endm

Create_New_Object_4 macro addr,terminate
	subq.w	#1,d0
    ifnb addr
	bmi.ATTRIBUTE	addr								; branch, if there are no free object slots here
    else
	bmi.ATTRIBUTE	.done								; branch, if there are no free object slots here
    endif

.find
	lea	next_object(a1),a1							; goto next object RAM slot
	tst.l	address(a1)								; is object RAM slot empty?
	dbeq	d0,.find								; if not, branch

    ifb addr
.done
    endif
    ifnb terminate
	rts
    endif
    endm

; ---------------------------------------------------------------------------
; macro to display text on the plane
; ---------------------------------------------------------------------------

DrawPlaneText macro source,loc,vram,pal,pri,terminate
    ifnb source
	lea	source(pc),a1
    endif
	locVRAM	loc,d1
    if ((make_art_tile(vram,pal,pri))<=$7F)
	moveq	#make_art_tile(vram,pal,pri),d3
    else
	move.w	#make_art_tile(vram,pal,pri),d3
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Draw_PlaneText).w
    else
	jmp	(Draw_PlaneText).w
    endif
    endm

DrawPlaneTextAdvanced macro source,loc,twidth,theight,vram,pal,pri,terminate
    ifnb source
	lea	source(pc),a1
    endif
	locVRAM	loc,d1
	move.l	#words_to_long( \
	    bytesToXcnt(((twidth)+(tile_width-1)),tile_width), \
	    bytesToXcnt(((theight)+(tile_height-1)),tile_height) \
	),d2
    if ((make_art_tile(vram,pal,pri))<=$7F)
	moveq	#make_art_tile(vram,pal,pri),d3
    else
	move.w	#make_art_tile(vram,pal,pri),d3
    endif
    if ("terminate"="0") || ("terminate"="")
	jsr	(Draw_PlaneText_Advanced).w
    else
	jmp	(Draw_PlaneText_Advanced).w
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

jsrb macro loc
    if (loc)<$8000
	jsr	(loc).w
    else
	jsr	(loc).l
    endif
    endm

jmpb macro loc
    if (loc)<$8000
	jmp	(loc).w
    else
	jmp	(loc).l
    endif
    endm
; ---------------------------------------------------------------------------

_KosPlus_LoopUnroll = 3

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

zoneanimend macro
zoneanimcount_{"\{zoneanimcur}"} = zoneanimcount - 1
    endm

zoneanimplcdecl macro duration,artaddr,vramaddr,numentries,numvramtiles
start:
	dc.l (duration&$FF)<<24|dmaSource(artaddr)
	dc.w tiles_to_bytes(vramaddr)
	dc.b numentries,numvramtiles
zoneanimcount := zoneanimcount + 1
    endm

zoneanimpaldecl macro duration,paladdr,palram,numentries,numcolors
start:
	dc.l (duration&$FF)<<24|paladdr
	dc.w ((palram)&$FFFF)
	dc.b numentries,numcolors
zoneanimcount := zoneanimcount + 1
    endm

; macros for defining water transition
watertransheader macro {INTLABEL}
__LABEL__ label *
	dc.w (((__LABEL___end - __LABEL__ - 2) / 2) - 1)				; number of entries in list minus one
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
	dc.w data-header,0
	dc.l header
._headpos := header
    endm

; macro to define a palette script header
palscripthdr macro palette,entries,value
	dc.w (palette)&$FFFF
	dc.b entries-1,value
    endm

; macro to define a palette script data
palscriptdata macro frames
.framec := frames-1
	shift
	dc.w ALLARGS
	dc.w .framec
    endm

; macro to define a palette script data from an external file
palscriptfile macro frames
.framec := frames-1
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
	dc.w -4,header-._headpos
._headpos := header
    endm

; macro to run the custom script routine
palscriptrun macro header
	dc.w -6
    endm

; ---------------------------------------------------------------------------
; macro to declare a mappings table (taken from Sonic 2 Hg disassembly)
; ---------------------------------------------------------------------------

SonicMappingsVer := 3
SonicDplcVer := 3

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
		dc.b ((__LABEL___end - __LABEL___Begin) / 5)
	elseif SonicMappingsVer=2
		dc.w ((__LABEL___end - __LABEL___Begin) / 8)
	else
		dc.w ((__LABEL___end - __LABEL___Begin) / 6)
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
		dc.b ((__LABEL___end - __LABEL___Begin) / 2)
	elseif SonicDplcVer=3
		dc.w (((__LABEL___end - __LABEL___Begin) / 2)-1)
	else
		dc.w ((__LABEL___end - __LABEL___Begin) / 2)
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

copyTilemap macro loc,twidth,theight,terminate
	locVRAM	loc,d0
	moveq	#bytesToXcnt(((twidth)+(tile_width-1)),tile_width),d1
	moveq	#bytesToXcnt(((theight)+(tile_height-1)),tile_height),d2
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

copyTilemap2 macro loc,vram,pal,pri,twidth,theight,terminate
	locVRAM	loc,d0
	moveq	#bytesToXcnt(((twidth)+(tile_width-1)),tile_width),d1
	moveq	#bytesToXcnt(((theight)+(tile_height-1)),tile_height),d2
    if ((make_art_tile(vram,pal,pri))<=$7F)
	moveq	#make_art_tile(vram,pal,pri),d3
    else
	move.w	#make_art_tile(vram,pal,pri),d3
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

copyTilemap3 macro loc,twidth,theight,terminate
	locVRAM	loc,d0
	moveq	#bytesToXcnt(((twidth)+(tile_width-1)),tile_width),d1
	moveq	#bytesToXcnt(((theight)+(tile_height-1)),tile_height),d2
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

copyTilemapToRAM macro twidth,theight,row,terminate
	moveq	#bytesToXcnt(((twidth)+(tile_width-1)),tile_width),d1
	moveq	#bytesToXcnt(((theight)+(tile_height-1)),tile_height),d2
    if ((row)<=$7F)
	moveq	#(row),d3
    else
	move.w	#(row),d3
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

clearTilemap macro loc,twidth,theight,terminate
	locVRAM	loc,d0
	moveq	#bytesToXcnt(((twidth)+(tile_width-1)),tile_width),d1
	moveq	#bytesToXcnt(((theight)+(tile_height-1)),tile_height),d2
    if ("terminate"="0") || ("terminate"="")
	jsr	(Clear_Plane_Map).w
    else
	jmp	(Clear_Plane_Map).w
    endif
    endm

; ---------------------------------------------------------------------------
; macro for a pattern load request list header
; ---------------------------------------------------------------------------

; macro for a pattern load request
plrlistheader macro {INTLABEL}
__LABEL__ label *
plrlistcount := 0
plrlistcur := "__LABEL__"
	dc.w plrlistcount___LABEL__							; number of pattern load request (-1)
    endm

plreq macro toVRAMaddr,fromROMaddr
	dc.l fromROMaddr
	dc.w tiles_to_bytes(toVRAMaddr)
plrlistcount := plrlistcount + 1
    endm

plrlistend macro
plrlistcount_{"\{plrlistcur}"} = plrlistcount - 1
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

ptrTableEntry macro loc
ptr_loc:	label *
	dc.ATTRIBUTE loc-current_offset_table
    endm

offsetEntry macro ptr
	dc.ATTRIBUTE ptr-*
    endm

GameModeEntry macro ptr
GameMode_ptr:	label *
	dc.l ptr
    endm

incfile macro name,path
attr := lowstring("ATTRIBUTE")
	name:	label *
    if substr(attr,0,1)="b"
	binclude path
    elseif substr(attr,0,1)="i"
	include path
    else
	fatal "incfile: attribute must start with 'b' or 'i', but it's '\{substr(attr,0,1)}'"
    endif
    if substr(attr,1,1)="o"
	ObjectLayoutBoundary
    elseif substr(attr,1,1)="r"
	RingLayoutBoundary
    endif
    if strstr(attr,"e") >= 0
	name_end:	label *
	if strstr(attr,"d") >= 0
	    if (((name)+((name_end-name))-1)>>17)<>((name)>>17)
		fatal "DMA crosses a 128kB boundary. You should either split the DMA manually or align the source adequately."
	    endif
	endif
    endif
    if strstr(attr,"a") >= 0
	even
    endif
    endm
; ---------------------------------------------------------------------------

HScroll_Header macro {INTLABEL}
__LABEL__ label *
hscrollcount := 0
hscrollcur := "__LABEL__"
	dc.w hscrollcount___LABEL__							; number of horizontal scroll list (-1)
    endm

HScroll_Data macro pixel,size,velocity,plane
	dc.w velocity,size
	if upstring("plane")="FG"
		dc.w H_scroll_buffer+(pixel<<2)
	elseif upstring("plane")="BG"
		dc.w (H_scroll_buffer+2)+(pixel<<2)
	else
		fatal "Error! Non-existent plane."
	endif
hscrollcount := hscrollcount + 1
    endm

HScroll_End macro
hscrollcount_{"\{hscrollcur}"} = hscrollcount - 1
    endm
; ---------------------------------------------------------------------------

; macro for defining title card letters in conjunction with the remapped character set
titlecardVRAMLetters macro opt,opt2,str
	save
	codepage TITLECARD
.llookup := " ABCDEFGHIJKLMNOPQRSTUVWXYZ.()0123456789!"					; letter lookup string
    if opt2
.ignore := " "										; set to initial state
    else
.ignore := " ZONE0"									; set to initial state
    endif
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

; macro for generating title card letter mappings with the remapped character set
titlecardMapLetters macro opt,pos=-32,str
	save
	codepage TITLECARD
.vram_start := $804D
.narrow := "IJL.1!"
.wide := "MOQW069"
.llookup := " ABCDEFGHIJKLMNOPQRSTUVWXYZ.()0123456789!"
.ignore := " ZONE0"
.used := ""
    irpc char,.ignore
.used := .used + "char"									; mark ignored characters as used
    endm
.collected := ""
    if opt
	; not sort letters (S2 style)
	irpc char,str
	    if strstr(.used,"char") < 0
.used := .used + "char"									; mark as used
		if strstr(.ignore,"char") < 0
.collected := .collected + "char"
		endif
	    endif
	endm
    else
	; letters in alphabetical order (S3K style)
	irpc char,.llookup
	    if strstr(str,"char") >= 0
		if strstr(.used,"char") < 0
.used := .used + "char"									; mark as used
		    if strstr(.ignore,"char") < 0
.collected := .collected + "char"
		    endif
		endif
	    endif
	endm
    endif
.total_width := 0
.sprite_count := 0
    irpc char,str
	if "char" = " "
.total_width := .total_width + 8
	else
.sprite_count := .sprite_count + 1
	    if strstr(.narrow,"char") >= 0
.total_width := .total_width + 8
	    elseif strstr(.wide,"char") >= 0
.total_width := .total_width + 24
	    else
.total_width := .total_width + 16
	    endif
	endif
    endm
	dc.w .sprite_count
.current_x := ((screen_width/2)+(pos)) - .total_width
    irpc char,str
.width := 16
.size := 6
	if strstr(.narrow,"char") >= 0
.width := 8
.size := 2
	elseif strstr(.wide,"char") >= 0
.width := 24
.size := $A
	endif
	if "char" = " "
.current_x := .current_x + 8
	else
	    if "char" = "Z"
.vram_final := $8037
	    elseif ("char" = "O") || ("char" = "0")
.vram_final := $802E
	    elseif "char" = "N"
.vram_final := $8028
	    elseif "char" = "E"
.vram_final := $8022
	    else
.vram_final := .vram_start
.found := 0
		irpc c,.collected
		    if .found = 0
			if "c" = "char"
.found := 1
			else
			    if strstr(.narrow,"c") >= 0
.vram_final := .vram_final + 3
			    elseif strstr(.wide,"c") >= 0
.vram_final := .vram_final + 9
			    else
.vram_final := .vram_final + 6
			    endif
			endif
		    endif
		endm
	    endif
	    dc.b 0, .size
	    dc.w .vram_final, .current_x
.current_x := .current_x + .width
	endif
    endm
	even
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
	charset '0',"\0\2\4\6\8\xA\xC\xE\x10\x12"
	charset '*',$14
	charset ':',$16
	charset 'E',$18
	restore
