; ---------------------------------------------------------------------------
; Smooth Palette (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_SmoothPalette:
		move.l	#.main,address(a0)
		move.b	#7,objoff_39(a0)						; set 7 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	.return
	        move.w	objoff_3A(a0),objoff_2E(a0)
		movea.w	objoff_30(a0),a1						; palette RAM
		movea.l	objoff_32(a0),a2						; palette pointer
		move.w	objoff_36(a0),d0						; palette size
		jsr	(Pal_SmoothToPalette).w

		; check delete
		subq.b	#1,objoff_39(a0)
		bpl.s	.return
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w
; ---------------------------------------------------------------------------

.return
		rts

; =============== S U B R O U T I N E =======================================

Obj_SmoothPalette2:
		move.l	#.main,address(a0)
		move.b	#7,objoff_39(a0)						; set 7-1 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	.return
	        move.w	objoff_3A(a0),objoff_2E(a0)
		movea.l	objoff_30(a0),a3
		move.w	(a3)+,d6							; loop count

.loop
		movea.l	(a3)+,a2							; palette pointer
		movea.w	(a3)+,a1							; palette RAM
		move.w	(a3)+,d0							; palette size
		jsr	(Pal_SmoothToPalette).w
		dbf	d6,.loop

		; check delete
		subq.b	#1,objoff_39(a0)
		bpl.s	.return
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w
; ---------------------------------------------------------------------------

.return
		rts
; ---------------------------------------------------------------------------

Child6_SmoothPalette:
		dc.w 1-1
		dc.l Obj_SmoothPalette
Child6_SmoothPalette2:
		dc.w 1-1
		dc.l Obj_SmoothPalette2

; ---------------------------------------------------------------------------
; Fade selected to black (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_FadeSelectedToBlack:
		move.l	#.main,address(a0)
		move.b	#7,objoff_39(a0)						; set 7 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	Obj_SmoothPalette2.return
		move.w	objoff_3A(a0),objoff_2E(a0)

		; start
		movea.w	objoff_30(a0),a1
		move.w	objoff_3C(a0),d0
		moveq	#$E,d1
		moveq	#signextendB($E0),d2

.loop
		jsr	(DecColor_Obj).w
		dbf	d0,.loop

		; check delete
		subq.b	#1,objoff_39(a0)
		bpl.s	Obj_SmoothPalette2.return
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w

; ---------------------------------------------------------------------------
; Fade selected from black (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_FadeSelectedFromBlack:
		move.l	#.main,address(a0)
		move.b	#7,objoff_39(a0)						; set 7 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	Obj_FadeToWhite.return
		move.w	objoff_3A(a0),objoff_2E(a0)

		; start
		movea.w	objoff_30(a0),a1
		movea.w	objoff_32(a0),a2
		move.w	objoff_3C(a0),d0
		moveq	#$E,d1
		moveq	#signextendB($E0),d2

.loop
		jsr	(IncColor_Obj).w
		dbf	d0,.loop

		; check delete
		subq.b	#1,objoff_39(a0)
		bpl.s	Obj_FadeToWhite.return
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_FadeToWhite:
		move.l	#.main,address(a0)
		move.b	#7,objoff_39(a0)						; set 7 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	.return
		move.w	objoff_3A(a0),objoff_2E(a0)

		; start
		lea	(Normal_palette).w,a1
		moveq	#64-1,d0

.loop
		jsr	(IncColor_Obj2).w
		dbf	d0,.loop

		; check delete
		subq.b	#1,objoff_39(a0)
		bpl.s	.return
		tst.b	objoff_2C(a0)
		beq.s	.delete
		move.l	#Obj_FadeFromWhite,address(a0)
		bset	#5,objoff_38(a0)

.return
		rts
; ---------------------------------------------------------------------------

.delete
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_FadeFromWhite:
		move.l	#.main,address(a0)
		move.b	#7,objoff_39(a0)						; set 7 for normal fade
		move.w	#3,objoff_2E(a0)

.main

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	Obj_FadeToWhite.return
		addq.w	#3+1,objoff_2E(a0)

		; start
		lea	(Normal_palette).w,a1
		lea	(Target_palette).w,a2
		moveq	#64-1,d0

.loop
		jsr	(DecColor_Obj2).w
		dbf	d0,.loop

		; check delete
		subq.b	#1,objoff_39(a0)
		bpl.s	Obj_FadeToWhite.return
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w
