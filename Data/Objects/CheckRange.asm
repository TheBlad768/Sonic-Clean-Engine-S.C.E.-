
; =============== S U B R O U T I N E =======================================

Check_CameraInRange:
		move.w	(Camera_Y_pos).w,d0
		cmp.w	(a1)+,d0
		bcs.s	Check_CameraInRange_Fail
		cmp.w	(a1)+,d0
		bhi.s	Check_CameraInRange_Fail
		move.w	(Camera_X_pos).w,d1
		cmp.w	(a1)+,d1
		bcs.s	Check_CameraInRange_Fail
		cmp.w	(a1)+,d1
		bhi.s	Check_CameraInRange_Fail
		bclr	#7,$27(a0)
		cmp.w	(a1),d0
		bls.s		+
		bset	#7,$27(a0)
+		bclr	#6,$27(a0)
		cmp.w	4(a1),d1
		bls.s		+
		bset	#6,$27(a0)
+		move.l	(sp),address(a0)
		rts
; ---------------------------------------------------------------------------

Check_CameraInRange_Fail:
		bsr.w	Delete_Sprite_If_Not_In_Range
		addq.w	#4,sp
		rts
; End of function Check_CameraInRange

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
		rts
; ---------------------------------------------------------------------------

Check_InTheirRange_Fail:
		moveq	#0,d0
		rts
; End of function Check_InTheirRange

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
; End of function Check_InMyRange

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
		cmp.w	d3,d1
		blo.s		+
		cmp.w	d5,d1
		bhs.s	+
		cmp.w	d4,d2
		blo.s		+
		cmp.w	d6,d2
		bhs.s	+
		move.w	a2,d0
+		rts
; End of function Check_PlayerInRange
