; ---------------------------------------------------------------------------
; Shaking foreground/background
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ShakeScreen_Setup:
		move.w	(Screen_shaking_offset).w,(Screen_shaking_last_offset).w
		moveq	#0,d1
		cmpi.b	#id_SonicDeath,(Player_1+routine).w
		bhs.s	++
		move.w	(Screen_shaking_flag).w,d0
		beq.s	++
		bmi.s	+
		subq.w	#1,d0
		move.w	d0,(Screen_shaking_flag).w
		cmpi.w	#$14,d0
		bhs.s	+
		move.b	ScreenShakeArray(pc,d0.w),d1
		ext.w	d1
		bra.s	++
; ---------------------------------------------------------------------------
+		move.w	(Level_frame_counter).w,d0
		andi.w	#$3F,d0
		move.b	ScreenShakeArray2(pc,d0.w),d1
+		move.w	d1,(Screen_shaking_offset).w
		rts

; =============== S U B R O U T I N E =======================================

ScreenShakeArray:
		dc.b 1, -1, 1, -1, 2, -2, 2, -2, 3, -3, 3, -3, 4, -4, 4, -4, 5, -5, 5, -5
ScreenShakeArray2:
		dc.b 1, 2, 1, 3, 1, 2, 2, 1, 2, 3, 1, 2, 1, 2, 0, 0
		dc.b 2, 0, 3, 2, 2, 3, 2, 2, 1, 3, 0, 0, 1, 0, 1, 3
		dc.b 1, 2, 1, 3, 1, 2, 2, 1, 2, 3, 1, 2, 1, 2, 0, 0
		dc.b 2, 0, 3, 2, 2, 3, 2, 2, 1, 3, 0, 0, 1, 0, 1, 3