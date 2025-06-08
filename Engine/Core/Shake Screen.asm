; ---------------------------------------------------------------------------
; Shaking foreground/background
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ShakeScreen_Setup:
		moveq	#0,d1
		move.w	(Screen_shaking_offset).w,(Screen_shaking_last_offset).w
		cmpi.b	#PlayerID_Death,(Player_1+routine).w				; has player just died?
		bhs.s	.setso								; if yes, branch
		move.w	(Screen_shaking_flag).w,d0
		beq.s	.setso
		bmi.s	.shake
		subq.w	#1,d0
		move.w	d0,(Screen_shaking_flag).w
		cmpi.w	#(ScreenShakeArray2-ScreenShakeArray),d0
		bhs.s	.shake
		move.b	ScreenShakeArray(pc,d0.w),d1
		ext.w	d1

.setso
		move.w	d1,(Screen_shaking_offset).w
		rts
; ---------------------------------------------------------------------------

.shake
		moveq	#$3F,d0
		and.w	(Level_frame_counter).w,d0
		move.b	ScreenShakeArray2(pc,d0.w),d1
		move.w	d1,(Screen_shaking_offset).w
		rts

; =============== S U B R O U T I N E =======================================

ScreenShakeArray:
		dc.b 1, -1, 1, -1, 2, -2, 2, -2, 3, -3, 3, -3, 4, -4, 4, -4, 5, -5, 5, -5
ScreenShakeArray2:
		dc.b 1, 2, 1, 3, 1, 2, 2, 1, 2, 3, 1, 2, 1, 2, 0, 0
		dc.b 2, 0, 3, 2, 2, 3, 2, 2, 1, 3, 0, 0, 1, 0, 1, 3
		dc.b 1, 2, 1, 3, 1, 2, 2, 1, 2, 3, 1, 2, 1, 2, 0, 0
		dc.b 2, 0, 3, 2, 2, 3, 2, 2, 1, 3, 0, 0, 1, 0, 1, 3
	even
