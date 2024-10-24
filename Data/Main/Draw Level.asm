; ---------------------------------------------------------------------------
; Drawing level tiles
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_DrawLevel:
		lea	(VDP_data_port).l,a6

.main
		lea	(Plane_buffer).w,a0
		bsr.s	VInt_DrawLevel_2
		move.l	(Plane_buffer_2_addr).w,d0
		beq.s	VInt_DrawLevel_Return
		movea.l	d0,a0

VInt_DrawLevel_2:
		move.w	(a0),d0
		beq.s	VInt_DrawLevel_Done
		clr.w	(a0)+
		move.w	(a0)+,d1
		bmi.s	VInt_DrawLevel_Col
		move.w	#$8F02,d2										; VRAM increment at 2 bytes (horizontal level write)
		move.w	#$80,d3
		bra.s	VInt_DrawLevel_Draw
; ---------------------------------------------------------------------------

VInt_DrawLevel_Col:
		move.w	#$8F80,d2										; VRAM increment at $80 bytes (vertical level write)
		moveq	#2,d3
		andi.w	#$7FFF,d1

VInt_DrawLevel_Draw:
		move.w	d2,VDP_control_port-VDP_data_port(a6)
		move.w	d0,d2
		move.w	d1,d4
		bsr.s	VInt_VRAMWrite
		move.w	d2,d0
		add.w	d3,d0
		move.w	d4,d1
		bsr.s	VInt_VRAMWrite
		bra.s	VInt_DrawLevel_2
; ---------------------------------------------------------------------------

VInt_DrawLevel_Done:
		move.w	#$8F02,VDP_control_port-VDP_data_port(a6)		; VRAM increment at 2 bytes

VInt_DrawLevel_Return:
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
		swap	d0
		move.l	d0,VDP_control_port-VDP_data_port(a6)

.copy
		move.l	(a0)+,VDP_data_port-VDP_data_port(a6)
		dbf	d1,.copy

VInt_VRAMWrite_Return:
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
		beq.s	VInt_VRAMWrite_Return
		tst.b	d2
		bpl.s	.check
		neg.w	d2
		move.w	d3,d0
		addi.w	#320+16,d0

.check
		andi.w	#$30,d2
		cmpi.w	#16,d2							; the camera scrolls more than 16 pixels?
		sne	(Plane_double_update_flag).w			; if so, set flag

		; update 1
		movem.w	d1/d6,-(sp)
		bsr.s	Setup_TileColumnDraw
		movem.w	(sp)+,d1/d6

		; check flag
		tst.b	(Plane_double_update_flag).w			; is update flag was set?
		beq.s	VInt_VRAMWrite_Return			; if not, branch

		; update 2
		addi.w	#16,d0
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
		beq.s	VInt_VRAMWrite_Return
		tst.b	d2
		bpl.s	.check
		neg.w	d2
		move.w	d3,d0
		addi.w	#320+16,d0
		swap	d1

.check
		andi.w	#$30,d2
		cmpi.w	#16,d2							; the camera scrolls more than 16 pixels?
		sne	(Plane_double_update_flag).w			; if so, set flag

		; update 1
		movem.w	d1/d6,-(sp)
		bsr.s	Setup_TileColumnDraw
		movem.w	(sp)+,d1/d6

		; check flag
		tst.b	(Plane_double_update_flag).w			; is update flag was set?
		beq.s	VInt_VRAMWrite_Return			; if not, branch

		; update 2
		addi.w	#16,d0

Setup_TileColumnDraw:
		move.w	d1,d2
		andi.w	#$70,d2
		move.w	d1,d3
		lsl.w	#4,d3
		andi.w	#$F00,d3
		asr.w	#4,d1
		move.w	d1,d4
		asr.w	d1
		and.w	(Layout_row_index_mask).w,d1
		andi.w	#$F,d4
		moveq	#$10,d5
		sub.w	d4,d5
		move.w	d5,d4
		sub.w	d6,d5
		bmi.s	+
		move.w	d0,d5
		asr.w	#2,d5
		andi.w	#$7C,d5
		add.w	d7,d5
		add.w	d3,d5
		move.w	d5,(a0)+
		move.w	d6,d5
		subq.w	#1,d6
		move.w	d6,(a0)+
		bset	#7,-2(a0)
		lea	(a0),a1
		add.w	d5,d5
		add.w	d5,d5
		adda.w	d5,a0
		bsr.w	Get_LevelChunkColumn
		bra.s	++
+		neg.w	d5
		move.w	d5,-(sp)
		move.w	d0,d5
		asr.w	#2,d5
		andi.w	#$7C,d5
		add.w	d7,d5
		add.w	d3,d5
		move.w	d5,(a0)+
		move.w	d4,d6
		subq.w	#1,d6
		move.w	d6,(a0)+
		bset	#7,-2(a0)
		lea	(a0),a1
		add.w	d4,d4
		add.w	d4,d4
		adda.w	d4,a0
		bsr.w	Get_LevelChunkColumn
		bsr.s	+
		move.w	(sp)+,d6
		move.w	d0,d5
		asr.w	#2,d5
		andi.w	#$7C,d5
		add.w	d7,d5
		move.w	d5,(a0)+
		move.w	d6,d5
		subq.w	#1,d6
		move.w	d6,(a0)+
		bset	#7,-2(a0)
		lea	(a0),a1
		add.w	d5,d5
		add.w	d5,d5
		adda.w	d5,a0
+		swap	d7

-		move.w	(a5,d2.w),d3
		move.w	d3,d4
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		move.w	(a2,d3.w),d5
		swap	d5
		move.w	4(a2,d3.w),d5
		move.w	6(a2,d3.w),d7
		move.w	2(a2,d3.w),d3
		swap	d3
		move.w	d7,d3
		btst	#$B,d4
		beq.s	+
		eori.l	#words_to_long(flip_y,flip_y),d5
		eori.l	#words_to_long(flip_y,flip_y),d3
		swap	d5
		swap	d3
+		btst	#$A,d4
		beq.s	+
		eori.l	#words_to_long(flip_x,flip_x),d5
		eori.l	#words_to_long(flip_x,flip_x),d3
		exg	d3,d5
+		move.l	d5,(a1)+
		move.l	d3,(a0)+
		addi.w	#$10,d2
		andi.w	#$70,d2
		bne.s	+
		addq.w	#4,d1
		and.w	(Layout_row_index_mask).w,d1
		bsr.s	Get_LevelChunkColumn
+		dbf	d6,-
		swap	d7
		clr.w	(a0)
		rts

; ---------------------------------------------------------------------------
; Get chunk (Column)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_LevelChunkColumn:
		movea.l	(Level_layout_addr_ROM).w,a4
		move.w	d0,d3
		asr.w	#7,d3
		add.w	d3,d3							; chunk ID to word
		add.w	(a3,d1.w),d3
		adda.w	d3,a4
		moveq	#0,d3
		move.w	(a4),d3							; move 128*128 chunk ID to d3
		lsl.w	#7,d3								; multiply by $80
		move.w	d0,d4
		asr.w	#3,d4
		andi.w	#$E,d4
		add.w	d4,d3
		movea.l	(Level_chunk_addr_ROM).w,a5
		adda.l	d3,a5

.return
		rts

; ---------------------------------------------------------------------------
; Draw BG 2
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_BG2:
		lea	(Camera_Y_pos_BG_copy).w,a6
		lea	(Camera_Y_pos_BG_rounded).w,a5
		moveq	#0,d1		; Camera_X_pos_BG_copy
		moveq	#$20,d6

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
		addi.w	#224+16,d0
		and.w	(Camera_Y_pos_mask).w,d0

.check
		andi.w	#$30,d2
		cmpi.w	#16,d2							; the camera scrolls more than 16 pixels?
		sne	(Plane_double_update_flag).w			; if so, set flag

		; update 1
		movem.w	d1/d6,-(sp)
		bsr.s	Setup_TileRowDraw
		movem.w	(sp)+,d1/d6

		; check flag
		tst.b	(Plane_double_update_flag).w			; is update flag was set?
		beq.s	Get_LevelChunkColumn.return		; if not, branch

		; update 2
		addi.w	#16,d0
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
		addi.w	#224+16,d0
		and.w	(Camera_Y_pos_mask).w,d0
		swap	d1

.check
		andi.w	#$30,d2
		cmpi.w	#16,d2							; the camera scrolls more than 16 pixels?
		sne	(Plane_double_update_flag).w			; if so, set flag

		; update 1
		movem.w	d1/d6,-(sp)
		bsr.s	Setup_TileRowDraw
		movem.w	(sp)+,d1/d6

		; check flag
		tst.b	(Plane_double_update_flag).w			; is update flag was set?
		beq.w	Get_LevelChunkColumn.return		; if not, branch

		; update 2
		addi.w	#16,d0
		and.w	(Camera_Y_pos_mask).w,d0

Setup_TileRowDraw:
		asr.w	#4,d1
		move.w	d1,d2
		move.w	d1,d4
		asr.w	#3,d1
		add.w	d1,d1							; chunk ID to word
		add.w	d2,d2
		move.w	d2,d3
		andi.w	#$E,d2
		add.w	d3,d3
		andi.w	#$7C,d3
		andi.w	#$1F,d4
		moveq	#$20,d5
		sub.w	d4,d5
		move.w	d5,d4
		sub.w	d6,d5
		bmi.s	+
		move.w	d0,d5
		andi.w	#$F0,d5							; if the length of the write can fit without wrapping the nametable
		lsl.w	#4,d5
		add.w	d7,d5
		add.w	d3,d5
		move.w	d5,(a0)+
		move.w	d6,d5
		subq.w	#1,d6
		move.w	d6,(a0)+
		lea	(a0),a1
		add.w	d5,d5
		add.w	d5,d5
		adda.w	d5,a0
		bsr.w	Get_LevelAddrChunkRow
		bra.s	++
+		neg.w	d5								; if the length of the write wraps over the length of the nametable
		move.w	d5,-(sp)
		move.w	d0,d5
		andi.w	#$F0,d5
		lsl.w	#4,d5
		add.w	d7,d5
		add.w	d3,d5
		move.w	d5,(a0)+
		move.w	d4,d6
		subq.w	#1,d6
		move.w	d6,(a0)+
		lea	(a0),a1
		add.w	d4,d4
		add.w	d4,d4
		adda.w	d4,a0
		bsr.s	Get_LevelAddrChunkRow
		bsr.s	+
		move.w	(sp)+,d6							; must place one more write command to account for rollover
		move.w	d0,d5
		andi.w	#$F0,d5
		lsl.w	#4,d5
		add.w	d7,d5
		move.w	d5,(a0)+
		move.w	d6,d5
		subq.w	#1,d6
		move.w	d6,(a0)+
		lea	(a0),a1
		add.w	d5,d5
		add.w	d5,d5
		adda.w	d5,a0
+
-		move.w	(a5,d2.w),d3
		move.w	d3,d4
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		move.l	(a2,d3.w),d5
		move.l	4(a2,d3.w),d3
		btst	#$B,d4
		beq.s	+
		eori.l	#words_to_long(flip_y,flip_y),d5
		eori.l	#words_to_long(flip_y,flip_y),d3
		exg	d3,d5
+		btst	#$A,d4
		beq.s	+
		eori.l	#words_to_long(flip_x,flip_x),d5
		eori.l	#words_to_long(flip_x,flip_x),d3
		swap	d5
		swap	d3
+		move.l	d5,(a1)+
		move.l	d3,(a0)+
		addq.w	#2,d2
		andi.w	#$E,d2
		bne.s	+
		addq.w	#2,d1							; chunk ID to word
		bsr.s	Get_ChunkRow
+		dbf	d6,-
		clr.w	(a0)
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
		move.w	(a4,d1.w),d3						; move 128*128 chunk ID to d3
		lsl.w	#7,d3								; multiply by $80
		move.w	d0,d4
		andi.w	#$70,d4
		add.w	d4,d3
		movea.l	(Level_chunk_addr_ROM).w,a5
		adda.l	d3,a5
		rts

; ---------------------------------------------------------------------------
; Refresh plane
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Refresh_PlaneFull:
		moveq	#$10-1,d2

.refresh
		movem.l	d0-d2/a0,-(sp)
		moveq	#$20,d6
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/a0
		addi.w	#16,d0
		dbf	d2,.refresh
		rts

; ---------------------------------------------------------------------------
; Refresh plane deform
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Refresh_PlaneTileDeform:
		move.w	(a4)+,d2
		moveq	#$10-1,d3

.find
		cmp.w	d2,d0
		bmi.s	.refresh
		add.w	(a4)+,d2
		addq.w	#4,a5		; next
		bra.s	.find
; ---------------------------------------------------------------------------

.refresh
		move.w	(a5),d1
		moveq	#$20,d6
		movem.l	d0/d2-d3/a0/a4-a5,-(sp)
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0/d2-d3/a0/a4-a5
		addi.w	#16,d0
		dbf	d3,.find
		rts

; ---------------------------------------------------------------------------
; Refresh plane VScroll
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Refresh_PlaneDirectVScroll:
		move.w	(a4)+,d2
		moveq	#$20-1,d3

.find
		cmp.w	d2,d0
		bmi.s	.refresh
		add.w	(a4)+,d2
		addq.w	#4,a5		; next
		bra.s	.find
; ---------------------------------------------------------------------------

.refresh
		move.w	(a5),d1
		moveq	#$10,d6
		movem.l	d0/d2-d3/a0/a4-a5,-(sp)
		bsr.w	Setup_TileColumnDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0/d2-d3/a0/a4-a5
		addi.w	#16,d0
		dbf	d3,.find
		rts

; ---------------------------------------------------------------------------
; Refresh background
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Refresh_PlaneFullDirect_BG:
		moveq	#$20,d6
		bra.s	Refresh_PlaneDirect2_BG
; ---------------------------------------------------------------------------

Refresh_PlaneScreenDirect_BG:
		moveq	#$15,d6

Refresh_PlaneDirect2_BG:
		move.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	(Camera_X_pos_BG_copy).w,d1

Refresh_PlaneDirect_BG:
		disableInts
		moveq	#$F-1,d2

.refresh
		movem.l	d0-d2/d6/a0,-(sp)			; redraws the entire plane in one go during 68k execution
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/d6/a0
		addi.w	#16,d0
		dbf	d2,.refresh
		enableInts
		rts

; ---------------------------------------------------------------------------
; Refresh foreground
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Refresh_PlaneFullDirect:
		moveq	#$20,d6
		bra.s	Refresh_PlaneDirect2
; ---------------------------------------------------------------------------

Refresh_PlaneScreenDirect:
		moveq	#$15,d6

Refresh_PlaneDirect2:
		move.w	(Camera_Y_pos_copy).w,d0
		move.w	(Camera_X_pos_copy).w,d1

Refresh_PlaneDirect:
		disableInts
		moveq	#$F-1,d2

.refresh
		movem.l	d0-d2/d6/a0,-(sp)			; redraws the entire plane in one go during 68k execution
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/d6/a0
		addi.w	#16,d0
		dbf	d2,.refresh
		enableInts
		rts

; ---------------------------------------------------------------------------
; Update foreground tiles
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DrawTilesAsYouMove:
		lea	(Camera_X_pos_copy).w,a6
		lea	(Camera_X_pos_rounded).w,a5
		move.w	(Camera_Y_pos_copy).w,d1
		moveq	#$F,d6
		bsr.w	Draw_TileColumn
		lea	(Camera_Y_pos_copy).w,a6
		lea	(Camera_Y_pos_rounded).w,a5
		move.w	(Camera_X_pos_copy).w,d1
		moveq	#$15,d6
		bra.w	Draw_TileRow

; ---------------------------------------------------------------------------
; Update background tiles
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DrawBGAsYouMove:
		lea	(Camera_X_pos_BG_copy).w,a6
		lea	(Camera_X_pos_BG_rounded).w,a5
		move.w	(Camera_Y_pos_BG_copy).w,d1
		moveq	#$F,d6
		bsr.w	Draw_TileColumn
		lea	(Camera_Y_pos_BG_copy).w,a6
		lea	(Camera_Y_pos_BG_rounded).w,a5
		move.w	(Camera_X_pos_BG_copy).w,d1
		moveq	#$15,d6
		bra.w	Draw_TileRow

; ---------------------------------------------------------------------------
; Draw foreground
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_FG:
		movem.l	d5/a4-a5,-(sp)
		lea	(Camera_Y_pos_copy).w,a6
		bsr.w	Get_DeformDrawPosVert
		lea	(Camera_Y_pos_rounded).w,a5
		bsr.w	Draw_TileRow2
		movem.l	(sp)+,d5/a4/a6
		move.w	(Camera_Y_pos_rounded).w,d6
		bra.s	Draw_BGNoVert

; ---------------------------------------------------------------------------
; Draw background
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_BG:
		movem.l	d5/a4-a5,-(sp)
		lea	(Camera_Y_pos_BG_copy).w,a6
		bsr.s	Get_DeformDrawPosVert
		lea	(Camera_Y_pos_BG_rounded).w,a5
		bsr.w	Draw_TileRow2
		movem.l	(sp)+,d5/a4/a6
		move.w	(Camera_Y_pos_BG_rounded).w,d6
		tst.w	(Camera_Y_pos_BG_copy).w
		bpl.s	Draw_BGNoVert
		moveq	#-16,d6								; set align (16 pixels)
		and.w	(Camera_Y_pos_BG_copy).w,d6

Draw_BGNoVert:
		move.w	d6,d1

-		sub.w	(a4)+,d6
		bmi.s	+
		moveq	#-16,d0								; set align (16 pixels)
		and.w	(a6)+,d0
		move.w	d0,(a6)+
		subq.w	#1,d5
		bra.s	-
; ---------------------------------------------------------------------------
+		neg.w	d6
		lsr.w	#4,d6
		moveq	#$F,d4
		sub.w	d6,d4
		bhs.s	+
		moveq	#0,d4
		moveq	#$F,d6
+
-		movem.w	d1/d4-d6,-(sp)
		movem.l	a4/a6,-(sp)
		lea	2(a6),a5
		bsr.w	Draw_TileColumn
		movem.l	(sp)+,a4/a6
		movem.w	(sp)+,d1/d4-d6
		addq.w	#4,a6
		tst.w	d4
		beq.s	+
		lsl.w	#4,d6
		add.w	d6,d1
		subq.w	#1,d5
		move.w	(a4)+,d6
		lsr.w	#4,d6
		move.w	d4,d0
		sub.w	d6,d4
		bpl.s	-
		move.w	d0,d6
		moveq	#0,d4
		bra.s	-
; ---------------------------------------------------------------------------
+
-		subq.w	#1,d5
		beq.s	Get_DeformDrawPosVert.return
		moveq	#-16,d0								; set align (16 pixels)
		and.w	(a6)+,d0
		move.w	d0,(a6)+
		bra.s	-

; ---------------------------------------------------------------------------
; Get deform position
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_DeformDrawPosVert:
		move.w	(a4)+,d2
		move.w	(a6),d0
		bsr.s	.find
		addi.w	#224,d0

.find
		cmp.w	d2,d0
		bmi.s	.set
		add.w	(a4)+,d2
		addq.w	#4,a5		; next
		bra.s	.find
; ---------------------------------------------------------------------------

.set
		move.w	(a5),d1
		swap	d1

.return
		rts

; ---------------------------------------------------------------------------
; Draw VScroll foreground
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DrawTilesVDeform:
		movem.l	d5/a4-a5,-(sp)
		lea	(Camera_X_pos_copy).w,a6
		bsr.w	Get_XDeformRange
		lea	(Camera_X_pos_rounded).w,a5
		bsr.w	Draw_TileColumn2
		movem.l	(sp)+,d5/a4/a6
		move.w	(Camera_X_pos_rounded).w,d6
		bra.s	DrawTilesVDeform2.main

; ---------------------------------------------------------------------------
; Draw VScroll background
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DrawTilesVDeform2:
		movem.l	d5/a4-a5,-(sp)
		lea	(Camera_X_pos_BG_copy).w,a6
		bsr.s	Get_XDeformRange
		lea	(Camera_X_pos_BG_rounded).w,a5
		bsr.w	Draw_TileColumn2
		movem.l	(sp)+,d5/a4/a6
		move.w	(Camera_X_pos_BG_rounded).w,d6

.main
		move.w	d6,d1

-		sub.w	(a4)+,d6
		blo.s		+
		move.w	(a6)+,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(a6)+
		subq.w	#1,d5
		bra.s	-
; ---------------------------------------------------------------------------
+		neg.w	d6
		lsr.w	#4,d6
		moveq	#$15,d4
		sub.w	d6,d4
		bhs.s	+
		moveq	#0,d4
		moveq	#$15,d6

+
-		movem.w	d1/d4-d6,-(sp)
		movem.l	a4/a6,-(sp)
		lea	2(a6),a5
		bsr.w	Draw_TileRow
		movem.l	(sp)+,a4/a6
		movem.w	(sp)+,d1/d4-d6
		addq.w	#4,a6
		tst.w	d4
		beq.s	+
		lsl.w	#4,d6
		add.w	d6,d1
		subq.w	#1,d5
		move.w	(a4)+,d6
		lsr.w	#4,d6
		move.w	d4,d0
		sub.w	d6,d4
		bhs.s	-
		move.w	d0,d6
		moveq	#0,d4
		bra.s	-
; ---------------------------------------------------------------------------
+
-		subq.w	#1,d5
		beq.s	Get_XDeformRange.return
		move.w	(a6)+,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(a6)+
		bra.s	-

; ---------------------------------------------------------------------------
; Get VScroll deform position
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_XDeformRange:
		move.w	(a4)+,d2
		move.w	(a6),d0
		bsr.s	.find
		addi.w	#320,d0

.find
		cmp.w	d2,d0
		blo.s		.set
		add.w	(a4)+,d2
		addq.w	#4,a5		; next
		bra.s	.find
; ---------------------------------------------------------------------------

.set
		move.w	(a5),d1
		swap	d1

.return
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical bottom to up (save data)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertBottomUp:
		movem.w	d1-d2,-(sp)
		bsr.s	Draw_PlaneVertSingleBottomUp
		movem.w	(sp)+,d1-d2
		bpl.s	Draw_PlaneVertSingleBottomUp
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical bottom to up
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertSingleBottomUp:
		and.w	(Camera_Y_pos_mask).w,d2
		move.w	d2,d3
		addi.w	#224+16,d3
		and.w	(Camera_Y_pos_mask).w,d3
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s		.next
		cmp.w	d3,d0
		bhi.s	.next
		moveq	#$20,d6
		bsr.w	Setup_TileRowDraw

.next
		subi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical top to down
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertTopDown:
		and.w	(Camera_Y_pos_mask).w,d2
		move.w	d2,d3
		addi.w	#224+16,d3
		and.w	(Camera_Y_pos_mask).w,d3
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s		.next
		cmp.w	d3,d0
		bhi.s	.next
		moveq	#$20,d6
		bsr.w	Setup_TileRowDraw

.next
		addi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; ---------------------------------------------------------------------------
; Draw plane horizontal right to left (save data)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzRightToLeft:
		movem.w	d1-d2,-(sp)
		bsr.s	Draw_PlaneHorzSingleRightToLeft
		movem.w	(sp)+,d1-d2
		bpl.s	Draw_PlaneHorzSingleRightToLeft
		rts

; ---------------------------------------------------------------------------
; Draw plane horizontal right to left
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzSingleRightToLeft:
		andi.w	#-16,d2								; align (16 pixels)
		move.w	d2,d3
		addi.w	#512-16,d3
		andi.w	#-16,d3								; align (16 pixels)
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s		.next
		cmp.w	d3,d0
		bhi.s	.next
		moveq	#$10,d6
		bsr.w	Setup_TileColumnDraw

.next
		subi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; ---------------------------------------------------------------------------
; Draw plane horizontal left to right (save data)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzLeftToRight:
		movem.w	d1-d2,-(sp)
		bsr.s	Draw_PlaneHorzSingleLeftToRight
		movem.w	(sp)+,d1-d2
		bpl.s	Draw_PlaneHorzSingleLeftToRight
		rts

; ---------------------------------------------------------------------------
; Draw plane horizontal left to right
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzSingleLeftToRight:
		andi.w	#-16,d2								; align (16 pixels)
		move.w	d2,d3
		addi.w	#512-16,d3
		andi.w	#-16,d3								; align (16 pixels)
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s		.next
		cmp.w	d3,d0
		bhi.s	.next
		moveq	#$10,d6
		bsr.w	Setup_TileColumnDraw

.next
		addi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical bottom to up complex (save data)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertBottomUpComplex:
		movem.l	d1/a4-a5,-(sp)
		bsr.s	Draw_PlaneVertSingleBottomUpComplex
		movem.l	(sp)+,d1/a4-a5
		bpl.s	Draw_PlaneVertSingleBottomUpComplex
		rts

; ---------------------------------------------------------------------------
; Draw plane vertical bottom to up complex
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertSingleBottomUpComplex:
		and.w	(Camera_Y_pos_mask).w,d1
		move.w	d1,d2
		addi.w	#224+16,d2
		and.w	(Camera_Y_pos_mask).w,d2
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d1,d0
		blo.s		.next
		cmp.w	d2,d0
		bhi.s	.next

.find
		addq.w	#4,a5		; next
		cmp.w	(a4)+,d0
		bpl.s	.find

		; refresh
		move.w	(a5),d1
		moveq	#$20,d6
		bsr.w	Setup_TileRowDraw

.next
		subi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; ---------------------------------------------------------------------------
; Reset tile offset position (Actual)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Reset_TileOffsetPositionActual:
		move.w	(Camera_X_pos_copy).w,d0
		move.w	d0,d1
		andi.w	#-16,d0							; align (16 pixels)
		move.w	d0,(Camera_X_pos_rounded).w
		move.w	(Camera_Y_pos_copy).w,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(Camera_Y_pos_rounded).w
		rts

; ---------------------------------------------------------------------------
; Reset tile offset position (Eff)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Reset_TileOffsetPositionEff:
		move.w	(Camera_X_pos_BG_copy).w,d0
		move.w	d0,d1
		andi.w	#-16,d0							; align (16 pixels)
		move.w	d0,d2
		move.w	d0,(Camera_X_pos_BG_rounded).w
		move.w	(Camera_Y_pos_BG_copy).w,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(Camera_Y_pos_BG_rounded).w
		rts

; ---------------------------------------------------------------------------
; Adjust background during loop
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Adjust_BGDuringLoop:
		move.w	(a1),d1
		move.w	d0,(a1)+
		sub.w	d1,d0
		bpl.s	.loc_4F37C
		neg.w	d0
		cmp.w	d2,d0
		blo.s		.loc_4F378
		sub.w	d3,d0

.loc_4F378
		sub.w	d0,(a1)+
		rts
; ---------------------------------------------------------------------------

.loc_4F37C
		cmp.w	d2,d0
		blo.s		.loc_4F382
		sub.w	d3,d0

.loc_4F382
		add.w	d0,(a1)+
		rts

; ---------------------------------------------------------------------------
; Load level data
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadLevelLoadBlock:

		; load primary level art
		movea.l	(Level_data_addr_RAM.8x8data1).w,a1
		move.w	(a1),d4											; save art size
		moveq	#tiles_to_bytes(0),d2								; VRAM
		bsr.w	Queue_KosPlus_Module

		; load secondary level art
		move.l	(Level_data_addr_RAM.8x8data2).w,d0
		beq.s	.waitplc
		movea.l	d0,a1
		move.w	d4,d2											; return art size for the starting position
		bsr.w	Queue_KosPlus_Module

.waitplc
		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Process_KosPlus_Queue
		bsr.w	Wait_VSync
		bsr.w	Process_KosPlus_Module_Queue
		tst.w	(KosPlus_modules_left).w
		bne.s	.waitplc											; wait for KosPlusM queue to clear
		rts

; ---------------------------------------------------------------------------
; Clear switches RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Clear_Switches:
		clearRAM2 Level_trigger_array, Level_trigger_array_end
		rts

; ---------------------------------------------------------------------------
; Reset level data
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Reset_LevelData:
		move.l	#Load_Sprites_Init,(Object_load_addr_RAM).w
		move.l	#Load_Rings_Init,(Rings_manager_addr_RAM).w
		bsr.s	Clear_Switches

		; clear
		move.b	d0,(Screen_event_routine).w
		move.b	d0,(Background_event_routine).w
		move.b	d0,(Boss_flag).w
		move.b	d0,(Respawn_table_keep).w

		; load
		bsr.s	LoadLevelPointer
		bsr.s	Load_Level
		bsr.w	CheckLevelForWater

; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; Uses Sonic & Knuckles format mapping
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Solids:
		movea.l	(Level_data_addr_RAM.Solid).w,a1

Load_Solids2:
		move.l	a1,(Primary_collision_addr).w
		move.l	a1,(Collision_addr).w
		addq.w	#1,a1
		move.l	a1,(Secondary_collision_addr).w
		rts

; ---------------------------------------------------------------------------
; Load level data 2
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadLevelLoadBlock2:
		movea.l	(Level_data_addr_RAM.PLC1).w,a5
		bsr.w	LoadPLC_Raw_KosPlusM

.skipPLC
		lea	(Level_data_addr_RAM.16x16ram).w,a2

		; save blocks address
		move.l	(a2)+,(Block_table_addr_ROM).w

		; load primary level blocks
		move.l	(a2)+,d0
		beq.s	.notbsec
		movea.l	d0,a0
		movea.l	-8(a2),a1											; load blocks address
		bsr.w	KosPlus_Decomp

		; load secondary level blocks
		move.l	(a2),d0
		beq.s	.notbsec
		movea.l	d0,a0
		bsr.w	KosPlus_Decomp

.notbsec
		addq.w	#4,a2											; next

		; save chunks address
		move.l	(a2)+,(Level_chunk_addr_ROM).w

		; load primary level chunks
		move.l	(a2)+,d0
		beq.s	.notcsec
		movea.l	d0,a0
		movea.l	-8(a2),a1											; load chunks address
		bsr.w	KosPlus_Decomp

		; load secondary level chunks
		move.l	(a2),d0
		beq.s	.notcsec
		movea.l	d0,a0
		bsr.w	KosPlus_Decomp

.notcsec

		; load level palette
		lea	(Level_data_addr_RAM.Palette).w,a2					; level palette
		moveq	#0,d0
		move.b	(a2),d0
		bsr.w	LoadPalette										; load palette

; ---------------------------------------------------------------------------
; Load level layout
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Level:
		movea.l	(Level_data_addr_RAM.Layout).w,a1

Load_Level2:
		move.l	a1,(Level_layout_addr_ROM).w						; save to addr
		addq.w	#8,a1											; skip layout header
		move.l	a1,(Level_layout_addr2_ROM).w					; save to addr2
		rts

; ---------------------------------------------------------------------------
; Load level pointer (resize, events, etc...)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadLevelPointer:
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0

.mul		= 0

	if .mul
		lsr.w	#6,d0
		mulu.w	#(Level_data_addr_RAM_end-Level_data_addr_RAM),d0
	else
		move.w	d0,d1											; multiply by $82
		lsr.w	#5,d1
		add.w	d0,d0
		add.w	d1,d0
	endif

.skip
		lea	(LevelLoadPointer).l,a2
		adda.w	d0,a2

.load
		lea	(Level_data_addr_RAM).w,a3

		; if you make a different buffer size, you need to change this code

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)<>$82
		fatal "Warning! The buffer size is different!"
	endif

		set	.a,0

	rept (Level_data_addr_RAM_end-Level_data_addr_RAM)/$20		; copy $82 bytes
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,.a(a3)										; copy $20 bytes
		set	.a,.a + $20
	endr

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&$10
		movem.l	(a2)+,d0-d3
		movem.l	d0-d3,.a(a3)										; copy $10 bytes
		set	.a,.a + $10
	endif

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&8
		movem.l	(a2)+,d0-d1
		movem.l	d0-d1,.a(a3)										; copy 8 bytes
		set	.a,.a + 8
	endif

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&4
		move.l	(a2)+,.a(a3)										; copy 4 bytes
		set	.a,.a + 4
	endif

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&2
		move.w	(a2)+,.a(a3)										; copy 2 bytes
		set	.a,.a + 2
	endif

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&1
		move.b	(a2)+,.a(a3)										; copy 1 byte
		set	.a,.a + 1
	endif

		rts
