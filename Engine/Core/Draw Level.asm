; ---------------------------------------------------------------------------
; Drawing level tiles
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_DrawLevel:
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5

.main
		lea	(Plane_buffer).w,a0
		bsr.s	.find

		; check secondary plane buffer
		move.l	(Plane_buffer_2_addr).w,d0					; get secondary plane buffer pointer to d0
		beq.s	.return								; if zero, branch
		movea.l	d0,a0								; load secondary plane buffer pointer to a0

.find
		move.w	(a0),d0								; get destination VRAM address to d0
		beq.s	.done								; if zero, exit
		clr.w	(a0)+								; clear current slot
		move.w	(a0)+,d1							; get number of tiles to d1
		bmi.s	.column								; branch, if is column flag was set

		; draw row tiles
		move.w	#$8F02,d2							; VRAM increment at 2 bytes (horizontal level write)
		move.w	#$80,d3								; set next line
		bra.s	.draw
; ---------------------------------------------------------------------------

.column

		; draw column tiles
		move.w	#$8F80,d2							; VRAM increment at $80 bytes (vertical level write)
		moveq	#2,d3								; set next line
		andi.w	#$7FFF,d1							; clear column flag bit

.draw
		move.w	d2,VDP_control_port-VDP_control_port(a5)			; set VRAM increment (horizontal or vertical level write)

		; update 1
		move.w	d0,d2								; save VRAM address
		move.w	d1,d4								; save loop count
		bsr.s	VInt_VRAMWrite

		; update 2
		move.w	d2,d0								; load saved VRAM address
		add.w	d3,d0								; next line for column/row
		move.w	d4,d1								; load saved loop count
		bsr.s	VInt_VRAMWrite

		; next
		bra.s	.find
; ---------------------------------------------------------------------------

.done
		move.w	#$8F02,VDP_control_port-VDP_control_port(a5)			; VRAM increment at 2 bytes

.return
		rts

; ---------------------------------------------------------------------------
; VRAM write
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_VRAMWrite:
		swap	d0
		clr.w	d0
		swap	d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#vdpComm(0,VRAM,WRITE)>>16,d0
		swap	d0								; d0 = VDP command to write to destination
		move.l	d0,VDP_control_port-VDP_control_port(a5)

.copy
		move.l	(a0)+,VDP_data_port-VDP_data_port(a6)
		dbf	d1,.copy

.return
		rts

; ---------------------------------------------------------------------------
; VRAM read
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_VRAMRead:
		swap	d0
		clr.w	d0
		swap	d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		swap	d0								; d0 = VDP command to write to destination
		move.l	d0,VDP_control_port-VDP_control_port(a5)

.copy
		move.l	VDP_data_port-VDP_data_port(a6),(a0)+
		dbf	d1,.copy

.return
		rts

; ---------------------------------------------------------------------------
; Draw tile column
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_TileColumn:
		moveq	#-16,d0
		and.w	(a6),d0
		move.w	(a5),d2
		move.w	d0,(a5)
		move.w	d2,d3
		sub.w	d0,d2
		beq.s	VInt_VRAMRead.return
		tst.b	d2
		bpl.s	.check
		neg.w	d2
		move.w	d3,d0
		addi.w	#screen_width+block_width,d0

.check
		andi.w	#$30,d2
		cmpi.w	#block_width,d2							; the camera scrolls more than 16 pixels?
		sne	(Plane_double_update_flag).w					; if so, set flag

		; update 1
		movem.w	d1/d6,-(sp)							; save the registers to the stack
		bsr.s	Setup_TileColumnDraw
		movem.w	(sp)+,d1/d6							; return saved registers from the stack

		; check flag
		tst.b	(Plane_double_update_flag).w					; is update flag was set?
		beq.s	VInt_VRAMRead.return						; if not, branch

		; update 2
		addi.w	#block_width,d0
		bra.s	Setup_TileColumnDraw

; ---------------------------------------------------------------------------
; Draw tile column 2
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_TileColumn2:
		moveq	#-16,d0
		and.w	(a6),d0
		move.w	(a5),d2
		move.w	d0,(a5)
		move.w	d2,d3
		sub.w	d0,d2
		beq.s	VInt_VRAMRead.return
		tst.b	d2
		bpl.s	.check
		neg.w	d2
		move.w	d3,d0
		addi.w	#screen_width+block_width,d0
		swap	d1

.check
		andi.w	#$30,d2
		cmpi.w	#block_width,d2							; the camera scrolls more than 16 pixels?
		sne	(Plane_double_update_flag).w					; if so, set flag

		; update 1
		movem.w	d1/d6,-(sp)							; save the registers to the stack
		bsr.s	Setup_TileColumnDraw
		movem.w	(sp)+,d1/d6							; return saved registers from the stack

		; check flag
		tst.b	(Plane_double_update_flag).w					; is update flag was set?
		beq.s	VInt_VRAMRead.return						; if not, branch

		; update 2
		addi.w	#block_width,d0

Setup_TileColumnDraw:
		move.w	d1,d2
		andi.w	#$70,d2
		move.w	d1,d3
		lsl.w	#4,d3								; multiply by $10
		andi.w	#$F00,d3
		asr.w	#4,d1
		move.w	d1,d4
		asr.w	d1
		and.w	(Layout_row_index_mask).w,d1
		andi.w	#$F,d4
		moveq	#gameplay_plane_height/block_height,d5
		sub.w	d4,d5
		move.w	d5,d4
		sub.w	d6,d5
		bmi.s	.next
		move.w	d0,d5
		asr.w	#2,d5
		andi.w	#$7C,d5
		add.w	d7,d5								; add plane base address to d5
		add.w	d3,d5
		move.w	d5,(a0)+
		move.w	d6,d5
		subq.w	#1,d6								; dbf fix
		move.w	d6,(a0)+
		bset	#7,-2(a0)							; set column flag
		lea	(a0),a1
		add.w	d5,d5
		add.w	d5,d5
		adda.w	d5,a0
		bsr.w	Get_LevelChunkColumn
		bra.s	.swap
; ---------------------------------------------------------------------------

.next
		neg.w	d5
		move.w	d5,-(sp)
		move.w	d0,d5
		asr.w	#2,d5
		andi.w	#$7C,d5
		add.w	d7,d5								; add plane base address to d5
		add.w	d3,d5
		move.w	d5,(a0)+
		move.w	d4,d6
		subq.w	#1,d6								; dbf fix
		move.w	d6,(a0)+
		bset	#7,-2(a0)							; set column flag
		lea	(a0),a1
		add.w	d4,d4
		add.w	d4,d4
		adda.w	d4,a0
		bsr.w	Get_LevelChunkColumn
		bsr.s	.swap
		move.w	(sp)+,d6
		move.w	d0,d5
		asr.w	#2,d5
		andi.w	#$7C,d5
		add.w	d7,d5								; add plane base address to d5
		move.w	d5,(a0)+
		move.w	d6,d5
		subq.w	#1,d6								; dbf fix
		move.w	d6,(a0)+
		bset	#7,-2(a0)							; set column flag
		lea	(a0),a1
		add.w	d5,d5
		add.w	d5,d5
		adda.w	d5,a0

.swap
		swap	d7								; swap data to avoid losing plane base address

.getblock
		move.w	(a5,d2.w),d3
		move.w	d3,d4
		andi.w	#$3FF,d3
		lsl.w	#3,d3								; multiply by 8
		move.w	(a2,d3.w),d5
		swap	d5
		move.w	4(a2,d3.w),d5
		move.w	6(a2,d3.w),d7
		move.w	2(a2,d3.w),d3
		swap	d3
		move.w	d7,d3

		; check xy flip flags
		btst	#$B,d4
		beq.s	.notflipy
		eori.l	#words_to_long(flip_y,flip_y),d5
		eori.l	#words_to_long(flip_y,flip_y),d3
		swap	d5
		swap	d3

.notflipy
		btst	#$A,d4
		beq.s	.notflipx
		eori.l	#words_to_long(flip_x,flip_x),d5
		eori.l	#words_to_long(flip_x,flip_x),d3
		exg	d3,d5

.notflipx
		move.l	d5,(a1)+
		move.l	d3,(a0)+
		addi.w	#16,d2
		andi.w	#$70,d2
		bne.s	.skip
		addq.w	#4,d1
		and.w	(Layout_row_index_mask).w,d1
		bsr.s	Get_LevelChunkColumn

.skip
		dbf	d6,.getblock
		swap	d7								; swap data back to return plane base address
		clr.w	(a0)								; end marker
		rts

; ---------------------------------------------------------------------------
; Get chunk (Column)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_LevelChunkColumn:
		movea.l	(Level_layout_addr_ROM).w,a4
		move.w	d0,d3
		asr.w	#7,d3
		add.w	d3,d3								; chunk ID to word
		add.w	(a3,d1.w),d3
		adda.w	d3,a4
		moveq	#0,d3
		move.w	(a4),d3								; move 128*128 chunk ID to d3
		lsl.w	#7,d3								; multiply by $80
		move.w	d0,d4
		asr.w	#3,d4
		andi.w	#$E,d4
		add.w	d4,d3
		movea.l	(Level_data_addr_RAM.128x128RAM).w,a5
		adda.l	d3,a5

.return
		rts

; ---------------------------------------------------------------------------
; Draw HScroll background 2
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_BGHDeform2:

		; update camera y scroll
		lea	(Camera_Y_pos_BG_copy).w,a6
		lea	(Camera_Y_pos_BG_rounded).w,a5
		moveq	#0,d1								; Camera_X_pos_BG_copy
		moveq	#gameplay_plane_width/block_width,d6

; ---------------------------------------------------------------------------
; Draw tile row
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_TileRow:
		move.w	(a6),d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	(a5),d2
		move.w	d0,(a5)
		move.w	d2,d3
		sub.w	d0,d2
		beq.s	Get_LevelChunkColumn.return
		tst.b	d2
		bpl.s	.check
		neg.w	d2
		move.w	d3,d0
		addi.w	#screen_height+block_height,d0
		and.w	(Camera_Y_pos_mask).w,d0

.check
		andi.w	#$30,d2
		cmpi.w	#block_height,d2						; the camera scrolls more than 16 pixels?
		sne	(Plane_double_update_flag).w					; if so, set flag

		; update 1
		movem.w	d1/d6,-(sp)							; save the registers to the stack
		bsr.s	Setup_TileRowDraw
		movem.w	(sp)+,d1/d6							; return saved registers from the stack

		; check flag
		tst.b	(Plane_double_update_flag).w					; is update flag was set?
		beq.s	Get_LevelChunkColumn.return					; if not, branch

		; update 2
		addi.w	#block_height,d0
		and.w	(Camera_Y_pos_mask).w,d0
		bra.s	Setup_TileRowDraw

; ---------------------------------------------------------------------------
; Draw tile row 2
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_TileRow2:
		move.w	(a6),d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	(a5),d2
		move.w	d0,(a5)
		move.w	d2,d3
		sub.w	d0,d2
		beq.s	Get_LevelChunkColumn.return
		tst.b	d2
		bpl.s	.check
		neg.w	d2
		move.w	d3,d0
		addi.w	#screen_height+block_height,d0
		and.w	(Camera_Y_pos_mask).w,d0
		swap	d1

.check
		andi.w	#$30,d2
		cmpi.w	#block_height,d2						; the camera scrolls more than 16 pixels?
		sne	(Plane_double_update_flag).w					; if so, set flag

		; update 1
		movem.w	d1/d6,-(sp)							; save the registers to the stack
		bsr.s	Setup_TileRowDraw
		movem.w	(sp)+,d1/d6							; return saved registers from the stack

		; check flag
		tst.b	(Plane_double_update_flag).w					; is update flag was set?
		beq.w	Get_LevelChunkColumn.return					; if not, branch

		; update 2
		addi.w	#block_height,d0
		and.w	(Camera_Y_pos_mask).w,d0

Setup_TileRowDraw:
		asr.w	#4,d1
		move.w	d1,d2
		move.w	d1,d4
		asr.w	#3,d1
		add.w	d1,d1								; chunk ID to word
		add.w	d2,d2
		move.w	d2,d3
		andi.w	#$E,d2
		add.w	d3,d3
		andi.w	#$7C,d3
		andi.w	#$1F,d4
		moveq	#gameplay_plane_width/block_width,d5
		sub.w	d4,d5
		move.w	d5,d4
		sub.w	d6,d5
		bmi.s	.next
		move.w	d0,d5
		andi.w	#$F0,d5								; if the length of the write can fit without wrapping the nametable
		lsl.w	#4,d5								; multiply by $10
		add.w	d7,d5								; add plane base address to d5
		add.w	d3,d5
		move.w	d5,(a0)+
		move.w	d6,d5
		subq.w	#1,d6								; dbf fix
		move.w	d6,(a0)+
		lea	(a0),a1
		add.w	d5,d5
		add.w	d5,d5
		adda.w	d5,a0
		bsr.w	Get_LevelAddrChunkRow
		bra.s	.getblock
; ---------------------------------------------------------------------------

.next
		neg.w	d5								; if the length of the write wraps over the length of the nametable
		move.w	d5,-(sp)
		move.w	d0,d5
		andi.w	#$F0,d5
		lsl.w	#4,d5								; multiply by $10
		add.w	d7,d5								; add plane base address to d5
		add.w	d3,d5
		move.w	d5,(a0)+
		move.w	d4,d6
		subq.w	#1,d6								; dbf fix
		move.w	d6,(a0)+
		lea	(a0),a1
		add.w	d4,d4
		add.w	d4,d4
		adda.w	d4,a0
		bsr.s	Get_LevelAddrChunkRow
		bsr.s	.getblock
		move.w	(sp)+,d6							; must place one more write command to account for rollover
		move.w	d0,d5
		andi.w	#$F0,d5
		lsl.w	#4,d5								; multiply by $10
		add.w	d7,d5								; add plane base address to d5
		move.w	d5,(a0)+
		move.w	d6,d5
		subq.w	#1,d6								; dbf fix
		move.w	d6,(a0)+
		lea	(a0),a1
		add.w	d5,d5
		add.w	d5,d5
		adda.w	d5,a0

.getblock
		move.w	(a5,d2.w),d3
		move.w	d3,d4
		andi.w	#$3FF,d3
		lsl.w	#3,d3								; multiply by 8
		move.l	(a2,d3.w),d5
		move.l	4(a2,d3.w),d3

		; check xy flip flags
		btst	#$B,d4
		beq.s	.notflipy
		eori.l	#words_to_long(flip_y,flip_y),d5
		eori.l	#words_to_long(flip_y,flip_y),d3
		exg	d3,d5

.notflipy
		btst	#$A,d4
		beq.s	.notflipx
		eori.l	#words_to_long(flip_x,flip_x),d5
		eori.l	#words_to_long(flip_x,flip_x),d3
		swap	d5
		swap	d3

.notflipx
		move.l	d5,(a1)+
		move.l	d3,(a0)+
		addq.w	#2,d2
		andi.w	#$E,d2
		bne.s	.skip
		addq.w	#2,d1								; chunk ID to word
		bsr.s	Get_ChunkRow

.skip
		dbf	d6,.getblock
		clr.w	(a0)								; end marker
		rts

; ---------------------------------------------------------------------------
; Get chunk (Row)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_LevelAddrChunkRow:
		movea.l	(Level_layout_addr_ROM).w,a4
		move.w	d0,d3
		asr.w	#5,d3
		and.w	(Layout_row_index_mask).w,d3
		adda.w	(a3,d3.w),a4

Get_ChunkRow:
		moveq	#0,d3
		move.w	(a4,d1.w),d3							; move 128*128 chunk ID to d3
		lsl.w	#7,d3								; multiply by $80
		move.w	d0,d4
		andi.w	#$70,d4
		add.w	d4,d3
		movea.l	(Level_data_addr_RAM.128x128RAM).w,a5
		adda.l	d3,a5
		rts

; ---------------------------------------------------------------------------
; Refresh plane full (horizontal deformation)
; ---------------------------------------------------------------------------
;
; Input:
; d0 = Camera Y pos (or BG) rounded ; align (16 pixels)
; d1 = Camera X pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Refresh_PlaneFullHScroll:
		moveq	#bytesToXcnt(gameplay_plane_height,block_height),d2

		; redraws the entire plane in one go during 68k execution

.refresh
		movem.l	d0-d2/a0,-(sp)							; save the registers to the stack
		moveq	#gameplay_plane_width/block_width,d6
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/a0							; return saved registers from the stack
		addi.w	#block_height,d0
		dbf	d2,.refresh
		rts

; ---------------------------------------------------------------------------
; Refresh plane full (vertical deformation)
; ---------------------------------------------------------------------------
;
; Input:
; d0 = Camera X pos (or BG) rounded ; align (16 pixels)
; d1 = Camera Y pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Refresh_PlaneFullVScroll:
		moveq	#bytesToXcnt(gameplay_plane_width,block_width),d2

		; redraws the entire plane in one go during 68k execution

.refresh
		movem.l	d0-d2/a0,-(sp)							; save the registers to the stack
		moveq	#gameplay_plane_height/block_height,d6
		bsr.w	Setup_TileColumnDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/a0							; return saved registers from the stack
		addi.w	#block_width,d0
		dbf	d2,.refresh
		rts

; ---------------------------------------------------------------------------
; Refresh plane tile deform (horizontal deformation)
; ---------------------------------------------------------------------------
;
; Input:
; a4 = draw array
; a5 = horizontal scroll table
; d0 = Camera X pos (or BG) rounded ; align (16 pixels)

; =============== S U B R O U T I N E =======================================

Refresh_PlaneTileDeformHScroll:
		move.w	(a4)+,d2
		moveq	#bytesToXcnt(gameplay_plane_height,block_height),d3

		; redraws the entire plane in one go during 68k execution

.find
		cmp.w	d2,d0
		bmi.s	.refresh
		add.w	(a4)+,d2
		addq.w	#4,a5								; next
		bra.s	.find
; ---------------------------------------------------------------------------

.refresh
		move.w	(a5),d1
		moveq	#gameplay_plane_width/block_width,d6
		movem.l	d0/d2-d3/a0/a4-a5,-(sp)						; save the registers to the stack
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0/d2-d3/a0/a4-a5						; return saved registers from the stack
		addi.w	#block_height,d0
		dbf	d3,.find
		rts

; ---------------------------------------------------------------------------
; Refresh plane tile deform (vertical deformation)
; ---------------------------------------------------------------------------
;
; Input:
; a4 = draw array
; a5 = horizontal scroll table
; d0 = Camera Y pos (or BG) rounded ; align (16 pixels)

; =============== S U B R O U T I N E =======================================

Refresh_PlaneTileDeformVScroll:
		move.w	(a4)+,d2
		moveq	#bytesToXcnt(gameplay_plane_width,block_width),d3

		; redraws the entire plane in one go during 68k execution

.find
		cmp.w	d2,d0
		bmi.s	.refresh
		add.w	(a4)+,d2
		addq.w	#4,a5								; next
		bra.s	.find
; ---------------------------------------------------------------------------

.refresh
		move.w	(a5),d1
		moveq	#gameplay_plane_height/block_height,d6
		movem.l	d0/d2-d3/a0/a4-a5,-(sp)						; save the registers to the stack
		bsr.w	Setup_TileColumnDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0/d2-d3/a0/a4-a5						; return saved registers from the stack
		addi.w	#block_width,d0
		dbf	d3,.find
		rts

; ---------------------------------------------------------------------------
; Refresh background plane (horizontal deformation)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Refresh_BGPlaneFullDirectHScroll:
		moveq	#gameplay_plane_width/block_width,d6
		bra.s	Refresh_BGPlaneDirectHScroll2
; ---------------------------------------------------------------------------

Refresh_BGPlaneScreenDirectHScroll:
		moveq	#(screen_width+block_width)/block_width,d6

Refresh_BGPlaneDirectHScroll2:
		move.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	(Camera_X_pos_BG_copy).w,d1

Refresh_BGPlaneDirectHScroll:
		disableInts
		moveq	#bytesToXcnt(gameplay_plane_height,block_height),d2

		; redraws the entire plane in one go during 68k execution

.refresh
		movem.l	d0-d2/d6/a0,-(sp)						; save the registers to the stack
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/d6/a0						; return saved registers from the stack
		addi.w	#block_height,d0
		dbf	d2,.refresh
		enableInts
		rts

; ---------------------------------------------------------------------------
; Refresh foreground plane (horizontal deformation)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Refresh_FGPlaneFullDirectHScroll:
		moveq	#gameplay_plane_width/block_width,d6
		bra.s	Refresh_FGPlaneDirectHScroll2
; ---------------------------------------------------------------------------

Refresh_FGPlaneScreenDirectHScroll:
		moveq	#(screen_width+block_width)/block_width,d6

Refresh_FGPlaneDirectHScroll2:
		move.w	(Camera_Y_pos_copy).w,d0
		move.w	(Camera_X_pos_copy).w,d1

Refresh_FGPlaneDirectHScroll:
		disableInts
		moveq	#bytesToXcnt((screen_height+block_height),block_height),d2

		; redraws the entire plane in one go during 68k execution

.refresh
		movem.l	d0-d2/d6/a0,-(sp)						; save the registers to the stack
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/d6/a0						; return saved registers from the stack
		addi.w	#block_height,d0
		dbf	d2,.refresh
		enableInts
		rts

; ---------------------------------------------------------------------------
; Refresh background plane (vertical deformation)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Refresh_BGPlaneFullDirectVScroll:
		moveq	#gameplay_plane_height/block_height,d6
		bra.s	Refresh_BGPlaneDirectVScroll2
; ---------------------------------------------------------------------------

Refresh_BGPlaneScreenDirectVScroll:
		moveq	#(screen_height+block_height)/block_height,d6

Refresh_BGPlaneDirectVScroll2:
		move.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	(Camera_X_pos_BG_copy).w,d1

Refresh_BGPlaneDirectVScroll:
		disableInts
		moveq	#bytesToXcnt(gameplay_plane_width,block_width),d2

		; redraws the entire plane in one go during 68k execution

.refresh
		movem.l	d0-d2/d6/a0,-(sp)						; save the registers to the stack
		bsr.w	Setup_TileColumnDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/d6/a0						; return saved registers from the stack
		addi.w	#block_width,d0
		dbf	d2,.refresh
		enableInts
		rts

; ---------------------------------------------------------------------------
; Refresh foreground plane (vertical deformation)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Refresh_FGPlaneFullDirectVScroll:
		moveq	#gameplay_plane_height/block_height,d6
		bra.s	Refresh_BGPlaneDirectVScroll2
; ---------------------------------------------------------------------------

Refresh_FGPlaneScreenDirectVScroll:
		moveq	#(screen_height+block_height)/block_height,d6

Refresh_FGPlaneDirectVScroll2:
		move.w	(Camera_Y_pos_copy).w,d0
		move.w	(Camera_X_pos_copy).w,d1

Refresh_FGPlaneDirectVScroll:
		disableInts
		moveq	#bytesToXcnt(gameplay_plane_width,block_width),d2

		; redraws the entire plane in one go during 68k execution

.refresh
		movem.l	d0-d2/d6/a0,-(sp)						; save the registers to the stack
		bsr.w	Setup_TileColumnDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/d6/a0						; return saved registers from the stack
		addi.w	#block_width,d0
		dbf	d2,.refresh
		enableInts
		rts

; ---------------------------------------------------------------------------
; Update foreground tiles
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_FGAsYouMove:

		; update camera x scroll
		lea	(Camera_X_pos_copy).w,a6
		lea	(Camera_X_pos_rounded).w,a5
		move.w	(Camera_Y_pos_copy).w,d1
		moveq	#(screen_height+block_height)/block_height,d6
		bsr.w	Draw_TileColumn

		; update camera y scroll
		lea	(Camera_Y_pos_copy).w,a6
		lea	(Camera_Y_pos_rounded).w,a5
		move.w	(Camera_X_pos_copy).w,d1
		moveq	#(screen_width+block_width)/block_width,d6
		bra.w	Draw_TileRow

; ---------------------------------------------------------------------------
; Update background tiles
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_BGAsYouMove:

		; update camera x scroll
		lea	(Camera_X_pos_BG_copy).w,a6
		lea	(Camera_X_pos_BG_rounded).w,a5
		move.w	(Camera_Y_pos_BG_copy).w,d1
		moveq	#(screen_height+block_height)/block_height,d6
		bsr.w	Draw_TileColumn

		; update camera y scroll
		lea	(Camera_Y_pos_BG_copy).w,a6
		lea	(Camera_Y_pos_BG_rounded).w,a5
		move.w	(Camera_X_pos_BG_copy).w,d1
		moveq	#(screen_width+block_width)/block_width,d6
		bra.w	Draw_TileRow

; ---------------------------------------------------------------------------
; Draw HScroll foreground
; ---------------------------------------------------------------------------
;
; Input:
; a4 = draw array
; a5 = horizontal scroll table
; d5 = draw array size
; d6 = width size

; =============== S U B R O U T I N E =======================================

Draw_FGHDeform:

		; update camera y scroll
		movem.l	d5/a4-a5,-(sp)							; save the registers to the stack
		lea	(Camera_Y_pos_copy).w,a6
		bsr.s	Get_DeformDrawPosVert
		lea	(Camera_Y_pos_rounded).w,a5
		bsr.w	Draw_TileRow2
		movem.l	(sp)+,d5/a4/a6							; return saved registers from the stack

		; update camera x scroll
		move.w	(Camera_Y_pos_rounded).w,d6
		bra.s	Draw_BGHDeformNoVert

; ---------------------------------------------------------------------------
; Get HScroll deform position
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_DeformDrawPosVert:
		move.w	(a4)+,d2
		move.w	(a6),d0
		bsr.s	.find
		addi.w	#screen_height,d0

.find
		cmp.w	d2,d0
		bmi.s	.set
		add.w	(a4)+,d2
		addq.w	#4,a5								; next
		bra.s	.find
; ---------------------------------------------------------------------------

.set
		move.w	(a5),d1
		swap	d1

.return
		rts

; ---------------------------------------------------------------------------
; Draw HScroll background
; ---------------------------------------------------------------------------
;
; Input:
; a4 = draw array
; a5 = horizontal scroll table
; d5 = draw array size
; d6 = width size

; =============== S U B R O U T I N E =======================================

Draw_BGHDeform:

		; update camera y scroll
		movem.l	d5/a4-a5,-(sp)							; save the registers to the stack
		lea	(Camera_Y_pos_BG_copy).w,a6
		bsr.s	Get_DeformDrawPosVert
		lea	(Camera_Y_pos_BG_rounded).w,a5
		bsr.w	Draw_TileRow2
		movem.l	(sp)+,d5/a4/a6							; return saved registers from the stack

		; update camera x scroll
		move.w	(Camera_Y_pos_BG_rounded).w,d6
		tst.w	(Camera_Y_pos_BG_copy).w
		bpl.s	Draw_BGHDeformNoVert
		moveq	#-block_height,d6						; set align (16 pixels)
		and.w	(Camera_Y_pos_BG_copy).w,d6

Draw_BGHDeformNoVert:
		move.w	d6,d1

.find
		sub.w	(a4)+,d6
		bmi.s	.found
		moveq	#-block_width,d0						; set align (16 pixels)
		and.w	(a6)+,d0
		move.w	d0,(a6)+
		subq.w	#1,d5								; next
		bra.s	.find
; ---------------------------------------------------------------------------

.found
		neg.w	d6
		lsr.w	#4,d6								; divide by $10
		moveq	#(screen_height+block_height)/block_height,d4
		sub.w	d6,d4
		bhs.s	.loop
		moveq	#0,d4
		moveq	#(screen_height+block_height)/block_height,d6

.loop
		movem.w	d1/d4-d6,-(sp)							; save the registers to the stack
		movem.l	a4/a6,-(sp)							; "
		lea	2(a6),a5
		bsr.w	Draw_TileColumn
		movem.l	(sp)+,a4/a6							; "
		movem.w	(sp)+,d1/d4-d6							; return saved registers from the stack
		addq.w	#4,a6
		tst.w	d4
		beq.s	.loop2
		lsl.w	#4,d6								; multiply by $10
		add.w	d6,d1
		subq.w	#1,d5								; next
		move.w	(a4)+,d6
		lsr.w	#4,d6								; divide by $10
		move.w	d4,d0
		sub.w	d6,d4
		bpl.s	.loop
		move.w	d0,d6
		moveq	#0,d4
		bra.s	.loop
; ---------------------------------------------------------------------------

.loop2
		subq.w	#1,d5								; next
		beq.s	Get_DeformDrawPosHorz.return
		moveq	#-block_width,d0						; set align (16 pixels)
		and.w	(a6)+,d0
		move.w	d0,(a6)+
		bra.s	.loop2

; ---------------------------------------------------------------------------
; Draw VScroll foreground
; ---------------------------------------------------------------------------
;
; Input:
; a4 = draw array
; a5 = vertical scroll table
; d5 = draw array size
; d6 = height size

; =============== S U B R O U T I N E =======================================

Draw_FGVDeform:

		; update camera x scroll
		movem.l	d5/a4-a5,-(sp)							; save the registers to the stack
		lea	(Camera_X_pos_copy).w,a6
		bsr.s	Get_DeformDrawPosHorz
		lea	(Camera_X_pos_rounded).w,a5
		bsr.w	Draw_TileColumn2
		movem.l	(sp)+,d5/a4/a6							; return saved registers from the stack

		; update camera y scroll
		move.w	(Camera_X_pos_rounded).w,d6
		bra.s	Draw_BGVDeformNoHorz

; ---------------------------------------------------------------------------
; Get VScroll deform position
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_DeformDrawPosHorz:
		move.w	(a4)+,d2
		move.w	(a6),d0
		bsr.s	.find
		addi.w	#screen_width,d0

.find
		cmp.w	d2,d0
		blo.s	.set
		add.w	(a4)+,d2
		addq.w	#4,a5								; next
		bra.s	.find
; ---------------------------------------------------------------------------

.set
		move.w	(a5),d1
		swap	d1

.return
		rts

; ---------------------------------------------------------------------------
; Draw VScroll background
; ---------------------------------------------------------------------------
;
; Input:
; a4 = draw array
; a5 = vertical scroll table
; d5 = draw array size
; d6 = height size

; =============== S U B R O U T I N E =======================================

Draw_BGVDeform:

		; update camera x scroll
		movem.l	d5/a4-a5,-(sp)							; save the registers to the stack
		lea	(Camera_X_pos_BG_copy).w,a6
		bsr.s	Get_DeformDrawPosHorz
		lea	(Camera_X_pos_BG_rounded).w,a5
		bsr.w	Draw_TileColumn2
		movem.l	(sp)+,d5/a4/a6							; return saved registers from the stack

		; update camera y scroll
		move.w	(Camera_X_pos_BG_rounded).w,d6

Draw_BGVDeformNoHorz:
		move.w	d6,d1

.find
		sub.w	(a4)+,d6
		blo.s	.found
		move.w	(a6)+,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(a6)+
		subq.w	#1,d5								; next
		bra.s	.find
; ---------------------------------------------------------------------------

.found
		neg.w	d6
		lsr.w	#4,d6								; divide by $10
		moveq	#(screen_width+block_width)/block_width,d4
		sub.w	d6,d4
		bhs.s	.loop
		moveq	#0,d4
		moveq	#(screen_width+block_width)/block_width,d6

.loop
		movem.w	d1/d4-d6,-(sp)							; save the registers to the stack
		movem.l	a4/a6,-(sp)							; "
		lea	2(a6),a5
		bsr.w	Draw_TileRow
		movem.l	(sp)+,a4/a6							; "
		movem.w	(sp)+,d1/d4-d6							; return saved registers from the stack
		addq.w	#4,a6
		tst.w	d4
		beq.s	.loop2
		lsl.w	#4,d6								; multiply by $10
		add.w	d6,d1
		subq.w	#1,d5								; next
		move.w	(a4)+,d6
		lsr.w	#4,d6								; divide by $10
		move.w	d4,d0
		sub.w	d6,d4
		bhs.s	.loop
		move.w	d0,d6
		moveq	#0,d4
		bra.s	.loop
; ---------------------------------------------------------------------------

.loop2
		subq.w	#1,d5								; next
		beq.s	Draw_PlaneVertBottomUp.return
		move.w	(a6)+,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(a6)+
		bra.s	.loop2

; ---------------------------------------------------------------------------
; Draw plane vertical bottom to up (double update)
; ---------------------------------------------------------------------------
;
; Input:
; d1 = Camera X pos (or BG) copy
; d2 = Camera Y pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertBottomUp:

		; update 1
		movem.w	d1-d2,-(sp)							; save the registers to the stack
		bsr.s	Draw_PlaneVertSingleBottomUp
		movem.w	(sp)+,d1-d2							; return saved registers from the stack

		; check draw delayed rowcount
		bpl.s	Draw_PlaneVertSingleBottomUp					; if draw delayed rowcount remains, update again

.return
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical bottom to up
; ---------------------------------------------------------------------------
;
; Input:
; d1 = Camera X pos (or BG) copy
; d2 = Camera Y pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertSingleBottomUp:
		and.w	(Camera_Y_pos_mask).w,d2
		move.w	d2,d3
		addi.w	#screen_height+block_height,d3
		and.w	(Camera_Y_pos_mask).w,d3
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s	.next
		cmp.w	d3,d0
		bhi.s	.next
		moveq	#gameplay_plane_width/block_width,d6
		bsr.w	Setup_TileRowDraw

.next
		subi.w	#block_height,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w					; decrement draw delayed rowcount
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical top to down (double update)
; ---------------------------------------------------------------------------
;
; Input:
; d1 = Camera X pos (or BG) copy
; d2 = Camera Y pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertTopDown:

		; update 1
		movem.w	d1-d2,-(sp)							; save the registers to the stack
		bsr.s	Draw_PlaneVertSingleTopDown
		movem.w	(sp)+,d1-d2							; return saved registers from the stack

		; check draw delayed rowcount
		bpl.s	Draw_PlaneVertSingleTopDown					; if draw delayed rowcount remains, update again
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical top to down
; ---------------------------------------------------------------------------
;
; Input:
; d1 = Camera X pos (or BG) copy
; d2 = Camera Y pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertSingleTopDown:
		and.w	(Camera_Y_pos_mask).w,d2
		move.w	d2,d3
		addi.w	#screen_height+block_height,d3
		and.w	(Camera_Y_pos_mask).w,d3
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s	.next
		cmp.w	d3,d0
		bhi.s	.next
		moveq	#gameplay_plane_width/block_width,d6
		bsr.w	Setup_TileRowDraw

.next
		addi.w	#block_height,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w					; decrement draw delayed rowcount
		rts

; ---------------------------------------------------------------------------
; Draw plane horizontal right to left (double update)
; ---------------------------------------------------------------------------
;
; Input:
; d1 = Camera Y pos (or BG) copy
; d2 = Camera X pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzRightToLeft:

		; update 1
		movem.w	d1-d2,-(sp)							; save the registers to the stack
		bsr.s	Draw_PlaneHorzSingleRightToLeft
		movem.w	(sp)+,d1-d2							; return saved registers from the stack

		; check draw delayed rowcount
		bpl.s	Draw_PlaneHorzSingleRightToLeft					; if draw delayed rowcount remains, update again
		rts

; ---------------------------------------------------------------------------
; Draw plane horizontal right to left
; ---------------------------------------------------------------------------
;
; Input:
; d1 = Camera Y pos (or BG) copy
; d2 = Camera X pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzSingleRightToLeft:
		andi.w	#-16,d2								; align (16 pixels)
		move.w	d2,d3
		addi.w	#gameplay_plane_width-block_width,d3
		andi.w	#-16,d3								; align (16 pixels)
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s	.next
		cmp.w	d3,d0
		bhi.s	.next
		moveq	#gameplay_plane_height/block_height,d6
		bsr.w	Setup_TileColumnDraw

.next
		subi.w	#block_width,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w					; decrement draw delayed rowcount
		rts

; ---------------------------------------------------------------------------
; Draw plane horizontal left to right (double update)
; ---------------------------------------------------------------------------
;
; Input:
; d1 = Camera Y pos (or BG) copy
; d2 = Camera X pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzLeftToRight:

		; update 1
		movem.w	d1-d2,-(sp)							; save the registers to the stack
		bsr.s	Draw_PlaneHorzSingleLeftToRight
		movem.w	(sp)+,d1-d2							; return saved registers from the stack

		; check draw delayed rowcount
		bpl.s	Draw_PlaneHorzSingleLeftToRight					; if draw delayed rowcount remains, update again
		rts

; ---------------------------------------------------------------------------
; Draw plane horizontal left to right
; ---------------------------------------------------------------------------
;
; Input:
; d1 = Camera Y pos (or BG) copy
; d2 = Camera X pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzSingleLeftToRight:
		andi.w	#-16,d2								; align (16 pixels)
		move.w	d2,d3
		addi.w	#gameplay_plane_width-block_width,d3
		andi.w	#-16,d3								; align (16 pixels)
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s	.next
		cmp.w	d3,d0
		bhi.s	.next
		moveq	#gameplay_plane_height/block_height,d6
		bsr.w	Setup_TileColumnDraw

.next
		addi.w	#block_width,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w					; decrement draw delayed rowcount
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical bottom to up complex (double update)
; ---------------------------------------------------------------------------
;
; Input:
; a4 = draw array
; a5 = horizontal scroll table
; d1 = Camera Y pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertBottomUpComplex:

		; update 1
		movem.l	d1/a4-a5,-(sp)							; save the registers to the stack
		bsr.s	Draw_PlaneVertSingleBottomUpComplex
		movem.l	(sp)+,d1/a4-a5							; return saved registers from the stack

		; check draw delayed rowcount
		bpl.s	Draw_PlaneVertSingleBottomUpComplex				; if draw delayed rowcount remains, update again
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical bottom to up complex
; ---------------------------------------------------------------------------
;
; Input:
; a4 = draw array
; a5 = horizontal scroll table
; d1 = Camera Y pos (or BG) copy

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertSingleBottomUpComplex:
		and.w	(Camera_Y_pos_mask).w,d1
		move.w	d1,d2
		addi.w	#screen_height+block_height,d2
		and.w	(Camera_Y_pos_mask).w,d2
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d1,d0
		blo.s	.next
		cmp.w	d2,d0
		bhi.s	.next

.find
		addq.w	#4,a5								; next
		cmp.w	(a4)+,d0
		bpl.s	.find

		; refresh
		move.w	(a5),d1
		moveq	#gameplay_plane_width/block_width,d6
		bsr.w	Setup_TileRowDraw

.next
		subi.w	#block_height,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w					; decrement draw delayed rowcount
		rts

; ---------------------------------------------------------------------------
; Reset foreground tile offset position (horizontal deformation)
; ---------------------------------------------------------------------------
;
; Input:
; none
;
; Outputs:
; d0 = Camera Y pos rounded ; align (16 pixels)
; d1 = Camera X pos copy

; =============== S U B R O U T I N E =======================================

Reset_FGTileOffsetPositionHScroll:
		move.w	(Camera_X_pos_copy).w,d0
		move.w	d0,d1								; copy camera x pos to d1
		andi.w	#-16,d0								; align (16 pixels)
		move.w	d0,(Camera_X_pos_rounded).w
		move.w	(Camera_Y_pos_copy).w,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(Camera_Y_pos_rounded).w
		rts

; ---------------------------------------------------------------------------
; Reset background tile offset position (horizontal deformation)
; ---------------------------------------------------------------------------
;
; Input:
; none
;
; Outputs:
; d0 = Camera Y pos BG rounded ; align (16 pixels)
; d1 = Camera X pos BG copy
; d2 = Camera X pos BG rounded ; align (16 pixels)

; =============== S U B R O U T I N E =======================================

Reset_BGTileOffsetPositionHScroll:
		move.w	(Camera_X_pos_BG_copy).w,d0
		move.w	d0,d1								; copy camera x pos bg to d1
		andi.w	#-16,d0								; align (16 pixels)
		move.w	d0,d2								; copy camera x pos bg rounded to d2
		move.w	d0,(Camera_X_pos_BG_rounded).w
		move.w	(Camera_Y_pos_BG_copy).w,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(Camera_Y_pos_BG_rounded).w
		rts

; ---------------------------------------------------------------------------
; Reset foreground tile offset position (vertical deformation)
; ---------------------------------------------------------------------------
;
; Input:
; none
;
; Outputs:
; d0 = Camera X pos rounded ; align (16 pixels)
; d1 = Camera Y pos copy

; =============== S U B R O U T I N E =======================================

Reset_FGTileOffsetPositionVScroll:
		move.w	(Camera_Y_pos_copy).w,d0
		move.w	d0,d1								; copy camera y pos to d1
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(Camera_Y_pos_rounded).w
		move.w	(Camera_X_pos_copy).w,d0
		andi.w	#-16,d0								; align (16 pixels)
		move.w	d0,(Camera_X_pos_rounded).w
		rts

; ---------------------------------------------------------------------------
; Reset background tile offset position (vertical deformation)
; ---------------------------------------------------------------------------
;
; Input:
; none
;
; Outputs:
; d0 = Camera X pos BG rounded ; align (16 pixels)
; d1 = Camera Y pos BG copy
; d2 = Camera Y pos BG rounded ; align (16 pixels)

; =============== S U B R O U T I N E =======================================

Reset_BGTileOffsetPositionVScroll:
		move.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	d0,d1								; copy camera y pos bg to d1
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,d2								; copy camera y pos bg rounded to d2
		move.w	d0,(Camera_Y_pos_BG_rounded).w
		move.w	(Camera_X_pos_BG_copy).w,d0
		andi.w	#-16,d0								; align (16 pixels)
		move.w	d0,(Camera_X_pos_BG_rounded).w
		rts

; ---------------------------------------------------------------------------
; Get background tile collision offset position
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_BGActualEffectiveDiff:
		move.w	(Camera_X_pos_copy).w,d0
		sub.w	(Camera_X_pos_BG_copy).w,d0
		move.w	d0,(Camera_X_diff).w
		move.w	(Camera_Y_pos_copy).w,d0
		sub.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	d0,(Camera_Y_diff).w
		rts
