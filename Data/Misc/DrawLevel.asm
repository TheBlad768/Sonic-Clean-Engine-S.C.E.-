; ---------------------------------------------------------------------------
; Drawing level tiles
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_DrawLevel:
		lea	(VDP_data_port).l,a6
		lea	(Plane_buffer).w,a0

VInt_DrawLevel_2:
		move.w	(a0),d0
		beq.s	VInt_DrawLevel_Done
		clr.w	(a0)+
		move.w	(a0)+,d1
		bmi.s	VInt_DrawLevel_Col
		move.w	#$8F02,d2		; VRAM increment at 2 bytes (horizontal level write)
		move.w	#$80,d3
		bra.s	VInt_DrawLevel_Draw
; ---------------------------------------------------------------------------

VInt_DrawLevel_Col:
		move.w	#$8F80,d2		; VRAM increment at $80 bytes (vertical level write)
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
		move.w	#$8F02,VDP_control_port-VDP_data_port(a6)

VInt_DrawLevel_Return:
		rts

; =============== S U B R O U T I N E =======================================

VInt_VRAMWrite:
		swap	d0
		clr.w	d0
		swap	d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,VDP_control_port-VDP_data_port(a6)

-		move.l	(a0)+,VDP_data_port-VDP_data_port(a6)
		dbf	d1,-

VInt_VRAMWrite_Return:
		rts

; =============== S U B R O U T I N E =======================================

Draw_TileColumn:
		move.w	(a6),d0
		andi.w	#$FFF0,d0
		move.w	(a5),d2
		move.w	d0,(a5)
		move.w	d2,d3
		sub.w	d0,d2
		beq.s	VInt_VRAMWrite_Return
		tst.b	d2
		bpl.s	+
		neg.w	d2
		move.w	d3,d0
		addi.w	#$150,d0
+		andi.w	#$30,d2
		cmpi.w	#$10,d2
		sne	(Plane_double_update_flag).w
		movem.w	d1/d6,-(sp)
		bsr.s	Setup_TileColumnDraw
		movem.w	(sp)+,d1/d6
		tst.b	(Plane_double_update_flag).w
		beq.s	VInt_VRAMWrite_Return
		addi.w	#$10,d0
		bra.s	Setup_TileColumnDraw

; =============== S U B R O U T I N E =======================================

Draw_TileColumn2:
		move.w	(a6),d0
		andi.w	#$FFF0,d0
		move.w	(a5),d2
		move.w	d0,(a5)
		move.w	d2,d3
		sub.w	d0,d2
		beq.s	VInt_VRAMWrite_Return
		tst.b	d2
		bpl.s	+
		neg.w	d2
		move.w	d3,d0
		addi.w	#$150,d0
		swap	d1
+		andi.w	#$30,d2
		cmpi.w	#$10,d2
		sne	(Plane_double_update_flag).w
		movem.w	d1/d6,-(sp)
		bsr.s	Setup_TileColumnDraw
		movem.w	(sp)+,d1/d6
		tst.b	(Plane_double_update_flag).w
		beq.s	VInt_VRAMWrite_Return
		addi.w	#$10,d0

Setup_TileColumnDraw:
		move.w	d1,d2
		andi.w	#$70,d2
		move.w	d1,d3
		lsl.w	#4,d3
		andi.w	#$F00,d3
		asr.w	#4,d1
		move.w	d1,d4
		asr.w	#1,d1
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
		eori.l	#$10001000,d5
		eori.l	#$10001000,d3
		swap	d5
		swap	d3
+		btst	#$A,d4
		beq.s	+
		eori.l	#$8000800,d5
		eori.l	#$8000800,d3
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

; =============== S U B R O U T I N E =======================================

Get_LevelChunkColumn:
		movea.l	(Level_layout_addr_ROM).w,a4
		move.w	(a3,d1.w),d3
		andi.w	#$7FFF,d3
		adda.w	d3,a4
		move.w	d0,d3
		asr.w	#7,d3
		adda.w	d3,a4
		moveq	#-1,d3
		clr.w	d3
		move.b	(a4),d3
		lsl.w	#7,d3
		move.w	d0,d4
		asr.w	#3,d4
		andi.w	#$E,d4
		add.w	d4,d3
		movea.l	d3,a5

Get_LevelChunkColumn_Return:
		rts

; =============== S U B R O U T I N E =======================================

Draw_TileRow:
		move.w	(a6),d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	(a5),d2
		move.w	d0,(a5)
		move.w	d2,d3
		sub.w	d0,d2
		beq.s	Get_LevelChunkColumn_Return
		tst.b	d2
		bpl.s	+
		neg.w	d2
		move.w	d3,d0
		addi.w	#$F0,d0
		and.w	(Camera_Y_pos_mask).w,d0
+		andi.w	#$30,d2
		cmpi.w	#$10,d2
		sne	(Plane_double_update_flag).w
		movem.w	d1/d6,-(sp)
		bsr.s	Setup_TileRowDraw
		movem.w	(sp)+,d1/d6
		tst.b	(Plane_double_update_flag).w
		beq.s	Get_LevelChunkColumn_Return
		addi.w	#$10,d0
		and.w	(Camera_Y_pos_mask).w,d0
		bra.s	Setup_TileRowDraw

; =============== S U B R O U T I N E =======================================

Draw_TileRow2:
		move.w	(a6),d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	(a5),d2
		move.w	d0,(a5)
		move.w	d2,d3
		sub.w	d0,d2
		beq.s	Get_LevelChunkColumn_Return
		tst.b	d2
		bpl.s	+
		neg.w	d2
		move.w	d3,d0
		addi.w	#$F0,d0
		and.w	(Camera_Y_pos_mask).w,d0
		swap	d1
+		andi.w	#$30,d2
		cmpi.w	#$10,d2
		sne	(Plane_double_update_flag).w
		movem.w	d1/d6,-(sp)
		bsr.s	Setup_TileRowDraw
		movem.w	(sp)+,d1/d6
		tst.b	(Plane_double_update_flag).w
		beq.w	Get_LevelChunkColumn_Return
		addi.w	#$10,d0
		and.w	(Camera_Y_pos_mask).w,d0

Setup_TileRowDraw:
		asr.w	#4,d1
		move.w	d1,d2
		move.w	d1,d4
		asr.w	#3,d1
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
		andi.w	#$F0,d5		; If the length of the write can fit without wrapping the nametable
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
+		neg.w	d5			; If the length of the write wraps over the length of the nametable
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
		move.w	(sp)+,d6		; Must place one more write command to account for rollover
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
		eori.l	#$10001000,d5
		eori.l	#$10001000,d3
		exg	d3,d5
+		btst	#$A,d4
		beq.s	+
		eori.l	#$8000800,d5
		eori.l	#$8000800,d3
		swap	d5
		swap	d3
+		move.l	d5,(a1)+
		move.l	d3,(a0)+
		addq.w	#2,d2
		andi.w	#$E,d2
		bne.s	+
		addq.w	#1,d1
		bsr.s	Get_ChunkRow
+		dbf	d6,-
		clr.w	(a0)
		rts

; =============== S U B R O U T I N E =======================================

Get_LevelAddrChunkRow:
		movea.l	(Level_layout_addr_ROM).w,a4
		move.w	d0,d3
		asr.w	#5,d3
		and.w	(Layout_row_index_mask).w,d3
		move.w	(a3,d3.w),d3
		andi.w	#$7FFF,d3
		adda.w	d3,a4

Get_ChunkRow:
		moveq	#-1,d3
		clr.w	d3
		move.b	(a4,d1.w),d3
		lsl.w	#7,d3
		move.w	d0,d4
		andi.w	#$70,d4
		add.w	d4,d3
		movea.l	d3,a5
		rts

; =============== S U B R O U T I N E =======================================

Refresh_PlaneFull:
		moveq	#$F,d2

-		movem.l	d0-d2/a0,-(sp)
		moveq	#$20,d6
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/a0
		addi.w	#$10,d0
		dbf	d2,-
		rts

; =============== S U B R O U T I N E =======================================

Refresh_PlaneTileDeform:
		move.w	(a4)+,d2
		moveq	#$F,d3

-		cmp.w	d2,d0
		bmi.s	+
		add.w	(a4)+,d2
		addq.w	#4,a5
		bra.s	-
+		move.w	(a5),d1
		moveq	#$20,d6
		movem.l	d0/d2-d3/a0/a4-a5,-(sp)
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0/d2-d3/a0/a4-a5
		addi.w	#$10,d0
		dbf	d3,-
		rts
; ---------------------------------------------------------------------------
; Refresh Foreground
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
		moveq	#$E,d2

-		movem.l	d0-d2/d6/a0,-(sp)		; Redraws the entire plane in one go during 68k execution
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/d6/a0
		addi.w	#$10,d0
		dbf	d2,-
		enableInts
		rts
; ---------------------------------------------------------------------------
; Refresh Background
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
		moveq	#$F,d2

-		movem.l	d0-d2/d6/a0,-(sp)		; Redraws the entire plane in one go during 68k execution
		bsr.w	Setup_TileRowDraw
		bsr.w	VInt_DrawLevel
		movem.l	(sp)+,d0-d2/d6/a0
		addi.w	#$10,d0
		dbf	d2,-
		enableInts
		rts

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

; =============== S U B R O U T I N E =======================================

Draw_BG:
		movem.l	d5/a4-a5,-(sp)
		lea	(Camera_Y_pos_BG_copy).w,a6
		bsr.w	Get_DeformDrawPosVert
		lea	(Camera_Y_pos_BG_rounded).w,a5
		bsr.w	Draw_TileRow2
		movem.l	(sp)+,d5/a4/a6
		move.w	(Camera_Y_pos_BG_rounded).w,d6
		tst.w	(Camera_Y_pos_BG_copy).w
		bpl.s	Draw_BGNoVert
		move.w	(Camera_Y_pos_BG_copy).w,d6
		andi.w	#$FFF0,d6

Draw_BGNoVert:
		move.w	d6,d1

-		sub.w	(a4)+,d6
		bmi.s	+
		move.w	(a6)+,d0
		andi.w	#$FFF0,d0
		move.w	d0,(a6)+
		subq.w	#1,d5
		bra.s	-
; ---------------------------------------------------------------------------
+		neg.w	d6
		lsr.w	#4,d6
		moveq	#$F,d4
		sub.w	d6,d4
		bcc.s	+
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
		beq.s	Get_DeformDrawPosVert_Return
		move.w	(a6)+,d0
		andi.w	#$FFF0,d0
		move.w	d0,(a6)+
		bra.s	-

; =============== S U B R O U T I N E =======================================

Draw_BG2:
		lea	(Camera_Y_pos_BG_copy).w,a6
		lea	(Camera_Y_pos_BG_rounded).w,a5
		moveq	#0,d1		; Camera_X_pos_copy
		moveq	#$20,d6
		bra.w	Draw_TileRow

; =============== S U B R O U T I N E =======================================

Get_DeformDrawPosVert:
		move.w	(a4)+,d2
		move.w	(a6),d0
		bsr.s	+
		addi.w	#224,d0
+
-		cmp.w	d2,d0
		bmi.s	+
		add.w	(a4)+,d2
		addq.w	#4,a5
		bra.s	-
; ---------------------------------------------------------------------------
+		move.w	(a5),d1
		swap	d1

Get_DeformDrawPosVert_Return:
		rts

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

; =============== S U B R O U T I N E =======================================

DrawTilesVDeform2:
		movem.l	d5/a4-a5,-(sp)
		lea	(Camera_X_pos_BG_copy).w,a6
		bsr.w	Get_XDeformRange
		lea	(Camera_X_pos_BG_rounded).w,a5
		bsr.w	Draw_TileColumn2
		movem.l	(sp)+,d5/a4/a6
		move.w	(Camera_X_pos_BG_rounded).w,d6

.main:
		move.w	d6,d1

-		sub.w	(a4)+,d6
		bcs.s	+
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
		bcc.s	+
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
		bcc.s	-
		move.w	d0,d6
		moveq	#0,d4
		bra.s	-
; ---------------------------------------------------------------------------
+
-		subq.w	#1,d5
		beq.s	Get_XDeformRange_Return
		move.w	(a6)+,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(a6)+
		bra.s	-

; =============== S U B R O U T I N E =======================================

Get_XDeformRange:
		move.w	(a4)+,d2
		move.w	(a6),d0
		bsr.s	+
		addi.w	#$140,d0

+
-		cmp.w	d2,d0
		blo.s		+
		add.w	(a4)+,d2
		addq.w	#4,a5
		bra.s	-
; ---------------------------------------------------------------------------
+		move.w	(a5),d1
		swap	d1

Get_XDeformRange_Return:
		rts

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertBottomUp:
		movem.w	d1-d2,-(sp)
		bsr.s	Draw_PlaneVertSingleBottomUp
		movem.w	(sp)+,d1-d2
		bpl.s	Draw_PlaneVertSingleBottomUp
		rts

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertSingleBottomUp:
		and.w	(Camera_Y_pos_mask).w,d2
		move.w	d2,d3
		addi.w	#$F0,d3
		and.w	(Camera_Y_pos_mask).w,d3
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s		+
		cmp.w	d3,d0
		bhi.s	+
		moveq	#$20,d6
		bsr.w	Setup_TileRowDraw
+		subi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertTopDown:
		and.w	(Camera_Y_pos_mask).w,d2
		move.w	d2,d3
		addi.w	#$F0,d3
		and.w	(Camera_Y_pos_mask).w,d3
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s		+
		cmp.w	d3,d0
		bhi.s	+
		moveq	#$20,d6
		bsr.w	Setup_TileRowDraw
+		addi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzRightToLeft:
		movem.w	d1-d2,-(sp)
		bsr.s	sub_4EFCA
		movem.w	(sp)+,d1-d2
		bpl.s	sub_4EFCA
		rts

; =============== S U B R O U T I N E =======================================

sub_4EFCA:
		andi.w	#$FFF0,d2
		move.w	d2,d3
		addi.w	#$1F0,d3
		andi.w	#$FFF0,d3
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s		+
		cmp.w	d3,d0
		bhi.s	+
		moveq	#$10,d6
		bsr.w	Setup_TileColumnDraw
+		subi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; =============== S U B R O U T I N E =======================================

Draw_PlaneHorzLeftToRight:
		movem.w	d1-d2,-(sp)
		bsr.s	sub_4F004
		movem.w	(sp)+,d1-d2
		bpl.s	sub_4F004
		rts

; =============== S U B R O U T I N E =======================================

sub_4F004:
		andi.w	#$FFF0,d2
		move.w	d2,d3
		addi.w	#$1F0,d3
		andi.w	#$FFF0,d3
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d2,d0
		blo.s		+
		cmp.w	d3,d0
		bhi.s	+
		moveq	#$10,d6
		bsr.w	Setup_TileColumnDraw
+		addi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; =============== S U B R O U T I N E =======================================

Draw_PlaneVertBottomUpComplex:
		movem.l	d1/a4-a5,-(sp)
		bsr.s	sub_4F03E
		movem.l	(sp)+,d1/a4-a5
		bpl.s	sub_4F03E
		rts

; =============== S U B R O U T I N E =======================================

sub_4F03E:
		and.w	(Camera_Y_pos_mask).w,d1
		move.w	d1,d2
		addi.w	#$F0,d2
		and.w	(Camera_Y_pos_mask).w,d2
		move.w	(Draw_delayed_position).w,d0
		cmp.w	d1,d0
		blo.s		+
		cmp.w	d2,d0
		bhi.s	+

-		addq.w	#4,a5
		cmp.w	(a4)+,d0
		bpl.s	-
		move.w	(a5),d1
		moveq	#$20,d6
		bsr.w	Setup_TileRowDraw
+		subi.w	#16,(Draw_delayed_position).w
		subq.w	#1,(Draw_delayed_rowcount).w
		rts

; =============== S U B R O U T I N E =======================================

Reset_TileOffsetPositionActual:
		move.w	(Camera_X_pos_copy).w,d0
		move.w	d0,d1
		andi.w	#$FFF0,d0
		move.w	d0,(Camera_X_pos_rounded).w
		move.w	(Camera_Y_pos_copy).w,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(Camera_Y_pos_rounded).w
		rts

; =============== S U B R O U T I N E =======================================

Reset_TileOffsetPositionEff:
		move.w	(Camera_X_pos_BG_copy).w,d0
		move.w	d0,d1
		andi.w	#$FFF0,d0
		move.w	d0,d2
		move.w	d0,(Camera_X_pos_BG_rounded).w
		move.w	(Camera_Y_pos_BG_copy).w,d0
		and.w	(Camera_Y_pos_mask).w,d0
		move.w	d0,(Camera_Y_pos_BG_rounded).w
		rts

; =============== S U B R O U T I N E =======================================

Clear_Switches:
		clearRAM2 Level_trigger_array, Level_trigger_array_end
		rts

; =============== S U B R O U T I N E =======================================

Restart_LevelData:
		clr.b	(Background_event_routine).w
		move.l	#Load_Sprites_Init,(Object_load_addr_RAM).w
		move.l	#Load_Rings_Init,(Rings_manager_addr_RAM).w
		clr.b	(Boss_flag).w
		clr.b	(Respawn_table_keep).w
		bsr.s	Clear_Switches
		bsr.w	Load_Level
		bsr.w	Load_Solids
		bra.w	CheckLevelForWater

; =============== S U B R O U T I N E =======================================

Reset_ObjectsPosition3:
		bsr.s	Reset_ObjectsPosition2
		move.w	(Camera_X_pos).w,(Camera_min_X_pos).w
		move.w	(Camera_X_pos).w,(Camera_max_X_pos).w
		move.w	(Camera_Y_pos).w,(Camera_min_Y_pos).w
		move.w	(Camera_Y_pos).w,(Camera_max_Y_pos).w
		rts
; ---------------------------------------------------------------------------

Reset_ObjectsPosition2:
		sub.w	d1,(Player_1+y_pos).w
		sub.w	d0,(Player_1+x_pos).w
		sub.w	d0,(Camera_X_pos).w
		sub.w	d1,(Camera_Y_pos).w
		sub.w	d0,(Camera_X_pos_copy).w
		sub.w	d1,(Camera_Y_pos_copy).w
		move.w	(Camera_max_Y_pos).w,(Camera_target_max_Y_pos).w
		bra.s	Offset_ObjectsDuringTransition
; ---------------------------------------------------------------------------

Reset_ObjectsPosition:
		move.w	(Camera_X_pos).w,d0

Reset_ObjectsPosition4:
		sub.w	d1,(Player_1+y_pos).w
		sub.w	d0,(Player_1+x_pos).w
		sub.w	d0,(Camera_X_pos).w
		sub.w	d1,(Camera_Y_pos).w
		sub.w	d0,(Camera_X_pos_copy).w
		sub.w	d1,(Camera_Y_pos_copy).w
		sub.w	d0,(Camera_min_X_pos).w
		sub.w	d0,(Camera_max_X_pos).w
		sub.w	d1,(Camera_min_Y_pos).w
		sub.w	d1,(Camera_max_Y_pos).w
		move.w	(Camera_max_Y_pos).w,(Camera_target_max_Y_pos).w

; =============== S U B R O U T I N E =======================================

Offset_ObjectsDuringTransition:
		lea	(Dynamic_object_RAM+next_object).w,a1
		moveq	#((Dynamic_object_RAM_end-Dynamic_object_RAM)/object_size)-1,d2

.check
		tst.l	address(a1)
		beq.s	.nextobj
		btst	#2,render_flags(a1)
		beq.s	.nextobj
		sub.w	d0,x_pos(a1)
		sub.w	d1,y_pos(a1)

.nextobj
		lea	next_object(a1),a1
		dbf	d2,.check
		rts

; =============== S U B R O U T I N E =======================================

Change_ActSizes:
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#3,d0
		lea	LevelSizes(pc),a1
		lea	(a1,d0.w),a1
		move.l	(a1)+,d0
		move.l	d0,(Camera_min_X_pos).w
		move.l	d0,(Camera_target_min_X_pos).w
		move.l	(a1)+,d0
		move.l	d0,(Camera_min_Y_pos).w
		move.l	d0,(Camera_target_min_Y_pos).w
		rts

; =============== S U B R O U T I N E =======================================

LoadLevelLoadBlock:
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	(LevelLoadBlock).l,a2
		lea	(a2,d0.w),a2
		move.l	(a2)+,d0
		andi.l	#$FFFFFF,d0
		movea.l	d0,a1
		moveq	#0,d2
		bsr.w	Queue_Kos_Module

.waitplc
		move.b	#VintID_Fade,(V_int_routine).w
		jsr	(Process_Kos_Queue).w
		jsr	(Wait_VSync).w
		jsr	(Process_Kos_Module_Queue).w
		tst.w	(Kos_modules_left).w
		bne.s	.waitplc
		rts

; =============== S U B R O U T I N E =======================================

LoadLevelLoadBlock2:
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	(LevelLoadBlock).l,a2
		lea	(a2,d0.w),a2
		pea	(a2)
		addq.w	#4,a2
		move.l	(a2)+,(Block_table_addr_ROM).w
		movea.l	(a2)+,a0
		lea	(RAM_start).l,a1
		jsr	(Kos_Decomp).w
		bsr.s	Load_Level
		jsr	(LoadPLC_KosM).w
		movea.l	(sp)+,a2
		moveq	#0,d0
		move.b	(a2),d0
		jmp	(LoadPalette).w

; =============== S U B R O U T I N E =======================================

Load_Level:
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#4,d0
		lea	(LevelPtrs).l,a0
		movea.l	(a0,d0.w),a0

Load_Level2:
		move.l	a0,(Level_layout_addr_ROM).w
		addq.l	#8,a0
		move.l	a0,(Level_layout2_addr_ROM).w
		rts

; =============== S U B R O U T I N E =======================================

LoadLevelPointer:
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#3,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		lea	(LevelLoadPointer).l,a2
		lea	(a2,d0.w),a2
		lea	(Level_data_addr_RAM).w,a3

	rept	(Level_data_addr_RAM_end-Level_data_addr_RAM)/4
		move.l	(a2)+,(a3)+
	endr
		rts
; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; Uses Sonic & Knuckles format mapping
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Solids:
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#4,d0
		lea	(SolidIndexes).l,a0
		movea.l	(a0,d0.w),a0

Load_Solids2:
		move.l	a0,(Primary_collision_addr).w
		move.l	a0,(Collision_addr).w
		addq.l	#1,a0
		move.l	a0,(Secondary_collision_addr).w
		rts
