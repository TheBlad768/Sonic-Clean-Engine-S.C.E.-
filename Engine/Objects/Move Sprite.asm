; ---------------------------------------------------------------------------
; Move sprite subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

MoveSprite:
		movem.w	x_vel(a0),d0/d2							; load xy speed
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a0)							; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,y_pos(a0)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		addi.w	#$38,y_vel(a0)							; increase vertical speed (apply gravity)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_TestGravity:
		tst.b	(Reverse_gravity_flag).w					; are we in reverse gravity mode?
		beq.s	MoveSprite							; if not, branch

MoveSprite_ReverseGravity:
		movem.w	x_vel(a0),d0/d2							; load xy speed
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		neg.l	d2								; reverse it
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a0)							; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,y_pos(a0)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		addi.w	#$38,y_vel(a0)							; increase vertical speed (apply gravity)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite2:
		movem.w	x_vel(a0),d0/d2							; load xy speed
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a0)							; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,y_pos(a0)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite2_TestGravity:
		tst.b	(Reverse_gravity_flag).w					; are we in reverse gravity mode?
		beq.s	MoveSprite2							; if not, branch

MoveSprite2_ReverseGravity:
		movem.w	x_vel(a0),d0/d2							; load xy speed
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		neg.l	d2								; reverse it
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a0)							; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,y_pos(a0)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_LightGravity:
		moveq	#$20,d1								; set vertical speed

MoveSprite_CustomGravity:
		movem.w	x_vel(a0),d0/d2							; load xy speed
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a0)							; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,y_pos(a0)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		add.w	d1,y_vel(a0)							; increase vertical speed (apply gravity)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_NormGravity_Parent:
		moveq	#$38,d1								; set vertical speed

MoveSprite_CustomGravity_Parent:
		movem.w	x_vel(a1),d0/d2							; load xy speed
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a1)							; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,y_pos(a1)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		add.w	d1,y_vel(a1)							; increase vertical speed (apply gravity)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite2_Parent:
		movem.w	x_vel(a1),d0/d2							; load xy speed
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a1)							; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,y_pos(a1)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_Reserve:
		movem.w	x_vel(a0),d0/d2							; load xy speed
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,objoff_32(a0)						; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,objoff_36(a0)						; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		addi.w	#$38,y_vel(a0)							; increase vertical speed (apply gravity)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite2_Reserve:
		movem.w	x_vel(a0),d0/d2							; load xy speed
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,objoff_32(a0)						; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,objoff_36(a0)						; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_Absolute_Reserve:
		movem.l	objoff_32(a0),d0/d2						; load xy speed
		add.l	d0,x_pos(a0)							; add to x-axis position
		add.l	d2,y_pos(a0)							; add to y-axis position
		addi.l	#$380000,objoff_36(a0)						; increase vertical speed (apply gravity)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite2_Absolute_Reserve:
		movem.l	objoff_32(a0),d0/d2						; load xy speed
		add.l	d0,x_pos(a0)							; add to x-axis position
		add.l	d2,y_pos(a0)							; add to y-axis position
		rts

; ---------------------------------------------------------------------------
; Stop moving object
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Stop_Object:
		clr.l	x_vel(a1)							; clear velocity
		clr.w	ground_vel(a1)							; clear ground velocity
		rts
