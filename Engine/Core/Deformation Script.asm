; ---------------------------------------------------------------------------
; Simple horizontal deformation
; Inputs:
; a2 = config: buffer, initial pixel, velocity, deformation size
; a3 = deformation table
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HScroll_Deform:
		lea	(H_scroll_table).w,a3						; load scroll table

.main
		move.w	(a2)+,d6							; get list of deformation

.next
		movem.w	(a2)+,d2/d5/a1							; get velocity parameter, deformation size, deformation buffer
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position

.loop
		add.l	d2,(a3)								; add velocity to deformation table
		move.w	(a3),(a1)							; set velocity from deformation table to deformation buffer
		addq.w	#4,a1								; next deformation line
		addq.w	#4,a3								; next deformation table
		dbf	d5,.loop
		dbf	d6,.next
		rts

; ---------------------------------------------------------------------------
; Simple vertical deformation
; Inputs:
; a1 = deformation table
; a2 = config: velocity
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VScroll_Deform:
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5
		move.l	#vdpComm(0,VSRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		moveq	#bytesToXcnt((320*2),16),d6

.loop
		move.w	(a2)+,d2							; get velocity parameter
		ext.l	d2
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d2,(a1)								; add velocity to deformation table
		move.w	(a1),VDP_data_port-VDP_data_port(a6)				; set velocity from deformation table to deformation buffer
		addq.w	#4,a1
		dbf	d6,.loop
		rts

; ---------------------------------------------------------------------------
; Plain deformation
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PlainDeformation:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_X_pos_copy).w,d0
		neg.w	d0
		swap	d0
		move.w	(Camera_X_pos_BG_copy).w,d0
		neg.w	d0
		moveq	#bytesToXcnt(224,8),d1

.loop

	rept 8
		move.l	d0,(a1)+
	endr

		dbf	d1,.loop
		rts

; ---------------------------------------------------------------------------
; Plain deformation (flipped)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PlainDeformation_Flipped:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_X_pos_BG_copy).w,d0
		neg.w	d0
		swap	d0
		move.w	(Camera_X_pos_copy).w,d0
		neg.w	d0
		moveq	#bytesToXcnt(224,8),d1

.loop

	rept 8
		move.l	d0,(a1)+
	endr

		dbf	d1,.loop
		rts

; ---------------------------------------------------------------------------
; FG deform
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

MakeFGDeformArray:
		move.w	d1,d0
		lsr.w	d0								; division by 2
		bhs.s	.skip

.loop
		move.w	(a6)+,d5
		add.w	d6,d5
		move.w	d5,(a1)+

.skip
		move.w	(a6)+,d5
		add.w	d6,d5
		move.w	d5,(a1)+
		dbf	d0,.loop
		rts

; ---------------------------------------------------------------------------
; Foreground scrolling
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

FGScroll_Deformation:
		lea	(Camera_H_scroll_shift).w,a1

.main
		move.w	(a1)+,d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,(a1)	; Camera_H_scroll_shift+2

.scroll
		move.w	(a1),d0	; Camera_H_scroll_shift+2
		neg.w	d0
		lea	(H_scroll_buffer).w,a1
		moveq	#bytesToXcnt(224,8),d1

.loop

	rept 8
		move.w	(a1),d2
		add.w	d0,d2
		move.w	d2,(a1)
		addq.w	#4,a1								; skip FBG
	endr

		dbf	d1,.loop
		rts

; =============== S U B R O U T I N E =======================================

ApplyDeformation:
		move.w	#224-1,d1

ApplyDeformation3:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	(Camera_X_pos_copy).w,d3

ApplyDeformation2:
		move.w	(a4)+,d2
		smi	d4
		bpl.s	.loc_4F0E8
		andi.w	#$7FFF,d2

.loc_4F0E8
		sub.w	d2,d0
		bmi.s	.loc_4F0FA
		addq.w	#2,a5
		tst.b	d4
		beq.s	ApplyDeformation2
		subq.w	#2,a5
		add.w	d2,d2
		adda.w	d2,a5
		bra.s	ApplyDeformation2
; ---------------------------------------------------------------------------

.loc_4F0FA
		tst.b	d4
		beq.s	.loc_4F104
		add.w	d0,d2
		add.w	d2,d2
		adda.w	d2,a5

.loc_4F104
		neg.w	d0
		move.w	d1,d2
		sub.w	d0,d2
		bhs.s	.loc_4F110
		move.w	d1,d0
		addq.w	#1,d0

.loc_4F110
		neg.w	d3
		swap	d3

.loc_4F114
		subq.w	#1,d0

.loc_4F116
		tst.b	d4
		beq.s	.loc_4F130
		lsr.w	d0								; division by 2
		bhs.s	.loc_4F124

.loc_4F11E
		move.w	(a5)+,d3
		neg.w	d3
		move.l	d3,(a1)+

.loc_4F124
		move.w	(a5)+,d3
		neg.w	d3
		move.l	d3,(a1)+
		dbf	d0,.loc_4F11E
		bra.s	.loc_4F140
; ---------------------------------------------------------------------------

.loc_4F130
		move.w	(a5)+,d3
		neg.w	d3
		lsr.w	d0								; division by 2
		bhs.s	.loc_4F13A

.loc_4F138
		move.l	d3,(a1)+

.loc_4F13A
		move.l	d3,(a1)+
		dbf	d0,.loc_4F138

.loc_4F140
		tst.w	d2
		bmi.s	.locret_4F158
		move.w	(a4)+,d0
		smi	d4
		bpl.s	.loc_4F14E
		andi.w	#$7FFF,d0

.loc_4F14E
		move.w	d2,d3
		sub.w	d0,d2
		bpl.s	.loc_4F114
		move.w	d3,d0
		bra.s	.loc_4F116
; ---------------------------------------------------------------------------

.locret_4F158
		rts

; =============== S U B R O U T I N E =======================================

ApplyTitleDeformation:
		move.w	#224-1,d1

ApplyTitleDeformation3:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	(Camera_X_pos_copy).w,d3

ApplyTitleDeformation2:
		move.w	(a4)+,d2
		smi	d4
		bpl.s	.loc_4F0E8
		andi.w	#$7FFF,d2

.loc_4F0E8
		sub.w	d2,d0
		bmi.s	.loc_4F0FA
		addq.w	#2,a5
		tst.b	d4
		beq.s	ApplyTitleDeformation2
		subq.w	#2,a5
		add.w	d2,d2
		adda.w	d2,a5
		bra.s	ApplyTitleDeformation2
; ---------------------------------------------------------------------------

.loc_4F0FA
		tst.b	d4
		beq.s	.loc_4F104
		add.w	d0,d2
		add.w	d2,d2
		adda.w	d2,a5

.loc_4F104
		neg.w	d0
		move.w	d1,d2
		sub.w	d0,d2
		bhs.s	.loc_4F110
		move.w	d1,d0
		addq.w	#1,d0

.loc_4F110
		neg.w	d3
		swap	d3

.loc_4F114
		subq.w	#1,d0

.loc_4F116
		tst.b	d4
		beq.s	.loc_4F130
		lsr.w	d0								; division by 2
		bhs.s	.loc_4F124

.loc_4F11E
		move.w	(a5)+,d3
		neg.w	d3
		addq.w	#2,a1
		move.w	d3,(a1)+

.loc_4F124
		move.w	(a5)+,d3
		neg.w	d3
		addq.w	#2,a1
		move.w	d3,(a1)+
		dbf	d0,.loc_4F11E
		bra.s	.loc_4F140
; ---------------------------------------------------------------------------

.loc_4F130
		move.w	(a5)+,d3
		neg.w	d3
		lsr.w	d0								; division by 2
		bhs.s	.loc_4F13A

.loc_4F138
		addq.w	#2,a1
		move.w	d3,(a1)+

.loc_4F13A
		addq.w	#2,a1
		move.w	d3,(a1)+
		dbf	d0,.loc_4F138

.loc_4F140
		tst.w	d2
		bmi.s	.locret_4F158
		move.w	(a4)+,d0
		smi	d4
		bpl.s	.loc_4F14E
		andi.w	#$7FFF,d0

.loc_4F14E
		move.w	d2,d3
		sub.w	d0,d2
		bpl.s	.loc_4F114
		move.w	d3,d0
		bra.s	.loc_4F116
; ---------------------------------------------------------------------------

.locret_4F158
		rts

; =============== S U B R O U T I N E =======================================

ApplyFGDeformation:
		move.w	#224-1,d1

ApplyFGDeformation3:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_Y_pos_copy).w,d0
		move.w	(Camera_X_pos_BG_copy).w,d3

ApplyFGDeformation2:
		move.w	(a4)+,d2
		smi	d4
		bpl.s	loc_4F174
		andi.w	#$7FFF,d2

loc_4F174:
		sub.w	d2,d0
		bmi.s	loc_4F186
		addq.w	#2,a5
		tst.b	d4
		beq.s	ApplyFGDeformation2
		subq.w	#2,a5
		add.w	d2,d2
		adda.w	d2,a5
		bra.s	ApplyFGDeformation2
; ---------------------------------------------------------------------------

loc_4F186:
		tst.b	d4
		beq.s	loc_4F190
		add.w	d0,d2
		add.w	d2,d2
		adda.w	d2,a5

loc_4F190:
		neg.w	d0
		move.w	d1,d2
		sub.w	d0,d2
		bhs.s	loc_4F19C
		move.w	d1,d0
		addq.w	#1,d0

loc_4F19C:
		neg.w	d3

loc_4F19E:
		subq.w	#1,d0

loc_4F1A0:
		tst.b	d4
		beq.s	loc_4F1C2
		lsr.w	d0								; division by 2
		bhs.s	loc_4F1B2

loc_4F1A8:
		swap	d3
		move.w	(a5)+,d3
		neg.w	d3
		swap	d3
		move.l	d3,(a1)+

loc_4F1B2:
		swap	d3
		move.w	(a5)+,d3
		neg.w	d3
		swap	d3
		move.l	d3,(a1)+
		dbf	d0,loc_4F1A8
		bra.s	loc_4F1D6
; ---------------------------------------------------------------------------

loc_4F1C2:
		swap	d3
		move.w	(a5)+,d3
		neg.w	d3
		swap	d3
		lsr.w	d0								; division by 2
		bhs.s	loc_4F1D0

loc_4F1CE:
		move.l	d3,(a1)+

loc_4F1D0:
		move.l	d3,(a1)+
		dbf	d0,loc_4F1CE

loc_4F1D6:
		tst.w	d2
		bmi.s	locret_4F1EE
		move.w	(a4)+,d0
		smi	d4
		bpl.s	loc_4F1E4
		andi.w	#$7FFF,d0

loc_4F1E4:
		move.w	d2,d1
		sub.w	d0,d2
		bpl.s	loc_4F19E
		move.w	d1,d0
		bra.s	loc_4F1A0
; ---------------------------------------------------------------------------

locret_4F1EE:
		rts

; =============== S U B R O U T I N E =======================================

ApplyFGandBGDeformation3:
		lea	(H_scroll_buffer).w,a1

ApplyFGandBGDeformation:
		swap	d7
		swap	d3

ApplyFGandBGDeformation2:
		move.w	(a4)+,d3
		smi	d7
		bpl.s	loc_4F1FE
		andi.w	#$7FFF,d3

loc_4F1FE:
		sub.w	d3,d0
		bmi.s	loc_4F210
		addq.w	#2,a5
		tst.b	d7
		beq.s	ApplyFGandBGDeformation2
		subq.w	#2,a5
		add.w	d3,d3
		adda.w	d3,a5
		bra.s	ApplyFGandBGDeformation2
; ---------------------------------------------------------------------------

loc_4F210:
		tst.b	d7
		beq.s	loc_4F21A
		add.w	d0,d3
		add.w	d3,d3
		adda.w	d3,a5

loc_4F21A:
		swap	d3
		neg.w	d0
		move.w	d1,d4
		sub.w	d0,d4
		bhs.s	loc_4F228
		move.w	d1,d0
		addq.w	#1,d0

loc_4F228:
		subq.w	#1,d0

loc_4F22A:
		tst.b	d7
		beq.s	loc_4F250
		lsr.w	d0								; division by 2
		bhs.s	loc_4F23E

loc_4F232:
		move.w	(a2)+,d6
		swap	d6
		move.w	(a5)+,d6
		neg.w	d6
		add.w	(a6)+,d6
		move.l	d6,(a1)+

loc_4F23E:
		move.w	(a2)+,d6
		swap	d6
		move.w	(a5)+,d6
		neg.w	d6
		add.w	(a6)+,d6
		move.l	d6,(a1)+
		dbf	d0,loc_4F232
		bra.s	loc_4F270
; ---------------------------------------------------------------------------

loc_4F250:
		move.w	(a5)+,d5
		neg.w	d5
		lsr.w	d0								; division by 2
		bhs.s	loc_4F262

loc_4F258:
		move.w	(a2)+,d6
		swap	d6
		move.w	(a6)+,d6
		add.w	d5,d6
		move.l	d6,(a1)+

loc_4F262:
		move.w	(a2)+,d6
		swap	d6
		move.w	(a6)+,d6
		add.w	d5,d6
		move.l	d6,(a1)+
		dbf	d0,loc_4F258

loc_4F270:
		tst.w	d4
		bmi.s	loc_4F288
		move.w	(a4)+,d0
		smi	d7
		bpl.s	loc_4F27E
		andi.w	#$7FFF,d0

loc_4F27E:
		move.w	d4,d5
		sub.w	d0,d4
		bpl.s	loc_4F228
		move.w	d5,d0
		bra.s	loc_4F22A
; ---------------------------------------------------------------------------

loc_4F288:
		swap	d7
		rts

; =============== S U B R O U T I N E =======================================

Apply_FGVScroll:
		lea	(V_scroll_buffer).w,a1

Apply_FGVScroll2:
		move.w	(Camera_Y_pos_BG_copy).w,d1
		move.w	(Camera_X_pos_copy).w,d0
		move.w	d0,d2
		andi.w	#$F,d2
		beq.s	loc_4F2A4
		addi.w	#$10,d0

loc_4F2A4:
		lsr.w	#4,d0

loc_4F2A6:
		addq.w	#2,a5
		move.w	(a4)+,d2
		lsr.w	#4,d2
		sub.w	d2,d0
		bpl.s	loc_4F2A6
		neg.w	d0
		moveq	#$13,d2
		sub.w	d0,d2
		bhs.s	loc_4F2BA
		moveq	#$14,d0

loc_4F2BA:
		subq.w	#1,d0

loc_4F2BC:
		move.w	(a5)+,d3

loc_4F2BE:
		move.w	d3,(a1)+
		move.w	d1,(a1)+
		dbf	d0,loc_4F2BE
		tst.w	d2
		bmi.s	locret_4F2D8
		move.w	(a4)+,d0
		lsr.w	#4,d0
		move.w	d2,d3
		sub.w	d0,d2
		bpl.s	loc_4F2BA
		move.w	d3,d0
		bra.s	loc_4F2BC
; ---------------------------------------------------------------------------

locret_4F2D8:
		rts
