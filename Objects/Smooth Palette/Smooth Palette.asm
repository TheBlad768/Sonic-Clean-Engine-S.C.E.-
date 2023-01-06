; ---------------------------------------------------------------------------
; Smooth Palette (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_SmoothPalette:
		move.l	#.main,address(a0)
		tst.b	objoff_38(a0)
		bne.s	.main
		move.b	#7-1,objoff_38(a0)		; set 7-1 for normal fade

.main
		subq.w	#1,objoff_2E(a0)
		bpl.s	.return
	        move.w	subtype(a0),objoff_2E(a0)
		movea.w	objoff_30(a0),a1			; palette ram
		movea.l	objoff_32(a0),a2			; palette pointer
		move.w	objoff_36(a0),d0			; palette size
		jsr	(Pal_SmoothToPalette).w
		subq.b	#1,objoff_38(a0)
		bpl.s	.return
		move.l	#Delete_Current_Sprite,address(a0)

.return
		rts

; =============== S U B R O U T I N E =======================================

Obj_SmoothPalette2:
		move.l	#.main,address(a0)
		tst.b	objoff_38(a0)
		bne.s	.main
		move.b	#7-1,objoff_38(a0)		; set 7-1 for normal fade

.main
		subq.w	#1,objoff_2E(a0)
		bpl.s	.return
	        move.w	subtype(a0),objoff_2E(a0)
		movea.l	objoff_30(a0),a3
		move.w	(a3)+,d6					; loop count

.loop
		movea.l	(a3)+,a2					; palette pointer
		movea.w	(a3)+,a1					; palette ram
		move.w	(a3)+,d0					; palette size
		jsr	(Pal_SmoothToPalette).w
		dbf	d6,.loop

		subq.b	#1,objoff_38(a0)
		bpl.s	.return
		move.l	#Delete_Current_Sprite,address(a0)

.return
		rts
; ---------------------------------------------------------------------------

ChildObjDat6_SmoothPalette:
		dc.w 1-1
		dc.l Obj_SmoothPalette
ChildObjDat6_SmoothPalette2:
		dc.w 1-1
		dc.l Obj_SmoothPalette2
