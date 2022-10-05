; ---------------------------------------------------------------------------
; Change flip
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipX:
		bclr	#0,render_flags(a0)
		tst.w	d0
		beq.s	.left
		bset	#0,render_flags(a0)

.left
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipX2:
		bclr	#0,render_flags(a0)
		tst.w	d0
		bne.s	.right
		bset	#0,render_flags(a0)

.right
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipY:
		bclr	#1,render_flags(a0)
		tst.w	d1
		beq.s	.up
		bset	#1,render_flags(a0)

.up
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipY2:
		bclr	#1,render_flags(a0)
		tst.w	d1
		bne.s	.down
		bset	#1,render_flags(a0)

.down
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipXWithVelocity:
		bclr	#0,render_flags(a0)
		tst.w	x_vel(a0)
		bmi.s	.left
		bset	#0,render_flags(a0)

.left
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipXWithVelocity2:
		bclr	#0,render_flags(a0)
		tst.w	x_vel(a0)
		bpl.s	.right
		bset	#0,render_flags(a0)

.right
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipXUseParent:
		movea.w	parent3(a0),a1
		bclr	#0,render_flags(a0)
		btst	#0,render_flags(a1)
		beq.s	.notflipx
		bset	#0,render_flags(a0)

.notflipx
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipYUseParent:
		movea.w	parent3(a0),a1
		bclr	#1,render_flags(a0)
		btst	#1,render_flags(a1)
		beq.s	.notflipy
		bset	#1,render_flags(a0)

.notflipy
		rts

; =============== S U B R O U T I N E =======================================

Change_VelocityWithFlipX:
		btst	#0,render_flags(a0)
		beq.s	.notflipx
		neg.w	d0

.notflipx
		move.w	d0,x_vel(a0)
		rts

; =============== S U B R O U T I N E =======================================

Change_VelocityWithFlipXUseParent:
		movea.w	parent3(a0),a1
		btst	#0,render_flags(a1)
		beq.s	.notflipx
		neg.w	d0

.notflipx
		move.w	d0,x_vel(a0)
		rts
