
; =============== S U B R O U T I N E =======================================

ObjectFall:
MoveSprite:
		move.w	x_vel(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,x_pos(a0)
		move.w	y_vel(a0),d0
		addi.w	#$38,y_vel(a0)		; increase vertical speed
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,y_pos(a0)
		rts
; End of function ObjectFall

; =============== S U B R O U T I N E =======================================

SpeedToPos:
MoveSprite2:
		move.w	x_vel(a0),d0		; load horizontal speed
		ext.l	d0
		asl.l	#8,d0				; multiply speed by $100
		add.l	d0,x_pos(a0)		; update x-axis position
		move.w	y_vel(a0),d0		; load vertical	speed
		ext.l	d0
		asl.l	#8,d0				; multiply by $100
		add.l	d0,y_pos(a0)		; update y-axis position
		rts
; End of function SpeedToPos

; =============== S U B R O U T I N E =======================================

MoveSprite_TestGravity:
		tst.b	(Reverse_gravity_flag).w
		beq.s	MoveSprite

MoveSprite_ReverseGravity:
		move.w	x_vel(a0),d0		; load x speed
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a0)		; add x speed to x position	; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		move.w	y_vel(a0),d0		; load y speed
		addi.w	#$38,y_vel(a0)	; increase vertical speed (apply gravity)
		neg.w	d0				; reverse it
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,y_pos(a0)		; add old y speed to y position	; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_TestGravity2:
		tst.b	(Reverse_gravity_flag).w
		beq.s	MoveSprite2

;MoveSprite_ReverseGravity2:
		move.w	x_vel(a0),d0		; load horizontal speed
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a0)		; add to x-axis position	; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		move.w	y_vel(a0),d0		; load vertical speed
		neg.w	d0				; reverse it
		ext.l	d0
		asl.l	#8,d0				; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,y_pos(a0)		; add to y-axis position	; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)
		rts
; End of function MoveSprite_TestGravity2

; =============== S U B R O U T I N E =======================================

MoveSprite_LightGravity:
		moveq	#$20,d1

MoveSprite_CustomGravity:
		move.w	x_vel(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,x_pos(a0)
		move.w	y_vel(a0),d0
		add.w	d1,y_vel(a0)
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,y_pos(a0)
		rts
; End of function MoveSprite_LightGravity

; =============== S U B R O U T I N E =======================================

MoveSprite_NormGravity:
		moveq	#$38,d1
		move.w	x_vel(a1),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,x_pos(a1)
		move.w	y_vel(a1),d0
		add.w	d1,y_vel(a1)
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,y_pos(a1)
		rts
; End of function MoveSprite_NormGravity
