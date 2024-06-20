
; =============== S U B R O U T I N E =======================================

Check_CameraInRange:
		move.w	(Camera_Y_pos).w,d0
		cmp.w	(a1)+,d0
		blo.s		Check_CameraInRange_Fail
		cmp.w	(a1)+,d0
		bhi.s	Check_CameraInRange_Fail
		move.w	(Camera_X_pos).w,d1
		cmp.w	(a1)+,d1
		blo.s		Check_CameraInRange_Fail
		cmp.w	(a1)+,d1
		bhi.s	Check_CameraInRange_Fail
		bclr	#7,objoff_27(a0)
		cmp.w	(a1),d0
		bls.s		.skip
		bset	#7,objoff_27(a0)

.skip
		bclr	#6,objoff_27(a0)
		cmp.w	4(a1),d1
		bls.s		.skip2
		bset	#6,objoff_27(a0)

.skip2
		move.l	(sp),address(a0)
		rts
; ---------------------------------------------------------------------------

Check_CameraInRange_Fail:
		addq.w	#4,sp															; exit from current object
		bra.w	Delete_Sprite_If_Not_In_Range

; =============== S U B R O U T I N E =======================================

sub_85C7E:
		move.w	(Camera_X_pos).w,(Camera_min_X_pos).w
		move.w	(Camera_target_max_Y_pos).w,d0
		cmp.w	(Camera_max_Y_pos).w,d0
		blo.s		.return
		move.w	d0,(Camera_min_Y_pos).w
		move.w	objoff_3A(a0),d0
		cmp.w	(Camera_X_pos).w,d0
		bhi.s	.return
		movea.l	objoff_34(a0),a1
		jmp	(a1)
; ---------------------------------------------------------------------------

.return
		rts

; =============== S U B R O U T I N E =======================================

Init_BossArena:
		st	(Boss_flag).w

Init_BossArena2:
		music	mus_FadeOut													; fade out music
		move.w	#2*60,objoff_2E(a0)

Init_BossArena3:
		move.w	(Camera_min_Y_pos).w,(Camera_stored_min_Y_pos).w
		move.w	(Camera_target_max_Y_pos).w,(Camera_stored_max_Y_pos).w
		move.w	(Camera_min_X_pos).w,(Camera_stored_min_X_pos).w
		move.w	(Camera_max_X_pos).w,(Camera_stored_max_X_pos).w
		move.l	(a1)+,(Camera_saved_min_Y_pos).w
		move.l	(a1)+,(Camera_saved_min_X_pos).w
		rts

; =============== S U B R O U T I N E =======================================

Load_BossArena:
		btst	#0,objoff_27(a0)
		bne.s	loc_85CC6
		subq.w	#1,objoff_2E(a0)
		bpl.s	loc_85CC6
		move.b	objoff_26(a0),d0
		move.b	d0,(Current_music+1).w
		bsr.w	Play_Music
		bset	#0,objoff_27(a0)

loc_85CC6:
		btst	#1,objoff_27(a0)
		bne.s	loc_85D06
		move.w	(Camera_Y_pos).w,d0
		tst.b	objoff_27(a0)
		bmi.s	loc_85CE6
		cmp.w	(Camera_saved_min_Y_pos).w,d0
		bhs.s	loc_85CF2
		move.w	d0,(Camera_min_Y_pos).w
		bra.s	loc_85D06
; ---------------------------------------------------------------------------

loc_85CE6:
		moveq	#$60,d1
		add.w	(Camera_saved_max_Y_pos).w,d1
		cmp.w	d1,d0
		bhi.s	loc_85D06

loc_85CF2:
		bset	#1,objoff_27(a0)
		move.w	(Camera_saved_min_Y_pos).w,(Camera_min_Y_pos).w
		move.w	(Camera_saved_max_Y_pos).w,d0
		move.w	d0,(Camera_target_max_Y_pos).w

loc_85D06:
		btst	#2,objoff_27(a0)
		bne.s	loc_85D48
		move.w	(Camera_X_pos).w,d0
		btst	#6,objoff_27(a0)
		bne.s	loc_85D28
		cmp.w	(Camera_saved_min_X_pos).w,d0
		bhs.s	loc_85D36
		move.w	d0,(Camera_min_X_pos).w
		bra.s	loc_85D48
; ---------------------------------------------------------------------------

loc_85D28:
		cmp.w	(Camera_saved_max_X_pos).w,d0
		bls.s		loc_85D36
		move.w	d0,(Camera_max_X_pos).w
		bra.s	loc_85D48
; ---------------------------------------------------------------------------

loc_85D36:
		bset	#2,objoff_27(a0)
		move.w	(Camera_saved_min_X_pos).w,(Camera_min_X_pos).w
		move.w	(Camera_saved_max_X_pos).w,(Camera_max_X_pos).w

loc_85D48:
		moveq	#7,d0
		and.b	objoff_27(a0),d0
		cmpi.b	#7,d0
		bne.s	Check_InTheirRange_Return
		clr.w	objoff_1C(a0)
		clr.w	objoff_26(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

Check_InTheirRange:
		move.w	x_pos(a0),d0
		move.w	x_pos(a1),d1
		add.w	(a2)+,d1
		cmp.w	d1,d0
		blt.s		Check_InTheirRange_Fail
		add.w	(a2)+,d1
		cmp.w	d1,d0
		bge.s	Check_InTheirRange_Fail
		move.w	y_pos(a0),d0
		move.w	y_pos(a1),d1
		add.w	(a2)+,d1
		cmp.w	d1,d0
		blt.s		Check_InTheirRange_Fail
		add.w	(a2)+,d1
		cmp.w	d1,d0
		bge.s	Check_InTheirRange_Fail
		moveq	#1,d0

Check_InTheirRange_Return:
		rts
; ---------------------------------------------------------------------------

Check_InTheirRange_Fail:
		moveq	#0,d0
		rts

; =============== S U B R O U T I N E =======================================

Check_InMyRange:
		move.w	x_pos(a0),d0
		move.w	x_pos(a1),d1
		add.w	(a2)+,d0
		cmp.w	d0,d1
		blt.s		Check_InMyRange_Fail
		add.w	(a2)+,d0
		cmp.w	d0,d1
		bge.s	Check_InMyRange_Fail
		move.w	y_pos(a0),d0
		move.w	y_pos(a1),d1
		add.w	(a2)+,d0
		cmp.w	d0,d1
		blt.s		Check_InMyRange_Fail
		add.w	(a2)+,d0
		cmp.w	d0,d1
		bge.s	Check_InMyRange_Fail
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

Check_InMyRange_Fail:
		moveq	#0,d0
		rts

; =============== S U B R O U T I N E =======================================

Check_PlayerInRange:
		moveq	#0,d0
		lea	(Player_1).w,a2
		move.w	x_pos(a2),d1
		move.w	y_pos(a2),d2
		move.w	x_pos(a0),d3
		move.w	y_pos(a0),d4
		add.w	(a1)+,d3
		move.w	d3,d5
		add.w	(a1)+,d5
		add.w	(a1)+,d4
		move.w	d4,d6
		add.w	(a1)+,d6

		; check
		cmp.w	d3,d1
		blo.s		.return
		cmp.w	d5,d1
		bhs.s	.return
		cmp.w	d4,d2
		blo.s		.return
		cmp.w	d6,d2
		bhs.s	.return
		move.w	a2,d0

.return
		rts

; =============== S U B R O U T I N E =======================================

Check_PlayerInRange2:
		move.w	(Player_1+y_pos).w,d0
		cmp.w	(a1)+,d0
		blo.s		.fail
		cmp.w	(a1)+,d0
		bhi.s	.fail
		move.w	(Player_1+x_pos).w,d1
		cmp.w	(a1)+,d1
		blo.s		.fail
		cmp.w	(a1),d1
		bhi.s	.fail

.done
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

.fail
		moveq	#0,d0
		rts

; =============== S U B R O U T I N E =======================================

Chk_OffScreen:
		move.w	x_pos(a0),d0														; get object x-position
		sub.w	(Camera_X_pos).w,d0												; subtract screen x-position
		bmi.s	.offscreen
		cmpi.w	#320,d0															; is object on the screen?
		bge.s	.offscreen														; if not, branch
		move.w	y_pos(a0),d0														; get object y-position
		sub.w	(Camera_Y_pos).w,d0												; subtract screen y-position
		bmi.s	.offscreen
		cmpi.w	#224,d0															; is object on the screen?
		bge.s	.offscreen														; if not, branch

		; onscreen
		moveq	#0,d0															; set flag to 0
		rts
; ---------------------------------------------------------------------------

.offscreen
		moveq	#1,d0															; set flag to 1
		rts

; =============== S U B R O U T I N E =======================================

Chk_WidthOffScreen:
		moveq	#0,d1
		move.b	width_pixels(a0),d1
		move.w	x_pos(a0),d0														; get object x-position
		sub.w	(Camera_X_pos).w,d0												; subtract screen x-position
		add.w	d1,d0															; add object width
		bmi.s	.offscreen
		add.w	d1,d1
		sub.w	d1,d0
		cmpi.w	#320,d0															; is object on the screen?
		bge.s	.offscreen														; if not, branch
		move.w	y_pos(a0),d0														; get object y-position
		sub.w	(Camera_Y_pos).w,d0												; subtract screen y-position
		bmi.s	.offscreen
		cmpi.w	#224,d0															; is object on the screen?
		bge.s	.offscreen														; if not, branch

		; onscreen
		moveq	#0,d0															; set flag to 0
		rts
; ---------------------------------------------------------------------------

.offscreen
		moveq	#1,d0															; set flag to 1
		rts
